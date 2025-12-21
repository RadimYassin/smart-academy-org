package com.radim.project.repository;

import com.radim.project.entity.Course;
import com.radim.project.entity.Quiz;
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
@DisplayName("QuizRepository Integration Tests")
class QuizRepositoryTest {

    @Autowired
    private QuizRepository quizRepository;

    @Autowired
    private TestEntityManager entityManager;

    private Course testCourse;
    private Quiz quiz1;
    private Quiz quiz2;

    @BeforeEach
    void setUp() {
        testCourse = Course.builder()
                .title("Java Programming")
                .description("Learn Java")
                .category("Programming")
                .level(CourseLevel.BEGINNER)
                .teacherId(1L)
                .build();

        testCourse = entityManager.persistAndFlush(testCourse);

        quiz1 = Quiz.builder()
                .title("Java Basics Quiz")
                .description("Test your Java knowledge")
                .course(testCourse)
                .passingScore(70)
                .difficulty(QuizDifficulty.EASY)
                .mandatory(true)
                .build();

        quiz2 = Quiz.builder()
                .title("Advanced Java Quiz")
                .description("Advanced concepts")
                .course(testCourse)
                .passingScore(80)
                .difficulty(QuizDifficulty.HARD)
                .mandatory(false)
                .build();
    }

    @Test
    @DisplayName("Should save quiz successfully")
    void save_Success() {
        // When
        Quiz saved = quizRepository.save(quiz1);

        // Then
        assertThat(saved.getId()).isNotNull();
        assertThat(saved.getTitle()).isEqualTo("Java Basics Quiz");
        assertThat(saved.getCourse().getId()).isEqualTo(testCourse.getId());
    }

    @Test
    @DisplayName("Should find quiz by ID")
    void findById_Success() {
        // Given
        Quiz saved = entityManager.persistAndFlush(quiz1);

        // When
        Optional<Quiz> found = quizRepository.findById(saved.getId());

        // Then
        assertThat(found).isPresent();
        assertThat(found.get().getTitle()).isEqualTo("Java Basics Quiz");
    }

    @Test
    @DisplayName("Should find quizzes by course ID")
    void findByCourseId_Success() {
        // Given
        entityManager.persist(quiz1);
        entityManager.persist(quiz2);
        entityManager.flush();

        // When
        List<Quiz> quizzes = quizRepository.findByCourseId(testCourse.getId());

        // Then
        assertThat(quizzes).hasSize(2);
    }

    @Test
    @DisplayName("Should find mandatory quizzes for course")
    void findByCourse_IdAndMandatoryTrue_Success() {
        // Given
        entityManager.persist(quiz1);
        entityManager.persist(quiz2);
        entityManager.flush();

        // When
        List<Quiz> mandatoryQuizzes = quizRepository.findByCourse_IdAndMandatoryTrue(testCourse.getId());

        // Then
        assertThat(mandatoryQuizzes).hasSize(1);
        assertThat(mandatoryQuizzes.get(0).getMandatory()).isTrue();
        assertThat(mandatoryQuizzes.get(0).getTitle()).isEqualTo("Java Basics Quiz");
    }

    @Test
    @DisplayName("Should delete quiz successfully")
    void delete_Success() {
        // Given
        Quiz saved = entityManager.persistAndFlush(quiz1);
        UUID quizId = saved.getId();

        // When
        quizRepository.delete(saved);
        entityManager.flush();
        entityManager.clear();

        // Then
        Optional<Quiz> found = quizRepository.findById(quizId);
        assertThat(found).isEmpty();
    }

    @Test
    @DisplayName("Should return empty list when no quizzes for course")
    void findByCourseId_Empty() {
        // Given
        UUID nonExistentCourseId = UUID.randomUUID();

        // When
        List<Quiz> quizzes = quizRepository.findByCourseId(nonExistentCourseId);

        // Then
        assertThat(quizzes).isEmpty();
    }
}
