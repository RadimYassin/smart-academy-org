import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';
import '../../../domain/repositories/course_repository.dart';
import '../../../data/models/course/quiz_attempt.dart';
import '../../../data/models/course/question.dart';
import '../../widgets/loading_indicator.dart';

class StudentQuizDetailScreen extends StatefulWidget {
  final String attemptId;

  const StudentQuizDetailScreen({
    super.key,
    required this.attemptId,
  });

  @override
  State<StudentQuizDetailScreen> createState() => _StudentQuizDetailScreenState();
}

class _StudentQuizDetailScreenState extends State<StudentQuizDetailScreen> {
  QuizAttempt? attempt;
  List<Question> questions = [];
  Map<String, String> selectedAnswers = {}; // questionId -> selectedOptionId
  int currentQuestionIndex = 0; // Track current question
  bool isLoading = true;
  bool isSubmitting = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadAttemptDetails();
  }

  Future<void> _loadAttemptDetails() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final courseRepository = Get.find<CourseRepository>();
      final loadedAttempt = await courseRepository.getAttemptDetails(widget.attemptId);

      setState(() {
        attempt = loadedAttempt;
      });

      // If attempt is not submitted, load questions
      if (loadedAttempt.submittedAt == null) {
        final loadedQuestions = await courseRepository.getQuestionsByQuiz(loadedAttempt.quizId);
        setState(() {
          questions = loadedQuestions;
        });
      }

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString().replaceAll('Exception: ', '');
        isLoading = false;
      });
    }
  }

  void _goToNextQuestion() {
    if (currentQuestionIndex < questions.length - 1) {
      setState(() {
        currentQuestionIndex++;
      });
    }
  }

  Future<void> _submitQuiz() async {
    if (attempt == null) return;

    // Check if all questions are answered
    if (selectedAnswers.length < questions.length) {
      // Go to first unanswered question
      for (int i = 0; i < questions.length; i++) {
        if (!selectedAnswers.containsKey(questions[i].id)) {
          setState(() {
            currentQuestionIndex = i;
          });
          Get.snackbar(
            'Incomplete Quiz',
            'Please answer all questions before submitting.',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.orange.withOpacity(0.8),
            colorText: Colors.white,
          );
          return;
        }
      }
    }

    try {
      setState(() {
        isSubmitting = true;
      });

      final courseRepository = Get.find<CourseRepository>();
      
      // Create answer submissions
      final answerSubmissions = selectedAnswers.entries.map((entry) {
        return AnswerSubmission(
          questionId: entry.key,
          selectedOptionId: entry.value,
        );
      }).toList();

      final submitRequest = SubmitQuizAttemptRequest(answers: answerSubmissions);
      
      // Submit quiz
      final submittedAttempt = await courseRepository.submitQuizAttempt(
        widget.attemptId,
        submitRequest,
      );

      // Reload attempt details to get results
      final updatedAttempt = await courseRepository.getAttemptDetails(widget.attemptId);

      setState(() {
        attempt = updatedAttempt;
        isSubmitting = false;
      });

      Get.snackbar(
        'Quiz Submitted!',
        'Your score: ${submittedAttempt.score}/${submittedAttempt.maxScore}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green.withOpacity(0.8),
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } catch (e) {
      setState(() {
        isSubmitting = false;
      });

      Get.snackbar(
        'Error',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? AppColors.primary : AppColors.background,
      appBar: AppBar(
        backgroundColor: isDarkMode ? AppColors.primaryDark : AppColors.primary,
        foregroundColor: AppColors.white,
        title: Text(attempt?.submittedAt == null ? 'Take Quiz' : 'Attempt Details'),
      ),
      body: _buildBody(isDarkMode),
    );
  }

  Widget _buildBody(bool isDarkMode) {
    if (isLoading) {
      return const Center(child: LoadingIndicator());
    }

    if (errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                'Error loading attempt details',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? AppColors.white : AppColors.black,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isDarkMode ? AppColors.greyLight : AppColors.grey,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loadAttemptDetails,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (attempt == null) {
      return Center(
        child: Text(
          'Attempt not found',
          style: TextStyle(color: isDarkMode ? AppColors.white : AppColors.black),
        ),
      );
    }

    // If quiz is not submitted, show questions one by one
    if (attempt!.submittedAt == null) {
      if (questions.isEmpty) {
        return Center(
          child: Text(
            'No questions available',
            style: TextStyle(
              color: isDarkMode ? AppColors.greyLight : AppColors.grey,
            ),
          ),
        );
      }

      final currentQuestion = questions[currentQuestionIndex];
      final isFirstQuestion = currentQuestionIndex == 0;
      final isLastQuestion = currentQuestionIndex == questions.length - 1;
      final hasAnswered = selectedAnswers.containsKey(currentQuestion.id);

      return Column(
        children: [
          // Progress Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: isDarkMode ? AppColors.primaryDark : AppColors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Question ${currentQuestionIndex + 1} of ${questions.length}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDarkMode ? AppColors.white : AppColors.black,
                      ),
                    ),
                    Text(
                      attempt!.quizTitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDarkMode ? AppColors.greyLight : AppColors.grey,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: (currentQuestionIndex + 1) / questions.length,
                    minHeight: 6,
                    backgroundColor: isDarkMode
                        ? AppColors.primaryLight.withOpacity(0.2)
                        : AppColors.grey.withOpacity(0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                  ),
                ),
              ],
            ),
          ),

          // Question Card
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: _buildQuestionCard(currentQuestion, currentQuestionIndex + 1, isDarkMode)
                  .animate()
                  .fadeIn(duration: 300.ms)
                  .slideX(begin: 0.1, end: 0, duration: 300.ms),
            ),
          ),

          // Navigation Buttons
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDarkMode ? AppColors.primaryDark : AppColors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  // Previous Button
                  if (!isFirstQuestion)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          setState(() {
                            currentQuestionIndex--;
                          });
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: isDarkMode ? AppColors.white : AppColors.black,
                          side: BorderSide(
                            color: isDarkMode
                                ? AppColors.border.withOpacity(0.2)
                                : AppColors.border,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.arrow_back, size: 20),
                            SizedBox(width: 8),
                            Text('Previous'),
                          ],
                        ),
                      ),
                    ),
                  if (!isFirstQuestion) const SizedBox(width: 12),
                  
                  // Next/Submit Button
                  Expanded(
                    flex: isFirstQuestion ? 1 : 1,
                    child: ElevatedButton(
                      onPressed: isSubmitting
                          ? null
                          : (isLastQuestion ? _submitQuiz : _goToNextQuestion),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.onboardingContinue,
                        foregroundColor: AppColors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: isSubmitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  isLastQuestion ? 'Submit Quiz' : 'Next',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (!isLastQuestion) ...[
                                  const SizedBox(width: 8),
                                  const Icon(Icons.arrow_forward, size: 20),
                                ],
                              ],
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    // If quiz is submitted, show results
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildScoreCard(attempt!, isDarkMode),
          const SizedBox(height: 24),
          if (attempt!.answers != null && attempt!.answers!.isNotEmpty) ...[
            Text(
              'Answer Review',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? AppColors.white : AppColors.black,
              ),
            ),
            const SizedBox(height: 16),
            ...attempt!.answers!.asMap().entries.map((entry) {
              final index = entry.key;
              final answer = entry.value;
              return _buildAnswerCard(answer, index + 1, isDarkMode)
                  .animate()
                  .fadeIn(delay: (index * 50).ms)
                  .slideX(begin: 0.1, end: 0);
            }),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDarkMode ? AppColors.primaryDark : AppColors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDarkMode
                      ? AppColors.border.withValues(alpha: 0.2)
                      : AppColors.border,
                ),
              ),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 48,
                      color: isDarkMode ? AppColors.greyLight : AppColors.grey,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Answer details not available',
                      style: TextStyle(
                        fontSize: 16,
                        color: isDarkMode ? AppColors.greyLight : AppColors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildScoreCard(QuizAttempt attempt, bool isDarkMode) {
    final percentage = attempt.percentage.round();
    final color = attempt.passed
        ? Colors.green
        : (percentage >= 50 ? Colors.orange : Colors.red);

    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha: 0.2),
            color.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: color.withValues(alpha: 0.5),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color, color.shade700],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Icon(
              attempt.passed ? Icons.check_circle : Icons.close,
              color: AppColors.white,
              size: 50,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            attempt.quizTitle,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? AppColors.white : AppColors.black,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              '$percentage%',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildStatChip(
                'Score',
                '${attempt.score}/${attempt.maxScore}',
                Icons.star,
                color,
                isDarkMode,
              ),
              const SizedBox(width: 16),
              _buildStatChip(
                'Status',
                attempt.passed ? 'Passed' : 'Failed',
                attempt.passed ? Icons.check : Icons.close,
                color,
                isDarkMode,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _formatDate(attempt.submittedAt ?? attempt.startedAt),
            style: TextStyle(
              fontSize: 14,
              color: isDarkMode ? AppColors.greyLight : AppColors.grey,
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: 100.ms)
        .scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1));
  }

  Widget _buildStatChip(
    String label,
    String value,
    IconData icon,
    Color color,
    bool isDarkMode,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? AppColors.white : AppColors.black,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: isDarkMode ? AppColors.greyLight : AppColors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAnswerCard(AnswerDetail answer, int questionNumber, bool isDarkMode) {
    final color = answer.isCorrect ? Colors.green : Colors.red;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.primaryDark : AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.5),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  answer.isCorrect ? Icons.check : Icons.close,
                  color: AppColors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Question $questionNumber',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? AppColors.white : AppColors.black,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            answer.questionContent,
            style: TextStyle(
              fontSize: 15,
              color: isDarkMode ? AppColors.white : AppColors.black,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: answer.isCorrect
                  ? Colors.green.withValues(alpha: 0.1)
                  : Colors.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  answer.isCorrect ? Icons.check_circle : Icons.cancel,
                  color: color,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    answer.isCorrect
                        ? 'Your answer was correct'
                        : 'Your answer was incorrect',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(Question question, int questionNumber, bool isDarkMode) {
    final selectedOptionId = selectedAnswers[question.id];

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.primaryDark : AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDarkMode
              ? AppColors.border.withValues(alpha: 0.2)
              : AppColors.border,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    '$questionNumber',
                    style: const TextStyle(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  question.questionText,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? AppColors.white : AppColors.black,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (question.options != null && question.options!.isNotEmpty) ...[
            ...question.options!.map((option) {
              final isSelected = selectedOptionId == option.id;
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        selectedAnswers[question.id] = option.id;
                      });
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.orange.withOpacity(0.1)
                            : (isDarkMode
                                ? AppColors.primaryLight.withOpacity(0.1)
                                : AppColors.grey.withOpacity(0.05)),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? Colors.orange
                              : (isDarkMode
                                  ? AppColors.border.withValues(alpha: 0.2)
                                  : AppColors.border),
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected
                                    ? Colors.orange
                                    : (isDarkMode
                                        ? AppColors.greyLight
                                        : AppColors.grey),
                                width: 2,
                              ),
                              color: isSelected
                                  ? Colors.orange
                                  : Colors.transparent,
                            ),
                            child: isSelected
                                ? const Icon(
                                    Icons.check,
                                    size: 16,
                                    color: AppColors.white,
                                  )
                                : null,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              option.optionText,
                              style: TextStyle(
                                fontSize: 16,
                                color: isDarkMode ? AppColors.white : AppColors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDarkMode
                    ? AppColors.primaryLight.withOpacity(0.1)
                    : AppColors.grey.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'No options available',
                style: TextStyle(
                  fontSize: 14,
                  color: isDarkMode ? AppColors.greyLight : AppColors.grey,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}

