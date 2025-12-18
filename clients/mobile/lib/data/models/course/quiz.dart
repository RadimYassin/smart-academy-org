import 'question.dart' show Question;

class Quiz {
  final String id;
  final String courseId;
  final String title;
  final String? description;
  final String? difficulty; // 'EASY' | 'MEDIUM' | 'HARD'
  final int? passingScore;
  final bool? mandatory;
  final List<Question>? questions;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Quiz({
    required this.id,
    required this.courseId,
    required this.title,
    this.description,
    this.difficulty,
    this.passingScore,
    this.mandatory,
    this.questions,
    this.createdAt,
    this.updatedAt,
  });

  factory Quiz.fromJson(Map<String, dynamic> json) {
    return Quiz(
      id: json['id'] as String,
      courseId: json['courseId'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      difficulty: json['difficulty'] as String?,
      passingScore: json['passingScore'] as int?,
      mandatory: json['mandatory'] as bool?,
      questions: json['questions'] != null
          ? (json['questions'] as List).map((q) => Question.fromJson(q)).toList()
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
      if (difficulty != null) 'difficulty': difficulty,
      if (passingScore != null) 'passingScore': passingScore,
      if (mandatory != null) 'mandatory': mandatory,
      if (questions != null) 'questions': questions!.map((q) => q.toJson()).toList(),
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }
}

class CreateQuizRequest {
  final String title;
  final String? description;
  final String? difficulty; // 'EASY' | 'MEDIUM' | 'HARD'
  final int? passingScore;
  final bool? mandatory;

  CreateQuizRequest({
    required this.title,
    this.description,
    this.difficulty,
    this.passingScore,
    this.mandatory,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      if (description != null) 'description': description,
      if (difficulty != null) 'difficulty': difficulty,
      if (passingScore != null) 'passingScore': passingScore,
      if (mandatory != null) 'mandatory': mandatory,
    };
  }
}

