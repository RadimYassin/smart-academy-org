// PrepaData Status Response
class PrepaDataStatusResponse {
  final String service;
  final String status;
  final String description;
  final List<String> capabilities;

  PrepaDataStatusResponse({
    required this.service,
    required this.status,
    required this.description,
    required this.capabilities,
  });

  factory PrepaDataStatusResponse.fromJson(Map<String, dynamic> json) {
    return PrepaDataStatusResponse(
      service: json['service'] as String,
      status: json['status'] as String,
      description: json['description'] as String,
      capabilities: (json['capabilities'] as List).map((e) => e as String).toList(),
    );
  }
}

// PrepaData Clean Request
class PrepaDataCleanRequest {
  final double threshold;

  PrepaDataCleanRequest({
    this.threshold = 50.0,
  });

  Map<String, dynamic> toJson() {
    return {
      'threshold': threshold,
    };
  }
}

// PrepaData Clean Response
class PrepaDataCleanResponse {
  final String status;
  final String message;
  final int recordsProcessed;
  final String outputPath;

  PrepaDataCleanResponse({
    required this.status,
    required this.message,
    required this.recordsProcessed,
    required this.outputPath,
  });

  factory PrepaDataCleanResponse.fromJson(Map<String, dynamic> json) {
    return PrepaDataCleanResponse(
      status: json['status'] as String,
      message: json['message'] as String,
      recordsProcessed: json['records_processed'] as int,
      outputPath: json['output_path'] as String,
    );
  }
}
