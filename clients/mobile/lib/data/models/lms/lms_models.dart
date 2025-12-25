// ============================================================================
// LMS Data Synchronization Models
// ============================================================================

class LMSDataResponse {
  final String status;
  final String message;
  final int? recordsProcessed;
  final DateTime? timestamp;
  final Map<String, dynamic>? data;

  LMSDataResponse({
    required this.status,
    required this.message,
    this.recordsProcessed,
    this.timestamp,
    this.data,
  });

  factory LMSDataResponse.fromJson(Map<String, dynamic> json) {
    return LMSDataResponse(
      status: json['status'] as String? ?? 'unknown',
      message: json['message'] as String? ?? '',
      recordsProcessed: json['records_processed'] as int?,
      timestamp: json['timestamp'] != null 
          ? DateTime.parse(json['timestamp'] as String)
          : null,
      data: json,
    );
  }

  bool get isSuccess => status == 'success' || status == 'ok';
}

class AIStudentData {
  final int studentId;
  final String studentName;
  final Map<String, dynamic> performanceData;
  final List<CourseGrade> grades;
  final DateTime lastUpdated;

  AIStudentData({
    required this.studentId,
    required this.studentName,
    required this.performanceData,
    required this.grades,
    required this.lastUpdated,
  });

  factory AIStudentData.fromJson(Map<String, dynamic> json) {
    return AIStudentData(
      studentId: json['student_id'] as int,
      studentName: json['student_name'] as String,
      performanceData: Map<String, dynamic>.from(json['performance_data'] ?? {}),
      grades: (json['grades'] as List?)
          ?.map((g) => CourseGrade.fromJson(g))
          .toList() ?? [],
      lastUpdated: json['last_updated'] != null
          ? DateTime.parse(json['last_updated'] as String)
          : DateTime.now(),
    );
  }
}

class CourseGrade {
  final String courseId;
  final String courseName;
  final double grade;
  final double attendance;
  final double participation;

  CourseGrade({
    required this.courseId,
    required this.courseName,
    required this.grade,
    required this.attendance,
    required this.participation,
  });

  factory CourseGrade.fromJson(Map<String, dynamic> json) {
    return CourseGrade(
      courseId: json['course_id'] as String,
      courseName: json['course_name'] as String,
      grade: (json['grade'] as num).toDouble(),
      attendance: (json['attendance'] as num).toDouble(),
      participation: (json['participation'] as num).toDouble(),
    );
  }
}

class LMSStats {
  final int totalStudents;
  final int totalCourses;
  final int totalEnrollments;
  final int totalGrades;
  final DateTime lastSync;
  final Map<String, int>? breakdown;

  LMSStats({
    required this.totalStudents,
    required this.totalCourses,
    required this.totalEnrollments,
    required this.totalGrades,
    required this.lastSync,
    this.breakdown,
  });

  factory LMSStats.fromJson(Map<String, dynamic> json) {
    return LMSStats(
      totalStudents: json['total_students'] as int? ?? 0,
      totalCourses: json['total_courses'] as int? ?? 0,
      totalEnrollments: json['total_enrollments'] as int? ?? 0,
      totalGrades: json['total_grades'] as int? ?? 0,
      lastSync: json['last_sync'] != null
          ? DateTime.parse(json['last_sync'] as String)
          : DateTime.now(),
      breakdown: json['breakdown'] != null
          ? Map<String, int>.from(json['breakdown'])
          : null,
    );
  }
}

class SyncCourseResponse {
  final String courseId;
  final int studentsSync;
  final String status;
  final String message;

  SyncCourseResponse({
    required this.courseId,
    required this.studentsSync,
    required this.status,
    required this.message,
  });

  factory SyncCourseResponse.fromJson(Map<String, dynamic> json) {
    return SyncCourseResponse(
      courseId: json['course_id'] as String? ?? '',
      studentsSync: json['students_sync'] as int? ?? 0,
      status: json['status'] as String? ?? 'unknown',
      message: json['message'] as String? ?? '',
    );
  }

  bool get isSuccess => status == 'success';
}
