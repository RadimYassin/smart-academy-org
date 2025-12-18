import '../../data/models/student/student_class.dart';

abstract class ClassRepository {
  Future<StudentClass> createClass(CreateClassRequest request);
  Future<List<StudentClass>> getMyClasses();
  Future<StudentClass> getClassById(String classId);
  Future<void> deleteClass(String classId);
  Future<void> addStudentsToClass(String classId, AddStudentsRequest request);
  Future<List<ClassStudent>> getClassStudents(String classId);
  Future<void> removeStudentFromClass(String classId, int studentId);
}

