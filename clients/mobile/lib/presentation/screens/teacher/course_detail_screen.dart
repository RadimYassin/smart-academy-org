import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';
import '../../../domain/repositories/course_repository.dart';
import '../../controllers/courses_controller.dart';
import '../../controllers/enrollment_controller.dart';
import '../../widgets/loading_indicator.dart';
import 'modals/assign_student_modal.dart';

class CourseDetailScreen extends StatefulWidget {
  final String courseId;

  const CourseDetailScreen({super.key, required this.courseId});

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> {
  @override
  void initState() {
    super.initState();
    final controller = Get.find<CoursesController>();
    final enrollmentController = Get.find<EnrollmentController>();
    
    // Load course and content on init
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // If course not selected, load it first
      if (controller.selectedCourse.value?.id != widget.courseId) {
        try {
          final courseRepository = Get.find<CourseRepository>();
          final course = await courseRepository.getCourseById(widget.courseId);
          controller.selectedCourse.value = course;
        } catch (e) {
          Get.snackbar('Error', 'Failed to load course');
          Get.back();
          return;
        }
      }
      // Load course content and enrollments
      controller.loadCourseContent(widget.courseId);
      enrollmentController.loadCourseEnrollments(widget.courseId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CoursesController>();
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final enrollmentController = Get.find<EnrollmentController>();

    return Scaffold(
      backgroundColor: isDarkMode ? AppColors.primary : AppColors.background,
      appBar: AppBar(
        title: Text(controller.selectedCourse.value?.title ?? 'Course Detail'),
        backgroundColor: isDarkMode ? AppColors.primaryDark : AppColors.primary,
        foregroundColor: AppColors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.people),
            onPressed: () {
              enrollmentController.selectedCourseId.value = widget.courseId;
              enrollmentController.showAssignStudentModal.value = true;
            },
            tooltip: 'Assign Students',
          ),
        ],
      ),
      body: Stack(
        children: [
          Obx(() {
            if (controller.isLoadingCourseContent.value) {
              return const Center(child: LoadingIndicator());
            }

            return               RefreshIndicator(
              onRefresh: () => controller.loadCourseContent(widget.courseId),
              child: CustomScrollView(
                slivers: [
                  // Course Info
                  SliverToBoxAdapter(
                    child: _buildCourseInfo(context, controller, isDarkMode),
                  ),

                  // Modules Section
                  SliverToBoxAdapter(
                    child: _buildModulesSection(context, controller, isDarkMode),
                  ),

                  // Quizzes Section
                  SliverToBoxAdapter(
                    child: _buildQuizzesSection(context, controller, isDarkMode),
                  ),

                  // Enrollments Section
                  SliverToBoxAdapter(
                    child: _buildEnrollmentsSection(context, controller, enrollmentController, isDarkMode),
                  ),
                ],
              ),
            );
          }),
          // Modals overlay
          Obx(() => enrollmentController.showAssignStudentModal.value
              ? const AssignStudentModal()
              : const SizedBox.shrink()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Show add module modal
          Get.snackbar('Info', 'Add module functionality coming soon');
        },
        backgroundColor: AppColors.onboardingContinue,
        child: const Icon(Icons.add, color: AppColors.white),
      ),
    );
  }

