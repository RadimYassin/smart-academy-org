// Unit tests for UserDto model

import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/data/models/user/user_dto.dart';

void main() {
  group('UserDto', () {
    const jsonSnakeCase = {
      'id': 1,
      'first_name': 'Alice',
      'last_name': 'Smith',
      'email': 'alice@example.com',
      'role': 'TEACHER',
      'createdAt': '2024-01-01T10:00:00.000',
      'updatedAt': '2024-01-02T10:00:00.000',
    };

    const jsonCamelCase = {
      'id': 1,
      'firstName': 'Alice',
      'lastName': 'Smith',
      'email': 'alice@example.com',
      'role': 'TEACHER',
    };

    const jsonComplexRole = {
      'id': 1,
      'firstName': 'Alice',
      'lastName': 'Smith',
      'email': 'alice@example.com',
      'role': {'id': 2, 'name': 'ADMIN'},
    };

    test('fromJson creates correct instance from snake_case JSON', () {
      final user = UserDto.fromJson(jsonSnakeCase);

      expect(user.id, equals(1));
      expect(user.firstName, equals('Alice'));
      expect(user.lastName, equals('Smith'));
      expect(user.email, equals('alice@example.com'));
      expect(user.role, equals('TEACHER'));
      expect(user.createdAt, equals(DateTime(2024, 1, 1, 10)));
      expect(user.updatedAt, equals(DateTime(2024, 1, 2, 10)));
    });

    test('fromJson creates correct instance from camelCase JSON', () {
      final user = UserDto.fromJson(jsonCamelCase);

      expect(user.firstName, equals('Alice'));
      expect(user.lastName, equals('Smith'));
    });

    test('fromJson handles complex role object', () {
      final user = UserDto.fromJson(jsonComplexRole);

      expect(user.role, equals('ADMIN'));
    });

    test('fromJson handles missing fields with defaults', () {
      final user = UserDto.fromJson({'id': 1});

      expect(user.id, equals(1));
      expect(user.firstName, equals(''));
      expect(user.lastName, equals(''));
      expect(user.email, equals(''));
      expect(user.role, equals('STUDENT'));
      expect(user.createdAt, isNull);
    });

    test('fromJson handles string IDs (parsing)', () {
      final user = UserDto.fromJson({'id': '123'});
      expect(user.id, equals(123));
    });

    test('toJson returns correct map', () {
      final user = UserDto(
        id: 1,
        firstName: 'Bob',
        lastName: 'Jones',
        email: 'bob@test.com',
        role: 'STUDENT',
        createdAt: DateTime(2024, 1, 1),
      );

      final json = user.toJson();

      expect(json['id'], equals(1));
      expect(json['firstName'], equals('Bob'));
      expect(json['lastName'], equals('Jones'));
      expect(json['email'], equals('bob@test.com'));
      expect(json['role'], equals('STUDENT'));
      expect(json['createdAt'], isNotNull);
      expect(json.containsKey('updatedAt'), isFalse);
    });

    test('fullName property returns correct string', () {
      final user = UserDto(
        id: 1,
        firstName: 'Bob',
        lastName: 'Jones',
        email: 'bob@test.com',
        role: 'STUDENT',
      );

      expect(user.fullName, equals('Bob Jones'));
    });
  });

  group('UpdateUserRequest', () {
    test('toJson return correct map', () {
      final request = UpdateUserRequest(firstName: 'Jane', lastName: 'Doe');
      final json = request.toJson();
      
      expect(json['firstName'], equals('Jane'));
      expect(json['lastName'], equals('Doe'));
    });
  });
}
