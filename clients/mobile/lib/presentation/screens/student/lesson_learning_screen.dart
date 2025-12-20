import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/course/lesson.dart';
import '../../../data/models/course/lesson_content.dart';
import '../../controllers/courses_controller.dart';
import '../../controllers/progress_controller.dart';

class LessonLearningScreen extends StatefulWidget {
  final String courseId;
  final String lessonId;
  final String moduleId;
  final int? initialContentIndex;

  const LessonLearningScreen({
    super.key,
    required this.courseId,
    required this.lessonId,
    required this.moduleId,
    this.initialContentIndex,
  });

  @override
  State<LessonLearningScreen> createState() => _LessonLearningScreenState();
}

class _LessonLearningScreenState extends State<LessonLearningScreen> {
  int _currentContentIndex = 0;
  bool _isMarkingComplete = false;

  @override
  void initState() {
    super.initState();
    _currentContentIndex = widget.initialContentIndex ?? 0;
    // Defer loading until after the build phase to avoid setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
    _loadLessonContent();
    });
  }

  void _loadLessonContent() {
    final controller = Get.find<CoursesController>();
    controller.loadCourseContent(widget.courseId);
  }

  Lesson? get _lesson {
    final controller = Get.find<CoursesController>();
    for (final module in controller.courseModules) {
      if (module.id == widget.moduleId && module.lessons != null) {
        return module.lessons!.firstWhere(
          (l) => l.id == widget.lessonId,
          orElse: () => module.lessons!.first,
        );
      }
    }
    return null;
  }

  List<LessonContent> get _contentItems {
    final lesson = _lesson;
    if (lesson == null || lesson.contents == null) return [];
    return List.from(lesson.contents!)
      ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
  }

  LessonContent? get _currentContent {
    if (_contentItems.isEmpty) return null;
    if (_currentContentIndex >= _contentItems.length) {
      _currentContentIndex = _contentItems.length - 1;
    }
    return _contentItems[_currentContentIndex];
  }

  bool get _hasPrevious => _currentContentIndex > 0;
  bool get _hasNext => _currentContentIndex < _contentItems.length - 1;
  bool get _isLastContent => _currentContentIndex == _contentItems.length - 1;

  bool get _isLessonCompleted {
    final progressController = Get.find<ProgressController>();
    return progressController.isLessonCompleted(widget.courseId, widget.lessonId);
  }

  /// Find the next lesson in the course
  Map<String, String>? _getNextLesson() {
    final controller = Get.find<CoursesController>();
    final progressController = Get.find<ProgressController>();
    
    // Get all lessons in order (sorted by module orderIndex and lesson orderIndex)
    final allLessons = <({String lessonId, String moduleId, int moduleOrder, int lessonOrder})>[];
    
    for (final module in controller.courseModules) {
      if (module.lessons != null) {
        for (final lesson in module.lessons!) {
          allLessons.add((
            lessonId: lesson.id,
            moduleId: module.id,
            moduleOrder: module.orderIndex,
            lessonOrder: lesson.orderIndex,
          ));
        }
      }
    }
    
    // Sort by module order, then lesson order
    allLessons.sort((a, b) {
      final moduleCompare = a.moduleOrder.compareTo(b.moduleOrder);
      if (moduleCompare != 0) return moduleCompare;
      return a.lessonOrder.compareTo(b.lessonOrder);
    });
    
    // Find current lesson index
    int currentIndex = -1;
    for (int i = 0; i < allLessons.length; i++) {
      if (allLessons[i].lessonId == widget.lessonId) {
        currentIndex = i;
        break;
      }
    }
    
    // Find next incomplete lesson
    for (int i = currentIndex + 1; i < allLessons.length; i++) {
      final nextLesson = allLessons[i];
      if (!progressController.isLessonCompleted(widget.courseId, nextLesson.lessonId)) {
        return {
          'lessonId': nextLesson.lessonId,
          'moduleId': nextLesson.moduleId,
        };
      }
    }
    
    return null;
  }

  Future<void> _markLessonComplete() async {
    if (_isMarkingComplete || _isLessonCompleted) return;

    setState(() => _isMarkingComplete = true);

    try {
      final progressController = Get.find<ProgressController>();
      await progressController.markLessonComplete(widget.lessonId);
      await progressController.loadCourseProgress(widget.courseId);
      await progressController.loadAllLessonProgressForCourse(widget.courseId);

      if (mounted) {
        // Check if there's a next lesson
        final nextLesson = _getNextLesson();
        if (nextLesson != null) {
          Get.snackbar(
            'Lesson Completed!',
            'Click "Next Lesson" to continue',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.green.withOpacity(0.8),
            colorText: Colors.white,
            duration: const Duration(seconds: 2),
          );
        } else {
          Get.snackbar(
            'Congratulations!',
            'You\'ve completed all lessons!',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.green.withOpacity(0.8),
            colorText: Colors.white,
            duration: const Duration(seconds: 2),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Get.snackbar(
          'Error',
          'Failed to mark lesson as complete',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red.withOpacity(0.8),
          colorText: Colors.white,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isMarkingComplete = false);
      }
    }
  }

  void _navigateContent(String direction) async {
    if (direction == 'prev' && _hasPrevious) {
      setState(() => _currentContentIndex--);
    } else if (direction == 'next') {
      // If we're on the last content and lesson is completed, go to next lesson
      if (_isLastContent && _isLessonCompleted) {
        final nextLesson = _getNextLesson();
        if (nextLesson != null) {
          // Navigate to next lesson
          Get.offNamed(
            '/student/lessons/${nextLesson['lessonId']}',
            arguments: {
              'courseId': widget.courseId,
              'lessonId': nextLesson['lessonId'],
              'moduleId': nextLesson['moduleId'],
            },
          );
          return;
        } else {
          // No more lessons, go back to course view
          Get.snackbar(
            'Congratulations!',
            'You\'ve completed all lessons in this course!',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.green.withOpacity(0.8),
            colorText: Colors.white,
            duration: const Duration(seconds: 2),
          );
          // Wait a bit then go back
          await Future.delayed(const Duration(seconds: 2));
          Get.back();
          return;
        }
      } else if (_hasNext) {
        // Navigate to next content in same lesson
        setState(() => _currentContentIndex++);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final lesson = _lesson;
    final currentContent = _currentContent;

    if (lesson == null) {
      return Scaffold(
        backgroundColor: isDarkMode ? AppColors.primary : AppColors.background,
        appBar: AppBar(
          title: const Text('Lesson'),
          backgroundColor: isDarkMode ? AppColors.primaryDark : AppColors.primary,
          foregroundColor: AppColors.white,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: isDarkMode ? AppColors.primary : AppColors.background,
      appBar: AppBar(
        backgroundColor: isDarkMode ? AppColors.primaryDark : AppColors.primary,
        foregroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              lesson.title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (_contentItems.isNotEmpty)
              Text(
                '${_currentContentIndex + 1} of ${_contentItems.length}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.normal,
                ),
              ),
          ],
        ),
        actions: [
          if (_isLessonCompleted)
            Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle, size: 16, color: Colors.white),
                  SizedBox(width: 4),
                  Text(
                    'COMPLETE',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
      body: Obx(() {
        final progressController = Get.find<ProgressController>();
        final isCompleted = progressController.isLessonCompleted(
          widget.courseId,
          widget.lessonId,
        );

        return Column(
          children: [
            // Progress Indicator
            if (_contentItems.isNotEmpty)
              Container(
                height: 4,
                color: isDarkMode ? AppColors.primaryDark : AppColors.white,
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: (_currentContentIndex + 1) / _contentItems.length,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.onboardingContinue,
                          AppColors.onboardingContinue.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

            // Lesson Status Banner
            if (lesson != null && lesson.title.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isCompleted
                      ? Colors.green.withOpacity(0.1)
                      : Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isCompleted
                        ? Colors.green.withOpacity(0.3)
                        : Colors.blue.withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isCompleted ? Icons.check_circle : Icons.info_outline,
                      color: isCompleted ? Colors.green : Colors.blue,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isCompleted ? 'Lesson Completed' : 'Lesson in Progress',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isDarkMode ? AppColors.white : AppColors.black,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isCompleted
                                ? 'You\'ve completed "${lesson.title}"'
                                : 'Complete all content and mark lesson as complete',
                            style: TextStyle(
                              color: isDarkMode ? AppColors.greyLight : AppColors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
                  .animate()
                  .fadeIn(delay: 100.ms)
                  .slideY(begin: -0.1, end: 0),

            // Content Display
            Expanded(
              child: currentContent == null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.description_outlined,
                            size: 64,
                            color: isDarkMode ? AppColors.greyLight : AppColors.grey,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No content available',
                            style: TextStyle(
                              color: isDarkMode ? AppColors.greyLight : AppColors.grey,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Content Type Header
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.onboardingContinue.withOpacity(0.1),
                                  AppColors.onboardingContinue.withOpacity(0.05),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: AppColors.onboardingContinue.withOpacity(0.2),
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: AppColors.onboardingContinue.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    _getContentIcon(currentContent.type),
                                    color: AppColors.onboardingContinue,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${currentContent.type} Content',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.onboardingContinue,
                                          letterSpacing: 1.2,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Part ${_currentContentIndex + 1} of ${_contentItems.length}',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: isDarkMode
                                              ? AppColors.greyLight
                                              : AppColors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          )
                              .animate()
                              .fadeIn(delay: 200.ms)
                              .slideY(begin: 0.1, end: 0),

                          const SizedBox(height: 24),

                          // Content Display Based on Type
                          _buildContentDisplay(currentContent, isDarkMode)
                              .animate()
                              .fadeIn(delay: 300.ms)
                              .scale(delay: 300.ms, begin: const Offset(0.95, 0.95)),
                        ],
                      ),
                    ),
            ),

            // Navigation and Action Buttons
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDarkMode ? AppColors.primaryDark : AppColors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Navigation Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Previous Button
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _hasPrevious ? () => _navigateContent('prev') : null,
                          icon: const Icon(Icons.chevron_left),
                          label: const Text('Previous'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            side: BorderSide(
                              color: _hasPrevious
                                  ? AppColors.onboardingContinue
                                  : (isDarkMode
                                      ? AppColors.greyLight.withOpacity(0.3)
                                      : AppColors.grey.withOpacity(0.3)),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Next Button
                      Expanded(
                        child: Obx(() {
                          final progressController = Get.find<ProgressController>();
                          final isCompleted = progressController.isLessonCompleted(
                            widget.courseId,
                            widget.lessonId,
                          );
                          final nextLesson = _getNextLesson();
                          final canGoToNextLesson = _isLastContent && isCompleted && nextLesson != null;
                          final hasNextContent = _hasNext;
                          final canNavigate = hasNextContent || canGoToNextLesson;
                          
                          return ElevatedButton.icon(
                            onPressed: canNavigate ? () => _navigateContent('next') : null,
                            icon: Icon(canGoToNextLesson ? Icons.arrow_forward : Icons.chevron_right),
                            label: Text(canGoToNextLesson ? 'Next Lesson' : 'Next'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: canNavigate
                                  ? AppColors.onboardingContinue
                                  : (isDarkMode
                                      ? AppColors.greyLight.withOpacity(0.3)
                                      : AppColors.grey.withOpacity(0.3)),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: canNavigate ? 4 : 0,
                            ),
                          );
                        }),
                      ),
                    ],
                  ),

                  // Mark Complete Button (only on last content)
                  if (_isLastContent && !_isLessonCompleted) ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isMarkingComplete ? null : _markLessonComplete,
                        icon: _isMarkingComplete
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor:
                                      AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Icon(Icons.check_circle),
                        label: Text(_isMarkingComplete ? 'Marking...' : 'Mark Lesson Complete'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 4,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildContentDisplay(LessonContent content, bool isDarkMode) {
    switch (content.type.toUpperCase()) {
      case 'TEXT':
        return _buildTextContent(content, isDarkMode);
      case 'VIDEO':
        return _buildVideoContent(content, isDarkMode);
      case 'IMAGE':
        return _buildImageContent(content, isDarkMode);
      case 'PDF':
        return _buildPdfContent(content, isDarkMode);
      case 'QUIZ':
        return _buildQuizContent(content, isDarkMode);
      default:
        return _buildUnknownContent(content, isDarkMode);
    }
  }

  Widget _buildTextContent(LessonContent content, bool isDarkMode) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.primaryDark : AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SelectableText(
        content.textContent ?? 'No text content available',
        style: TextStyle(
          fontSize: 16,
          height: 1.7,
          color: isDarkMode ? AppColors.white : AppColors.black,
        ),
      ),
    );
  }

  Widget _buildVideoContent(LessonContent content, bool isDarkMode) {
    final videoUrl = content.videoUrl;
    if (videoUrl == null || videoUrl.isEmpty) {
      return _buildEmptyContent('No video URL provided', Icons.video_library, isDarkMode);
    }

    // Check if it's a YouTube URL
    if (_isYouTubeUrl(videoUrl)) {
      return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: _buildYouTubeEmbed(videoUrl),
          ),
        ),
      );
    }

    // Regular video
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: _buildVideoPlayer(videoUrl),
        ),
      ),
    );
  }

  Widget _buildVideoPlayer(String videoUrl) {
    // Automatically open video URL in browser/app
    // Also provide a button for manual opening
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _launchUrl(videoUrl);
    });
    
    return Container(
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.play_circle_outline, size: 64, color: Colors.white),
            const SizedBox(height: 16),
            const Text(
              'Opening Video...',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () => _launchUrl(videoUrl),
              icon: const Icon(Icons.open_in_new),
              label: const Text('Open Video'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.onboardingContinue,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildYouTubeEmbed(String videoUrl) {
    // Automatically open YouTube URL in browser/app
    // Also provide a button for manual opening
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _launchUrl(videoUrl);
    });
    
    return Container(
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.play_circle_outline, size: 64, color: Colors.white),
            const SizedBox(height: 16),
            const Text(
              'Opening YouTube Video...',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () => _launchUrl(videoUrl),
              icon: const Icon(Icons.open_in_new),
              label: const Text('Open in YouTube'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageContent(LessonContent content, bool isDarkMode) {
    final imageUrl = content.imageUrl;
    if (imageUrl == null || imageUrl.isEmpty) {
      return _buildEmptyContent('No image URL provided', Icons.image, isDarkMode);
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.primaryDark : AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.network(
          imageUrl,
          fit: BoxFit.contain,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              height: 300,
              color: isDarkMode ? AppColors.primaryDark : AppColors.background,
              child: Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                      : null,
                ),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Container(
              height: 300,
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  const Text('Failed to load image'),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: () => _launchUrl(imageUrl),
                    icon: const Icon(Icons.open_in_new),
                    label: const Text('Open in browser'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPdfContent(LessonContent content, bool isDarkMode) {
    final pdfUrl = content.pdfUrl;
    if (pdfUrl == null || pdfUrl.isEmpty) {
      return _buildEmptyContent('No PDF URL provided', Icons.picture_as_pdf, isDarkMode);
    }

    // Automatically open PDF URL in browser/app
    // Also provide a button for manual opening
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _launchUrl(pdfUrl);
    });

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.primaryDark : AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            Icons.picture_as_pdf,
            size: 64,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          Text(
            'PDF Document',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? AppColors.white : AppColors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Opening PDF in browser...',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: isDarkMode ? AppColors.greyLight : AppColors.grey,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _launchUrl(pdfUrl),
            icon: const Icon(Icons.open_in_new),
            label: const Text('Open PDF'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizContent(LessonContent content, bool isDarkMode) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.orange.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.quiz,
            size: 64,
            color: Colors.orange,
          ),
          const SizedBox(height: 16),
          Text(
            'Quiz Content',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? AppColors.white : AppColors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Quiz functionality will be available soon',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: isDarkMode ? AppColors.greyLight : AppColors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnknownContent(LessonContent content, bool isDarkMode) {
    return _buildEmptyContent(
      'Unknown content type: ${content.type}',
      Icons.help_outline,
      isDarkMode,
    );
  }

  Widget _buildEmptyContent(String message, IconData icon, bool isDarkMode) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(48),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.primaryDark : AppColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: isDarkMode ? AppColors.greyLight : AppColors.grey),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isDarkMode ? AppColors.greyLight : AppColors.grey,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getContentIcon(String type) {
    switch (type.toUpperCase()) {
      case 'VIDEO':
        return Icons.video_library;
      case 'IMAGE':
        return Icons.image;
      case 'TEXT':
        return Icons.text_fields;
      case 'PDF':
        return Icons.picture_as_pdf;
      case 'QUIZ':
        return Icons.quiz;
      default:
        return Icons.description;
    }
  }

  bool _isYouTubeUrl(String url) {
    return url.contains('youtube.com') || url.contains('youtu.be');
  }

  String? _extractYouTubeVideoId(String url) {
    // Extract video ID from various YouTube URL formats
    final patterns = [
      RegExp(r'(?:youtube\.com\/watch\?v=|youtu\.be\/|youtube\.com\/embed\/)([^&\n?#]+)'),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(url);
      if (match != null && match.groupCount >= 1) {
        return match.group(1);
      }
    }
    return null;
  }

  Future<void> _launchUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      
      // Try to launch URL with platform default (browser)
      // This will use the default browser or appropriate app
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.platformDefault,
      );
      
      if (!launched) {
        // If platform default fails, try external application
        final launchedExternal = await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
        
        if (!launchedExternal) {
    Get.snackbar(
            'Error',
            'Could not open URL: $url',
      snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.red.withOpacity(0.8),
      colorText: Colors.white,
            duration: const Duration(seconds: 3),
    );
        }
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to open URL: $e',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    }
  }
}

