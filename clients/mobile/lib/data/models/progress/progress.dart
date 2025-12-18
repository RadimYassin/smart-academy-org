class LessonProgressResponse {
  final String lessonId;
  final String lessonTitle;
  final bool completed;
  final DateTime? completedAt;

  LessonProgressResponse({
    required this.lessonId,
    required this.lessonTitle,
    required this.completed,
    this.completedAt,
  });

  factory LessonProgressResponse.fromJson(Map<String, dynamic> json) {
    return LessonProgressResponse(
      lessonId: json['lessonId'] as String,
      lessonTitle: json['lessonTitle'] as String? ?? '',
      completed: json['completed'] as bool? ?? false,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lessonId': lessonId,
      'lessonTitle': lessonTitle,
      'completed': completed,
      if (completedAt != null) 'completedAt': completedAt!.toIso8601String(),
    };
  }
}

class CourseProgressResponse {
  final String courseId;
  final String courseTitle;
  final int totalLessons;
  final int completedLessons;
  final double completionRate;

  CourseProgressResponse({
    required this.courseId,
    required this.courseTitle,
    required this.totalLessons,
    required this.completedLessons,
    required this.completionRate,
  });

  factory CourseProgressResponse.fromJson(Map<String, dynamic> json) {
    return CourseProgressResponse(
      courseId: json['courseId'] as String,
      courseTitle: json['courseTitle'] as String? ?? '',
      totalLessons: json['totalLessons'] as int? ?? 0,
      completedLessons: json['completedLessons'] as int? ?? 0,
      completionRate: (json['completionRate'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'courseId': courseId,
      'courseTitle': courseTitle,
      'totalLessons': totalLessons,
      'completedLessons': completedLessons,
      'completionRate': completionRate,
    };
  }
}

