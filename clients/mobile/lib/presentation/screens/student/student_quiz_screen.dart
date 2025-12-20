import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/jwt_utils.dart';
import '../../../core/utils/logger.dart';
import '../../../domain/repositories/course_repository.dart';
import '../../../domain/repositories/user_repository.dart';
import '../../../data/models/course/quiz_attempt.dart';
import '../../widgets/loading_indicator.dart';
import '../../controllers/profile_controller.dart';
import 'student_quiz_detail_screen.dart';
import 'student_quiz_history_screen.dart';

class StudentQuizScreen extends StatefulWidget {
  final String quizId;
  final String quizTitle;
  final String? quizDescription;

  const StudentQuizScreen({
    super.key,
    required this.quizId,
    required this.quizTitle,
    this.quizDescription,
  });

  @override
  State<StudentQuizScreen> createState() => _StudentQuizScreenState();
}

class _StudentQuizScreenState extends State<StudentQuizScreen> {
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

      final loadedAttempts = await courseRepository.getStudentQuizAttempts(
        studentId,
        widget.quizId,
      );
      
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

  Future<void> _startQuiz() async {
    try {
      final courseRepository = Get.find<CourseRepository>();
      final userRepository = Get.find<UserRepository>();

      // Count completed attempts (only submitted attempts)
      final completedAttempts = attempts.where((a) => a.submittedAt != null).length;
      const freeAttempts = 3;
      const requiredCredits = 5.0;

      Logger.logInfo('📊 Quiz Attempt Summary:');
      Logger.logInfo('   - Completed attempts: $completedAttempts');
      Logger.logInfo('   - Free attempts: $freeAttempts');

      // Check if payment is required (4th attempt or more)
      final requiresPayment = completedAttempts >= freeAttempts;

      if (requiresPayment) {
        Logger.logInfo('💳 Payment required: Student has $completedAttempts completed attempts (>= $freeAttempts)');

        // Get current credit balance
        final creditBalance = await userRepository.getCreditBalance();
        final currentBalance = creditBalance.balance;

        Logger.logInfo('💰 Current balance: ${currentBalance.toStringAsFixed(2)} credits');
        Logger.logInfo('💰 Required credits: $requiredCredits');

        if (currentBalance < requiredCredits) {
          Get.snackbar(
            'Insufficient Credits',
            'You need $requiredCredits credits to take this quiz again.\n'
            'Your current balance: ${currentBalance.toStringAsFixed(2)} credits.\n\n'
            'Please complete more lessons to earn credits!',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.orange.withOpacity(0.8),
            colorText: Colors.white,
            duration: const Duration(seconds: 4),
          );
          return;
        }

        // Show confirmation dialog
        final confirmed = await Get.dialog<bool>(
          AlertDialog(
            title: const Text('Additional Attempt'),
            content: Text(
              'You have already completed $completedAttempts attempts for this quiz.\n\n'
              'An additional attempt costs $requiredCredits credits.\n\n'
              'Current balance: ${currentBalance.toStringAsFixed(2)} credits\n'
              'After payment: ${(currentBalance - requiredCredits).toStringAsFixed(2)} credits\n\n'
              'Do you want to proceed?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.onboardingContinue,
                  foregroundColor: AppColors.white,
                ),
                child: const Text('Pay & Start'),
              ),
            ],
          ),
        );

        if (confirmed != true) {
          return;
        }

        // Deduct credits BEFORE starting the quiz
        try {
          Logger.logInfo('💰 Deducting $requiredCredits credits before starting quiz...');
          final newBalance = await userRepository.deductCredits(requiredCredits);

          Logger.logInfo('✅ Successfully deducted $requiredCredits credits.');
          Logger.logInfo('✅ New balance: ${newBalance.balance.toStringAsFixed(2)}');

          // Show success message
          Get.snackbar(
            'Payment Successful',
            '${requiredCredits.toStringAsFixed(0)} credits deducted. New balance: ${newBalance.balance.toStringAsFixed(2)}',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.green.withOpacity(0.8),
            colorText: Colors.white,
            duration: const Duration(seconds: 2),
        );

          // Update ProfileController if it exists
          try {
            final profileController = Get.find<ProfileController>();
            profileController.creditBalance.value = newBalance;
            profileController.creditBalanceError.value = '';
            Logger.logInfo('✅ Updated ProfileController with new balance');
          } catch (e) {
            Logger.logWarning('ProfileController not found, skipping credit balance update: $e');
          }
        } catch (e, stackTrace) {
          Logger.logError('❌ Failed to deduct credits', error: e);
          Logger.logError('❌ Stack trace', error: stackTrace);
          Get.snackbar(
            'Payment Failed',
            'Failed to deduct credits: ${e.toString().replaceAll('Exception: ', '')}',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.red.withOpacity(0.8),
            colorText: Colors.white,
            duration: const Duration(seconds: 3),
          );
          return; // Don't start quiz if payment fails
        }

        Logger.logInfo('✅ Payment successful. Proceeding to start quiz...');
      } else {
        Logger.logInfo('✅ No payment required. Completed attempts: $completedAttempts (< $freeAttempts)');
      }

