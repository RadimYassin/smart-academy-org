import 'package:get/get.dart';
import '../../../core/utils/logger.dart';
import '../../../data/models/student/student_class.dart';
import '../../../data/models/student/student_dto.dart';
import '../../../data/models/auth/register_request.dart';
import '../../../domain/repositories/class_repository.dart';
import '../../../domain/repositories/student_repository.dart';
import '../../../domain/repositories/auth_repository.dart';

class StudentsController extends GetxController {
  // Repositories
  late final ClassRepository _classRepository;
  late final StudentRepository _studentRepository;
  late final AuthRepository _authRepository;

  // Classes
  final classes = <StudentClass>[].obs;
  final isLoadingClasses = false.obs;
  final errorMessage = ''.obs;

  // Students
  final allStudents = <StudentDto>[].obs;
  final isLoadingStudents = false.obs;
  final studentsByClass = <String, List<ClassStudent>>{}.obs;
  final loadingStudentsForClass = <String>{}.obs;

  // UI State
  final expandedClasses = <String>{}.obs;
  final selectedClass = Rxn<StudentClass>();

  // Modals
  final showCreateClassModal = false.obs;
  final showCreateStudentModal = false.obs;
  final showAddStudentsModal = false.obs;

  // Form states
  final newClass = CreateClassRequest(name: '', description: '').obs;
  final newStudent = {
    'email': '',
    'password': '',
    'firstName': '',
    'lastName': '',
  }.obs;

  // Add students modal
  final selectedStudentIds = <int>[].obs;
  final searchQuery = ''.obs;
  final filteredStudents = <StudentDto>[].obs;

  @override
  void onInit() {
    super.onInit();
    _classRepository = Get.find<ClassRepository>();
    _studentRepository = Get.find<StudentRepository>();
    _authRepository = Get.find<AuthRepository>();
    loadClasses();
    loadAllStudents();
  }

  /// Load all classes
  Future<void> loadClasses() async {
    try {
      isLoadingClasses.value = true;
      errorMessage.value = '';
      
      final data = await _classRepository.getMyClasses();
      classes.value = data;
      
      Logger.logInfo('Loaded ${data.length} classes');
    } catch (e) {
      Logger.logError('Load classes error', error: e);
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
      Get.snackbar(
        'Error',
        errorMessage.value,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Get.theme.colorScheme.error.withOpacity(0.8),
        colorText: Get.theme.colorScheme.onError,
      );
    } finally {
      isLoadingClasses.value = false;
    }
  }

  /// Load all available students
  Future<void> loadAllStudents() async {
    try {
      isLoadingStudents.value = true;
      
      final students = await _studentRepository.getAllStudents();
      allStudents.value = students;
      
      Logger.logInfo('Loaded ${students.length} students');
    } catch (e) {
      Logger.logError('Load students error', error: e);
      Get.snackbar(
        'Error',
        'Failed to load students',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Get.theme.colorScheme.error.withOpacity(0.8),
        colorText: Get.theme.colorScheme.onError,
      );
    } finally {
      isLoadingStudents.value = false;
    }
  }

  /// Create a new class
  Future<void> createClass() async {
    try {
      if (newClass.value.name.trim().isEmpty) {
        Get.snackbar('Error', 'Class name is required');
        return;
      }

      final created = await _classRepository.createClass(newClass.value);
      classes.add(created);
      
      // Reset form
      newClass.value = CreateClassRequest(name: '', description: '');
      showCreateClassModal.value = false;
      
      Get.snackbar(
        'Success',
        'Class created successfully',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Get.theme.colorScheme.primary.withOpacity(0.8),
        colorText: Get.theme.colorScheme.onPrimary,
      );
    } catch (e) {
      Logger.logError('Create class error', error: e);
      Get.snackbar(
        'Error',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.TOP,
        backgroundColor: Get.theme.colorScheme.error.withOpacity(0.8),
        colorText: Get.theme.colorScheme.onError,
      );
    }
  }

