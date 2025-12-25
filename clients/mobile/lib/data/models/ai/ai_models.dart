// ============================================================================
// Student Performance Prediction Models
// ============================================================================

class PredictionRequest {
  final Map<String, dynamic> studentData;

  PredictionRequest({required this.studentData});

  Map<String, dynamic> toJson() {
    return {'student_data': studentData};
  }
}

class PredictionResponse {
  final int studentId;
  final String prediction; // "Success" or "Fail"
  final double probabilityFail;
  final double probabilitySuccess;
  final String riskLevel; // "Low", "Medium", "High"

  PredictionResponse({
    required this.studentId,
    required this.prediction,
    required this.probabilityFail,
    required this.probabilitySuccess,
    required this.riskLevel,
  });

  factory PredictionResponse.fromJson(Map<String, dynamic> json) {
    return PredictionResponse(
      studentId: json['student_id'] as int,
      prediction: json['prediction'] as String,
      probabilityFail: (json['probability_fail'] as num).toDouble(),
      probabilitySuccess: (json['probability_success'] as num).toDouble(),
      riskLevel: json['risk_level'] as String,
    );
  }

  bool get isAtRisk => riskLevel == 'High' || riskLevel == 'Medium';
  bool get willFail => prediction == 'Fail';
}

// ============================================================================
// Student Profiling/Clustering Models
// ============================================================================

class ProfileRequest {
  final String? dataPath;
  final int nClusters;

  ProfileRequest({
    this.dataPath,
    this.nClusters = 4,
  });

  Map<String, dynamic> toJson() {
    return {
      'data_path': dataPath,
      'n_clusters': nClusters,
    };
  }
}

class ProfileResponse {
  final String status;
  final String message;
  final int totalStudents;
  final Map<int, int> clusters; // cluster_id: count
  final String outputPath;

  ProfileResponse({
    required this.status,
    required this.message,
    required this.totalStudents,
    required this.clusters,
    required this.outputPath,
  });

  factory ProfileResponse.fromJson(Map<String, dynamic> json) {
    return ProfileResponse(
      status: json['status'] as String,
      message: json['message'] as String,
      totalStudents: json['total_students'] as int,
      clusters: Map<int, int>.from(json['clusters']),
      outputPath: json['output_path'] as String,
    );
  }
}

// ============================================================================
// Data Preparation Models
// ============================================================================

class PrepDataResponse {
  final String status;
  final String message;
  final int recordsProcessed;
  final String outputPath;

  PrepDataResponse({
    required this.status,
    required this.message,
    required this.recordsProcessed,
    required this.outputPath,
  });

  factory PrepDataResponse.fromJson(Map<String, dynamic> json) {
    return PrepDataResponse(
      status: json['status'] as String,
      message: json['message'] as String,
      recordsProcessed: json['records_processed'] as int,
      outputPath: json['output_path'] as String,
    );
  }
}

// ============================================================================
// Recommendation Models
// ============================================================================

class RecommendationRequest {
  final List<int> studentIds;
  final String? resourcesPath;

  RecommendationRequest({
    required this.studentIds,
    this.resourcesPath,
  });

  Map<String, dynamic> toJson() {
    return {
      'student_ids': studentIds,
      if (resourcesPath != null) 'resources_path': resourcesPath,
    };
  }
}

class RecommendationResponse {
  final String status;
  final String message;
  final int totalRecommendations;
  final String outputPath;

  RecommendationResponse({
    required this.status,
    required this.message,
    required this.totalRecommendations,
    required this.outputPath,
  });

  factory RecommendationResponse.fromJson(Map<String, dynamic> json) {
    return RecommendationResponse(
      status: json['status'] as String,
      message: json['message'] as String,
      totalRecommendations: json['total_recommendations'] as int,
      outputPath: json['output_path'] as String,
    );
  }
}

class Recommendation {
  final int studentId;
  final String studentName;
  final String riskLevel;
  final List<String> resources;
  final String actionPlan;

  Recommendation({
    required this.studentId,
    required this.studentName,
    required this.riskLevel,
    required this.resources,
    required this.actionPlan,
  });

  factory Recommendation.fromJson(Map<String, dynamic> json) {
    return Recommendation(
      studentId: json['student_id'] as int,
      studentName: json['student_name'] as String,
      riskLevel: json['risk_level'] as String,
      resources: List<String>.from(json['resources'] ?? []),
      actionPlan: json['action_plan'] as String,
    );
  }
}

// ============================================================================
// Service Status Models
// ============================================================================

class AIServiceStatus {
  final String service;
  final String status;
  final String description;
  final List<String> capabilities;
  final Map<String, dynamic>? additionalInfo;

  AIServiceStatus({
    required this.service,
    required this.status,
    required this.description,
    required this.capabilities,
    this.additionalInfo,
  });

  factory AIServiceStatus.fromJson(Map<String, dynamic> json) {
    return AIServiceStatus(
      service: json['service'] as String,
      status: json['status'] as String,
      description: json['description'] as String,
      capabilities: List<String>.from(json['capabilities'] ?? []),
      additionalInfo: json,
    );
  }

  bool get isUp => status == 'UP';
}

// ============================================================================
// Model Training Models
// ============================================================================

class TrainRequest {
  final String? dataPath;
  final bool useGridSearch;

  TrainRequest({
    this.dataPath,
    this.useGridSearch = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'data_path': dataPath,
      'use_grid_search': useGridSearch,
    };
  }
}

class TrainResponse {
  final String status;
  final String message;
  final double accuracy;
  final String modelPath;

  TrainResponse({
    required this.status,
    required this.message,
    required this.accuracy,
    required this.modelPath,
  });

  factory TrainResponse.fromJson(Map<String, dynamic> json) {
    return TrainResponse(
      status: json['status'] as String,
      message: json['message'] as String,
      accuracy: (json['accuracy'] as num).toDouble(),
      modelPath: json['model_path'] as String,
    );
  }

  String get accuracyPercentage => '${(accuracy * 100).toStringAsFixed(2)}%';
}
