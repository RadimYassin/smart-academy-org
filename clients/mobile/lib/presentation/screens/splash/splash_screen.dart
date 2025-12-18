import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/logger.dart';
import '../../routes/app_routes.dart';
import '../../widgets/hourglass_icon.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _setupStatusBar();
    _navigateToHome();
  }

  void _setupStatusBar() {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    );
  }

  _navigateToHome() async {
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;

    try {
      final storage = GetStorage();
      final isLoggedIn = storage.read<bool>(AppConstants.isLoggedInKey) ?? false;
      final userRole = storage.read<String>(AppConstants.userRoleKey) ?? '';

      Logger.logInfo('Splash: isLoggedIn=$isLoggedIn, role=$userRole');

      if (isLoggedIn && userRole.isNotEmpty) {
        // User is logged in, navigate based on role
        if (userRole.toUpperCase() == 'TEACHER') {
          Logger.logInfo('Splash: Navigating to teacher dashboard');
          Get.offAllNamed(AppRoutes.teacherDashboard);
        } else if (userRole.toUpperCase() == 'STUDENT') {
          Logger.logInfo('Splash: Navigating to student home');
          Get.offAllNamed(AppRoutes.studentHome);
        } else {
          // Unknown role, go to onboarding
          Logger.logWarning('Splash: Unknown role, going to onboarding');
          Get.offNamed('/onboarding');
        }
      } else {
        // User not logged in, go to onboarding
        Logger.logInfo('Splash: User not logged in, going to onboarding');
        Get.offNamed('/onboarding');
      }
    } catch (e) {
      Logger.logError('Splash navigation error', error: e);
      // On error, default to onboarding
      Get.offNamed('/onboarding');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          color: AppColors.primary,
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Hourglass Icon
                const HourglassIcon(
                  size: 120,
                  color: Colors.white,
                  backgroundColor: Colors.transparent,
                ),
                const SizedBox(height: 32),
                // App Name
                const Text(
                  AppStrings.appName,
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 12),
                // Slogan
                const Text(
                  AppStrings.appSlogan,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

