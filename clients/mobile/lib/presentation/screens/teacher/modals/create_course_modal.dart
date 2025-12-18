import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/models/course/course.dart';
import '../../../controllers/courses_controller.dart';

class CreateCourseModal extends GetView<CoursesController> {
  const CreateCourseModal({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final categoryController = TextEditingController();
    final thumbnailController = TextEditingController();
    final selectedLevel = 'BEGINNER'.obs;

    return Obx(() {
      if (!controller.showCreateCourseModal.value) return const SizedBox.shrink();

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
                    'Create New Course',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? AppColors.white : AppColors.black,
                        ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      controller.showCreateCourseModal.value = false;
                      titleController.clear();
                      descriptionController.clear();
                      categoryController.clear();
                      thumbnailController.clear();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: 'Course Title *',
                  hintText: 'e.g., Introduction to Flutter',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: isDarkMode ? AppColors.primaryLight.withOpacity(0.1) : AppColors.background,
                ),
                onChanged: (value) {
                  controller.newCourse.value = CreateCourseRequest(
                    title: value,
                    description: descriptionController.text,
                    category: categoryController.text,
                    level: selectedLevel.value,
                    thumbnailUrl: thumbnailController.text.isEmpty ? null : thumbnailController.text,
                  );
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description *',
                  hintText: 'Course description',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: isDarkMode ? AppColors.primaryLight.withOpacity(0.1) : AppColors.background,
                ),
                maxLines: 3,
                onChanged: (value) {
                  controller.newCourse.value = CreateCourseRequest(
                    title: titleController.text,
                    description: value,
                    category: categoryController.text,
                    level: selectedLevel.value,
                    thumbnailUrl: thumbnailController.text.isEmpty ? null : thumbnailController.text,
                  );
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: categoryController,
                decoration: InputDecoration(
                  labelText: 'Category *',
                  hintText: 'e.g., Programming, Design, Business',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: isDarkMode ? AppColors.primaryLight.withOpacity(0.1) : AppColors.background,
                ),
                onChanged: (value) {
                  controller.newCourse.value = CreateCourseRequest(
                    title: titleController.text,
                    description: descriptionController.text,
                    category: value,
                    level: selectedLevel.value,
                    thumbnailUrl: thumbnailController.text.isEmpty ? null : thumbnailController.text,
                  );
                },
              ),
              const SizedBox(height: 16),
              Obx(() => DropdownButtonFormField<String>(
                value: selectedLevel.value,
                decoration: InputDecoration(
                  labelText: 'Level *',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: isDarkMode ? AppColors.primaryLight.withOpacity(0.1) : AppColors.background,
                ),
                items: ['BEGINNER', 'INTERMEDIATE', 'ADVANCED'].map((level) {
                  return DropdownMenuItem(value: level, child: Text(level));
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    selectedLevel.value = value;
                    controller.newCourse.value = CreateCourseRequest(
                      title: titleController.text,
                      description: descriptionController.text,
                      category: categoryController.text,
                      level: value,
                      thumbnailUrl: thumbnailController.text.isEmpty ? null : thumbnailController.text,
                    );
                  }
                },
              )),
              const SizedBox(height: 16),
              TextField(
                controller: thumbnailController,
                decoration: InputDecoration(
                  labelText: 'Thumbnail URL (Optional)',
                  hintText: 'https://example.com/image.jpg',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: isDarkMode ? AppColors.primaryLight.withOpacity(0.1) : AppColors.background,
                ),
                onChanged: (value) {
                  controller.newCourse.value = CreateCourseRequest(
                    title: titleController.text,
                    description: descriptionController.text,
                    category: categoryController.text,
                    level: selectedLevel.value,
                    thumbnailUrl: value.isEmpty ? null : value,
                  );
                },
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        controller.showCreateCourseModal.value = false;
                        titleController.clear();
                        descriptionController.clear();
                        categoryController.clear();
                        thumbnailController.clear();
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
                        controller.createCourse();
                        titleController.clear();
                        descriptionController.clear();
                        categoryController.clear();
                        thumbnailController.clear();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.onboardingContinue,
                        foregroundColor: AppColors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Create Course'),
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