  /// Delete a class
  Future<void> deleteClass(String classId) async {
    try {
      await _classRepository.deleteClass(classId);
      classes.removeWhere((c) => c.id == classId);
      
      // Clear expanded state if deleted
      if (expandedClasses.contains(classId)) {
        expandedClasses.remove(classId);
      }
      
      Get.snackbar(
        'Success',
        'Class deleted successfully',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Get.theme.colorScheme.primary.withOpacity(0.8),
        colorText: Get.theme.colorScheme.onPrimary,
      );
    } catch (e) {
      Logger.logError('Delete class error', error: e);
      Get.snackbar(
        'Error',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.TOP,
        backgroundColor: Get.theme.colorScheme.error.withOpacity(0.8),
        colorText: Get.theme.colorScheme.onError,
      );
    }
  }

  /// Toggle class expansion
  Future<void> toggleClass(String classId) async {
    if (expandedClasses.contains(classId)) {
      expandedClasses.remove(classId);
    } else {
      expandedClasses.add(classId);
      // Load students when expanding
      if (!studentsByClass.containsKey(classId)) {
        await loadClassStudents(classId);
      }
    }
  }

  /// Load students for a class
  Future<void> loadClassStudents(String classId) async {
    try {
      loadingStudentsForClass.add(classId);
      
      final students = await _classRepository.getClassStudents(classId);
      studentsByClass[classId] = students;
      
      // Update class student count
      final classIndex = classes.indexWhere((c) => c.id == classId);
      if (classIndex != -1) {
        final updatedClass = StudentClass(
          id: classes[classIndex].id,
          name: classes[classIndex].name,
          description: classes[classIndex].description,
          teacherId: classes[classIndex].teacherId,
          studentCount: students.length,
          createdAt: classes[classIndex].createdAt,
          updatedAt: classes[classIndex].updatedAt,
        );
        classes[classIndex] = updatedClass;
      }
    } catch (e) {
      Logger.logError('Load class students error', error: e);
      Get.snackbar(
        'Error',
        'Failed to load students',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Get.theme.colorScheme.error.withOpacity(0.8),
        colorText: Get.theme.colorScheme.onError,
      );
    } finally {
      loadingStudentsForClass.remove(classId);
    }
  }

  /// Add students to class
  Future<void> addStudentsToClass(String classId, List<int> studentIds) async {
    try {
      if (studentIds.isEmpty) {
        Get.snackbar('Error', 'Please select at least one student');
        return;
      }

      await _classRepository.addStudentsToClass(
        classId,
        AddStudentsRequest(studentIds: studentIds),
      );
      
      // Reload students for this class
      await loadClassStudents(classId);
      // Reload classes to update count
      await loadClasses();
      
      showAddStudentsModal.value = false;
      selectedStudentIds.clear();
      
      Get.snackbar(
        'Success',
        '${studentIds.length} student(s) added successfully',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Get.theme.colorScheme.primary.withOpacity(0.8),
        colorText: Get.theme.colorScheme.onPrimary,
      );
    } catch (e) {
      Logger.logError('Add students error', error: e);
      Get.snackbar(
        'Error',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.TOP,
        backgroundColor: Get.theme.colorScheme.error.withOpacity(0.8),
        colorText: Get.theme.colorScheme.onError,
      );
    }
  }

  /// Remove student from class
  Future<void> removeStudentFromClass(String classId, int studentId) async {
    try {
      await _classRepository.removeStudentFromClass(classId, studentId);
      
      // Update local state
      if (studentsByClass.containsKey(classId)) {
        studentsByClass[classId]!.removeWhere((s) => s.studentId == studentId);
      }
      
      // Update class student count
      await loadClasses();
      
      Get.snackbar(
        'Success',
        'Student removed successfully',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Get.theme.colorScheme.primary.withOpacity(0.8),
        colorText: Get.theme.colorScheme.onPrimary,
      );
    } catch (e) {
      Logger.logError('Remove student error', error: e);
      Get.snackbar(
        'Error',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.TOP,
        backgroundColor: Get.theme.colorScheme.error.withOpacity(0.8),
        colorText: Get.theme.colorScheme.onError,
      );
    }
  }

