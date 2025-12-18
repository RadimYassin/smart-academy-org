import 'dart:developer' as developer;

class Logger {
  static void logInfo(String message, {String? tag}) {
    developer.log(
      message,
      name: tag ?? 'App',
      level: 500,
    );
  }

  static void logError(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    developer.log(
      message,
      name: tag ?? 'App',
      level: 1000,
      error: error,
      stackTrace: stackTrace,
    );
  }

  static void logDebug(String message, {String? tag}) {
    developer.log(
      message,
      name: tag ?? 'App',
      level: 300,
    );
  }

  static void logWarning(String message, {String? tag}) {
    developer.log(
      message,
      name: tag ?? 'App',
      level: 900,
    );
  }
}

