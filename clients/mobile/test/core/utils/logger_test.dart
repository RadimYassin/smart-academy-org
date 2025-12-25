// Unit tests for Logger utility

import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/utils/logger.dart';

void main() {
  group('Logger', () {
    // Note: Logger uses dart:developer which is difficult to test directly
    // These tests verify that the methods execute without throwing

    test('logInfo executes without throwing', () {
      expect(() => Logger.logInfo('Test info message'), returnsNormally);
    });

    test('logInfo with tag executes without throwing', () {
      expect(
        () => Logger.logInfo('Test info', tag: 'TestTag'),
        returnsNormally,
      );
    });

    test('logError executes without throwing', () {
      expect(() => Logger.logError('Test error message'), returnsNormally);
    });

    test('logError with all parameters executes without throwing', () {
      expect(
        () => Logger.logError(
          'Test error',
          tag: 'ErrorTag',
          error: Exception('Test exception'),
          stackTrace: StackTrace.current,
        ),
        returnsNormally,
      );
    });

    test('logDebug executes without throwing', () {
      expect(() => Logger.logDebug('Test debug message'), returnsNormally);
    });

    test('logDebug with tag executes without throwing', () {
      expect(
        () => Logger.logDebug('Test debug', tag: 'DebugTag'),
        returnsNormally,
      );
    });

    test('logWarning executes without throwing', () {
      expect(() => Logger.logWarning('Test warning message'), returnsNormally);
    });

    test('logWarning with tag executes without throwing', () {
      expect(
        () => Logger.logWarning('Test warning', tag: 'WarnTag'),
        returnsNormally,
      );
    });

    test('all log methods handle empty strings', () {
      expect(() => Logger.logInfo(''), returnsNormally);
      expect(() => Logger.logError(''), returnsNormally);
      expect(() => Logger.logDebug(''), returnsNormally);
      expect(() => Logger.logWarning(''), returnsNormally);
    });

    test('all log methods handle very long strings', () {
      final longMessage = 'A' * 1000;
      expect(() => Logger.logInfo(longMessage), returnsNormally);
      expect(() => Logger.logError(longMessage), returnsNormally);
      expect(() => Logger.logDebug(longMessage), returnsNormally);
      expect(() => Logger.logWarning(longMessage), returnsNormally);
    });
  });
}
