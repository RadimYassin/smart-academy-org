class LessonContent {
  final String id;
  final String lessonId;
  final String type; // 'PDF' | 'TEXT' | 'VIDEO' | 'IMAGE' | 'QUIZ'
  final String? textContent;
  final String? pdfUrl;
  final String? videoUrl;
  final String? imageUrl;
  final String? quizId;
  final int orderIndex;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  LessonContent({
    required this.id,
    required this.lessonId,
    required this.type,
    this.textContent,
    this.pdfUrl,
    this.videoUrl,
    this.imageUrl,
    this.quizId,
    required this.orderIndex,
    this.createdAt,
    this.updatedAt,
  });

  factory LessonContent.fromJson(Map<String, dynamic> json) {
    return LessonContent(
      id: json['id'] as String,
      lessonId: json['lessonId'] as String,
      type: json['type'] as String,
      textContent: json['textContent'] as String?,
      pdfUrl: json['pdfUrl'] as String?,
      videoUrl: json['videoUrl'] as String?,
      imageUrl: json['imageUrl'] as String?,
      quizId: json['quizId'] as String?,
      orderIndex: json['orderIndex'] as int,
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
      'lessonId': lessonId,
      'type': type,
      if (textContent != null) 'textContent': textContent,
      if (pdfUrl != null) 'pdfUrl': pdfUrl,
      if (videoUrl != null) 'videoUrl': videoUrl,
      if (imageUrl != null) 'imageUrl': imageUrl,
      if (quizId != null) 'quizId': quizId,
      'orderIndex': orderIndex,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }
}

class CreateLessonContentRequest {
  final String type; // 'PDF' | 'TEXT' | 'VIDEO' | 'IMAGE' | 'QUIZ'
  final String? textContent;
  final String? pdfUrl;
  final String? videoUrl;
  final String? imageUrl;
  final String? quizId;
  final int orderIndex;

  CreateLessonContentRequest({
    required this.type,
    this.textContent,
    this.pdfUrl,
    this.videoUrl,
    this.imageUrl,
    this.quizId,
    required this.orderIndex,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      if (textContent != null) 'textContent': textContent,
      if (pdfUrl != null) 'pdfUrl': pdfUrl,
      if (videoUrl != null) 'videoUrl': videoUrl,
      if (imageUrl != null) 'imageUrl': imageUrl,
      if (quizId != null) 'quizId': quizId,
      'orderIndex': orderIndex,
    };
  }
}

