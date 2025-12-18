import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/presentation/controllers/onboarding_controller.dart';
import '../../routes/app_routes.dart';
import '../../widgets/onboarding_illustration.dart';
import '../../widgets/certificate_illustration.dart';
import 'onboarding_content.dart';
import 'onboarding_screen.dart';

class OnboardingPageView extends StatelessWidget {
  const OnboardingPageView({super.key});

  OnboardingContent _getPageContent(int index, bool isDarkMode) {
    switch (index) {
      case 0:
        return OnboardingContent(
          illustration: OnboardingIllustration(isDarkMode: isDarkMode),
          title: 'Various Class Choices In One App',
          description:
              'Learn from the best in the field. Our instructors are industry leaders and subject matter experts committed to your success.',
        );
      case 1:
        return OnboardingContent(
          illustration: CertificateIllustration(isDarkMode: isDarkMode),
          title: 'Expand Your Career Opportunity',
          description:
              'Explore the best courses online with thousands of classes in design, business, marketing, and many more.',
        );
      case 2:
        return OnboardingContent(
          illustration: OnboardingIllustration(isDarkMode: isDarkMode),
          title: 'Get Started Today',
          description:
              'Join thousands of learners and start your journey to success. Your future starts now!',
        );
      default:
        return OnboardingContent(
          illustration: OnboardingIllustration(isDarkMode: isDarkMode),
          title: 'Welcome',
          description: 'Welcome to the app.',
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Initialize controller
    final onboardingController = Get.put(OnboardingController());

    return PageView.builder(
      controller: onboardingController.pageController,
      onPageChanged: onboardingController.onPageChanged,
      itemCount: 3,
      physics: const BouncingScrollPhysics(),
      itemBuilder: (context, index) {
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;
        final pageContent = _getPageContent(index, isDarkMode);

        return OnboardingScreen(
          key: ValueKey(index),
          currentIndex: index,
          onPageChanged: (newIndex) {
            if (newIndex < 3) {
              onboardingController.pageController.animateToPage(
                newIndex,
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOutCubic,
              );
            } else {
              // Navigate to next screen when done
              Get.offAllNamed(AppRoutes.welcome);
            }
          },
          content: pageContent,
        );
      },
    );
  }
}
