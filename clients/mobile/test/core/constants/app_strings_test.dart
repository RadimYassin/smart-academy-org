// Unit tests for AppStrings

import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/constants/app_strings.dart';

void main() {
  group('AppStrings', () {
    group('Common strings', () {
      test('has correct app name and slogan', () {
        expect(AppStrings.appName, equals('Overskill'));
        expect(AppStrings.appSlogan, equals('Unlock your potential with us!'));
      });

      test('has correct action strings', () {
        expect(AppStrings.ok, equals('OK'));
        expect(AppStrings.cancel, equals('Cancel'));
        expect(AppStrings.retry, equals('Retry'));
      });

      test('has correct status strings', () {
        expect(AppStrings.loading, equals('Loading...'));
        expect(AppStrings.error, equals('Error'));
        expect(AppStrings.success, equals('Success'));
      });
    });

    group('Error message strings', () {
      test('has correct error messages', () {
        expect(AppStrings.somethingWentWrong, equals('Something went wrong'));
        expect(AppStrings.noInternetConnection, equals('No internet connection'));
        expect(AppStrings.connectionTimeout, equals('Connection timeout'));
      });
    });

    group('Authentication strings', () {
      test('has correct auth action strings', () {
        expect(AppStrings.login, equals('Login'));
        expect(AppStrings.logout, equals('Logout'));
        expect(AppStrings.signIn, equals('Sign In'));
        expect(AppStrings.signUp, equals('Sign Up'));
      });

      test('has correct auth field labels', () {
        expect(AppStrings.email, equals('Email'));
        expect(AppStrings.phoneNumber, equals('Phone Number'));
        expect(AppStrings.password, equals('Password'));
      });

      test('has correct auth messages', () {
        expect(AppStrings.forgotPassword, equals('Forgot Password?'));
        expect(AppStrings.alreadyHaveAccount, equals('Already have an account?'));
        expect(AppStrings.dontHaveAccount, equals('Don\'t have an account?'));
      });
    });

    group('Navigation strings', () {
      test('has correct navigation labels', () {
        expect(AppStrings.home, equals('Home'));
        expect(AppStrings.explore, equals('Explore'));
        expect(AppStrings.wishlist, equals('Wishlist'));
        expect(AppStrings.profile, equals('Profile'));
        expect(AppStrings.settings, equals('Settings'));
        expect(AppStrings.dashboard, equals('Dashboard'));
      });
    });

    group('Email verification strings', () {
      test('has correct verification strings', () {
        expect(AppStrings.authenticationCode, equals('Authentication Code'));
        expect(AppStrings.verifyAccount, equals('Verify Account'));
        expect(AppStrings.resendCode, equals('Resend Code'));
        expect(AppStrings.useDifferentEmail, equals('Use different email'));
      });
    });

    group('Course related strings', () {
      test('has correct course action strings', () {
        expect(AppStrings.buy, equals('Buy'));
        expect(AppStrings.seeMore, equals('See more'));
        expect(AppStrings.viewAll, equals('View All'));
      });

      test('has correct course section headers', () {
        expect(AppStrings.continueLearning, equals('Continue Learning'));
        expect(AppStrings.recentlyAdded, equals('Recently added'));
        expect(AppStrings.popularCourses, equals('Popular courses'));
        expect(AppStrings.suggestionForYou, equals('Suggestion for you'));
      });

      test('has correct level strings', () {
        expect(AppStrings.beginner, equals('Beginner'));
        expect(AppStrings.intermediate, equals('Intermediate'));
        expect(AppStrings.expert, equals('Expert'));
        expect(AppStrings.professionals, equals('Professionals'));
      });
    });

    group('Profile screen strings', () {
      test('has correct profile section strings', () {
        expect(AppStrings.courseCompleted, equals('Course Completed'));
        expect(AppStrings.daysStreak, equals('Days Streak'));
        expect(AppStrings.recent, equals('Recent'));
        expect(AppStrings.goals, equals('Goals'));
        expect(AppStrings.activity, equals('Activity'));
      });

      test('has correct settings strings', () {
        expect(AppStrings.personalDetails, equals('Personal Details'));
        expect(AppStrings.darkMode, equals('Dark Mode'));
        expect(AppStrings.language, equals('Language'));
        expect(AppStrings.privacy, equals('Privacy'));
        expect(AppStrings.helpCenter, equals('Help Center'));
      });
    });

    group('AI Chat strings', () {
      test('has correct AI chat strings', () {
        expect(AppStrings.aiAssistant, equals('AI Assistant'));
        expect(AppStrings.howCanIHelpYou, equals('How can I help you today?'));
        expect(AppStrings.typeMessage, equals('Type your message...'));
        expect(AppStrings.aiThinking, equals('AI is thinking...'));
      });
    });

    group('Search and filter strings', () {
      test('has correct search related strings', () {
        expect(AppStrings.search, equals('Search'));
        expect(AppStrings.searchForAnything, equals('Search for anything'));
        expect(AppStrings.filter, equals('Filter'));
        expect(AppStrings.sortBy, equals('Sort by'));
        expect(AppStrings.applyFilter, equals('Apply Filter'));
      });
    });

    group('Notification strings', () {
      test('has correct notification category strings', () {
        expect(AppStrings.notifications, equals('Notifications'));
        expect(AppStrings.promotions, equals('Promotions'));
        expect(AppStrings.system, equals('System'));
        expect(AppStrings.orders, equals('Orders'));
        expect(AppStrings.others, equals('Others'));
      });
    });

    group('Welcome & Onboarding strings', () {
      test('has correct welcome strings', () {
        expect(AppStrings.welcomeToOverskill, equals('Welcome to Overskill'));
        expect(AppStrings.getStarted, equals('Get started'));
      });

      test('has correct welcome back strings', () {
        expect(AppStrings.welcomeBack, equals('Hi! Welcome Back'));
        expect(AppStrings.welcomeBackSubtitle, isNotEmpty);
      });
    });
  });
}
