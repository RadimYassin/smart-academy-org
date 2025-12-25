// Unit tests for Course hierarchy models (Course, Module, Lesson, LessonContent)

import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/data/models/course/course.dart';
import 'package:mobile/data/models/course/module.dart';
import 'package:mobile/data/models/course/lesson.dart';
import 'package:mobile/data/models/course/lesson_content.dart';

void main() {
  group('Course Hierarchy', () {
    // --- LessonContent Tests ---
    group('LessonContent', () {
      final validJson = {
        'id': 'content-1',
        'lessonId': 'lesson-1',
        'type': 'TEXT',
        'textContent': 'Hello World',
        'orderIndex': 0,
        'createdAt': '2024-01-01T10:00:00.000',
        'updatedAt': '2024-01-01T12:00:00.000',
      };

      test('fromJson creates correct instance', () {
        final content = LessonContent.fromJson(validJson);
        expect(content.id, equals('content-1'));
        expect(content.lessonId, equals('lesson-1'));
        expect(content.type, equals('TEXT'));
        expect(content.textContent, equals('Hello World'));
      });

      test('toJson returns correct map', () {
        final content = LessonContent(
          id: '1',
          lessonId: 'l1',
          type: 'VIDEO',
          videoUrl: 'http://video.com',
          orderIndex: 1,
        );
        final json = content.toJson();
        expect(json['id'], equals('1'));
        expect(json['type'], equals('VIDEO'));
        expect(json['videoUrl'], equals('http://video.com'));
        expect(json.containsKey('textContent'), isFalse);
      });
    });

    // --- Lesson Tests ---
    group('Lesson', () {
      final validJson = {
        'id': 'lesson-1',
        'moduleId': 'module-1',
        'title': 'Intro Lesson',
        'summary': 'Short summary',
        'orderIndex': 1,
        'contents': [
          {
            'id': 'c1',
            'lessonId': 'lesson-1',
            'type': 'TEXT',
            'orderIndex': 0
          }
        ]
      };

      test('fromJson creates correct instance with contents', () {
        final lesson = Lesson.fromJson(validJson);
        expect(lesson.id, equals('lesson-1'));
        expect(lesson.title, equals('Intro Lesson'));
        expect(lesson.contents, hasLength(1));
        expect(lesson.contents!.first.type, equals('TEXT'));
      });

      test('toJson returns correct map', () {
        final lesson = Lesson(
          id: 'l1',
          moduleId: 'm1',
          title: 'Title',
          orderIndex: 0,
          contents: [],
        );
        final json = lesson.toJson();
        expect(json['id'], equals('l1'));
        expect(json['contents'], isEmpty);
      });
    });

    // --- Module Tests ---
    group('Module', () {
      final validJson = {
        'id': 'module-1',
        'courseId': 'course-1',
        'title': 'Module 1',
        'orderIndex': 0,
        'lessons': [
          {
            'id': 'l1',
            'moduleId': 'module-1',
            'title': 'L1',
            'orderIndex': 0
          }
        ]
      };

      test('fromJson creates correct instance with lessons', () {
        final module = Module.fromJson(validJson);
        expect(module.id, equals('module-1'));
        expect(module.title, equals('Module 1'));
        expect(module.lessons, hasLength(1));
        expect(module.lessons!.first.title, equals('L1'));
      });
    });

    // --- Course Tests ---
    group('Course', () {
      final validJson = {
        'id': 'course-1',
        'title': 'Flutter Course',
        'description': 'Learn Flutter',
        'category': 'Mobile',
        'level': 'BEGINNER',
        'thumbnailUrl': 'http://img.com',
        'teacherId': 101,
        'createdAt': '2024-01-01T00:00:00.000',
        'updatedAt': '2024-01-02T00:00:00.000',
        'modules': [
          {
            'id': 'm1',
            'courseId': 'course-1',
            'title': 'M1',
            'orderIndex': 0
          }
        ]
      };

      test('fromJson creates correct instance with modules', () {
        final course = Course.fromJson(validJson);
        expect(course.id, equals('course-1'));
        expect(course.title, equals('Flutter Course'));
        expect(course.teacherId, equals(101));
        expect(course.modules, hasLength(1));
        expect(course.modules!.first.title, equals('M1'));
      });

      test('fromJson handles null optional fields', () {
        final json = {
          'id': 'c1',
          'title': 'T',
          'category': 'C',
          'level': 'L',
          'teacherId': 1,
          'createdAt': '2024-01-01T00:00:00.000',
          'updatedAt': '2024-01-01T00:00:00.000',
        };
        final course = Course.fromJson(json);
        expect(course.description, isEmpty); // Default value
        expect(course.thumbnailUrl, isEmpty); // Default value
        expect(course.modules, isNull);
      });

      test('toJson returns correct map', () {
        final course = Course(
          id: 'c1',
          title: 'Title',
          description: 'Desc',
          category: 'Cat',
          level: 'Lev',
          thumbnailUrl: 'Url',
          teacherId: 1,
          createdAt: DateTime(2024),
          updatedAt: DateTime(2024),
        );
        final json = course.toJson();
        expect(json['id'], equals('c1'));
        expect(json.containsKey('modules'), isFalse);
      });
    });

    // --- Create Request Models Tests ---
    group('CreateRequestModels', () {
      test('CreateCourseRequest toJson', () {
        final req = CreateCourseRequest(
          title: 'T',
          description: 'D',
          category: 'C',
          level: 'L',
          thumbnailUrl: 'Url',
        );
        expect(req.toJson()['title'], equals('T'));
        expect(req.toJson()['thumbnailUrl'], equals('Url'));
      });

      test('CreateModuleRequest toJson', () {
        final req = CreateModuleRequest(
          title: 'T',
          description: 'D',
          orderIndex: 0,
        );
        expect(req.toJson()['title'], equals('T'));
      });

      test('CreateLessonRequest toJson', () {
        final req = CreateLessonRequest(
          title: 'T',
          summary: 'S',
          orderIndex: 0,
        );
        expect(req.toJson()['title'], equals('T'));
      });

      test('CreateLessonContentRequest toJson', () {
        final req = CreateLessonContentRequest(
          type: 'TEXT',
          textContent: 'Content',
          orderIndex: 0,
        );
        expect(req.toJson()['type'], equals('TEXT'));
        expect(req.toJson()['textContent'], equals('Content'));
      });
    });
  });
}
