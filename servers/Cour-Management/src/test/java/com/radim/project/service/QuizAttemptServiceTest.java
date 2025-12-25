package com.radim.project.service;

import com.radim.project.dto.QuizAttemptDto;
import com.radim.project.entity.*;
import com.radim.project.repository.*;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.MockedStatic;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContext;
import org.springframework.security.core.context.SecurityContextHolder;

import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class QuizAttemptServiceTest {

    @Mock
    private QuizAttemptRepository quizAttemptRepository;
    @Mock
    private StudentAnswerRepository studentAnswerRepository;
    @Mock
    private QuizRepository quizRepository;
    @Mock
    private QuestionRepository questionRepository;

    @InjectMocks
    private QuizAttemptService quizAttemptService;

    private MockedStatic<SecurityContextHolder> mockedSecurityContextHolder;
    private Long studentId;
    private UUID quizId;
    private Quiz quiz;

    @BeforeEach
    void setUp() {
        studentId = 1L;
        quizId = UUID.randomUUID();

        // Mock SecurityContext
        mockedSecurityContextHolder = mockStatic(SecurityContextHolder.class);
        SecurityContext securityContext = mock(SecurityContext.class);
        Authentication authentication = mock(Authentication.class);

        mockedSecurityContextHolder.when(SecurityContextHolder::getContext).thenReturn(securityContext);
        when(securityContext.getAuthentication()).thenReturn(authentication);
        when(authentication.getPrincipal()).thenReturn(studentId.toString());

        quiz = Quiz.builder()
                .id(quizId)
                .title("Test Quiz")
                .questions(new ArrayList<>())
                .passingScore(80)
                .build();
    }

    @AfterEach
    void tearDown() {
        mockedSecurityContextHolder.close();
    }

    @Test
    void startQuizAttempt_ShouldSuccess() {
        when(quizRepository.findById(quizId)).thenReturn(Optional.of(quiz));

        QuizAttempt attempt = QuizAttempt.builder()
                .id(UUID.randomUUID())
                .quiz(quiz)
                .studentId(studentId)
                .build();

        when(quizAttemptRepository.save(any(QuizAttempt.class))).thenReturn(attempt);

        QuizAttemptDto.AttemptResponse response = quizAttemptService.startQuizAttempt(quizId);

        assertThat(response).isNotNull();
        assertThat(response.getStudentId()).isEqualTo(studentId);
        verify(quizAttemptRepository).save(any(QuizAttempt.class));
    }

    @Test
    void submitQuizAttempt_ShouldSuccess() {
        UUID attemptId = UUID.randomUUID();
        QuizAttempt attempt = QuizAttempt.builder()
                .id(attemptId)
                .quiz(quiz)
                .studentId(studentId)
                .maxScore(1)
                .build();

        when(quizAttemptRepository.findById(attemptId)).thenReturn(Optional.of(attempt));

        UUID questionId = UUID.randomUUID();
        UUID optionId = UUID.randomUUID();
        QuestionOption option = QuestionOption.builder().id(optionId).isCorrect(true).build();
        Question question = Question.builder().id(questionId).options(List.of(option)).build();

        when(questionRepository.findById(questionId)).thenReturn(Optional.of(question));

        QuizAttemptDto.SubmitRequest.AnswerSubmission submission = new QuizAttemptDto.SubmitRequest.AnswerSubmission();
        submission.setQuestionId(questionId);
        submission.setSelectedOptionId(optionId);

        QuizAttemptDto.SubmitRequest request = new QuizAttemptDto.SubmitRequest();
        request.setAnswers(List.of(submission));

        when(quizAttemptRepository.save(any(QuizAttempt.class))).thenAnswer(invocation -> invocation.getArgument(0));

        QuizAttemptDto.AttemptResponse response = quizAttemptService.submitQuizAttempt(attemptId, request);

        assertThat(response.getScore()).isEqualTo(1);
        assertThat(response.getPassed()).isTrue();
        verify(studentAnswerRepository).saveAll(anyList());
    }

    @Test
    void submitQuizAttempt_ShouldThrowException_WhenNotAuthorized() {
        UUID attemptId = UUID.randomUUID();
        QuizAttempt attempt = QuizAttempt.builder()
                .id(attemptId)
                .studentId(999L)
                .build();

        when(quizAttemptRepository.findById(attemptId)).thenReturn(Optional.of(attempt));

        assertThatThrownBy(() -> quizAttemptService.submitQuizAttempt(attemptId, new QuizAttemptDto.SubmitRequest()))
                .isInstanceOf(RuntimeException.class)
                .hasMessage("Not authorized to submit this attempt");
    }

    @Test
    void submitQuizAttempt_ShouldThrowException_WhenAlreadySubmitted() {
        UUID attemptId = UUID.randomUUID();
        QuizAttempt attempt = QuizAttempt.builder()
                .id(attemptId)
                .studentId(studentId)
                .submittedAt(java.time.LocalDateTime.now())
                .build();

        when(quizAttemptRepository.findById(attemptId)).thenReturn(Optional.of(attempt));

        assertThatThrownBy(() -> quizAttemptService.submitQuizAttempt(attemptId, new QuizAttemptDto.SubmitRequest()))
                .isInstanceOf(RuntimeException.class)
                .hasMessage("Quiz already submitted");
    }
}