  Widget _buildCourseInfo(BuildContext context, CoursesController controller, bool isDarkMode) {
    final course = controller.selectedCourse.value;
    if (course == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.all(16),
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
            course.title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? AppColors.white : AppColors.black,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            course.description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isDarkMode ? AppColors.greyLight : AppColors.grey,
                ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.onboardingContinue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  course.category,
                  style: TextStyle(
                    color: AppColors.onboardingContinue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getLevelColor(course.level).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  course.level,
                  style: TextStyle(
                    color: _getLevelColor(course.level),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModulesSection(BuildContext context, CoursesController controller, bool isDarkMode) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Modules (${controller.courseModules.length})',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? AppColors.white : AppColors.black,
                    ),
              ),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () {
                  Get.snackbar('Info', 'Add module functionality coming soon');
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (controller.courseModules.isEmpty)
            _buildEmptyState('No modules yet', Icons.layers, isDarkMode)
          else
            ...controller.courseModules.map((module) {
              return _buildModuleCard(context, controller, module, isDarkMode)
                  .animate()
                  .fadeIn()
                  .slideY(begin: 0.1, end: 0);
            }),
        ],
      ),
    );
  }

  Widget _buildModuleCard(BuildContext context, CoursesController controller, module, bool isDarkMode) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.primaryDark : AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDarkMode ? AppColors.border.withOpacity(0.2) : AppColors.border,
        ),
      ),
      child: ExpansionTile(
        title: Text(
          module.title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: isDarkMode ? AppColors.white : AppColors.black,
              ),
        ),
        subtitle: module.description != null
            ? Text(
                module.description!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isDarkMode ? AppColors.greyLight : AppColors.grey,
                    ),
              )
            : null,
        children: [
          if (module.lessons == null || module.lessons!.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: _buildEmptyState('No lessons yet', Icons.book, isDarkMode),
            )
          else
            ...module.lessons!.map((lesson) {
              return _buildLessonCard(context, controller, lesson, isDarkMode);
            }),
        ],
      ),
    );
  }

  Widget _buildLessonCard(BuildContext context, CoursesController controller, lesson, bool isDarkMode) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.primaryLight.withOpacity(0.1) : AppColors.background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.play_circle_outline, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lesson.title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isDarkMode ? AppColors.white : AppColors.black,
                      ),
                ),
                if (lesson.summary != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    lesson.summary!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isDarkMode ? AppColors.greyLight : AppColors.grey,
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                if (lesson.contents != null && lesson.contents!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    '${lesson.contents!.length} content item(s)',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.onboardingContinue,
                          fontSize: 10,
                        ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizzesSection(BuildContext context, CoursesController controller, bool isDarkMode) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Quizzes (${controller.courseQuizzes.length})',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? AppColors.white : AppColors.black,
                    ),
              ),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () {
                  Get.snackbar('Info', 'Add quiz functionality coming soon');
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (controller.courseQuizzes.isEmpty)
            _buildEmptyState('No quizzes yet', Icons.quiz, isDarkMode)
          else
            ...controller.courseQuizzes.map((quiz) {
              return _buildQuizCard(context, controller, quiz, isDarkMode)
                  .animate()
                  .fadeIn()
                  .slideY(begin: 0.1, end: 0);
            }),
        ],
      ),
    );
  }

  Widget _buildQuizCard(BuildContext context, CoursesController controller, quiz, bool isDarkMode) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.primaryDark : AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDarkMode ? AppColors.border.withOpacity(0.2) : AppColors.border,
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.quiz, color: Colors.orange),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  quiz.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? AppColors.white : AppColors.black,
                      ),
                ),
                if (quiz.description != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    quiz.description!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isDarkMode ? AppColors.greyLight : AppColors.grey,
                        ),
                  ),
                ],
                if (quiz.questions != null && quiz.questions!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    '${quiz.questions!.length} question(s)',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.onboardingContinue,
                          fontSize: 10,
                        ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnrollmentsSection(
    BuildContext context,
    CoursesController controller,
    EnrollmentController enrollmentController,
    bool isDarkMode,
  ) {
    return Obx(() {
      return Container(
        margin: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Enrolled Students (${enrollmentController.enrollments.length})',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? AppColors.white : AppColors.black,
                      ),
                ),
                IconButton(
                  icon: const Icon(Icons.person_add),
                  onPressed: () {
                    enrollmentController.selectedCourseId.value = widget.courseId;
                    enrollmentController.showAssignStudentModal.value = true;
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (enrollmentController.enrollments.isEmpty)
              _buildEmptyState('No students enrolled yet', Icons.people, isDarkMode)
            else
              ...enrollmentController.enrollments.map((enrollment) {
                return _buildEnrollmentCard(context, enrollment, enrollmentController, isDarkMode)
                    .animate()
                    .fadeIn()
                    .slideY(begin: 0.1, end: 0);
              }),
          ],
        ),
      );
    });
  }

  Widget _buildEnrollmentCard(
    BuildContext context,
    enrollment,
    EnrollmentController enrollmentController,
    bool isDarkMode,
  ) {
    final studentName = enrollment.studentFirstName != null &&
            enrollment.studentLastName != null
        ? '${enrollment.studentFirstName} ${enrollment.studentLastName}'
        : 'Student ID: ${enrollment.studentId}';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.primaryDark : AppColors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDarkMode ? AppColors.border.withOpacity(0.2) : AppColors.border,
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.person, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  studentName,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isDarkMode ? AppColors.white : AppColors.black,
                      ),
                ),
                Text(
                  'Enrolled: ${_formatDate(enrollment.enrolledAt)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isDarkMode ? AppColors.greyLight : AppColors.grey,
                        fontSize: 10,
                      ),
                ),
              ],
            ),
          ),
          if (enrollment.studentId != null)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red, size: 20),
              onPressed: () {
                Get.dialog(
                  AlertDialog(
                    title: const Text('Unenroll Student'),
                    content: Text('Remove $studentName from this course?'),
                    actions: [
                      TextButton(
                        onPressed: () => Get.back(),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          Get.back();
                          enrollmentController.unenrollStudent(
                            widget.courseId,
                            enrollment.studentId!,
                          );
                        },
                        style: TextButton.styleFrom(foregroundColor: Colors.red),
                        child: const Text('Remove'),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message, IconData icon, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.primaryDark : AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDarkMode ? AppColors.border.withOpacity(0.2) : AppColors.border,
          style: BorderStyle.solid,
        ),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(icon, size: 48, color: isDarkMode ? AppColors.greyLight : AppColors.grey),
            const SizedBox(height: 12),
            Text(
              message,
              style: TextStyle(
                color: isDarkMode ? AppColors.greyLight : AppColors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getLevelColor(String level) {
    switch (level) {
      case 'BEGINNER':
        return Colors.green;
      case 'INTERMEDIATE':
        return Colors.orange;
      case 'ADVANCED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