  /// Create student account
  Future<void> createStudent() async {
    try {
      // Validate form
      if (newStudent['firstName']?.trim().isEmpty ?? true) {
        Get.snackbar('Error', 'First name is required');
        return;
      }
      if (newStudent['lastName']?.trim().isEmpty ?? true) {
        Get.snackbar('Error', 'Last name is required');
        return;
      }
      if (newStudent['email']?.trim().isEmpty ?? true) {
        Get.snackbar('Error', 'Email is required');
        return;
      }
      if (newStudent['password']?.trim().isEmpty ?? true) {
        Get.snackbar('Error', 'Password is required');
        return;
      }

      // Register student
      await _authRepository.register(
        RegisterRequest(
          email: newStudent['email']!,
          password: newStudent['password']!,
          firstName: newStudent['firstName']!,
          lastName: newStudent['lastName']!,
          role: 'STUDENT',
        ),
      );
      
      // Reset form
      newStudent.value = {
        'email': '',
        'password': '',
        'firstName': '',
        'lastName': '',
      };
      showCreateStudentModal.value = false;
      
      // Reload students list
      await loadAllStudents();
      
      Get.snackbar(
        'Success',
        'Student account created successfully',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Get.theme.colorScheme.primary.withOpacity(0.8),
        colorText: Get.theme.colorScheme.onPrimary,
      );
    } catch (e) {
      Logger.logError('Create student error', error: e);
      Get.snackbar(
        'Error',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.TOP,
        backgroundColor: Get.theme.colorScheme.error.withOpacity(0.8),
        colorText: Get.theme.colorScheme.onError,
      );
    }
  }

  /// Filter students for add modal
  void filterStudents(String query) {
    searchQuery.value = query;
    
    if (query.trim().isEmpty) {
      filteredStudents.value = allStudents;
    } else {
      final lowerQuery = query.toLowerCase();
      filteredStudents.value = allStudents.where((student) {
        return student.firstName.toLowerCase().contains(lowerQuery) ||
               student.lastName.toLowerCase().contains(lowerQuery) ||
               student.email.toLowerCase().contains(lowerQuery) ||
               student.id.toString().contains(lowerQuery);
      }).toList();
    }
  }

  /// Toggle student selection in add modal
  void toggleStudentSelection(int studentId) {
    if (selectedStudentIds.contains(studentId)) {
      selectedStudentIds.remove(studentId);
    } else {
      selectedStudentIds.add(studentId);
    }
  }

  /// Select all available students
  void selectAllStudents(List<int> existingIds) {
    final availableIds = filteredStudents
        .where((s) => !existingIds.contains(s.id))
        .map((s) => s.id)
        .toList();
    
    if (availableIds.every((id) => selectedStudentIds.contains(id))) {
      // Deselect all
      selectedStudentIds.removeWhere((id) => availableIds.contains(id));
    } else {
      // Select all
      selectedStudentIds.addAll(availableIds);
      selectedStudentIds.value = selectedStudentIds.toSet().toList();
    }
  }

  /// Open add students modal
  void openAddStudentsModal(StudentClass studentClass) {
    selectedClass.value = studentClass;
    selectedStudentIds.clear();
    searchQuery.value = '';
    filteredStudents.value = allStudents;
    showAddStudentsModal.value = true;
  }

  /// Get students for a class
  List<ClassStudent> getClassStudentsList(String classId) {
    return studentsByClass[classId] ?? [];
  }

  /// Get student info by ID
  StudentDto? getStudentInfo(int studentId) {
    try {
      return allStudents.firstWhere((s) => s.id == studentId);
    } catch (e) {
      return null;
    }
  }
}

