package com.radim.project.repository;

import com.radim.project.entity.Course;
import com.radim.project.entity.Enrollment;
import com.radim.project.entity.enums.AssignmentType;
import com.radim.project.entity.enums.CourseLevel;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.orm.jpa.DataJpaTest;
import org.springframework.boot.test.autoconfigure.orm.jpa.TestEntityManager;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;

@DataJpaTest
@DisplayName("EnrollmentRepository Integration Tests")
class EnrollmentRepositoryTest {

    @Autowired
    private EnrollmentRepository enrollmentRepository;

    @Autowired
    private TestEntityManager entityManager;

    private Course testCourse;
    private Enrollment enrollment1;
    private Enrollment enrollment2;
    private final Long studentId1 = 100L;
    private final Long studentId2 = 200L;
    private final Long teacherId = 1L;

    @BeforeEach
    void setUp() {
        testCourse = Course.builder()
                .title("Test Course")
                .description("Test Description")
                .category("Programming")
                .level(CourseLevel.BEGINNER)
                .teacherId(teacherId)
                .build();

        testCourse = entityManager.persistAndFlush(testCourse);

        enrollment1 = Enrollment.builder()
                .course(testCourse)
                .studentId(studentId1)
                .assignedBy(teacherId)
                .assignmentType(AssignmentType.INDIVIDUAL)
                .build();

        enrollment2 = Enrollment.builder()
                .course(testCourse)
                .studentId(studentId2)
                .assignedBy(teacherId)
                .assignmentType(AssignmentType.INDIVIDUAL)
                .build();
    }

    @Test
    @DisplayName("Should save enrollment successfully")
    void save_Success() {
        // When
        Enrollment saved = enrollmentRepository.save(enrollment1);

        // Then
        assertThat(saved.getId()).isNotNull();
        assertThat(saved.getStudentId()).isEqualTo(studentId1);
        assertThat(saved.getCourse().getId()).isEqualTo(testCourse.getId());
    }

    @Test
    @DisplayName("Should find enrollments by course ID")
    void findByCourse_Id_Success() {
        // Given
        entityManager.persist(enrollment1);
        entityManager.persist(enrollment2);
        entityManager.flush();

        // When
        List<Enrollment> enrollments = enrollmentRepository.findByCourse_Id(testCourse.getId());

        // Then
        assertThat(enrollments).hasSize(2);
        assertThat(enrollments).extracting(Enrollment::getStudentId)
                .containsExactlyInAnyOrder(studentId1, studentId2);
    }

    @Test
    @DisplayName("Should find enrollments by student ID")
    void findByStudentId_Success() {
        // Given
        entityManager.persist(enrollment1);
        entityManager.flush();

        // When
        List<Enrollment> enrollments = enrollmentRepository.findByStudentId(studentId1);

        // Then
        assertThat(enrollments).hasSize(1);
        assertThat(enrollments.get(0).getStudentId()).isEqualTo(studentId1);
    }

    @Test
    @DisplayName("Should find specific enrollment by course and student ID")
    void findByCourse_IdAndStudentId_Success() {
        // Given
        entityManager.persistAndFlush(enrollment1);

        // When
        Optional<Enrollment> found = enrollmentRepository.findByCourse_IdAndStudentId(
                testCourse.getId(), studentId1);

        // Then
        assertThat(found).isPresent();
        assertThat(found.get().getStudentId()).isEqualTo(studentId1);
        assertThat(found.get().getCourse().getId()).isEqualTo(testCourse.getId());
    }

    @Test
    @DisplayName("Should return empty when enrollment not found")
    void findByCourse_IdAndStudentId_NotFound() {
        // When
        Optional<Enrollment> found = enrollmentRepository.findByCourse_IdAndStudentId(
                testCourse.getId(), 999L);

        // Then
        assertThat(found).isEmpty();
    }

    @Test
    @DisplayName("Should check if enrollment exists")
    void existsByCourse_IdAndStudentId_True() {
        // Given
        entityManager.persistAndFlush(enrollment1);

        // When
        boolean exists = enrollmentRepository.existsByCourse_IdAndStudentId(
                testCourse.getId(), studentId1);

        // Then
        assertThat(exists).isTrue();
    }

    @Test
    @DisplayName("Should return false when enrollment does not exist")
    void existsByCourse_IdAndStudentId_False() {
        // When
        boolean exists = enrollmentRepository.existsByCourse_IdAndStudentId(
                testCourse.getId(), 999L);

        // Then
        assertThat(exists).isFalse();
    }

    @Test
    @DisplayName("Should delete enrollment successfully")
    void delete_Success() {
        // Given
        Enrollment saved = entityManager.persistAndFlush(enrollment1);
        UUID enrollmentId = saved.getId();

        // When
        enrollmentRepository.delete(saved);
        entityManager.flush();
        entityManager.clear();

        // Then
        Optional<Enrollment> found = enrollmentRepository.findById(enrollmentId);
        assertThat(found).isEmpty();
    }
}
