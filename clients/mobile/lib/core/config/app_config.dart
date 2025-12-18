enum Environment { development, staging, production }

class AppConfig {
  static late AppConfig _instance;

  final Environment environment;
  final String apiUrl;
  final bool enableLogging;

  AppConfig._({
    required this.environment,
    required this.apiUrl,
    required this.enableLogging,
  });

  factory AppConfig() => _instance;

  static void initialize({
    required Environment environment,
    required String apiUrl,
    bool enableLogging = true,
  }) {
    _instance = AppConfig._(
      environment: environment,
      apiUrl: apiUrl,
      enableLogging: enableLogging,
    );
  }

  bool get isProduction => environment == Environment.production;
  bool get isDevelopment => environment == Environment.development;
  bool get isStaging => environment == Environment.staging;

  @override
  String toString() => 'AppConfig(environment: $environment, apiUrl: $apiUrl)';
}

// Global configuration
final appConfig = AppConfig();

