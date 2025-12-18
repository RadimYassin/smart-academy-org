import '../../data/models/enrollment/enrollment.dart';

abstract class EnrollmentRepository {
  Future<Enrollment> assignStudent(AssignStudentRequest request);
  Future<List<Enrollment>> assignClass(AssignClassRequest request);
  Future<List<Enrollment>> getCourseEnrollments(String courseId);
  Future<void> unenrollStudent(String courseId, int studentId);
  Future<List<Enrollment>> getMyCourses();
}

