import 'module.dart';

class Course {
  final String id;
  final String title;
  final String description;
  final String category;
  final String level; // 'BEGINNER' | 'INTERMEDIATE' | 'ADVANCED'
  final String thumbnailUrl;
  final int teacherId;
  final List<Module>? modules;
  final DateTime createdAt;
  final DateTime updatedAt;

  Course({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.level,
    required this.thumbnailUrl,
    required this.teacherId,
    this.modules,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      category: json['category'] as String,
      level: json['level'] as String,
      thumbnailUrl: json['thumbnailUrl'] as String? ?? '',
      teacherId: json['teacherId'] as int,
      modules: json['modules'] != null
          ? (json['modules'] as List).map((m) => Module.fromJson(m)).toList()
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'level': level,
      'thumbnailUrl': thumbnailUrl,
      'teacherId': teacherId,
      if (modules != null) 'modules': modules!.map((m) => m.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class CreateCourseRequest {
  final String title;
  final String description;
  final String category;
  final String level; // 'BEGINNER' | 'INTERMEDIATE' | 'ADVANCED'
  final String? thumbnailUrl;

  CreateCourseRequest({
    required this.title,
    required this.description,
    required this.category,
    required this.level,
    this.thumbnailUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'category': category,
      'level': level,
      if (thumbnailUrl != null) 'thumbnailUrl': thumbnailUrl,
    };
  }
}

