class StudentClass {
  final String id;
  final String name;
  final String? description;
  final int teacherId;
  final int studentCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  StudentClass({
    required this.id,
    required this.name,
    this.description,
    required this.teacherId,
    required this.studentCount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory StudentClass.fromJson(Map<String, dynamic> json) {
    return StudentClass(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      teacherId: json['teacherId'] as int,
      studentCount: json['studentCount'] as int? ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'teacherId': teacherId,
      'studentCount': studentCount,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class CreateClassRequest {
  final String name;
  final String? description;

  CreateClassRequest({
    required this.name,
    this.description,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      if (description != null) 'description': description,
    };
  }
}

class ClassStudent {
  final int studentId;
  final int addedBy;
  final DateTime addedAt;

  ClassStudent({
    required this.studentId,
    required this.addedBy,
    required this.addedAt,
  });

  factory ClassStudent.fromJson(Map<String, dynamic> json) {
    return ClassStudent(
      studentId: json['studentId'] as int,
      addedBy: json['addedBy'] as int,
      addedAt: DateTime.parse(json['addedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'studentId': studentId,
      'addedBy': addedBy,
      'addedAt': addedAt.toIso8601String(),
    };
  }
}

class AddStudentsRequest {
  final List<int> studentIds;

  AddStudentsRequest({
    required this.studentIds,
  });

  Map<String, dynamic> toJson() {
    return {
      'studentIds': studentIds,
    };
  }
}

