package com.radim.project.service;

import com.radim.project.dto.EnrollmentDto;
import com.radim.project.entity.*;
import com.radim.project.entity.enums.AssignmentType;
import com.radim.project.repository.*;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
public class EnrollmentService {

    private final EnrollmentRepository enrollmentRepository;
    private final CourseRepository courseRepository;
    private final StudentClassRepository studentClassRepository;
    private final ClassStudentRepository classStudentRepository;

    @Transactional
    public EnrollmentDto.EnrollmentResponse assignStudentToCourse(UUID courseId, Long studentId, Long teacherId) {
        log.info("Assigning student {} to course {} by teacher {}", studentId, courseId, teacherId);

        Course course = courseRepository.findById(courseId)
                .orElseThrow(() -> new RuntimeException("Course not found"));

        // Verify teacher owns the course
        if (!course.getTeacherId().equals(teacherId)) {
            throw new RuntimeException("Access denied: You do not own this course");
        }

        // Check for duplicate enrollment
        if (enrollmentRepository.existsByCourse_IdAndStudentId(courseId, studentId)) {
            throw new RuntimeException("Student already enrolled in this course");
        }

        Enrollment enrollment = Enrollment.builder()
                .course(course)
                .studentId(studentId)
                .studentClass(null)
                .assignedBy(teacherId)
                .assignmentType(AssignmentType.INDIVIDUAL)
                .build();

        Enrollment saved = enrollmentRepository.save(enrollment);
        return toEnrollmentResponse(saved);
    }

    @Transactional
    public List<EnrollmentDto.EnrollmentResponse> assignClassToCourse(UUID courseId, UUID classId, Long teacherId) {
        log.info("Assigning class {} to course {} by teacher {}", classId, courseId, teacherId);

        Course course = courseRepository.findById(courseId)
                .orElseThrow(() -> new RuntimeException("Course not found"));

        // Verify teacher owns the course
        if (!course.getTeacherId().equals(teacherId)) {
            throw new RuntimeException("Access denied: You do not own this course");
        }

        StudentClass studentClass = studentClassRepository.findById(classId)
                .orElseThrow(() -> new RuntimeException("Class not found"));

        // Verify teacher owns the class
        if (!studentClass.getTeacherId().equals(teacherId)) {
            throw new RuntimeException("Access denied: You do not own this class");
        }

        // Get all students in the class
        List<ClassStudent> classStudents = classStudentRepository.findByStudentClassId(classId);

        List<EnrollmentDto.EnrollmentResponse> enrollments = classStudents.stream()
                .map(cs -> {
                    // Check if student already enrolled
                    if (enrollmentRepository.existsByCourse_IdAndStudentId(courseId, cs.getStudentId())) {
                        log.warn("Student {} already enrolled in course {}, skipping", cs.getStudentId(), courseId);
                        return null;
                    }

                    Enrollment enrollment = Enrollment.builder()
                            .course(course)
                            .studentId(cs.getStudentId())
                            .studentClass(studentClass)
                            .assignedBy(teacherId)
                            .assignmentType(AssignmentType.CLASS)
                            .build();

                    return enrollmentRepository.save(enrollment);
                })
                .filter(e -> e != null)
                .map(this::toEnrollmentResponse)
                .collect(Collectors.toList());

        log.info("Enrolled {} students from class {} to course {}", enrollments.size(), classId, courseId);
        return enrollments;
    }

    public List<EnrollmentDto.EnrollmentResponse> getStudentEnrollments(Long studentId) {
        log.info("Fetching enrollments for student {}", studentId);
        return enrollmentRepository.findByStudentId(studentId)
                .stream()
                .map(this::toEnrollmentResponse)
                .collect(Collectors.toList());
    }

    public List<EnrollmentDto.EnrollmentResponse> getCourseEnrollments(UUID courseId, Long teacherId) {
        log.info("Fetching enrollments for course {} by teacher {}", courseId, teacherId);

        Course course = courseRepository.findById(courseId)
                .orElseThrow(() -> new RuntimeException("Course not found"));

        // Verify teacher owns the course
        if (!course.getTeacherId().equals(teacherId)) {
            throw new RuntimeException("Access denied: You do not own this course");
        }

        return enrollmentRepository.findByCourse_Id(courseId)
                .stream()
                .map(this::toEnrollmentResponse)
                .collect(Collectors.toList());
    }

    @Transactional
    public void unenrollStudent(UUID courseId, Long studentId, Long teacherId) {
        log.info("Unenrolling student {} from course {} by teacher {}", studentId, courseId, teacherId);

        Course course = courseRepository.findById(courseId)
                .orElseThrow(() -> new RuntimeException("Course not found"));

        // Verify teacher owns the course
        if (!course.getTeacherId().equals(teacherId)) {
            throw new RuntimeException("Access denied: You do not own this course");
        }

        Enrollment enrollment = enrollmentRepository.findByCourse_IdAndStudentId(courseId, studentId)
                .orElseThrow(() -> new RuntimeException("Enrollment not found"));

        enrollmentRepository.delete(enrollment);
    }

    private EnrollmentDto.EnrollmentResponse toEnrollmentResponse(Enrollment enrollment) {
        return EnrollmentDto.EnrollmentResponse.builder()
                .id(enrollment.getId())
                .courseId(enrollment.getCourse().getId())
                .courseTitle(enrollment.getCourse().getTitle())
                .studentId(enrollment.getStudentId())
                .classId(enrollment.getStudentClass() != null ? enrollment.getStudentClass().getId() : null)
                .className(enrollment.getStudentClass() != null ? enrollment.getStudentClass().getName() : null)
                .assignedBy(enrollment.getAssignedBy())
                .assignmentType(enrollment.getAssignmentType())
                .enrolledAt(enrollment.getEnrolledAt())
                .build();
    }
}
