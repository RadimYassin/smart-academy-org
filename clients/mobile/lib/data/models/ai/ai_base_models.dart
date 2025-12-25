class AIHealthResponse {
  final String status;
  final String service;
  final int port;

  AIHealthResponse({
    required this.status,
    required this.service,
    required this.port,
  });

  factory AIHealthResponse.fromJson(Map<String, dynamic> json) {
    return AIHealthResponse(
      status: json['status'] as String,
      service: json['service'] as String,
      port: json['port'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'service': service,
      'port': port,
    };
  }
}

class AIInfoResponse {
  final String app;
  final String version;
  final String description;
  final List<String> services;

  AIInfoResponse({
    required this.app,
    required this.version,
    required this.description,
    required this.services,
  });

  factory AIInfoResponse.fromJson(Map<String, dynamic> json) {
    return AIInfoResponse(
      app: json['app'] as String,
      version: json['version'] as String,
      description: json['description'] as String,
      services: (json['services'] as List).map((e) => e as String).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'app': app,
      'version': version,
      'description': description,
      'services': services,
    };
  }
}
