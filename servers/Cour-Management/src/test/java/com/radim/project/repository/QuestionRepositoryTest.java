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
@DisplayName("QuestionRepository Integration Tests")
class QuestionRepositoryTest {

    @Autowired
    private QuestionRepository questionRepository;

    @Autowired
    private TestEntityManager entityManager;

    private Quiz testQuiz;
    private Question question1;
    private Question question2;

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

        testQuiz = Quiz.builder()
                .title("Java Quiz")
                .description("Test quiz")
                .course(testCourse)
                .passingScore(70)
                .difficulty(QuizDifficulty.EASY)
                .mandatory(true)
                .build();
        testQuiz = entityManager.persistAndFlush(testQuiz);

        question1 = new Question();
        question1.setQuiz(testQuiz);
        question1.setQuestionText("What is Java?");
        question1.setQuestionType("MULTIPLE_CHOICE");
        question1.setPoints(10);

        question2 = new Question();
        question2.setQuiz(testQuiz);
        question2.setQuestionText("What is OOP?");
        question2.setQuestionType("MULTIPLE_CHOICE");
        question2.setPoints(15);
    }

    @Test
    @DisplayName("Should save question successfully")
    void save_Success() {
        // When
        Question saved = questionRepository.save(question1);

        // Then
        assertThat(saved.getId()).isNotNull();
        assertThat(saved.getQuestionText()).isEqualTo("What is Java?");
        assertThat(saved.getPoints()).isEqualTo(10);
    }

    @Test
    @DisplayName("Should find question by ID")
    void findById_Success() {
        // Given
        Question saved = entityManager.persistAndFlush(question1);

        // When
        Optional<Question> found = questionRepository.findById(saved.getId());

        // Then
        assertThat(found).isPresent();
        assertThat(found.get().getQuestionText()).isEqualTo("What is Java?");
    }

    @Test
    @DisplayName("Should find questions by quiz ID")
    void findByQuizId_Success() {
        // Given
        entityManager.persist(question1);
        entityManager.persist(question2);
        entityManager.flush();

        // When
        List<Question> questions = questionRepository.findByQuizId(testQuiz.getId());

        // Then
        assertThat(questions).hasSize(2);
    }

    @Test
    @DisplayName("Should return empty list when no questions for quiz")
    void findByQuizId_Empty() {
        // Given
        UUID nonExistentQuizId = UUID.randomUUID();

        // When
        List<Question> questions = questionRepository.findByQuizId(nonExistentQuizId);

        // Then
        assertThat(questions).isEmpty();
    }

    @Test
    @DisplayName("Should delete question successfully")
    void delete_Success() {
        // Given
        Question saved = entityManager.persistAndFlush(question1);
        UUID questionId = saved.getId();

        // When
        questionRepository.delete(saved);
        entityManager.flush();
        entityManager.clear();

        // Then
        Optional<Question> found = questionRepository.findById(questionId);
        assertThat(found).isEmpty();
    }
}
