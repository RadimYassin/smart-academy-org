import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';
import '../../controllers/students_controller.dart';
import 'modals/create_class_modal.dart';
import 'modals/create_student_modal.dart';
import 'modals/add_students_modal.dart';

class StudentsScreen extends GetView<StudentsController> {
  const StudentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? AppColors.primary : AppColors.background,
      appBar: AppBar(
        title: const Text('Student Classes'),
        backgroundColor: isDarkMode ? AppColors.primaryDark : AppColors.primary,
        foregroundColor: AppColors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: () => controller.showCreateStudentModal.value = true,
            tooltip: 'Create Student',
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => controller.showCreateClassModal.value = true,
            tooltip: 'Create Class',
          ),
        ],
      ),
      body: Stack(
        children: [
          Obx(() {
            if (controller.isLoadingClasses.value) {
              return const Center(child: CircularProgressIndicator());
            }

            return RefreshIndicator(
              onRefresh: () => controller.loadClasses(),
              child: CustomScrollView(
            slivers: [
              // Error message
              if (controller.errorMessage.value.isNotEmpty)
                SliverToBoxAdapter(
                  child: Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            controller.errorMessage.value,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, size: 20),
                          onPressed: () => controller.errorMessage.value = '',
                        ),
                      ],
                    ),
                  ),
                ),

              // Classes list
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      if (index == 0) {
                        // Header
                        return _buildHeader(context, isDarkMode);
                      }
                      final classIndex = index - 1;
                      if (classIndex >= controller.classes.length) {
                        return null;
                      }
                      final studentClass = controller.classes[classIndex];
                      return _buildClassCard(context, studentClass, isDarkMode)
                          .animate()
                          .fadeIn(delay: (index * 50).ms)
                          .slideY(begin: 0.1, end: 0);
                    },
                    childCount: controller.classes.length + 1,
                  ),
                ),
              ),
            ],
          ),
        );
      }),
          // Modals overlay
          Obx(() => controller.showCreateClassModal.value
              ? const CreateClassModal()
              : const SizedBox.shrink()),
          Obx(() => controller.showCreateStudentModal.value
              ? const CreateStudentModal()
              : const SizedBox.shrink()),
          Obx(() => controller.showAddStudentsModal.value
              ? const AddStudentsModal()
              : const SizedBox.shrink()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => controller.showCreateClassModal.value = true,
        backgroundColor: AppColors.onboardingContinue,
        child: const Icon(Icons.add, color: AppColors.white),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.primaryDark : AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Student Classes Management',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? AppColors.white : AppColors.black,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create classes and manage student accounts',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isDarkMode ? AppColors.greyLight : AppColors.grey,
                ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => controller.showCreateStudentModal.value = true,
                  icon: const Icon(Icons.person_add),
                  label: const Text('Create Student'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => controller.showCreateClassModal.value = true,
                  icon: const Icon(Icons.add),
                  label: const Text('Create Class'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.onboardingContinue,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: 100.ms)
        .slideY(begin: -0.1, end: 0);
  }

  Widget _buildClassCard(BuildContext context, studentClass, bool isDarkMode) {
    final isExpanded = controller.expandedClasses.contains(studentClass.id);
    final students = controller.getClassStudentsList(studentClass.id);
    final isLoadingStudents = controller.loadingStudentsForClass.contains(studentClass.id);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.primaryDark : AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDarkMode ? AppColors.border.withOpacity(0.2) : AppColors.border,
        ),
      ),
      child: Column(
        children: [
          // Class header
          InkWell(
            onTap: () => controller.toggleClass(studentClass.id),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    isExpanded ? Icons.expand_more : Icons.chevron_right,
                    color: isDarkMode ? AppColors.white : AppColors.black,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          studentClass.name,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: isDarkMode ? AppColors.white : AppColors.black,
                              ),
                        ),
                        if (studentClass.description != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            studentClass.description!,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: isDarkMode ? AppColors.greyLight : AppColors.grey,
                                ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Text(
                    '${studentClass.studentCount} students',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isDarkMode ? AppColors.greyLight : AppColors.grey,
                        ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () => _showDeleteConfirmation(context, studentClass.id),
                    tooltip: 'Delete Class',
                  ),
                ],
              ),
            ),
          ),

          // Expanded content
          if (isExpanded)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDarkMode ? AppColors.primaryLight.withOpacity(0.1) : AppColors.background,
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Class info
                  _buildClassInfo(context, studentClass, isDarkMode),
                  const SizedBox(height: 16),
                  
                  // Students section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Students in Class',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isDarkMode ? AppColors.white : AppColors.black,
                            ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => controller.openAddStudentsModal(studentClass),
                        icon: const Icon(Icons.person_add, size: 16),
                        label: const Text('Add Students'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.onboardingContinue,
                          foregroundColor: AppColors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Students list
                  if (isLoadingStudents)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: const CircularProgressIndicator(),
                      ),
                    )
                  else if (students.isEmpty)
                    _buildEmptyStudents(context, studentClass, isDarkMode)
                  else
                    _buildStudentsList(context, studentClass.id, students, isDarkMode),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildClassInfo(BuildContext context, studentClass, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.primaryDark : AppColors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow('Created', _formatDate(studentClass.createdAt), isDarkMode),
          const SizedBox(height: 4),
          _buildInfoRow('Updated', _formatDate(studentClass.updatedAt), isDarkMode),
          const SizedBox(height: 4),
          _buildInfoRow('Total Students', '${studentClass.studentCount}', isDarkMode),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, bool isDarkMode) {
    return Row(
      children: [
        Text(
          '$label: ',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDarkMode ? AppColors.greyLight : AppColors.grey,
            fontSize: 12,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: isDarkMode ? AppColors.white : AppColors.black,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyStudents(BuildContext context, studentClass, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.primaryDark : AppColors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDarkMode ? AppColors.border.withOpacity(0.2) : AppColors.border,
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.people_outline,
            size: 48,
            color: isDarkMode ? AppColors.greyLight : AppColors.grey,
          ),
          const SizedBox(height: 12),
          Text(
            'No students in this class yet',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isDarkMode ? AppColors.greyLight : AppColors.grey,
                ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => controller.openAddStudentsModal(studentClass),
            icon: const Icon(Icons.person_add),
            label: const Text('Add First Student'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.onboardingContinue,
              foregroundColor: AppColors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentsList(BuildContext context, String classId, List students, bool isDarkMode) {
    return Container(
      constraints: const BoxConstraints(maxHeight: 300),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.primaryDark : AppColors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: students.length,
        itemBuilder: (context, index) {
          final classStudent = students[index];
          final studentInfo = controller.getStudentInfo(classStudent.studentId);
          
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDarkMode ? AppColors.primaryLight.withOpacity(0.1) : AppColors.background,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          if (studentInfo != null)
                            Text(
                              studentInfo.fullName,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: isDarkMode ? AppColors.white : AppColors.black,
                                  ),
                            )
                          else
                            Text(
                              'Student ID: ${classStudent.studentId}',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: isDarkMode ? AppColors.white : AppColors.black,
                                  ),
                            ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'ID: ${classStudent.studentId}',
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.blue,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (studentInfo != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          studentInfo.email,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: isDarkMode ? AppColors.greyLight : AppColors.grey,
                              ),
                        ),
                      ],
                      const SizedBox(height: 4),
                      Text(
                        'Added ${_formatDate(classStudent.addedAt)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: isDarkMode ? AppColors.greyLight : AppColors.grey,
                              fontSize: 10,
                            ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                  onPressed: () => _showRemoveStudentConfirmation(
                    context,
                    classId,
                    classStudent.studentId,
                  ),
                  tooltip: 'Remove from class',
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, String classId) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Class'),
        content: const Text('Are you sure you want to delete this class?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              controller.deleteClass(classId);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showRemoveStudentConfirmation(BuildContext context, String classId, int studentId) {
    Get.dialog(
      AlertDialog(
        title: const Text('Remove Student'),
        content: const Text('Remove this student from the class?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              controller.removeStudentFromClass(classId, studentId);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

