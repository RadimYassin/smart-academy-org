class Enrollment {
  final String id;
  final String courseId;
  final String? courseTitle;
  final int? studentId;
  final String? studentFirstName;
  final String? studentLastName;
  final String? classId;
  final String? className;
  final int assignedBy;
  final String assignmentType; // 'INDIVIDUAL' | 'CLASS'
  final DateTime enrolledAt;

  Enrollment({
    required this.id,
    required this.courseId,
    this.courseTitle,
    this.studentId,
    this.studentFirstName,
    this.studentLastName,
    this.classId,
    this.className,
    required this.assignedBy,
    required this.assignmentType,
    required this.enrolledAt,
  });

  factory Enrollment.fromJson(Map<String, dynamic> json) {
    return Enrollment(
      id: json['id'] as String,
      courseId: json['courseId'] as String,
      courseTitle: json['courseTitle'] as String?,
      studentId: json['studentId'] as int?,
      studentFirstName: json['studentFirstName'] as String?,
      studentLastName: json['studentLastName'] as String?,
      classId: json['classId'] as String?,
      className: json['className'] as String?,
      assignedBy: json['assignedBy'] as int,
      assignmentType: json['assignmentType'] as String,
      enrolledAt: DateTime.parse(json['enrolledAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'courseId': courseId,
      if (courseTitle != null) 'courseTitle': courseTitle,
      if (studentId != null) 'studentId': studentId,
      if (studentFirstName != null) 'studentFirstName': studentFirstName,
      if (studentLastName != null) 'studentLastName': studentLastName,
      if (classId != null) 'classId': classId,
      if (className != null) 'className': className,
      'assignedBy': assignedBy,
      'assignmentType': assignmentType,
      'enrolledAt': enrolledAt.toIso8601String(),
    };
  }
}

class AssignStudentRequest {
  final String courseId;
  final int studentId;

  AssignStudentRequest({
    required this.courseId,
    required this.studentId,
  });

  Map<String, dynamic> toJson() {
    return {
      'courseId': courseId,
      'studentId': studentId,
    };
  }
}

class AssignClassRequest {
  final String courseId;
  final String classId;

  AssignClassRequest({
    required this.courseId,
    required this.classId,
  });

  Map<String, dynamic> toJson() {
    return {
      'courseId': courseId,
      'classId': classId,
    };
  }
}

