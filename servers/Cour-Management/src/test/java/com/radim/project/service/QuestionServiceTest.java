package com.radim.project.service;

import com.radim.project.dto.QuizDto;
import com.radim.project.entity.*;
import com.radim.project.repository.QuestionRepository;
import com.radim.project.repository.QuizRepository;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.MockedStatic;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
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
class QuestionServiceTest {

    @Mock
    private QuestionRepository questionRepository;
    @Mock
    private QuizRepository quizRepository;

    @InjectMocks
    private QuestionService questionService;

    private MockedStatic<SecurityContextHolder> mockedSecurityContextHolder;
    private Long teacherId;
    private UUID quizId;
    private Quiz quiz;

    @BeforeEach
    void setUp() {
        teacherId = 1L;
        quizId = UUID.randomUUID();

        Course course = Course.builder().teacherId(teacherId).build();
        quiz = Quiz.builder().id(quizId).course(course).build();

        mockedSecurityContextHolder = mockStatic(SecurityContextHolder.class);
        SecurityContext securityContext = mock(SecurityContext.class);
        Authentication authentication = mock(Authentication.class);

        mockedSecurityContextHolder.when(SecurityContextHolder::getContext).thenReturn(securityContext);
        when(securityContext.getAuthentication()).thenReturn(authentication);
        when(authentication.getPrincipal()).thenReturn(teacherId.toString());
        doReturn(List.of(new SimpleGrantedAuthority("ROLE_TEACHER"))).when(authentication).getAuthorities();
    }

    @AfterEach
    void tearDown() {
        mockedSecurityContextHolder.close();
    }

    @Test
    void createQuestion_ShouldSuccess() {
        when(quizRepository.findById(quizId)).thenReturn(Optional.of(quiz));

        QuizDto.QuestionRequest request = QuizDto.QuestionRequest.builder()
                .questionText("What is Java?")
                .questionType("MULTIPLE_CHOICE")
                .points(10)
                .options(List.of(
                        new QuizDto.OptionRequest("A language", true),
                        new QuizDto.OptionRequest("A coffee", false)))
                .build();

        Question question = Question.builder()
                .id(UUID.randomUUID())
                .quiz(quiz)
                .questionText(request.getQuestionText())
                .options(new ArrayList<>())
                .build();

        when(questionRepository.save(any(Question.class))).thenReturn(question);

        QuizDto.QuestionResponse response = questionService.createQuestion(quizId, request);

        assertThat(response).isNotNull();
        verify(questionRepository).save(any(Question.class));
    }
}
