import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../controllers/students_controller.dart';

class CreateStudentModal extends GetView<StudentsController> {
  const CreateStudentModal({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final firstNameController = TextEditingController();
    final lastNameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    return Obx(() {
      if (!controller.showCreateStudentModal.value) return const SizedBox.shrink();

      return Dialog(
        backgroundColor: isDarkMode ? AppColors.primaryDark : AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Create Student Account',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? AppColors.white : AppColors.black,
                        ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      controller.showCreateStudentModal.value = false;
                      firstNameController.clear();
                      lastNameController.clear();
                      emailController.clear();
                      passwordController.clear();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),
              TextField(
                controller: firstNameController,
                decoration: InputDecoration(
                  labelText: 'First Name *',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: isDarkMode ? AppColors.primaryLight.withOpacity(0.1) : AppColors.background,
                ),
                onChanged: (value) {
                  controller.newStudent['firstName'] = value;
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: lastNameController,
                decoration: InputDecoration(
                  labelText: 'Last Name *',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: isDarkMode ? AppColors.primaryLight.withOpacity(0.1) : AppColors.background,
                ),
                onChanged: (value) {
                  controller.newStudent['lastName'] = value;
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email *',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: isDarkMode ? AppColors.primaryLight.withOpacity(0.1) : AppColors.background,
                ),
                onChanged: (value) {
                  controller.newStudent['email'] = value;
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password *',
                  hintText: 'Min 8 chars with digit, lowercase, uppercase, special char',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: isDarkMode ? AppColors.primaryLight.withOpacity(0.1) : AppColors.background,
                  helperText: 'Must contain: digit, lowercase, uppercase, special char (@#\$%^&+=)',
                  helperMaxLines: 2,
                ),
                onChanged: (value) {
                  controller.newStudent['password'] = value;
                },
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        controller.showCreateStudentModal.value = false;
                        firstNameController.clear();
                        lastNameController.clear();
                        emailController.clear();
                        passwordController.clear();
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: BorderSide(
                          color: isDarkMode ? AppColors.border : AppColors.grey,
                        ),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        controller.createStudent();
                        firstNameController.clear();
                        lastNameController.clear();
                        emailController.clear();
                        passwordController.clear();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: AppColors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Create Student'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }
}

