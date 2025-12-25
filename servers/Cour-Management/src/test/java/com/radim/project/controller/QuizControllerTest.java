package com.radim.project.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.radim.project.dto.QuizDto;
import com.radim.project.entity.enums.QuizDifficulty;
import com.radim.project.service.QuizService;
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

@WebMvcTest(QuizController.class)
@ActiveProfiles(" test\)
@ContextConfiguration(classes = { QuizController.class, QuizControllerTest.TestSecurityConfig.class })
@DisplayName("QuizController Web Layer Tests")
class QuizControllerTest {

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
        private QuizService quizService;

        private QuizDto.Response quizResponse;
        private QuizDto.Request quizRequest;
        private final UUID courseId = UUID.randomUUID();
        private final UUID quizId = UUID.randomUUID();

        @BeforeEach
        void setUp() {
                quizResponse = QuizDto.Response.builder()
                                .id(quizId)
                                .courseId(courseId)
                                .title("Java Quiz")
                                .description("Test your Java knowledge")
                                .difficulty(QuizDifficulty.EASY)
                                .build();

                quizRequest = QuizDto.Request.builder()
                                .title("Java Quiz")
                                .description("Test your Java knowledge")
                                .difficulty(QuizDifficulty.EASY)
                                .build();
        }

        @Test
        @DisplayName("Should get all quizzes for a course")
        void getQuizzes_Success() throws Exception {
                // Given
                List<QuizDto.Response> quizzes = Arrays.asList(quizResponse);
                when(quizService.getQuizzesByCourse(courseId)).thenReturn(quizzes);

                // When & Then
                mockMvc.perform(get("/courses/{courseId}/quizzes", courseId)
                                .contentType(MediaType.APPLICATION_JSON))
                                .andExpect(status().isOk())
                                .andExpect(jsonPath("$", hasSize(1)))
                                .andExpect(jsonPath("$[0].title", is("Java Quiz")));

                verify(quizService).getQuizzesByCourse(courseId);
        }

        @Test
        @DisplayName("Should get quiz by ID")
        void getQuizById_Success() throws Exception {
                // Given
                when(quizService.getQuizById(quizId)).thenReturn(quizResponse);

                // When & Then
                mockMvc.perform(get("/courses/{courseId}/quizzes/{quizId}", courseId, quizId)
                                .contentType(MediaType.APPLICATION_JSON))
                                .andExpect(status().isOk())
                                .andExpect(jsonPath("$.title", is("Java Quiz")));

                verify(quizService).getQuizById(quizId);
        }

        @Test
        @WithMockUser(roles = "TEACHER")
        @DisplayName("Should create quiz as teacher")
        void createQuiz_AsTeacher_Success() throws Exception {
                // Given
                when(quizService.createQuiz(any(UUID.class), any(QuizDto.Request.class)))
                                .thenReturn(quizResponse);

                // When & Then
                mockMvc.perform(post("/courses/{courseId}/quizzes", courseId)
                                .with(csrf())
                                .contentType(MediaType.APPLICATION_JSON)
                                .content(objectMapper.writeValueAsString(quizRequest)))
                                .andExpect(status().isCreated())
                                .andExpect(jsonPath("$.title", is("Java Quiz")));

                verify(quizService).createQuiz(any(UUID.class), any(QuizDto.Request.class));
        }

        @Test
        @WithMockUser(roles = "STUDENT")
        @DisplayName("Should return 403 when student tries to create quiz")
        void createQuiz_AsStudent_Forbidden() throws Exception {
                mockMvc.perform(post("/courses/{courseId}/quizzes", courseId)
                                .with(csrf())
                                .contentType(MediaType.APPLICATION_JSON)
                                .content(objectMapper.writeValueAsString(quizRequest)))
                                .andExpect(status().isForbidden());

                verify(quizService, never()).createQuiz(any(), any());
        }

        @Test
        @WithMockUser(roles = "TEACHER")
        @DisplayName("Should update quiz as teacher")
        void updateQuiz_AsTeacher_Success() throws Exception {
                // Given
                when(quizService.updateQuiz(any(UUID.class), any(UUID.class), any(QuizDto.Request.class)))
                                .thenReturn(quizResponse);

                // When & Then
                mockMvc.perform(put("/courses/{courseId}/quizzes/{quizId}", courseId, quizId)
                                .with(csrf())
                                .contentType(MediaType.APPLICATION_JSON)
                                .content(objectMapper.writeValueAsString(quizRequest)))
                                .andExpect(status().isOk());

                verify(quizService).updateQuiz(any(UUID.class), any(UUID.class), any(QuizDto.Request.class));
        }

        @Test
        @WithMockUser(roles = "TEACHER")
        @DisplayName("Should delete quiz as teacher")
        void deleteQuiz_AsTeacher_Success() throws Exception {
                mockMvc.perform(delete("/courses/{courseId}/quizzes/{quizId}", courseId, quizId)
                                .with(csrf())
                                .contentType(MediaType.APPLICATION_JSON))
                                .andExpect(status().isNoContent());

                verify(quizService).deleteQuiz(courseId, quizId);
        }

        @Test
        @WithMockUser(roles = "STUDENT")
        @DisplayName("Should return 403 when student tries to delete quiz")
        void deleteQuiz_AsStudent_Forbidden() throws Exception {
                mockMvc.perform(delete("/courses/{courseId}/quizzes/{quizId}", courseId, quizId)
                                .with(csrf())
                                .contentType(MediaType.APPLICATION_JSON))
                                .andExpect(status().isForbidden());

                verify(quizService, never()).deleteQuiz(any(), any());
        }
}

