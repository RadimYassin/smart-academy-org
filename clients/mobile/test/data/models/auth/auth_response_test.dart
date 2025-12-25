// Unit tests for AuthResponse model

import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/data/models/auth/auth_response.dart';

void main() {
  group('AuthResponse', () {
    const jsonSnakeCase = {
      'access_token': 'test_access_token',
      'refresh_token': 'test_refresh_token',
      'email': 'test@example.com',
      'first_name': 'John',
      'last_name': 'Doe',
      'role': 'STUDENT',
      'is_verified': true,
    };

    const jsonCamelCase = {
      'accessToken': 'test_access_token',
      'refreshToken': 'test_refresh_token',
      'email': 'test@example.com',
      'firstName': 'John',
      'lastName': 'Doe',
      'role': 'STUDENT',
      'isVerified': true,
    };

    test('fromJson creates correct instance from snake_case JSON', () {
      final authResponse = AuthResponse.fromJson(jsonSnakeCase);

      expect(authResponse.accessToken, equals('test_access_token'));
      expect(authResponse.refreshToken, equals('test_refresh_token'));
      expect(authResponse.email, equals('test@example.com'));
      expect(authResponse.firstName, equals('John'));
      expect(authResponse.lastName, equals('Doe'));
      expect(authResponse.role, equals('STUDENT'));
      expect(authResponse.isVerified, isTrue);
    });

    test('fromJson creates correct instance from camelCase JSON', () {
      final authResponse = AuthResponse.fromJson(jsonCamelCase);

      expect(authResponse.accessToken, equals('test_access_token'));
      expect(authResponse.refreshToken, equals('test_refresh_token'));
      expect(authResponse.email, equals('test@example.com'));
      expect(authResponse.firstName, equals('John'));
      expect(authResponse.lastName, equals('Doe'));
      expect(authResponse.role, equals('STUDENT'));
      expect(authResponse.isVerified, isTrue);
    });

    test('fromJson handles mixed case JSON', () {
      final jsonMixed = {
        'access_token': 'test_access_token',
        'refreshToken': 'test_refresh_token', // camelCase
        'email': 'test@example.com',
        'first_name': 'John',
        'lastName': 'Doe', // camelCase
        'role': 'TEACHER',
        'is_verified': false,
      };

      final authResponse = AuthResponse.fromJson(jsonMixed);

      expect(authResponse.accessToken, equals('test_access_token'));
      expect(authResponse.refreshToken, equals('test_refresh_token'));
      expect(authResponse.role, equals('TEACHER'));
    });

    test('fromJson handles missing fields with defaults', () {
      final Map<String, dynamic> emptyJson = {};
      final authResponse = AuthResponse.fromJson(emptyJson);

      expect(authResponse.accessToken, equals(''));
      expect(authResponse.refreshToken, equals(''));
      expect(authResponse.email, equals(''));
      expect(authResponse.firstName, equals(''));
      expect(authResponse.lastName, equals(''));
      expect(authResponse.role, equals('STUDENT')); 
      expect(authResponse.isVerified, isFalse);
    });

    test('toJson returns correct map', () {
      final authResponse = AuthResponse(
        accessToken: 'token',
        refreshToken: 'refresh',
        email: 'email@test.com',
        firstName: 'First',
        lastName: 'Last',
        role: 'ADMIN',
        isVerified: true,
      );

      final json = authResponse.toJson();

      expect(json['accessToken'], equals('token'));
      expect(json['refreshToken'], equals('refresh'));
      expect(json['email'], equals('email@test.com'));
      expect(json['firstName'], equals('First'));
      expect(json['lastName'], equals('Last'));
      expect(json['role'], equals('ADMIN'));
      expect(json['isVerified'], isTrue);
    });
  });
}
