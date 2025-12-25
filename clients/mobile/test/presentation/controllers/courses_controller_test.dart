// Unit tests for CoursesController

import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mobile/presentation/controllers/courses_controller.dart';
import 'package:mobile/domain/repositories/course_repository.dart';
import 'package:mobile/domain/repositories/auth_repository.dart';
import 'package:mobile/data/models/course/course.dart';
import 'package:mobile/data/models/course/create_course_request.dart';
import 'package:mobile/core/constants/app_constants.dart';

import 'courses_controller_test.mocks.dart';

@GenerateMocks([CourseRepository, AuthRepository, GetStorage])
void main() {
  late CoursesController controller;
  late MockCourseRepository mockCourseRepository;
  late MockAuthRepository mockAuthRepository;
  late MockGetStorage mockGetStorage;

  setUp(() {
    mockCourseRepository = MockCourseRepository();
    mockAuthRepository = MockAuthRepository();
    mockGetStorage = MockGetStorage();

    Get.put<CourseRepository>(mockCourseRepository);
    Get.put<AuthRepository>(mockAuthRepository);
    Get.put<GetStorage>(mockGetStorage);

    // Default mock behavior for successful initialization
    when(mockGetStorage.read('user_data')).thenReturn({'role': 'student', 'userId': 1});
    when(mockGetStorage.read(AppConstants.accessTokenKey)).thenReturn('token');
    when(mockCourseRepository.getAllCourses()).thenAnswer((_) async => []);

    controller = CoursesController();
  });

  tearDown(() {
    Get.reset();
  });

  group('CoursesController', () {
    test('onInit loads courses for student', () async {
      // Setup handled in setUp() but we need to trigger onInit
      
      // Act
      controller.onInit();
      
      // Wait for async operations
      await Future.delayed(Duration.zero);

      // Assert
      verify(mockGetStorage.read('user_data'));
      verify(mockCourseRepository.getAllCourses());
      expect(controller.courses.isEmpty, true);
    });

    test('loadCourses handles user with teacher role', () async {
      // Setup
      when(mockGetStorage.read('user_data')).thenReturn({'role': 'teacher', 'userId': 10});
      when(mockCourseRepository.getTeacherCourses(10)).thenAnswer((_) async => []);

      // Act
      controller.onInit(); // Re-init to pick up new mock values
      await controller.loadCourses();

      // Assert
      verify(mockCourseRepository.getTeacherCourses(10));
    });

    test('createCourse calls repository and refreshes list', () async {
      // Setup
      controller.onInit();
      controller.newCourse.value = CreateCourseRequest(
        title: 'New Course',
        description: 'Desc',
        category: 'Tech',
        level: 'BEGINNER'
      );
      
      final createdCourse = Course(
        id: 'new-id',
        title: 'New Course',
        description: 'Desc',
        category: 'Tech',
        level: 'BEGINNER',
        teacherId: 1,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now()
      );

      when(mockCourseRepository.createCourse(any)).thenAnswer((_) async => createdCourse);
      when(mockCourseRepository.getAllCourses()).thenAnswer((_) async => [createdCourse]);

      // Act
      await controller.createCourse();

      // Assert
      verify(mockCourseRepository.createCourse(any));
      expect(controller.courses.length, 1);
      expect(controller.courses.first.id, 'new-id');
      expect(controller.showCreateCourseModal.value, false);
    });

    test('deleteCourse calls repository and removes from list', () async {
      // Setup
      final courseToDelete = Course(
        id: 'del-id',
        title: 'Delete Me',
        description: 'Desc',
        category: 'Tech',
        level: 'BEGINNER',
        teacherId: 1,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now()
      );
      
      // Initial state with one course
      when(mockCourseRepository.getAllCourses()).thenAnswer((_) async => [courseToDelete]);
      controller.onInit();
      await controller.loadCourses();
      expect(controller.courses.length, 1);

      when(mockCourseRepository.deleteCourse('del-id')).thenAnswer((_) async => {});

      // Act
      controller.openDeleteCourseModal(courseToDelete);
      await controller.deleteCourse();

      // Assert
      verify(mockCourseRepository.deleteCourse('del-id'));
      expect(controller.courses.isEmpty, true);
      expect(controller.showDeleteCourseModal.value, false);
    });

    test('filtering functionality', () async {
      // Setup
      final course1 = Course(
        id: '1', title: 'Flutter Basics', description: 'Intro', category: 'Mobile', level: 'BEGINNER', 
        teacherId: 1, createdAt: DateTime.now(), updatedAt: DateTime.now());
      final course2 = Course(
        id: '2', title: 'Advanced React', description: 'Deep dive', category: 'Web', level: 'ADVANCED', 
        teacherId: 1, createdAt: DateTime.now(), updatedAt: DateTime.now());
      
      when(mockCourseRepository.getAllCourses()).thenAnswer((_) async => [course1, course2]);
      
      controller.onInit();
      await controller.loadCourses();

      // Test Search
      controller.updateSearchQuery('Flutter');
      expect(controller.filteredCourses.length, 1);
      expect(controller.filteredCourses.first.title, 'Flutter Basics');

      // Test Category
      controller.updateSearchQuery('');
      controller.updateCategoryFilter('Web');
      expect(controller.filteredCourses.length, 1);
      expect(controller.filteredCourses.first.title, 'Advanced React');

       // Test Level
      controller.updateCategoryFilter('All');
      controller.updateLevelFilter('BEGINNER');
      expect(controller.filteredCourses.length, 1);
      expect(controller.filteredCourses.first.title, 'Flutter Basics');
    });
  });
}
