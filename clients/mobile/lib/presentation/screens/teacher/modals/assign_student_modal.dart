import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../controllers/enrollment_controller.dart';
import '../../../controllers/students_controller.dart';

class AssignStudentModal extends GetView<EnrollmentController> {
  const AssignStudentModal({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final studentsController = Get.find<StudentsController>();
    final searchController = TextEditingController();

    return Obx(() {
      if (!controller.showAssignStudentModal.value || controller.selectedCourseId.value.isEmpty) {
        return const SizedBox.shrink();
      }

      // Load students if not loaded
      if (studentsController.allStudents.isEmpty && !studentsController.isLoadingStudents.value) {
        studentsController.loadAllStudents();
      }

      final availableStudents = studentsController.allStudents;

      return Dialog(
        backgroundColor: isDarkMode ? AppColors.primaryDark : AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          constraints: const BoxConstraints(maxHeight: 600),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Assign Students',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? AppColors.white : AppColors.black,
                          ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        controller.showAssignStudentModal.value = false;
                        searchController.clear();
                      },
                    ),
                  ],
                ),
              ),

              // Search bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    hintText: 'Search students...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: isDarkMode ? AppColors.primaryLight.withOpacity(0.1) : AppColors.background,
                  ),
                  onChanged: (value) => studentsController.filterStudents(value),
                ),
              ),

              const SizedBox(height: 16),

              // Students list
              Expanded(
                child: studentsController.isLoadingStudents.value
                    ? const Center(child: CircularProgressIndicator())
                    : studentsController.filteredStudents.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.people_outline,
                                  size: 48,
                                  color: isDarkMode ? AppColors.greyLight : AppColors.grey,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'No students found',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: isDarkMode ? AppColors.greyLight : AppColors.grey,
                                      ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            itemCount: studentsController.filteredStudents.length,
                            itemBuilder: (context, index) {
                              final student = studentsController.filteredStudents[index];

                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                decoration: BoxDecoration(
                                  color: isDarkMode
                                      ? AppColors.primaryLight.withOpacity(0.05)
                                      : AppColors.background,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: isDarkMode
                                        ? AppColors.border.withOpacity(0.2)
                                        : AppColors.border,
                                  ),
                                ),
                                child: ListTile(
                                  title: Text(
                                    student.fullName,
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: isDarkMode ? AppColors.white : AppColors.black,
                                        ),
                                  ),
                                  subtitle: Text(
                                    student.email,
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: isDarkMode ? AppColors.greyLight : AppColors.grey,
                                        ),
                                  ),
                                  trailing: ElevatedButton(
                                    onPressed: () {
                                      controller.assignStudent(
                                        controller.selectedCourseId.value,
                                        student.id,
                                      );
                                      controller.showAssignStudentModal.value = false;
                                      searchController.clear();
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.onboardingContinue,
                                      foregroundColor: AppColors.white,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 8,
                                      ),
                                    ),
                                    child: const Text('Assign'),
                                  ),
                                ),
                              );
                            },
                          ),
              ),

              // Actions
              Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          controller.showAssignStudentModal.value = false;
                          searchController.clear();
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: BorderSide(
                            color: isDarkMode ? AppColors.border : AppColors.grey,
                          ),
                        ),
                        child: const Text('Close'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}

