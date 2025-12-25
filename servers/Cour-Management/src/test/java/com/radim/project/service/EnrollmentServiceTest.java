package com.radim.project.service;

import com.radim.project.dto.EnrollmentDto;
import com.radim.project.entity.*;
import com.radim.project.entity.enums.AssignmentType;
import com.radim.project.repository.*;
import jakarta.persistence.EntityManager;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.test.util.ReflectionTestUtils;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class EnrollmentServiceTest {

    @Mock
    private EnrollmentRepository enrollmentRepository;
    @Mock
    private CourseRepository courseRepository;
    @Mock
    private StudentClassRepository studentClassRepository;
    @Mock
    private ClassStudentRepository classStudentRepository;
    @Mock
    private EntityManager entityManager;

    @InjectMocks
    private EnrollmentService enrollmentService;

    private UUID courseId;
    private Long studentId;
    private Long teacherId;
    private Course course;

    @BeforeEach
    void setUp() {
        courseId = UUID.randomUUID();
        studentId = 100L;
        teacherId = 200L;
        course = Course.builder()
                .id(courseId)
                .title("Test Course")
                .teacherId(teacherId)
                .build();

        ReflectionTestUtils.setField(enrollmentService, "entityManager", entityManager);
    }

    @Test
    void assignStudentToCourse_ShouldSuccess() {
        when(courseRepository.findById(courseId)).thenReturn(Optional.of(course));
        when(enrollmentRepository.existsByCourse_IdAndStudentId(courseId, studentId)).thenReturn(false);

        Enrollment enrollment = Enrollment.builder()
                .id(UUID.randomUUID())
                .course(course)
                .studentId(studentId)
                .assignedBy(teacherId)
                .assignmentType(AssignmentType.INDIVIDUAL)
                .enrolledAt(LocalDateTime.now())
                .build();

        when(enrollmentRepository.save(any(Enrollment.class))).thenReturn(enrollment);

        EnrollmentDto.EnrollmentResponse response = enrollmentService.assignStudentToCourse(courseId, studentId,
                teacherId);

        assertThat(response).isNotNull();
        assertThat(response.getStudentId()).isEqualTo(studentId);
        verify(enrollmentRepository).save(any(Enrollment.class));
    }

    @Test
    void assignStudentToCourse_ShouldThrowException_WhenCourseNotFound() {
        when(courseRepository.findById(courseId)).thenReturn(Optional.empty());

        assertThatThrownBy(() -> enrollmentService.assignStudentToCourse(courseId, studentId, teacherId))
                .isInstanceOf(RuntimeException.class)
                .hasMessage("Course not found");
    }

    @Test
    void assignStudentToCourse_ShouldThrowException_WhenTeacherNotOwner() {
        course.setTeacherId(999L);
        when(courseRepository.findById(courseId)).thenReturn(Optional.of(course));

        assertThatThrownBy(() -> enrollmentService.assignStudentToCourse(courseId, studentId, teacherId))
                .isInstanceOf(RuntimeException.class)
                .hasMessageContaining("Access denied");
    }

    @Test
    void assignStudentToCourse_ShouldThrowException_WhenAlreadyEnrolled() {
        when(courseRepository.findById(courseId)).thenReturn(Optional.of(course));
        when(enrollmentRepository.existsByCourse_IdAndStudentId(courseId, studentId)).thenReturn(true);

        assertThatThrownBy(() -> enrollmentService.assignStudentToCourse(courseId, studentId, teacherId))
                .isInstanceOf(RuntimeException.class)
                .hasMessage("Student already enrolled in this course");
    }

    @Test
    void assignClassToCourse_ShouldSuccess() {
        UUID classId = UUID.randomUUID();
        StudentClass studentClass = StudentClass.builder()
                .id(classId)
                .name("Test Class")
                .teacherId(teacherId)
                .build();

        when(courseRepository.findById(courseId)).thenReturn(Optional.of(course));
        when(studentClassRepository.findById(classId)).thenReturn(Optional.of(studentClass));
        when(enrollmentRepository.findByStudentClass_Id(classId)).thenReturn(new ArrayList<>());

        ClassStudent classStudent = new ClassStudent();
        classStudent.setStudentId(studentId);
        when(classStudentRepository.findByStudentClassId(classId)).thenReturn(List.of(classStudent));

        when(enrollmentRepository.existsByCourse_IdAndStudentId(courseId, studentId)).thenReturn(false);

        Enrollment savedEnrollment = new Enrollment();
        savedEnrollment.setId(UUID.randomUUID());
        savedEnrollment.setCourse(course);
        savedEnrollment.setStudentId(studentId);

        when(enrollmentRepository.save(any(Enrollment.class))).thenReturn(savedEnrollment);

        List<EnrollmentDto.EnrollmentResponse> responses = enrollmentService.assignClassToCourse(courseId, classId,
                teacherId);

        assertThat(responses).hasSize(1);
        verify(entityManager).clear();
        verify(entityManager).flush();
    }

    @Test
    void assignClassToCourse_ShouldThrowException_WhenClassEmpty() {
        UUID classId = UUID.randomUUID();
        StudentClass studentClass = StudentClass.builder()
                .id(classId)
                .teacherId(teacherId)
                .build();

        when(courseRepository.findById(courseId)).thenReturn(Optional.of(course));
        when(studentClassRepository.findById(classId)).thenReturn(Optional.of(studentClass));
        when(classStudentRepository.findByStudentClassId(classId)).thenReturn(new ArrayList<>());

        assertThatThrownBy(() -> enrollmentService.assignClassToCourse(courseId, classId, teacherId))
                .isInstanceOf(RuntimeException.class)
                .hasMessageContaining("Cannot enroll empty class");
    }

    @Test
    void getStudentEnrollments_ShouldReturnList() {
        when(enrollmentRepository.findByStudentId(studentId)).thenReturn(new ArrayList<>());

        List<EnrollmentDto.EnrollmentResponse> responses = enrollmentService.getStudentEnrollments(studentId);

        assertThat(responses).isEmpty();
    }

    @Test
    void unenrollStudent_ShouldSuccess() {
        when(courseRepository.findById(courseId)).thenReturn(Optional.of(course));
        Enrollment enrollment = new Enrollment();
        when(enrollmentRepository.findByCourse_IdAndStudentId(courseId, studentId)).thenReturn(Optional.of(enrollment));

        enrollmentService.unenrollStudent(courseId, studentId, teacherId);

        verify(enrollmentRepository).delete(enrollment);
    }
}
