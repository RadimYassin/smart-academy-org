import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:country_picker/country_picker.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../controllers/auth/signup_controller.dart';

class PhoneNumberScreen extends GetView<SignUpController> {
  const PhoneNumberScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? AppColors.primary : AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDarkMode ? AppColors.white : AppColors.black,
          ),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              // Header
              _buildHeader(context, isDarkMode),
              const SizedBox(height: 40),
              // Phone Input Field
              _buildPhoneInput(context, isDarkMode),
              const Spacer(),
              // Send Code Button
              _buildSendCodeButton(context, isDarkMode),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.whatsYourPhone,
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: isDarkMode ? AppColors.white : AppColors.black,
              ),
        )
            .animate()
            .fadeIn(duration: 500.ms, delay: 100.ms)
            .slideX(begin: -0.1, end: 0, duration: 500.ms, delay: 100.ms),
        const SizedBox(height: 8),
        Text(
          AppStrings.phoneSubtitle,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isDarkMode ? AppColors.greyLight : AppColors.grey,
                height: 1.5,
              ),
        )
            .animate()
            .fadeIn(duration: 500.ms, delay: 300.ms)
            .slideX(begin: -0.1, end: 0, duration: 500.ms, delay: 300.ms),
      ],
    );
  }

  Widget _buildPhoneInput(BuildContext context, bool isDarkMode) {
    return TextField(
      controller: controller.phoneController,
      keyboardType: TextInputType.phone,
      decoration: InputDecoration(
        hintText: 'Enter your phone number',
        prefixIcon: _buildCountryCodeSelector(context, isDarkMode),
      ),
    )
        .animate()
        .fadeIn(duration: 500.ms, delay: 500.ms)
        .slideY(begin: 0.1, end: 0, duration: 500.ms, delay: 500.ms);
  }

  Widget _buildCountryCodeSelector(BuildContext context, bool isDarkMode) {
    return Obx(
      () => InkWell(
        onTap: () {
          _showCountryPicker(context, isDarkMode);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Country flag
              Text(
                controller.selectedCountry.value.flagEmoji,
                style: const TextStyle(fontSize: 24),
              ),
              const SizedBox(width: 8),
              Text(
                controller.selectedCountry.value.phoneCode,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDarkMode ? AppColors.white : AppColors.black,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.arrow_drop_down,
                color: isDarkMode ? AppColors.greyLight : AppColors.grey,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCountryPicker(BuildContext context, bool isDarkMode) {
    showCountryPicker(
      context: context,
      favorite: ['US'],
      showPhoneCode: true,
      onSelect: (Country country) {
        controller.selectCountry(country);
      },
      countryListTheme: CountryListThemeData(
        flagSize: 30,
        backgroundColor: isDarkMode ? AppColors.primary : AppColors.background,
        textStyle: TextStyle(
          color: isDarkMode ? AppColors.white : AppColors.black,
          fontSize: 16,
        ),
        searchTextStyle: TextStyle(
          color: isDarkMode ? AppColors.white : AppColors.black,
          fontSize: 16,
        ),
        inputDecoration: InputDecoration(
          labelText: 'Search',
          hintText: 'Start typing to search',
          prefixIcon: Icon(
            Icons.search,
            color: isDarkMode ? AppColors.greyLight : AppColors.grey,
          ),
          labelStyle: TextStyle(
            color: isDarkMode ? AppColors.greyLight : AppColors.grey,
          ),
          hintStyle: TextStyle(
            color: isDarkMode ? AppColors.greyLight : AppColors.grey,
          ),
        ),
      ),
    );
  }

  Widget _buildSendCodeButton(BuildContext context, bool isDarkMode) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: controller.sendVerificationCode,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.onboardingContinue,
          foregroundColor: AppColors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          elevation: 0,
        ),
        child: Text(
          AppStrings.sendCode,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 500.ms, delay: 700.ms)
        .slideY(begin: 0.1, end: 0, duration: 500.ms, delay: 700.ms)
        .scale(
          delay: 700.ms,
          duration: 500.ms,
          begin: const Offset(0.95, 0.95),
          end: const Offset(1.0, 1.0),
          curve: Curves.easeOutBack,
        );
  }
}

