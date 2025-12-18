import '../../data/models/student/student_dto.dart';

abstract class StudentRepository {
  Future<List<StudentDto>> getAllStudents();
  Future<StudentDto> getStudentById(int studentId);
}

