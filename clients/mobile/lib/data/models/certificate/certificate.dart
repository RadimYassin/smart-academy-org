class Certificate {
  final String certificateId;
  final int studentId;
  final String courseId;
  final String verificationCode;
  final DateTime issueDate;
  final String? studentName;
  final String? courseName;

  Certificate({
    required this.certificateId,
    required this.studentId,
    required this.courseId,
    required this.verificationCode,
    required this.issueDate,
    this.studentName,
    this.courseName,
  });

  factory Certificate.fromJson(Map<String, dynamic> json) {
    return Certificate(
      certificateId: json['certificateId'] as String,
      studentId: json['studentId'] as int,
      courseId: json['courseId'] as String,
      verificationCode: json['verificationCode'] as String,
      issueDate: DateTime.parse(json['issueDate'] as String),
      studentName: json['studentName'] as String?,
      courseName: json['courseName'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'certificateId': certificateId,
      'studentId': studentId,
      'courseId': courseId,
      'verificationCode': verificationCode,
      'issueDate': issueDate.toIso8601String(),
      if (studentName != null) 'studentName': studentName,
      if (courseName != null) 'courseName': courseName,
    };
  }
}

class CertificateEligibility {
  final bool eligible;
  final double completionPercentage;
  final bool quizzesPassed;
  final String message;

  CertificateEligibility({
    required this.eligible,
    required this.completionPercentage,
    required this.quizzesPassed,
    required this.message,
  });

  factory CertificateEligibility.fromJson(Map<String, dynamic> json) {
    return CertificateEligibility(
      eligible: json['eligible'] as bool,
      completionPercentage: (json['completionPercentage'] as num).toDouble(),
      quizzesPassed: json['quizzesPassed'] as bool,
      message: json['message'] as String,
    );
  }
}

class CertificateVerification {
  final bool valid;
  final String studentName;
  final String courseName;
  final String issueDate;

  CertificateVerification({
    required this.valid,
    required this.studentName,
    required this.courseName,
    required this.issueDate,
  });

  factory CertificateVerification.fromJson(Map<String, dynamic> json) {
    return CertificateVerification(
      valid: json['valid'] as bool,
      studentName: json['studentName'] as String,
      courseName: json['courseName'] as String,
      issueDate: json['issueDate'] as String,
    );
  }
}
