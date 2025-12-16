package com.radim.project.service;

import com.radim.project.dto.EnrollmentDto;
import com.radim.project.entity.*;
import com.radim.project.entity.enums.AssignmentType;
import com.radim.project.repository.*;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.ArrayList;
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
    
    @PersistenceContext
    private EntityManager entityManager;

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

        // Verify class exists and teacher owns it
        StudentClass studentClass = studentClassRepository.findById(classId)
                .orElseThrow(() -> new RuntimeException("Class not found"));

        if (!studentClass.getTeacherId().equals(teacherId)) {
            throw new RuntimeException("Access denied: You do not own this class");
        }

        // Check if class is already enrolled in this course
        List<Enrollment> existingClassEnrollments = enrollmentRepository.findByStudentClass_Id(classId)
                .stream()
                .filter(e -> e.getCourse().getId().equals(courseId))
                .toList();
        
        if (!existingClassEnrollments.isEmpty()) {
            throw new RuntimeException("Class already enrolled in this course");
        }

        // Get all students in the class
        List<ClassStudent> classStudents = classStudentRepository.findByStudentClassId(classId);

        if (classStudents.isEmpty()) {
            log.warn("Class {} has no students, nothing to enroll", classId);
            throw new RuntimeException("Cannot enroll empty class to course. Please add students to the class first.");
        }

        log.info("Enrolling class {} ({} students) to course {} - creating individual enrollments for each student", 
                classId, classStudents.size(), courseId);

        List<EnrollmentDto.EnrollmentResponse> enrollments = new ArrayList<>();
        int successCount = 0;
        int skippedCount = 0;
        
        // Loop through each student in the class and add them individually to the course
        for (ClassStudent cs : classStudents) {
            Long studentId = cs.getStudentId();
            
            // Check if student already enrolled individually
            if (enrollmentRepository.existsByCourse_IdAndStudentId(courseId, studentId)) {
                log.warn("Student {} already enrolled in course {}, skipping", studentId, courseId);
                skippedCount++;
                continue;
            }

            try {
                // Create individual enrollment for this student
                // CHECK constraint requires: (student_id IS NOT NULL AND class_id IS NULL)
                Enrollment enrollment = new Enrollment();
                enrollment.setCourse(course);
                enrollment.setStudentId(studentId);
                // CRITICAL: studentClass MUST be null - setting it would violate CHECK constraint
                enrollment.setStudentClass(null);
                enrollment.setAssignedBy(teacherId);
                enrollment.setAssignmentType(AssignmentType.CLASS); // Indicates assigned via class
                enrollment.setEnrolledAt(LocalDateTime.now());
                
                log.debug("Creating enrollment: studentId={}, courseId={}, studentClass=null", 
                        studentId, courseId);
                
                // Clear entity manager to ensure no stale references
                entityManager.clear();
                
                Enrollment saved = enrollmentRepository.save(enrollment);
                entityManager.flush(); // Force immediate insert
                
                // Double-check that class_id is null after save
                if (saved.getStudentClass() != null) {
                    log.error("CRITICAL: Saved enrollment has non-null studentClass! This violates CHECK constraint.");
                    throw new RuntimeException("Failed to create enrollment: class_id should be NULL");
                }
                
                successCount++;
                
                log.debug("Successfully enrolled student {} in course {} (Enrollment ID: {})", 
                        studentId, courseId, saved.getId());
                enrollments.add(toEnrollmentResponse(saved));
                
            } catch (Exception e) {
                log.error("Failed to enroll student {} in course {}: {}", studentId, courseId, e.getMessage(), e);
                throw new RuntimeException("Failed to enroll student " + studentId + ": " + e.getMessage());
            }
        }
        
        log.info("Class enrollment complete: {} students enrolled, {} skipped (already enrolled)", 
                successCount, skippedCount);
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
