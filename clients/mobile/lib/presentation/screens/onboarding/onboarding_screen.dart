import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';
import '../../widgets/hourglass_icon.dart';
import 'onboarding_content.dart';

class OnboardingScreen extends StatelessWidget {
  final int currentIndex;
  final Function(int) onPageChanged;
  final OnboardingContent content;

  const OnboardingScreen({
    super.key,
    required this.currentIndex,
    required this.onPageChanged,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDarkMode ? AppColors.primary : AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 20),
              // Header with logo and app name
              _buildHeader(isDarkMode),
              const SizedBox(height: 40),
              
              // Illustration
              Expanded(
                child: Center(
                  child: content.illustration,
                ),
              )
                  .animate()
                  .fadeIn(duration: 800.ms, delay: 300.ms)
                  .scale(
                    delay: 300.ms,
                    duration: 800.ms,
                    begin: const Offset(0.5, 0.5),
                    end: const Offset(1.0, 1.0),
                    curve: Curves.easeOutBack,
                  )
                  .moveY(begin: 50, end: 0, duration: 800.ms, delay: 300.ms),
              
              // Content
              const SizedBox(height: 20),
              _buildContent(isDarkMode),
              const SizedBox(height: 40),
              
              // Progress indicator and navigation buttons
              _buildProgressAndButtons(context, isDarkMode),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDarkMode) {
    return Row(
      children: [
        // Logo
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isDarkMode ? AppColors.primaryDark : Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const HourglassIcon(
            size: 24,
            color: Colors.white,
            backgroundColor: Colors.transparent,
          ),
        )
            .animate()
            .fadeIn(duration: 600.ms, delay: 100.ms)
            .scale(delay: 100.ms, duration: 600.ms, begin: const Offset(0.8, 0.8))
            .shake(delay: 400.ms, duration: 400.ms, hz: 3),
        const SizedBox(width: 12),
        // App name
        Text(
          'Overskill',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : AppColors.primary,
          ),
        )
            .animate()
            .fadeIn(duration: 600.ms, delay: 200.ms)
            .slideX(begin: -0.2, end: 0, duration: 600.ms, delay: 200.ms),
      ],
    );
  }

  Widget _buildContent(bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        Text(
          content.title,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : AppColors.black,
            height: 1.2,
          ),
        )
            .animate()
            .fadeIn(duration: 600.ms, delay: 600.ms)
            .slideX(begin: -0.3, end: 0, duration: 600.ms, delay: 600.ms)
            .blur(begin: const Offset(10, 0), end: const Offset(0, 0), duration: 600.ms, delay: 600.ms),
        const SizedBox(height: 16),
        // Description
        Text(
          content.description,
          style: TextStyle(
            fontSize: 16,
            color: isDarkMode ? Colors.white70 : AppColors.grey,
            height: 1.5,
          ),
        )
            .animate()
            .fadeIn(duration: 600.ms, delay: 800.ms)
            .slideX(begin: -0.2, end: 0, duration: 600.ms, delay: 800.ms),
      ],
    );
  }

  Widget _buildProgressAndButtons(BuildContext context, bool isDarkMode) {
    return Column(
      children: [
        // Progress indicator
        _buildProgressIndicator(isDarkMode)
            .animate()
            .fadeIn(duration: 600.ms, delay: 1000.ms)
            .moveY(begin: 20, end: 0, duration: 600.ms, delay: 1000.ms),
        const SizedBox(height: 24),
        // Navigation buttons
        Row(
          children: [
            // Skip button (circular with arrow)
            GestureDetector(
              onTap: () {
                // Skip to end
              },
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: isDarkMode ? AppColors.primaryDark : AppColors.onboardingSkip,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_forward,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            )
                .animate()
                .fadeIn(duration: 600.ms, delay: 1200.ms)
                .scale(
                  delay: 1200.ms,
                  duration: 600.ms,
                  begin: const Offset(0.8, 0.8),
                  end: const Offset(1.0, 1.0),
                  curve: Curves.easeOutBack,
                ),
            const SizedBox(width: 16),
            // Continue button
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  onPageChanged(currentIndex + 1);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.onboardingContinue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Continue',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            )
                .animate()
                .fadeIn(duration: 600.ms, delay: 1300.ms)
                .slideX(begin: 0.5, end: 0, duration: 600.ms, delay: 1300.ms, curve: Curves.easeOutBack),
          ],
        ),
      ],
    );
  }

  Widget _buildProgressIndicator(bool isDarkMode) {
    final totalPages = 3;
    const indicatorWidth = 80.0;
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalPages, (index) {
        final isActive = index == currentIndex;
        final delayMs = index * 100;
        return Container(
          width: indicatorWidth,
          height: 4,
          margin: EdgeInsets.only(right: index < totalPages - 1 ? 4 : 0),
          decoration: BoxDecoration(
            color: isActive
                ? AppColors.progressActive
                : isDarkMode ? AppColors.primaryDark : AppColors.progressInactive,
            borderRadius: BorderRadius.circular(2),
          ),
        )
            .animate()
            .fadeIn(duration: 500.ms, delay: delayMs.ms)
            .slideX(begin: index % 2 == 0 ? -0.5 : 0.5, end: 0, duration: 500.ms, delay: delayMs.ms);
      }),
    );
  }
}
