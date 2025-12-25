// Unit tests for Student models (StudentDto, StudentClass, etc.)

import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/data/models/student/student_dto.dart';
import 'package:mobile/data/models/student/student_class.dart';

void main() {
  group('Student Models', () {
    // --- StudentDto Tests ---
    group('StudentDto', () {
      final validJson = {
        'id': 101,
        'email': 'student@test.com',
        'firstName': 'John',
        'lastName': 'Doe',
        'role': 'STUDENT',
        'isVerified': true,
      };

      test('fromJson creates correct instance', () {
        final dto = StudentDto.fromJson(validJson);
        expect(dto.id, equals(101));
        expect(dto.email, equals('student@test.com'));
        expect(dto.firstName, equals('John'));
        expect(dto.lastName, equals('Doe'));
        expect(dto.role, equals('STUDENT'));
        expect(dto.isVerified, isTrue);
      });

      test('fromJson handles defaults', () {
        final json = {
          'id': 101,
          'email': 'email',
        };
        final dto = StudentDto.fromJson(json);
        expect(dto.firstName, isEmpty);
        expect(dto.lastName, isEmpty);
        expect(dto.role, equals('STUDENT'));
        expect(dto.isVerified, isFalse);
      });

      test('toJson returns correct map', () {
        final dto = StudentDto(
          id: 1,
          email: 'e',
          firstName: 'F',
          lastName: 'L',
          role: 'R',
          isVerified: true,
        );
        final json = dto.toJson();
        expect(json['id'], equals(1));
        expect(json['firstName'], equals('F'));
      });

      test('fullName returns correct string', () {
        final dto = StudentDto(
          id: 1,
          email: 'e',
          firstName: 'John',
          lastName: 'Doe',
          role: 'R',
          isVerified: true,
        );
        expect(dto.fullName, equals('John Doe'));
      });
    });

    // --- StudentClass Tests ---
    group('StudentClass', () {
      final validJson = {
        'id': 'class-1',
        'name': 'Class A',
        'description': 'Desc',
        'teacherId': 10,
        'studentCount': 5,
        'createdAt': '2024-01-01T10:00:00.000',
        'updatedAt': '2024-01-01T10:00:00.000',
      };

      test('fromJson creates correct instance', () {
        final studentClass = StudentClass.fromJson(validJson);
        expect(studentClass.id, equals('class-1'));
        expect(studentClass.name, equals('Class A'));
        expect(studentClass.teacherId, equals(10));
        expect(studentClass.studentCount, equals(5));
      });

      test('toJson returns correct map', () {
        final studentClass = StudentClass(
          id: 'c1',
          name: 'N',
          teacherId: 1,
          studentCount: 0,
          createdAt: DateTime(2024),
          updatedAt: DateTime(2024),
        );
        final json = studentClass.toJson();
        expect(json['id'], equals('c1'));
        expect(json['name'], equals('N'));
      });
    });

    // --- CreateClassRequest Tests ---
    group('CreateClassRequest', () {
      test('toJson returns correct map', () {
        final req = CreateClassRequest(name: 'Name', description: 'Desc');
        expect(req.toJson()['name'], equals('Name'));
        expect(req.toJson()['description'], equals('Desc'));
      });
    });

    // --- ClassStudent Tests ---
    group('ClassStudent', () {
      final validJson = {
        'studentId': 1,
        'addedBy': 2,
        'addedAt': '2024-01-01T10:00:00.000',
      };

      test('fromJson creates correct instance', () {
        final cs = ClassStudent.fromJson(validJson);
        expect(cs.studentId, equals(1));
        expect(cs.addedBy, equals(2));
      });

      test('toJson returns correct map', () {
        final cs = ClassStudent(
          studentId: 1,
          addedBy: 2,
          addedAt: DateTime(2024),
        );
        expect(cs.toJson()['studentId'], equals(1));
      });
    });

    // --- AddStudentsRequest Tests ---
    group('AddStudentsRequest', () {
      test('toJson returns correct map', () {
        final req = AddStudentsRequest(studentIds: [1, 2, 3]);
        expect(req.toJson()['studentIds'], equals([1, 2, 3]));
      });
    });
  });
}
