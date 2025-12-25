package com.radim.project.repository;

import com.radim.project.entity.*;
import com.radim.project.entity.enums.CourseLevel;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.orm.jpa.DataJpaTest;
import org.springframework.boot.test.autoconfigure.orm.jpa.TestEntityManager;
import org.springframework.test.context.ActiveProfiles;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;

@DataJpaTest
@ActiveProfiles("test")
@DisplayName("StudentClassRepository Integration Tests")
class StudentClassRepositoryTest {

    @Autowired
    private StudentClassRepository studentClassRepository;

    @Autowired
    private TestEntityManager entityManager;

    private StudentClass testClass;
    private final Long teacherId = 1L;

    @BeforeEach
    void setUp() {
        testClass = StudentClass.builder()
                .name("Java 101")
                .description("Beginner Java class")
                .teacherId(teacherId)
                .build();
    }

    @Test
    @DisplayName("Should save student class successfully")
    void save_Success() {
        // When
        StudentClass saved = studentClassRepository.save(testClass);

        // Then
        assertThat(saved.getId()).isNotNull();
        assertThat(saved.getName()).isEqualTo("Java 101");
        assertThat(saved.getTeacherId()).isEqualTo(teacherId);
    }

    @Test
    @DisplayName("Should find student class by ID")
    void findById_Success() {
        // Given
        StudentClass saved = entityManager.persistAndFlush(testClass);

        // When
        Optional<StudentClass> found = studentClassRepository.findById(saved.getId());

        // Then
        assertThat(found).isPresent();
        assertThat(found.get().getName()).isEqualTo("Java 101");
    }

    @Test
    @DisplayName("Should find classes by teacher ID")
    void findByTeacherId_Success() {
        // Given
        entityManager.persistAndFlush(testClass);

        // When
        List<StudentClass> classes = studentClassRepository.findByTeacherId(teacherId);

        // Then
        assertThat(classes).hasSize(1);
        assertThat(classes.get(0).getTeacherId()).isEqualTo(teacherId);
    }

    @Test
    @DisplayName("Should delete student class successfully")
    void delete_Success() {
        // Given
        StudentClass saved = entityManager.persistAndFlush(testClass);
        UUID classId = saved.getId();

        // When
        studentClassRepository.delete(saved);
        entityManager.flush();
        entityManager.clear();

        // Then
        Optional<StudentClass> found = studentClassRepository.findById(classId);
        assertThat(found).isEmpty();
    }
}
