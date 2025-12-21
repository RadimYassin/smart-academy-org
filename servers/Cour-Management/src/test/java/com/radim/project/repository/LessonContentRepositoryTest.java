package com.radim.project.repository;

import com.radim.project.entity.*;
import com.radim.project.entity.enums.ContentType;
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
@DisplayName("LessonContentRepository Integration Tests")
class LessonContentRepositoryTest {

    @Autowired
    private LessonContentRepository lessonContentRepository;

    @Autowired
    private TestEntityManager entityManager;

    private Lesson testLesson;
    private LessonContent content1;

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

        content1 = LessonContent.builder()
                .lesson(testLesson)
                .type(ContentType.VIDEO)
                .videoUrl("https://example.com/video.mp4")
                .orderIndex(1)
                .build();
    }

    @Test
    @DisplayName("Should save lesson content successfully")
    void save_Success() {
        // When
        LessonContent saved = lessonContentRepository.save(content1);

        // Then
        assertThat(saved.getId()).isNotNull();
        assertThat(saved.getType()).isEqualTo(ContentType.VIDEO);
        assertThat(saved.getVideoUrl()).isEqualTo("https://example.com/video.mp4");
    }

    @Test
    @DisplayName("Should find content by lesson ID ordered")
    void findByLessonIdOrderByOrderIndexAsc_Success() {
        // Given
        entityManager.persistAndFlush(content1);

        // When
        var contents = lessonContentRepository.findByLessonIdOrderByOrderIndexAsc(testLesson.getId());

        // Then
        assertThat(contents).hasSize(1);
        assertThat(contents.get(0).getType()).isEqualTo(ContentType.VIDEO);
    }

    @Test
    @DisplayName("Should delete lesson content successfully")
    void delete_Success() {
        // Given
        LessonContent saved = entityManager.persistAndFlush(content1);
        UUID contentId = saved.getId();

        // When
        lessonContentRepository.delete(saved);
        entityManager.flush();
        entityManager.clear();

        // Then
        Optional<LessonContent> found = lessonContentRepository.findById(contentId);
        assertThat(found).isEmpty();
    }
}
