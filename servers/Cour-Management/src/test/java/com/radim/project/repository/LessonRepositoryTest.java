package com.radim.project.repository;

import com.radim.project.entity.Course;
import com.radim.project.entity.Lesson;
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
@DisplayName("LessonRepository Integration Tests")
class LessonRepositoryTest {

    @Autowired
    private LessonRepository lessonRepository;

    @Autowired
    private TestEntityManager entityManager;

    private Course testCourse;
    private com.radim.project.entity.Module testModule;
    private Lesson lesson1;
    private Lesson lesson2;

    @BeforeEach
    void setUp() {
        testCourse = Course.builder()
                .title("Java Course")
                .description("Learn Java")
                .category("Programming")
                .level(CourseLevel.BEGINNER)
                .teacherId(1L)
                .build();

        testCourse = entityManager.persistAndFlush(testCourse);

        testModule = com.radim.project.entity.Module.builder()
                .title("Module 1")
                .course(testCourse)
                .orderIndex(1)
                .build();

        testModule = entityManager.persistAndFlush(testModule);

        lesson1 = Lesson.builder()
                .title("Lesson 1: Introduction")
                .module(testModule)
                .orderIndex(1)
                .build();

        lesson2 = Lesson.builder()
                .title("Lesson 2: Variables")
                .module(testModule)
                .orderIndex(2)
                .build();
    }

    @Test
    @DisplayName("Should save lesson successfully")
    void save_Success() {
        // When
        Lesson saved = lessonRepository.save(lesson1);

        // Then
        assertThat(saved.getId()).isNotNull();
        assertThat(saved.getTitle()).isEqualTo("Lesson 1: Introduction");
        assertThat(saved.getModule().getId()).isEqualTo(testModule.getId());
    }

    @Test
    @DisplayName("Should find lesson by ID")
    void findById_Success() {
        // Given
        Lesson saved = entityManager.persistAndFlush(lesson1);

        // When
        Optional<Lesson> found = lessonRepository.findById(saved.getId());

        // Then
        assertThat(found).isPresent();
        assertThat(found.get().getTitle()).isEqualTo("Lesson 1: Introduction");
    }

    @Test
    @DisplayName("Should find lessons by module ID ordered")
    void findByModuleIdOrderByOrderIndexAsc_Success() {
        // Given
        entityManager.persist(lesson2);
        entityManager.persist(lesson1);
        entityManager.flush();

        // When
        List<Lesson> lessons = lessonRepository.findByModuleIdOrderByOrderIndexAsc(testModule.getId());

        // Then
        assertThat(lessons).hasSize(2);
        assertThat(lessons.get(0).getOrderIndex()).isEqualTo(1);
        assertThat(lessons.get(1).getOrderIndex()).isEqualTo(2);
    }

    @Test
    @DisplayName("Should return empty list when no lessons for module")
    void findByModuleIdOrderByOrderIndexAsc_Empty() {
        // Given
        UUID nonExistentModuleId = UUID.randomUUID();

        // When
        List<Lesson> lessons = lessonRepository.findByModuleIdOrderByOrderIndexAsc(nonExistentModuleId);

        // Then
        assertThat(lessons).isEmpty();
    }

    @Test
    @DisplayName("Should delete lesson successfully")
    void delete_Success() {
        // Given
        Lesson saved = entityManager.persistAndFlush(lesson1);
        UUID lessonId = saved.getId();

        // When
        lessonRepository.delete(saved);
        entityManager.flush();
        entityManager.clear();

        // Then
        Optional<Lesson> found = lessonRepository.findById(lessonId);
        assertThat(found).isEmpty();
    }
}
