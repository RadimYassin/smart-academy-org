// Unit tests for AppConfig

import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/config/app_config.dart';

void main() {
  group('AppConfig', () {
    group('Environment enum', () {
      test('has all required values', () {
        expect(Environment.values.length, equals(3));
        expect(Environment.values, contains(Environment.development));
        expect(Environment.values, contains(Environment.staging));
        expect(Environment.values, contains(Environment.production));
      });
    });

    group('initialization', () {
      test('can initialize with development environment', () {
        AppConfig.initialize(
          environment: Environment.development,
          apiUrl: 'http://localhost:8888',
        );

        final config = AppConfig();
        expect(config.environment, equals(Environment.development));
        expect(config.apiUrl, equals('http://localhost:8888'));
        expect(config.enableLogging, isTrue);
      });

      test('can initialize with staging environment', () {
        AppConfig.initialize(
          environment: Environment.staging,
          apiUrl: 'https://staging.api.com',
          enableLogging: false,
        );

        final config = AppConfig();
        expect(config.environment, equals(Environment.staging));
        expect(config.apiUrl, equals('https://staging.api.com'));
        expect(config.enableLogging, isFalse);
      });

      test('can initialize with production environment', () {
        AppConfig.initialize(
          environment: Environment.production,
          apiUrl: 'https://api.smart-academy.com',
          enableLogging: false,
        );

        final config = AppConfig();
        expect(config.environment, equals(Environment.production));
        expect(config.apiUrl, equals('https://api.smart-academy.com'));
        expect(config.enableLogging, isFalse);
      });
    });

    group('environment helpers', () {
      test('isDevelopment returns true for development environment', () {
        AppConfig.initialize(
          environment: Environment.development,
          apiUrl: 'http://localhost:8888',
        );

        final config = AppConfig();
        expect(config.isDevelopment, isTrue);
        expect(config.isStaging, isFalse);
        expect(config.isProduction, isFalse);
      });

      test('isStaging returns true for staging environment', () {
        AppConfig.initialize(
          environment: Environment.staging,
          apiUrl: 'https://staging.api.com',
        );

        final config = AppConfig();
        expect(config.isDevelopment, isFalse);
        expect(config.isStaging, isTrue);
        expect(config.isProduction, isFalse);
      });

      test('isProduction returns true for production environment', () {
        AppConfig.initialize(
          environment: Environment.production,
          apiUrl: 'https://api.smart-academy.com',
        );

        final config = AppConfig();
        expect(config.isDevelopment, isFalse);
        expect(config.isStaging, isFalse);
        expect(config.isProduction, isTrue);
      });
    });

    group('toString', () {
      test('provides meaningful string representation', () {
        AppConfig.initialize(
          environment: Environment.development,
          apiUrl: 'http://localhost:8888',
        );

        final config = AppConfig();
        final string = config.toString();

        expect(string, contains('AppConfig'));
        expect(string, contains('development'));
        expect(string, contains('http://localhost:8888'));
      });
    });

    group('singleton behavior', () {
      test('returns same instance after initialization', () {
        AppConfig.initialize(
          environment: Environment.development,
          apiUrl: 'http://localhost:8888',
        );

        final config1 = AppConfig();
        final config2 = AppConfig();

        expect(identical(config1, config2), isTrue);
      });
    });
  });
}
