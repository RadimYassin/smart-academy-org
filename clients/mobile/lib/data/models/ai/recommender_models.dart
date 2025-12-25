// RecoBuilder Generate Recommendation Request
class RecommenderGenerateRequest {
  final List<int> studentIds;
  final String resourcesPath;

  RecommenderGenerateRequest({
    required this.studentIds,
    this.resourcesPath = "../data/resources/educational_resources.json",
  });

  Map<String, dynamic> toJson() {
    return {
      'student_ids': studentIds,
      'resources_path': resourcesPath,
    };
  }
}

// RecoBuilder Generate Recommendation Response
class RecommenderGenerateResponse {
  final String status;
  final String message;
  final int totalRecommendations;
  final String outputPath;

  RecommenderGenerateResponse({
    required this.status,
    required this.message,
    required this.totalRecommendations,
    required this.outputPath,
  });

  factory RecommenderGenerateResponse.fromJson(Map<String, dynamic> json) {
    return RecommenderGenerateResponse(
      status: json['status'] as String,
      message: json['message'] as String,
      totalRecommendations: json['total_recommendations'] as int,
      outputPath: json['output_path'] as String,
    );
  }
}

// RecoBuilder Status Response
class RecommenderStatusResponse {
  final String service;
  final String status;
  final String description;
  final List<String> technologies;
  final bool openaiConfigured;
  final List<String> capabilities;

  RecommenderStatusResponse({
    required this.service,
    required this.status,
    required this.description,
    required this.technologies,
    required this.openaiConfigured,
    required this.capabilities,
  });

  factory RecommenderStatusResponse.fromJson(Map<String, dynamic> json) {
    return RecommenderStatusResponse(
      service: json['service'] as String,
      status: json['status'] as String,
      description: json['description'] as String,
      technologies: (json['technologies'] as List).map((e) => e as String).toList(),
      openaiConfigured: json['openai_configured'] as bool,
      capabilities: (json['capabilities'] as List).map((e) => e as String).toList(),
    );
  }
}
