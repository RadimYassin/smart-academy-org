package com.radim.project.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.radim.project.dto.QuizAttemptDto;
import com.radim.project.service.QuizAttemptService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.MediaType;
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configurers.AbstractHttpConfigurer;
import org.springframework.security.test.context.support.WithMockUser;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.web.servlet.MockMvc;

import java.util.Arrays;
import java.util.List;
import java.util.UUID;

import static org.hamcrest.Matchers.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.csrf;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@WebMvcTest(QuizAttemptController.class)
@ActiveProfiles(" test\)
@ContextConfiguration(classes = { QuizAttemptController.class, QuizAttemptControllerTest.TestSecurityConfig.class })
@DisplayName("QuizAttemptController Web Layer Tests")
class QuizAttemptControllerTest {

    @Configuration
    @EnableWebSecurity
    @EnableMethodSecurity
    static class TestSecurityConfig {
        @Bean
        public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
            http.csrf(AbstractHttpConfigurer::disable)
                    .authorizeHttpRequests(auth -> auth.anyRequest().permitAll());
            return http.build();
        }
    }

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @MockBean
    private QuizAttemptService quizAttemptService;

    private QuizAttemptDto.AttemptResponse attemptResponse;
    private final UUID quizId = UUID.randomUUID();
    private final Long studentId = 100L;

    @BeforeEach
    void setUp() {
        attemptResponse = QuizAttemptDto.AttemptResponse.builder()
                .id(UUID.randomUUID())
                .quizId(quizId)
                .studentId(studentId)
                .score(85)
                .percentage(85.0)
                .passed(true)
                .build();
    }

    @Test
    @WithMockUser(username = "100", roles = "STUDENT")
    @DisplayName("Should start quiz attempt")
    void startQuizAttempt_Success() throws Exception {
        // Given
        when(quizAttemptService.startQuizAttempt(quizId)).thenReturn(attemptResponse);

        // When & Then
        mockMvc.perform(post("/api/quiz-attempts/start/{quizId}", quizId)
                .with(csrf())
                .contentType(MediaType.APPLICATION_JSON))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.studentId", is(studentId.intValue())));

        verify(quizAttemptService).startQuizAttempt(quizId);
    }

    @Test
    @WithMockUser(username = "100", roles = "STUDENT")
    @DisplayName("Should submit quiz attempt")
    void submitQuizAttempt_Success() throws Exception {
        // Given
        UUID attemptId = UUID.randomUUID();
        QuizAttemptDto.SubmitRequest submitRequest = QuizAttemptDto.SubmitRequest.builder().build();
        when(quizAttemptService.submitQuizAttempt(any(UUID.class), any(QuizAttemptDto.SubmitRequest.class)))
                .thenReturn(attemptResponse);

        // When & Then
        mockMvc.perform(post("/api/quiz-attempts/{attemptId}/submit", attemptId)
                .with(csrf())
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(submitRequest)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.passed", is(true)));

        verify(quizAttemptService).submitQuizAttempt(any(UUID.class), any(QuizAttemptDto.SubmitRequest.class));
    }

    @Test
    @WithMockUser(username = "100", roles = "STUDENT")
    @DisplayName("Should get student attempts")
    void getStudentAttempts_Success() throws Exception {
        // Given
        List<QuizAttemptDto.AttemptResponse> attempts = Arrays.asList(attemptResponse);
        when(quizAttemptService.getStudentAttempts(studentId)).thenReturn(attempts);

        // When & Then
        mockMvc.perform(get("/api/quiz-attempts/student/{studentId}", studentId)
                .contentType(MediaType.APPLICATION_JSON))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$", hasSize(1)));

        verify(quizAttemptService).getStudentAttempts(studentId);
    }

    @Test
    @WithMockUser(roles = "TEACHER")
    @DisplayName("Should get quiz attempts as teacher")
    void getQuizAttempts_AsTeacher_Success() throws Exception {
        // Given
        List<QuizAttemptDto.AttemptResponse> attempts = Arrays.asList(attemptResponse);
        when(quizAttemptService.getQuizAttempts(quizId)).thenReturn(attempts);

        // When & Then
        mockMvc.perform(get("/api/quiz-attempts/quiz/{quizId}", quizId)
                .contentType(MediaType.APPLICATION_JSON))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$", hasSize(1)));

        verify(quizAttemptService).getQuizAttempts(quizId);
    }
}