      // Show loading
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      // Start new quiz attempt
      final attempt = await courseRepository.startQuizAttempt(widget.quizId);

      // Close loading dialog
      Get.back();

      // Navigate to quiz detail screen (where questions are shown)
      Get.to(() => StudentQuizDetailScreen(attemptId: attempt.id));
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
          title: const Text('Quiz'),
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
                'Error loading quiz',
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

    final completedAttempts = attempts.where((a) => a.submittedAt != null).length;
    const freeAttempts = 3;
    final remainingFreeAttempts = freeAttempts - completedAttempts;
    final requiresPayment = completedAttempts >= freeAttempts;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Quiz Icon
          Container(
            width: 120,
            height: 120,
            margin: const EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.orange,
                  Colors.orange.shade700,
                ],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.orange.withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
                      ),
                      child: const Icon(
              Icons.quiz,
              size: 64,
                        color: AppColors.white,
                      ),
          )
              .animate()
              .fadeIn(duration: 300.ms)
              .scale(delay: 100.ms, duration: 300.ms),

          // Quiz Title
          Text(
            widget.quizTitle,
            textAlign: TextAlign.center,
                        style: TextStyle(
              fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? AppColors.white : AppColors.black,
            ),
          )
              .animate()
              .fadeIn(delay: 200.ms, duration: 300.ms)
              .slideY(begin: 0.1, end: 0, delay: 200.ms, duration: 300.ms),

          if (widget.quizDescription != null) ...[
            const SizedBox(height: 16),
            Text(
              widget.quizDescription!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: isDarkMode ? AppColors.greyLight : AppColors.grey,
              ),
              )
                  .animate()
                .fadeIn(delay: 300.ms, duration: 300.ms)
                .slideY(begin: 0.1, end: 0, delay: 300.ms, duration: 300.ms),
          ],

          const SizedBox(height: 32),

          // Attempts Count Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDarkMode ? AppColors.primaryDark : AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDarkMode
                    ? AppColors.border.withOpacity(0.2)
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
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.history,
                      color: Colors.orange,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Completed Attempts',
                          style: TextStyle(
                            fontSize: 14,
                            color: isDarkMode ? AppColors.greyLight : AppColors.grey,
                          ),
                        ),
                        const SizedBox(height: 4),
                Text(
                          '$completedAttempts',
                  style: TextStyle(
                            fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? AppColors.white : AppColors.black,
                  ),
                ),
                      ],
                  ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: requiresPayment
                        ? Colors.orange.withOpacity(0.1)
                        : Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: requiresPayment
                          ? Colors.orange.withOpacity(0.3)
                          : Colors.green.withOpacity(0.3),
                  ),
                ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        requiresPayment ? Icons.payment : Icons.check_circle,
                        color: requiresPayment ? Colors.orange : Colors.green,
                        size: 20,
                ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          requiresPayment
                              ? 'Next attempt costs 5 credits'
                              : '$remainingFreeAttempts free attempt${remainingFreeAttempts != 1 ? 's' : ''} remaining',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: requiresPayment ? Colors.orange : Colors.green,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
              .animate()
              .fadeIn(delay: 400.ms, duration: 300.ms)
              .slideY(begin: 0.1, end: 0, delay: 400.ms, duration: 300.ms),

          const SizedBox(height: 24),

          // Start Quiz Button
          ElevatedButton(
            onPressed: _startQuiz,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.onboardingContinue,
              foregroundColor: AppColors.white,
              padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                  ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
        children: [
                const Icon(Icons.play_arrow, size: 28),
              const SizedBox(width: 12),
                const Text(
                  'Start Quiz',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          )
              .animate()
              .fadeIn(delay: 500.ms, duration: 300.ms)
              .slideY(begin: 0.1, end: 0, delay: 500.ms, duration: 300.ms),

          const SizedBox(height: 16),

          // View History Button
          TextButton(
            onPressed: () {
              Get.to(() => StudentQuizHistoryScreen(
                    quizId: widget.quizId,
                    quizTitle: widget.quizTitle,
                  ));
            },
                      child: Text(
              'View History',
                        style: TextStyle(
                fontSize: 16,
                color: isDarkMode ? AppColors.greyLight : AppColors.grey,
                          ),
                        ),
          )
              .animate()
              .fadeIn(delay: 600.ms, duration: 300.ms),
        ],
      ),
    );
  }
}

