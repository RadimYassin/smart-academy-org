import 'lesson_content.dart' show LessonContent;

class Lesson {
  final String id;
  final String moduleId;
  final String title;
  final String? summary;
  final int orderIndex;
  final List<LessonContent>? contents;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Lesson({
    required this.id,
    required this.moduleId,
    required this.title,
    this.summary,
    required this.orderIndex,
    this.contents,
    this.createdAt,
    this.updatedAt,
  });

  factory Lesson.fromJson(Map<String, dynamic> json) {
    return Lesson(
      id: json['id'] as String,
      moduleId: json['moduleId'] as String,
      title: json['title'] as String,
      summary: json['summary'] as String?,
      orderIndex: json['orderIndex'] as int,
      contents: json['contents'] != null
          ? (json['contents'] as List)
              .map((c) => LessonContent.fromJson(c))
              .toList()
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
      'moduleId': moduleId,
      'title': title,
      if (summary != null) 'summary': summary,
      'orderIndex': orderIndex,
      if (contents != null)
        'contents': contents!.map((c) => c.toJson()).toList(),
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }
}

class CreateLessonRequest {
  final String title;
  final String? summary;
  final int orderIndex;

  CreateLessonRequest({
    required this.title,
    this.summary,
    required this.orderIndex,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      if (summary != null) 'summary': summary,
      'orderIndex': orderIndex,
    };
  }
}

