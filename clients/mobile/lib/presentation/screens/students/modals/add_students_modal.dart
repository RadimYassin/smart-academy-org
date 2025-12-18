import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../controllers/students_controller.dart';

class AddStudentsModal extends GetView<StudentsController> {
  const AddStudentsModal({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final searchController = TextEditingController();

    return Obx(() {
      if (!controller.showAddStudentsModal.value || controller.selectedClass.value == null) {
        return const SizedBox.shrink();
      }

      final selectedClass = controller.selectedClass.value!;
      final existingIds = controller.getClassStudentsList(selectedClass.id)
          .map((s) => s.studentId)
          .toList();

      // Filter students
      final availableStudents = controller.filteredStudents
          .where((s) => !existingIds.contains(s.id))
          .toList();

      final allSelected = availableStudents.isNotEmpty &&
          availableStudents.every((s) => controller.selectedStudentIds.contains(s.id));

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
                      'Add Students to Class',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? AppColors.white : AppColors.black,
                          ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        controller.showAddStudentsModal.value = false;
                        controller.selectedStudentIds.clear();
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
                    hintText: 'Search students by name, email, or ID...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: isDarkMode ? AppColors.primaryLight.withOpacity(0.1) : AppColors.background,
                  ),
                  onChanged: (value) => controller.filterStudents(value),
                ),
              ),

              const SizedBox(height: 16),

              // Select all
              if (availableStudents.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDarkMode ? AppColors.primaryLight.withOpacity(0.1) : AppColors.background,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Checkbox(
                          value: allSelected,
                          onChanged: (_) => controller.selectAllStudents(existingIds),
                        ),
                        Text(
                          'Select All (${availableStudents.length} available)',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w500,
                                color: isDarkMode ? AppColors.white : AppColors.black,
                              ),
                        ),
                        const Spacer(),
                        if (controller.selectedStudentIds.isNotEmpty)
                          Text(
                            '${controller.selectedStudentIds.length} selected',
                            style: TextStyle(
                              color: AppColors.onboardingContinue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 8),

              // Students list
              Expanded(
                child: controller.isLoadingStudents.value
                    ? const Center(child: CircularProgressIndicator())
                    : availableStudents.isEmpty
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
                                  controller.filteredStudents.isEmpty
                                      ? 'No students found'
                                      : 'All students are already in this class',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: isDarkMode ? AppColors.greyLight : AppColors.grey,
                                      ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            itemCount: availableStudents.length,
                            itemBuilder: (context, index) {
                              final student = availableStudents[index];
                              final isSelected = controller.selectedStudentIds.contains(student.id);

                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.onboardingContinue.withOpacity(0.1)
                                      : isDarkMode
                                          ? AppColors.primaryLight.withOpacity(0.05)
                                          : AppColors.background,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.onboardingContinue
                                        : isDarkMode
                                            ? AppColors.border.withOpacity(0.2)
                                            : AppColors.border,
                                  ),
                                ),
                                child: InkWell(
                                  onTap: () => controller.toggleStudentSelection(student.id),
                                  borderRadius: BorderRadius.circular(8),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Row(
                                      children: [
                                        Checkbox(
                                          value: isSelected,
                                          onChanged: (_) => controller.toggleStudentSelection(student.id),
                                        ),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Text(
                                                    student.fullName,
                                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                                          fontWeight: FontWeight.bold,
                                                          color: isDarkMode ? AppColors.white : AppColors.black,
                                                        ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(
                                                      horizontal: 6,
                                                      vertical: 2,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: Colors.blue.withOpacity(0.2),
                                                      borderRadius: BorderRadius.circular(4),
                                                    ),
                                                    child: Text(
                                                      'ID: ${student.id}',
                                                      style: const TextStyle(
                                                        fontSize: 10,
                                                        color: Colors.blue,
                                                        fontWeight: FontWeight.w600,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                student.email,
                                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                      color: isDarkMode ? AppColors.greyLight : AppColors.grey,
                                                    ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
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
                          controller.showAddStudentsModal.value = false;
                          controller.selectedStudentIds.clear();
                          searchController.clear();
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
                        onPressed: controller.selectedStudentIds.isEmpty
                            ? null
                            : () {
                                controller.addStudentsToClass(
                                  selectedClass.id,
                                  controller.selectedStudentIds.toList(),
                                );
                                searchController.clear();
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.onboardingContinue,
                          foregroundColor: AppColors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          disabledBackgroundColor: AppColors.grey.withOpacity(0.3),
                        ),
                        child: Text(
                          controller.selectedStudentIds.isEmpty
                              ? 'Add Students'
                              : 'Add ${controller.selectedStudentIds.length} Student${controller.selectedStudentIds.length != 1 ? 's' : ''}',
                        ),
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

