import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';
import '../../../domain/repositories/course_repository.dart';
import '../../controllers/courses_controller.dart';
import '../../controllers/progress_controller.dart';
import '../../widgets/loading_indicator.dart';

class StudentCourseViewScreen extends StatefulWidget {
  final String courseId;

  const StudentCourseViewScreen({super.key, required this.courseId});

  @override
  State<StudentCourseViewScreen> createState() => _StudentCourseViewScreenState();
}

class _StudentCourseViewScreenState extends State<StudentCourseViewScreen> {
  @override
  void initState() {
    super.initState();
    final controller = Get.find<CoursesController>();
    final progressController = Get.find<ProgressController>();
    
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Load course if not already loaded
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
      
      // Load course content (modules, lessons, content, quizzes) - same pattern as microfrontends
      await controller.loadCourseContent(widget.courseId);
      
      // Load progress in parallel
      await Future.wait([
        progressController.loadCourseProgress(widget.courseId),
        progressController.loadAllLessonProgressForCourse(widget.courseId),
      ]);
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CoursesController>();
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final progressController = Get.find<ProgressController>();

    return Scaffold(
      backgroundColor: isDarkMode ? AppColors.primary : AppColors.background,
      body: Obx(() {
        if (controller.isLoadingCourseContent.value) {
          return const Center(child: LoadingIndicator());
        }

        final course = controller.selectedCourse.value;
        if (course == null) {
          return Center(
            child: Text(
              'Course not found',
              style: TextStyle(color: isDarkMode ? AppColors.white : AppColors.black),
            ),
          );
        }

        // Show error message if there's an error
        if (controller.errorMessage.value.isNotEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading course content',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? AppColors.white : AppColors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    controller.errorMessage.value,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isDarkMode ? AppColors.greyLight : AppColors.grey,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      controller.errorMessage.value = '';
                      controller.loadCourseContent(widget.courseId);
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            await controller.loadCourseContent(widget.courseId);
            await progressController.loadCourseProgress(widget.courseId);
            await progressController.loadAllLessonProgressForCourse(widget.courseId);
          },
          child: CustomScrollView(
            slivers: [
              // Hero Header with Course Image
              SliverAppBar(
                expandedHeight: 250,
                pinned: true,
                backgroundColor: isDarkMode ? AppColors.primaryDark : AppColors.primary,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: AppColors.white),
                  onPressed: () => Get.back(),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Course Thumbnail or Gradient
                      course.thumbnailUrl.isNotEmpty
                          ? Image.network(
                              course.thumbnailUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  _buildGradientHeader(isDarkMode),
                            )
                          : _buildGradientHeader(isDarkMode),
                      // Gradient Overlay
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.7),
                            ],
                          ),
                        ),
                      ),
                      // Course Title Overlay
                      Positioned(
                        bottom: 20,
                        left: 20,
                        right: 20,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              course.title,
                              style: const TextStyle(
                                color: AppColors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                shadows: [
                                  Shadow(
                                    color: Colors.black54,
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.onboardingContinue.withOpacity(0.9),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    course.level,
                                    style: const TextStyle(
                                      color: AppColors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    course.category,
                                    style: const TextStyle(
                                      color: AppColors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Course Overview Section
              SliverToBoxAdapter(
                child: _buildCourseOverview(context, course, progressController, isDarkMode)
                    .animate()
                    .fadeIn(delay: 100.ms)
                    .slideY(begin: 0.1, end: 0),
              ),

              // Continue Learning Button
              SliverToBoxAdapter(
                child: _buildContinueLearningButton(
                  context,
                  controller,
                  progressController,
                  isDarkMode,
                )
                    .animate()
                    .fadeIn(delay: 200.ms)
                    .slideY(begin: 0.1, end: 0),
              ),

              // Course Content Section
              SliverToBoxAdapter(
                child: _buildCourseContentSection(
                  context,
                  controller,
                  progressController,
                  isDarkMode,
                )
                    .animate()
                    .fadeIn(delay: 300.ms)
                    .slideY(begin: 0.1, end: 0),
              ),

              // Quizzes Section - Wrap in Obx to observe changes
              SliverToBoxAdapter(
                child: Obx(() {
                  if (controller.courseQuizzes.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  return _buildQuizzesSection(context, controller, isDarkMode)
                      .animate()
                      .fadeIn(delay: 400.ms)
                      .slideY(begin: 0.1, end: 0);
                }),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildGradientHeader(bool isDarkMode) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.onboardingContinue,
            AppColors.onboardingContinue.withOpacity(0.7),
            AppColors.primaryDark,
          ],
        ),
      ),
    );
  }

  Widget _buildCourseOverview(
    BuildContext context,
    course,
    ProgressController progressController,
    bool isDarkMode,
  ) {
    final progress = progressController.courseProgress[widget.courseId];
    final completionRate = progress?.completionRate ?? 0.0;
    final completedLessons = progress?.completedLessons ?? 0;
    final totalLessons = progress?.totalLessons ?? 0;

    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.primaryDark : AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress Section
          if (totalLessons > 0) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                      'Your Progress',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                              fontWeight: FontWeight.bold,
                            color: isDarkMode ? AppColors.white : AppColors.black,
                                            ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                      '$completedLessons of $totalLessons lessons',
                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: isDarkMode ? AppColors.greyLight : AppColors.grey,
                                            ),
                                      ),
                                    ],
                                  ),
                  Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                    color: AppColors.onboardingContinue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${completionRate.toInt()}%',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.onboardingContinue,
                              ),
                            ),
                          ),
                        ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: completionRate / 100,
                minHeight: 10,
                backgroundColor: isDarkMode
                    ? AppColors.primaryLight.withOpacity(0.2)
                    : AppColors.grey.withOpacity(0.2),
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.onboardingContinue),
                      ),
                    ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 16),
          ],

                // Course Description
                        Text(
                          'About this course',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                  color: isDarkMode ? AppColors.white : AppColors.black,
                              ),
                    ),
                    const SizedBox(height: 12),
          Text(
                        course.description,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: isDarkMode ? AppColors.greyLight : AppColors.grey,
                  height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContinueLearningButton(
    BuildContext context,
    CoursesController controller,
    ProgressController progressController,
    bool isDarkMode,
  ) {
    // Find the next incomplete lesson
    String? nextLessonId;
    String? nextModuleId;
    
    for (final module in controller.courseModules) {
      if (module.lessons != null) {
        for (final lesson in module.lessons!) {
          if (!progressController.isLessonCompleted(widget.courseId, lesson.id)) {
            nextLessonId = lesson.id;
            nextModuleId = module.id;
            break;
          }
        }
        if (nextLessonId != null) break;
      }
    }

    if (nextLessonId == null) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: ElevatedButton.icon(
        onPressed: () {
            // Navigate to lesson learning screen
            Get.toNamed(
              '/student/lessons/$nextLessonId',
              arguments: {
                'courseId': widget.courseId,
                'lessonId': nextLessonId,
                'moduleId': nextModuleId,
              },
            );
          },
        icon: const Icon(Icons.play_arrow, size: 24),
        label: const Text(
                        'Continue Learning',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.onboardingContinue,
          foregroundColor: AppColors.white,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
        ),
      ),
    );
  }

  Widget _buildCourseContentSection(
    BuildContext context,
    CoursesController controller,
    ProgressController progressController,
    bool isDarkMode,
  ) {
    // Wrap in Obx to observe changes to courseModules
    return Obx(() {
      final modules = controller.courseModules;
      final totalLessons = _getTotalLessons(controller);
      
      debugPrint('🟡 [_buildCourseContentSection] Building UI with ${modules.length} modules, $totalLessons lessons');
      debugPrint('  isLoadingCourseContent: ${controller.isLoadingCourseContent.value}');
      debugPrint('  courseModules.isEmpty: ${modules.isEmpty}');
      
      if (modules.isNotEmpty) {
        debugPrint('  ✅ Modules found:');
        for (var module in modules) {
          debugPrint('    - ${module.title} (${module.id}) with ${module.lessons?.length ?? 0} lessons');
        }
      } else {
        debugPrint('  ⚠️ No modules in courseModules list!');
      }
      
      return Container(
        margin: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.menu_book_rounded,
                  color: AppColors.onboardingContinue,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Text(
                  'Course Content',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? AppColors.white : AppColors.black,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${modules.length} modules • $totalLessons lessons',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isDarkMode ? AppColors.greyLight : AppColors.grey,
                  ),
            ),
            const SizedBox(height: 20),
            if (controller.isLoadingCourseContent.value)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (modules.isEmpty)
              _buildEmptyState(
                controller.errorMessage.value.isNotEmpty
                    ? controller.errorMessage.value
                    : 'No modules available for this course. The course content may not be set up yet.',
                Icons.layers,
                isDarkMode,
              )
            else
              ...modules.asMap().entries.map((entry) {
                final index = entry.key;
                final module = entry.value;
                return _buildModernModuleCard(
                  context,
                  controller,
                  module,
                  progressController,
                  isDarkMode,
                  index + 1,
                )
                    .animate()
                    .fadeIn(delay: (index * 50).ms)
                    .slideX(begin: -0.1, end: 0);
              }),
          ],
        ),
      );
    });
  }

  int _getTotalLessons(CoursesController controller) {
    int total = 0;
    for (final module in controller.courseModules) {
      total += module.lessons?.length ?? 0;
    }
    return total;
  }

  Widget _buildModernModuleCard(
    BuildContext context,
    CoursesController controller,
    module,
    ProgressController progressController,
    bool isDarkMode,
    int moduleNumber,
  ) {
    final lessons = module.lessons ?? [];
    final completedLessons = lessons.where((lesson) =>
        progressController.isLessonCompleted(widget.courseId, lesson.id)).length;
    final moduleProgress = lessons.isEmpty ? 0.0 : (completedLessons / lessons.length) * 100;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.primaryDark : AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDarkMode ? AppColors.border.withOpacity(0.2) : AppColors.border.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          childrenPadding: const EdgeInsets.only(bottom: 12),
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.onboardingContinue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                      '$moduleNumber',
                style: TextStyle(
                  color: AppColors.onboardingContinue,
                        fontWeight: FontWeight.bold,
                  fontSize: 16,
                      ),
                    ),
            ),
          ),
          title: Text(
            module.title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? AppColors.white : AppColors.black,
                ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (module.description != null) ...[
                const SizedBox(height: 4),
                Text(
                  module.description!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isDarkMode ? AppColors.greyLight : AppColors.grey,
                      ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.play_circle_outline,
                    size: 14,
                    color: isDarkMode ? AppColors.greyLight : AppColors.grey,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${lessons.length} lessons',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isDarkMode ? AppColors.greyLight : AppColors.grey,
                          fontSize: 12,
                        ),
                  ),
                  if (lessons.isNotEmpty) ...[
                    const SizedBox(width: 16),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: moduleProgress / 100,
                          minHeight: 4,
                          backgroundColor: isDarkMode
                              ? AppColors.primaryLight.withOpacity(0.2)
                              : AppColors.grey.withOpacity(0.2),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            moduleProgress == 100 ? Colors.green : AppColors.onboardingContinue,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${moduleProgress.toInt()}%',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: moduleProgress == 100
                            ? Colors.green
                            : (isDarkMode ? AppColors.greyLight : AppColors.grey),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
          children: [
            if (lessons.isEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: _buildEmptyState('No lessons yet', Icons.book, isDarkMode),
              )
            else
              ...lessons.asMap().entries.map((entry) {
                final lessonIndex = entry.key;
                final lesson = entry.value;
                final isCompleted = progressController.isLessonCompleted(
                  widget.courseId,
                  lesson.id,
                );
                return _buildModernLessonCard(
                  context,
                  controller,
                  module,
                  lesson,
                  isCompleted,
                  progressController,
                  isDarkMode,
                  lessonIndex + 1,
                );
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildModernLessonCard(
    BuildContext context,
    CoursesController controller,
    module,
    lesson,
    bool isCompleted,
    ProgressController progressController,
    bool isDarkMode,
    int lessonNumber,
  ) {
    final hasContent = lesson.contents != null && lesson.contents!.isNotEmpty;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isCompleted
            ? Colors.green.withOpacity(0.1)
            : isDarkMode
                ? AppColors.primaryLight.withOpacity(0.05)
                : AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCompleted
              ? Colors.green.withOpacity(0.5)
              : isDarkMode
                  ? AppColors.border.withOpacity(0.1)
                  : AppColors.border.withOpacity(0.2),
          width: isCompleted ? 1.5 : 1,
        ),
      ),
        child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // Navigate to lesson learning screen
            Get.toNamed(
              '/student/lessons/${lesson.id}',
              arguments: {
                'courseId': widget.courseId,
                'lessonId': lesson.id,
                'moduleId': module.id,
              },
            );
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Lesson Number/Status Icon
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? Colors.green.withOpacity(0.2)
                        : AppColors.onboardingContinue.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isCompleted ? Icons.check_circle : Icons.play_circle_outline,
                    color: isCompleted ? Colors.green : AppColors.onboardingContinue,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                // Lesson Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              lesson.title,
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: isDarkMode ? AppColors.white : AppColors.black,
                                  ),
                            ),
                          ),
                          if (isCompleted)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'COMPLETE',
                                style: TextStyle(
                                  color: AppColors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
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
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          if (hasContent) ...[
                            Icon(
                              Icons.description,
                              size: 14,
                              color: AppColors.onboardingContinue,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${lesson.contents!.length} content',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.onboardingContinue,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                          if (!isCompleted) ...[
                            const Spacer(),
                            TextButton.icon(
                              onPressed: () async {
                                await progressController.markLessonComplete(lesson.id);
                                await progressController.loadCourseProgress(widget.courseId);
                                await progressController.loadAllLessonProgressForCourse(widget.courseId);
                              },
                              icon: const Icon(Icons.check, size: 16),
                              label: const Text('Mark Complete'),
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.green,
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
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
            children: [
              Icon(
                Icons.quiz_rounded,
                color: Colors.orange,
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                'Quizzes',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? AppColors.white : AppColors.black,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...controller.courseQuizzes.map((quiz) {
            return _buildModernQuizCard(context, quiz, isDarkMode)
                .animate()
                .fadeIn()
                .slideX(begin: 0.1, end: 0);
          }),
        ],
      ),
    );
  }

  Widget _buildModernQuizCard(BuildContext context, quiz, bool isDarkMode) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.primaryDark : AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.orange.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // Navigate to quiz screen
            Get.toNamed(
              '/student/quizzes/${quiz.id}',
              arguments: {
                'quizTitle': quiz.title,
                'quizDescription': quiz.description,
              },
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
                  children: [
                    Container(
                  width: 50,
                  height: 50,
                      decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                      ),
                  child: const Icon(Icons.quiz, color: Colors.orange, size: 28),
                    ),
                    const SizedBox(width: 16),
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
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                      if (quiz.questions != null && quiz.questions!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                Row(
                  children: [
                            Icon(
                            Icons.help_outline,
                              size: 14,
                            color: Colors.orange,
                          ),
                          const SizedBox(width: 4),
                          Text(
                              '${quiz.questions!.length} questions',
                              style: TextStyle(
                              color: Colors.orange,
                                fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      ],
                          ],
                        ),
                      ),
                Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                  color: isDarkMode ? AppColors.greyLight : AppColors.grey,
                    ),
                  ],
                ),
            ),
          ),
        ),
    );
  }

  Widget _buildEmptyState(String message, IconData icon, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.primaryDark : AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDarkMode ? AppColors.border.withOpacity(0.2) : AppColors.border,
        ),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(icon, size: 56, color: isDarkMode ? AppColors.greyLight : AppColors.grey),
            const SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(
                color: isDarkMode ? AppColors.greyLight : AppColors.grey,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
