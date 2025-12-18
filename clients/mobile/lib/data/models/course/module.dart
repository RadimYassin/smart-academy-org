import 'lesson.dart' show Lesson;

class Module {
  final String id;
  final String courseId;
  final String title;
  final String? description;
  final int orderIndex;
  final List<Lesson>? lessons;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Module({
    required this.id,
    required this.courseId,
    required this.title,
    this.description,
    required this.orderIndex,
    this.lessons,
    this.createdAt,
    this.updatedAt,
  });

  factory Module.fromJson(Map<String, dynamic> json) {
    return Module(
      id: json['id'] as String,
      courseId: json['courseId'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      orderIndex: json['orderIndex'] as int,
      lessons: json['lessons'] != null
          ? (json['lessons'] as List).map((l) => Lesson.fromJson(l)).toList()
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'courseId': courseId,
      'title': title,
      if (description != null) 'description': description,
      'orderIndex': orderIndex,
      if (lessons != null) 'lessons': lessons!.map((l) => l.toJson()).toList(),
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }
}

class CreateModuleRequest {
  final String title;
  final String? description;
  final int orderIndex;

  CreateModuleRequest({
    required this.title,
    this.description,
    required this.orderIndex,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      if (description != null) 'description': description,
      'orderIndex': orderIndex,
    };
  }
}

