import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/jwt_utils.dart';
import '../../../domain/repositories/course_repository.dart';
import '../../../data/models/course/quiz_attempt.dart';
import '../../widgets/loading_indicator.dart';
import 'student_quiz_detail_screen.dart';

class StudentQuizHistoryScreen extends StatefulWidget {
  final String? quizId; // If null, show all attempts; if provided, show attempts for this quiz
  final String? quizTitle; // Optional title for header

  const StudentQuizHistoryScreen({
    super.key,
    this.quizId,
    this.quizTitle,
  });

  @override
  State<StudentQuizHistoryScreen> createState() => _StudentQuizHistoryScreenState();
}

class _StudentQuizHistoryScreenState extends State<StudentQuizHistoryScreen> {
  List<QuizAttempt> attempts = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadAttempts();
  }

  Future<void> _loadAttempts() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final courseRepository = Get.find<CourseRepository>();
      final studentId = JwtUtils.getUserIdFromToken();

      if (studentId == null) {
        throw Exception('Unable to get student ID. Please log in again.');
      }

      List<QuizAttempt> loadedAttempts;
      if (widget.quizId != null) {
        // Get attempts for specific quiz
        loadedAttempts = await courseRepository.getStudentQuizAttempts(studentId, widget.quizId!);
      } else {
        // Get all attempts
        loadedAttempts = await courseRepository.getStudentAttempts(studentId);
      }

      // Sort by submitted date (most recent first)
      loadedAttempts.sort((a, b) {
        final aDate = a.submittedAt ?? a.startedAt;
        final bDate = b.submittedAt ?? b.startedAt;
        return bDate.compareTo(aDate);
      });

      setState(() {
        attempts = loadedAttempts;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString().replaceAll('Exception: ', '');
        isLoading = false;
      });
    }
  }

  Future<void> _startNewQuiz() async {
    if (widget.quizId == null) {
      Get.snackbar('Error', 'Quiz ID is required');
      return;
    }

    try {
      final courseRepository = Get.find<CourseRepository>();
      
      // Show loading
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      // Start new quiz attempt
      final attempt = await courseRepository.startQuizAttempt(widget.quizId!);
      
      // Close loading dialog
      Get.back();
      
      // Navigate to attempt details screen
      Get.to(() => StudentQuizDetailScreen(attemptId: attempt.id));
      
      // Refresh attempts list
      _loadAttempts();
    } catch (e) {
      // Close loading dialog if still open
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }
      
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
        title: Text(widget.quizTitle ?? 'Quiz History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAttempts,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _buildBody(isDarkMode),
      floatingActionButton: widget.quizId != null
          ? FloatingActionButton.extended(
              onPressed: _startNewQuiz,
              backgroundColor: AppColors.onboardingContinue,
              icon: const Icon(Icons.play_arrow, color: AppColors.white),
              label: const Text(
                'Start Quiz',
                style: TextStyle(color: AppColors.white),
              ),
            )
          : null,
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
                'Error loading quiz history',
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
                onPressed: _loadAttempts,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (attempts.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.quiz_outlined,
                size: 80,
                color: isDarkMode ? AppColors.greyLight : AppColors.grey,
              ),
              const SizedBox(height: 24),
              Text(
                'No Quiz Attempts Yet',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? AppColors.white : AppColors.black,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.quizId != null
                    ? 'You haven\'t attempted this quiz yet.'
                    : 'You haven\'t attempted any quizzes yet.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: isDarkMode ? AppColors.greyLight : AppColors.grey,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadAttempts,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: attempts.length,
        itemBuilder: (context, index) {
          return _buildAttemptCard(attempts[index], isDarkMode, index);
        },
      ),
    );
  }

  Widget _buildAttemptCard(QuizAttempt attempt, bool isDarkMode, int index) {
    final percentage = attempt.percentage.round();
    final color = attempt.passed
        ? Colors.green
        : (percentage >= 50 ? Colors.orange : Colors.red);
    final date = attempt.submittedAt ?? attempt.startedAt;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // Navigate to attempt details
            Get.to(() => StudentQuizDetailScreen(attemptId: attempt.id));
          },
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  color.withValues(alpha: 0.1),
                  color.withValues(alpha: 0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: color.withValues(alpha: 0.3),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.2),
                  blurRadius: 15,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [color, color.shade700],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: color.withValues(alpha: 0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        attempt.passed ? Icons.check_circle : Icons.close,
                        color: AppColors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.quizTitle ?? attempt.quizTitle,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isDarkMode ? AppColors.white : AppColors.black,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _formatDate(date),
                            style: TextStyle(
                              fontSize: 12,
                              color: isDarkMode ? AppColors.greyLight : AppColors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$percentage%',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatItem(
                        'Score',
                        '${attempt.score}/${attempt.maxScore}',
                        Icons.star,
                        color,
                        isDarkMode,
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: isDarkMode
                          ? AppColors.border.withValues(alpha: 0.2)
                          : AppColors.border,
                    ),
                    Expanded(
                      child: _buildStatItem(
                        'Status',
                        attempt.passed ? 'Passed' : 'Failed',
                        attempt.passed ? Icons.check : Icons.close,
                        color,
                        isDarkMode,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: percentage / 100,
                    minHeight: 8,
                    backgroundColor: isDarkMode
                        ? AppColors.primaryLight.withValues(alpha: 0.2)
                        : AppColors.grey.withValues(alpha: 0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
                if (attempt.submittedAt == null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.access_time, size: 16, color: Colors.orange),
                        const SizedBox(width: 8),
                        Text(
                          'In Progress',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.orange,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(delay: (index * 50).ms)
        .slideY(begin: 0.1, end: 0);
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
    bool isDarkMode,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
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
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'Just now';
        }
        return '${difference.inMinutes} minutes ago';
      }
      return '${difference.inHours} hours ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

