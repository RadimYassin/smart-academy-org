package com.radim.project.repository;

import com.radim.project.entity.*;
import com.radim.project.entity.enums.CourseLevel;
import com.radim.project.entity.enums.QuizDifficulty;
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
@DisplayName("QuizAttemptRepository Integration Tests")
class QuizAttemptRepositoryTest {

    @Autowired
    private QuizAttemptRepository quizAttemptRepository;

    @Autowired
    private TestEntityManager entityManager;

    private Course testCourse;
    private Quiz testQuiz;
    private QuizAttempt attempt1;
    private QuizAttempt attempt2;
    private final Long studentId1 = 100L;
    private final Long studentId2 = 200L;

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

        testQuiz = Quiz.builder()
                .title("Java Quiz")
                .description("Test quiz")
                .course(testCourse)
                .passingScore(70)
                .difficulty(QuizDifficulty.EASY)
                .mandatory(true)
                .build();
        testQuiz = entityManager.persistAndFlush(testQuiz);

        attempt1 = QuizAttempt.builder()
                .quiz(testQuiz)
                .studentId(studentId1)
                .score(85)
                .maxScore(100)
                .percentage(85.0)
                .passed(true)
                .startedAt(java.time.LocalDateTime.now())
                .build();

        attempt2 = QuizAttempt.builder()
                .quiz(testQuiz)
                .studentId(studentId2)
                .score(60)
                .maxScore(100)
                .percentage(60.0)
                .passed(false)
                .startedAt(java.time.LocalDateTime.now())
                .build();
    }

    @Test
    @DisplayName("Should save quiz attempt successfully")
    void save_Success() {
        // When
        QuizAttempt saved = quizAttemptRepository.save(attempt1);

        // Then
        assertThat(saved.getId()).isNotNull();
        assertThat(saved.getScore()).isEqualTo(85);
        assertThat(saved.getPassed()).isTrue();
    }

    @Test
    @DisplayName("Should find quiz attempt by ID")
    void findById_Success() {
        // Given
        QuizAttempt saved = entityManager.persistAndFlush(attempt1);

        // When
        Optional<QuizAttempt> found = quizAttemptRepository.findById(saved.getId());

        // Then
        assertThat(found).isPresent();
        assertThat(found.get().getScore()).isEqualTo(85);
    }

    @Test
    @DisplayName("Should find attempts by student ID")
    void findByStudentId_Success() {
        // Given
        QuizAttempt otherAttempt = QuizAttempt.builder()
                .quiz(testQuiz)
                .studentId(studentId1)
                .score(75)
                .maxScore(100)
                .percentage(75.0)
                .passed(true)
                .startedAt(java.time.LocalDateTime.now())
                .build();

        entityManager.persist(attempt1);
        entityManager.persist(otherAttempt);
        entityManager.flush();

        // When
        List<QuizAttempt> attempts = quizAttemptRepository.findByStudentId(studentId1);

        // Then
        assertThat(attempts).hasSize(2);
        assertThat(attempts).allMatch(a -> a.getStudentId().equals(studentId1));
    }

    @Test
    @DisplayName("Should find attempts by quiz ID")
    void findByQuizId_Success() {
        // Given
        entityManager.persist(attempt1);
        entityManager.persist(attempt2);
        entityManager.flush();

        // When
        List<QuizAttempt> attempts = quizAttemptRepository.findByQuizId(testQuiz.getId());

        // Then
        assertThat(attempts).hasSize(2);
    }

    @Test
    @DisplayName("Should delete quiz attempt successfully")
    void delete_Success() {
        // Given
        QuizAttempt saved = entityManager.persistAndFlush(attempt1);
        UUID attemptId = saved.getId();

        // When
        quizAttemptRepository.delete(saved);
        entityManager.flush();
        entityManager.clear();

        // Then
        Optional<QuizAttempt> found = quizAttemptRepository.findById(attemptId);
        assertThat(found).isEmpty();
    }
}
