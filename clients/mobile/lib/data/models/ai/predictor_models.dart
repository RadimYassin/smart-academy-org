// PathPredictor Train Request
class PredictorTrainRequest {
  final String? dataPath;
  final bool useGridSearch;

  PredictorTrainRequest({
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

// PathPredictor Train Response
class PredictorTrainResponse {
  final String status;
  final String message;
  final double accuracy;
  final String modelPath;

  PredictorTrainResponse({
    required this.status,
    required this.message,
    required this.accuracy,
    required this.modelPath,
  });

  factory PredictorTrainResponse.fromJson(Map<String, dynamic> json) {
    return PredictorTrainResponse(
      status: json['status'] as String,
      message: json['message'] as String,
      accuracy: (json['accuracy'] as num).toDouble(),
      modelPath: json['model_path'] as String,
    );
  }
}

// PathPredictor Predict Request
class PredictorPredictRequest {
  final Map<String, dynamic> studentData;

  PredictorPredictRequest({
    required this.studentData,
  });

  Map<String, dynamic> toJson() {
    return {
      'student_data': studentData,
    };
  }
}

// PathPredictor Predict Response
class PredictorPredictResponse {
  final int studentId;
  final String prediction;
  final double probabilityFail;
  final double probabilitySuccess;
  final String riskLevel;

  PredictorPredictResponse({
    required this.studentId,
    required this.prediction,
    required this.probabilityFail,
    required this.probabilitySuccess,
    required this.riskLevel,
  });

  factory PredictorPredictResponse.fromJson(Map<String, dynamic> json) {
    return PredictorPredictResponse(
      studentId: json['student_id'] as int,
      prediction: json['prediction'] as String,
      probabilityFail: (json['probability_fail'] as num).toDouble(),
      probabilitySuccess: (json['probability_success'] as num).toDouble(),
      riskLevel: json['risk_level'] as String,
    );
  }
}

// PathPredictor Status Response
class PredictorStatusResponse {
  final String service;
  final String status;
  final String description;
  final String algorithm;
  final bool modelTrained;
  final String accuracy;
  final List<String> capabilities;

  PredictorStatusResponse({
    required this.service,
    required this.status,
    required this.description,
    required this.algorithm,
    required this.modelTrained,
    required this.accuracy,
    required this.capabilities,
  });

  factory PredictorStatusResponse.fromJson(Map<String, dynamic> json) {
    return PredictorStatusResponse(
      service: json['service'] as String,
      status: json['status'] as String,
      description: json['description'] as String,
      algorithm: json['algorithm'] as String,
      modelTrained: json['model_trained'] as bool,
      accuracy: json['accuracy'] as String,
      capabilities: (json['capabilities'] as List).map((e) => e as String).toList(),
    );
  }
}
