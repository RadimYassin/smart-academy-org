// StudentProfiler Profile Request
class ProfilerProfileRequest {
  final String? dataPath;
  final int nClusters;

  ProfilerProfileRequest({
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

// StudentProfiler Profile Response
class ProfilerProfileResponse {
  final String status;
  final String message;
  final int totalStudents;
  final Map<String, int> clusters;
  final String outputPath;

  ProfilerProfileResponse({
    required this.status,
    required this.message,
    required this.totalStudents,
    required this.clusters,
    required this.outputPath,
  });

  factory ProfilerProfileResponse.fromJson(Map<String, dynamic> json) {
    return ProfilerProfileResponse(
      status: json['status'] as String,
      message: json['message'] as String,
      totalStudents: json['total_students'] as int,
      clusters: (json['clusters'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(key, value as int),
      ),
      outputPath: json['output_path'] as String,
    );
  }
}

// StudentProfiler Status Response
class ProfilerStatusResponse {
  final String service;
  final String status;
  final String description;
  final String algorithm;
  final List<String> capabilities;

  ProfilerStatusResponse({
    required this.service,
    required this.status,
    required this.description,
    required this.algorithm,
    required this.capabilities,
  });

  factory ProfilerStatusResponse.fromJson(Map<String, dynamic> json) {
    return ProfilerStatusResponse(
      service: json['service'] as String,
      status: json['status'] as String,
      description: json['description'] as String,
      algorithm: json['algorithm'] as String,
      capabilities: (json['capabilities'] as List).map((e) => e as String).toList(),
    );
  }
}
