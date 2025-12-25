// Unit tests for CourseRepositoryImpl

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:mobile/data/repositories/course_repository_impl.dart';
import 'package:mobile/data/datasources/course_remote_datasource.dart';
import 'package:mobile/data/models/course/course.dart';
import 'package:mobile/data/models/course/module.dart';
import 'package:mobile/data/models/course/lesson.dart';

import 'course_repository_impl_test.mocks.dart';

@GenerateMocks([CourseRemoteDataSource])
void main() {
  late CourseRepositoryImpl repository;
  late MockCourseRemoteDataSource mockRemoteDataSource;

  setUp(() {
    mockRemoteDataSource = MockCourseRemoteDataSource();
    repository = CourseRepositoryImpl(mockRemoteDataSource);
  });

  group('CourseRepositoryImpl', () {
    // --- Course Tests ---
    group('getAllCourses', () {
      final tCourses = [
        Course(
          id: 'c1',
          title: 'Test Course',
          description: 'Desc',
          category: 'Cat',
          level: 'Lev',
          thumbnailUrl: 'Url',
          teacherId: 1,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        )
      ];

      test('should return list of courses when call is successful', () async {
        when(mockRemoteDataSource.getAllCourses()).thenAnswer((_) async => tCourses);
        final result = await repository.getAllCourses();
        expect(result, equals(tCourses));
        verify(mockRemoteDataSource.getAllCourses());
      });

      test('should rethrow exception when call fails', () async {
        when(mockRemoteDataSource.getAllCourses()).thenThrow(Exception());
        expect(() => repository.getAllCourses(), throwsException);
      });
    });

    group('getTeacherCourses', () {
      final tCourses = <Course>[];
      test('should return list of courses', () async {
        when(mockRemoteDataSource.getTeacherCourses(1)).thenAnswer((_) async => tCourses);
        final result = await repository.getTeacherCourses(1);
        expect(result, equals(tCourses));
      });
    });

    // --- Module Tests ---
    group('getModulesByCourse', () {
      final tModules = [
        Module(
          id: 'm1',
          courseId: 'c1',
          title: 'Mod',
          orderIndex: 0,
        )
      ];

      test('should return list of modules', () async {
        when(mockRemoteDataSource.getModulesByCourse('c1')).thenAnswer((_) async => tModules);
        final result = await repository.getModulesByCourse('c1');
        expect(result, equals(tModules));
      });
    });

    // --- Lesson Tests ---
    group('getLessonsByModule', () {
      final tLessons = <Lesson>[];
      test('should return list of lessons', () async {
        when(mockRemoteDataSource.getLessonsByModule('m1')).thenAnswer((_) async => tLessons);
        final result = await repository.getLessonsByModule('m1');
        expect(result, equals(tLessons));
      });
    });
  });
}
