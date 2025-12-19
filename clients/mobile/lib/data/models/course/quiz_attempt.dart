class QuizAttempt {
  final String id;
  final String quizId;
  final String quizTitle;
  final int studentId;
  final int score;
  final int maxScore;
  final double percentage;
  final bool passed;
  final DateTime startedAt;
  final DateTime? submittedAt;
  final List<AnswerDetail>? answers;

  QuizAttempt({
    required this.id,
    required this.quizId,
    required this.quizTitle,
    required this.studentId,
    required this.score,
    required this.maxScore,
    required this.percentage,
    required this.passed,
    required this.startedAt,
    this.submittedAt,
    this.answers,
  });

  factory QuizAttempt.fromJson(Map<String, dynamic> json) {
    return QuizAttempt(
      id: json['id'] as String,
      quizId: json['quizId'] as String,
      quizTitle: json['quizTitle'] as String,
      studentId: json['studentId'] as int,
      score: json['score'] as int,
      maxScore: json['maxScore'] as int,
      percentage: (json['percentage'] as num).toDouble(),
      passed: json['passed'] as bool,
      startedAt: DateTime.parse(json['startedAt'] as String),
      submittedAt: json['submittedAt'] != null
          ? DateTime.parse(json['submittedAt'] as String)
          : null,
      answers: json['answers'] != null
          ? (json['answers'] as List)
              .map((a) => AnswerDetail.fromJson(a as Map<String, dynamic>))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'quizId': quizId,
      'quizTitle': quizTitle,
      'studentId': studentId,
      'score': score,
      'maxScore': maxScore,
      'percentage': percentage,
      'passed': passed,
      'startedAt': startedAt.toIso8601String(),
      if (submittedAt != null) 'submittedAt': submittedAt!.toIso8601String(),
      if (answers != null) 'answers': answers!.map((a) => a.toJson()).toList(),
    };
  }
}

class AnswerDetail {
  final String questionId;
  final String questionContent;
  final String selectedOptionId;
  final String correctOptionId;
  final bool isCorrect;

  AnswerDetail({
    required this.questionId,
    required this.questionContent,
    required this.selectedOptionId,
    required this.correctOptionId,
    required this.isCorrect,
  });

  factory AnswerDetail.fromJson(Map<String, dynamic> json) {
    return AnswerDetail(
      questionId: json['questionId'] as String,
      questionContent: json['questionContent'] as String,
      selectedOptionId: json['selectedOptionId'] as String,
      correctOptionId: json['correctOptionId'] as String,
      isCorrect: json['isCorrect'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'questionId': questionId,
      'questionContent': questionContent,
      'selectedOptionId': selectedOptionId,
      'correctOptionId': correctOptionId,
      'isCorrect': isCorrect,
    };
  }
}

class SubmitQuizAttemptRequest {
  final List<AnswerSubmission> answers;

  SubmitQuizAttemptRequest({required this.answers});

  Map<String, dynamic> toJson() {
    return {
      'answers': answers.map((a) => a.toJson()).toList(),
    };
  }
}

class AnswerSubmission {
  final String questionId;
  final String selectedOptionId;

  AnswerSubmission({
    required this.questionId,
    required this.selectedOptionId,
  });

  Map<String, dynamic> toJson() {
    return {
      'questionId': questionId,
      'selectedOptionId': selectedOptionId,
    };
  }
}

