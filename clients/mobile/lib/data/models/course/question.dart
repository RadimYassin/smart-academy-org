class Question {
  final String id;
  final String quizId;
  final String questionText;
  final String questionType;
  final int? points;
  final List<QuestionOption>? options;

  Question({
    required this.id,
    required this.quizId,
    required this.questionText,
    required this.questionType,
    this.points,
    this.options,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'] as String,
      quizId: json['quizId'] as String,
      questionText: json['questionText'] as String,
      questionType: json['questionType'] as String,
      points: json['points'] as int?,
      options: json['options'] != null
          ? (json['options'] as List)
              .map((o) => QuestionOption.fromJson(o))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'quizId': quizId,
      'questionText': questionText,
      'questionType': questionType,
      if (points != null) 'points': points,
      if (options != null) 'options': options!.map((o) => o.toJson()).toList(),
    };
  }
}

class QuestionOption {
  final String id;
  final String questionId;
  final String optionText;
  final bool isCorrect;
  final int? optionOrder;

  QuestionOption({
    required this.id,
    required this.questionId,
    required this.optionText,
    required this.isCorrect,
    this.optionOrder,
  });

  factory QuestionOption.fromJson(Map<String, dynamic> json) {
    return QuestionOption(
      id: json['id'] as String,
      questionId: json['questionId'] as String,
      optionText: json['optionText'] as String,
      isCorrect: json['isCorrect'] as bool,
      optionOrder: json['optionOrder'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'questionId': questionId,
      'optionText': optionText,
      'isCorrect': isCorrect,
      if (optionOrder != null) 'optionOrder': optionOrder,
    };
  }
}

class CreateQuestionRequest {
  final String questionText;
  final String questionType;
  final int? points;
  final List<CreateQuestionOptionRequest>? options;

  CreateQuestionRequest({
    required this.questionText,
    required this.questionType,
    this.points,
    this.options,
  });

  Map<String, dynamic> toJson() {
    return {
      'questionText': questionText,
      'questionType': questionType,
      if (points != null) 'points': points,
      if (options != null)
        'options': options!.map((o) => o.toJson()).toList(),
    };
  }
}

class CreateQuestionOptionRequest {
  final String optionText;
  final bool isCorrect;
  final int? optionOrder;

  CreateQuestionOptionRequest({
    required this.optionText,
    required this.isCorrect,
    this.optionOrder,
  });

  Map<String, dynamic> toJson() {
    return {
      'optionText': optionText,
      'isCorrect': isCorrect,
      if (optionOrder != null) 'optionOrder': optionOrder,
    };
  }
}

