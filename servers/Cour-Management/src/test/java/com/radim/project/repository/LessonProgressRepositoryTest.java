package com.radim.project.repository;

import com.radim.project.entity.*;
import com.radim.project.entity.enums.CourseLevel;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.orm.jpa.DataJpaTest;
import org.springframework.boot.test.autoconfigure.orm.jpa.TestEntityManager;

import java.util.Optional;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;

@DataJpaTest
@DisplayName("LessonProgressRepository Integration Tests")
class LessonProgressRepositoryTest {

    @Autowired
    private LessonProgressRepository lessonProgressRepository;

    @Autowired
    private TestEntityManager entityManager;

    private Lesson testLesson;
    private LessonProgress progress1;
    private final Long studentId1 = 100L;

    @BeforeEach
    void setUp() {
        Course testCourse = Course.builder()
                .title("Java Course")
                .description("Learn Java")
                .category("Programming")
                .level(CourseLevel.BEGINNER)
                .teacherId(1L)
                .build();
        testCourse = entityManager.persistAndFlush(testCourse);

        com.radim.project.entity.Module testModule = com.radim.project.entity.Module.builder()
                .title("Module 1")
                .course(testCourse)
                .orderIndex(1)
                .build();
        testModule = entityManager.persistAndFlush(testModule);

        testLesson = Lesson.builder()
                .title("Lesson 1")
                .module(testModule)
                .orderIndex(1)
                .build();
        testLesson = entityManager.persistAndFlush(testLesson);

        progress1 = LessonProgress.builder()
                .lesson(testLesson)
                .studentId(studentId1)
                .completed(true)
                .build();
    }

    @Test
    @DisplayName("Should save lesson progress successfully")
    void save_Success() {
        // When
        LessonProgress saved = lessonProgressRepository.save(progress1);

        // Then
        assertThat(saved.getId()).isNotNull();
        assertThat(saved.getCompleted()).isTrue();
        assertThat(saved.getStudentId()).isEqualTo(studentId1);
    }

    @Test
    @DisplayName("Should find progress by student and lesson ID")
    void findByLessonIdAndStudentId_Success() {
        // Given
        entityManager.persistAndFlush(progress1);

        // When
        Optional<LessonProgress> found = lessonProgressRepository
                .findByLesson_IdAndStudentId(testLesson.getId(), studentId1);

        // Then
        assertThat(found).isPresent();
        assertThat(found.get().getCompleted()).isTrue();
    }

    @Test
    @DisplayName("Should delete progress successfully")
    void delete_Success() {
        // Given
        LessonProgress saved = entityManager.persistAndFlush(progress1);
        UUID progressId = saved.getId();

        // When
        lessonProgressRepository.delete(saved);
        entityManager.flush();
        entityManager.clear();

        // Then
        Optional<LessonProgress> found = lessonProgressRepository.findById(progressId);
        assertThat(found).isEmpty();
    }
}
