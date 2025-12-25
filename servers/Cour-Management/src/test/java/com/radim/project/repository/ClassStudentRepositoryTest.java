package com.radim.project.repository;

import com.radim.project.entity.*;
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
@DisplayName("ClassStudentRepository Integration Tests")
class ClassStudentRepositoryTest {

    @Autowired
    private ClassStudentRepository classStudentRepository;

    @Autowired
    private TestEntityManager entityManager;

    private StudentClass testClass;
    private ClassStudent classStudent1;
    private final Long studentId1 = 100L;
    private final Long studentId2 = 200L;

    @BeforeEach
    void setUp() {
        testClass = StudentClass.builder()
                .name("Java 101")
                .description("Beginner Java class")
                .teacherId(1L)
                .build();
        testClass = entityManager.persistAndFlush(testClass);

        classStudent1 = ClassStudent.builder()
                .studentClass(testClass)
                .studentId(studentId1)
                .addedBy(1L)
                .build();
    }

    @Test
    @DisplayName("Should save class student successfully")
    void save_Success() {
        // When
        ClassStudent saved = classStudentRepository.save(classStudent1);

        // Then
        assertThat(saved.getId()).isNotNull();
        assertThat(saved.getStudentId()).isEqualTo(studentId1);
    }

    @Test
    @DisplayName("Should find by student class ID")
    void findByStudentClassId_Success() {
        // Given
        entityManager.persist(classStudent1);
        entityManager.flush();

        // When
        List<ClassStudent> students = classStudentRepository.findByStudentClassId(testClass.getId());

        // Then
        assertThat(students).hasSize(1);
        assertThat(students.get(0).getStudentId()).isEqualTo(studentId1);
    }

    @Test
    @DisplayName("Should delete class student successfully")
    void delete_Success() {
        // Given
        ClassStudent saved = entityManager.persistAndFlush(classStudent1);
        UUID id = saved.getId();

        // When
        classStudentRepository.delete(saved);
        entityManager.flush();
        entityManager.clear();

        // Then
        Optional<ClassStudent> found = classStudentRepository.findById(id);
        assertThat(found).isEmpty();
    }
}
