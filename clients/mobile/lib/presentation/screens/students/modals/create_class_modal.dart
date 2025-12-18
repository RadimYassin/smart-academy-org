import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/models/student/student_class.dart';
import '../../../controllers/students_controller.dart';

class CreateClassModal extends GetView<StudentsController> {
  const CreateClassModal({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();

    return Obx(() {
      if (!controller.showCreateClassModal.value) return const SizedBox.shrink();

      return Dialog(
        backgroundColor: isDarkMode ? AppColors.primaryDark : AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Create New Class',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? AppColors.white : AppColors.black,
                        ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      controller.showCreateClassModal.value = false;
                      nameController.clear();
                      descriptionController.clear();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Class Name *',
                  hintText: 'e.g., Mathematics 101 - Section A',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: isDarkMode ? AppColors.primaryLight.withOpacity(0.1) : AppColors.background,
                ),
                onChanged: (value) {
                  controller.newClass.value = CreateClassRequest(
                    name: value,
                    description: descriptionController.text,
                  );
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description',
                  hintText: 'Optional description',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: isDarkMode ? AppColors.primaryLight.withOpacity(0.1) : AppColors.background,
                ),
                maxLines: 3,
                onChanged: (value) {
                  controller.newClass.value = CreateClassRequest(
                    name: nameController.text,
                    description: value,
                  );
                },
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        controller.showCreateClassModal.value = false;
                        nameController.clear();
                        descriptionController.clear();
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
                        controller.createClass();
                        nameController.clear();
                        descriptionController.clear();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.onboardingContinue,
                        foregroundColor: AppColors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Create Class'),
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

