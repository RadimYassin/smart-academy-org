package com.radim.project.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.radim.project.dto.QuizDto;
import com.radim.project.service.QuestionService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.http.MediaType;
import org.springframework.security.test.context.support.WithMockUser;
import org.springframework.test.web.servlet.MockMvc;

import java.util.Arrays;
import java.util.List;
import java.util.UUID;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.*;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.csrf;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

import com.radim.project.config.TestSecurityConfig;
import com.radim.project.security.JwtAuthenticationFilter;
import com.radim.project.security.SecurityConfig;
import org.springframework.context.annotation.Import;
import org.springframework.context.annotation.ComponentScan;
import org.springframework.context.annotation.FilterType;

@WebMvcTest(controllers = QuestionController.class, excludeFilters = {
                @ComponentScan.Filter(type = FilterType.ASSIGNABLE_TYPE, classes = SecurityConfig.class),
                @ComponentScan.Filter(type = FilterType.ASSIGNABLE_TYPE, classes = JwtAuthenticationFilter.class)
})
@Import(TestSecurityConfig.class)
class QuestionControllerTest {

        @Autowired
        private MockMvc mockMvc;

        @Autowired
        private ObjectMapper objectMapper;

        @MockBean
        private QuestionService questionService;

        private UUID quizId;
        private UUID questionId;
        private QuizDto.QuestionRequest questionRequest;
        private QuizDto.QuestionResponse questionResponse;

        @BeforeEach
        void setUp() {
                quizId = UUID.randomUUID();
                questionId = UUID.randomUUID();

                questionRequest = new QuizDto.QuestionRequest();
                questionRequest.setQuestionText("What is Spring Boot?");
                questionRequest.setQuestionType("MULTIPLE_CHOICE");
                questionRequest.setPoints(10);
                questionRequest.setOptions(Arrays.asList(
                                new QuizDto.OptionRequest("Option 1", true),
                                new QuizDto.OptionRequest("Option 2", false)));

                questionResponse = new QuizDto.QuestionResponse();
                questionResponse.setId(questionId);
                questionResponse.setQuestionText("What is Spring Boot?");
                questionResponse.setQuestionType("MULTIPLE_CHOICE");
                questionResponse.setPoints(10);
        }

        @Test
        @WithMockUser
        void testGetQuestions_ValidQuizId_ReturnsQuestionList() throws Exception {
                // Given
                List<QuizDto.QuestionResponse> questions = Arrays.asList(questionResponse);
                when(questionService.getQuestionsByQuiz(quizId)).thenReturn(questions);

                // When & Then
                mockMvc.perform(get("/quizzes/{quizId}/questions", quizId)
                                .with(csrf()))
                                .andExpect(status().isOk())
                                .andExpect(jsonPath("$[0].id").value(questionId.toString()))
                                .andExpect(jsonPath("$[0].questionText").value("What is Spring Boot?"))
                                .andExpect(jsonPath("$[0].points").value(10));

                verify(questionService).getQuestionsByQuiz(quizId);
        }

        @Test
        @WithMockUser(roles = "TEACHER")
        void testCreateQuestion_ValidData_CreatesSuccessfully() throws Exception {
                // Given
                when(questionService.createQuestion(eq(quizId), any(QuizDto.QuestionRequest.class)))
                                .thenReturn(questionResponse);

                // When & Then
                mockMvc.perform(post("/quizzes/{quizId}/questions", quizId)
                                .contentType(MediaType.APPLICATION_JSON)
                                .content(objectMapper.writeValueAsString(questionRequest))
                                .with(csrf()))
                                .andExpect(status().isCreated())
                                .andExpect(jsonPath("$.id").value(questionId.toString()))
                                .andExpect(jsonPath("$.questionText").value("What is Spring Boot?"));

                verify(questionService).createQuestion(eq(quizId), any(QuizDto.QuestionRequest.class));
        }

        @Test
        @WithMockUser(roles = "STUDENT")
        void testCreateQuestion_AsStudent_ThrowsAccessDenied() throws Exception {
                // When & Then
                mockMvc.perform(post("/quizzes/{quizId}/questions", quizId)
                                .contentType(MediaType.APPLICATION_JSON)
                                .content(objectMapper.writeValueAsString(questionRequest))
                                .with(csrf()))
                                .andExpect(status().isForbidden());

                verify(questionService, never()).createQuestion(any(UUID.class), any(QuizDto.QuestionRequest.class));
        }

        @Test
        @WithMockUser(roles = "TEACHER")
        void testUpdateQuestion_ValidData_UpdatesSuccessfully() throws Exception {
                // Given
                when(questionService.updateQuestion(eq(quizId), eq(questionId), any(QuizDto.QuestionRequest.class)))
                                .thenReturn(questionResponse);

                // When & Then
                mockMvc.perform(put("/quizzes/{quizId}/questions/{questionId}", quizId, questionId)
                                .contentType(MediaType.APPLICATION_JSON)
                                .content(objectMapper.writeValueAsString(questionRequest))
                                .with(csrf()))
                                .andExpect(status().isOk())
                                .andExpect(jsonPath("$.id").value(questionId.toString()));

                verify(questionService).updateQuestion(eq(quizId), eq(questionId), any(QuizDto.QuestionRequest.class));
        }

        @Test
        @WithMockUser(roles = "ADMIN")
        void testUpdateQuestion_AsAdmin_UpdatesSuccessfully() throws Exception {
                // Given
                when(questionService.updateQuestion(eq(quizId), eq(questionId), any(QuizDto.QuestionRequest.class)))
                                .thenReturn(questionResponse);

                // When & Then
                mockMvc.perform(put("/quizzes/{quizId}/questions/{questionId}", quizId, questionId)
                                .contentType(MediaType.APPLICATION_JSON)
                                .content(objectMapper.writeValueAsString(questionRequest))
                                .with(csrf()))
                                .andExpect(status().isOk());

                verify(questionService).updateQuestion(eq(quizId), eq(questionId), any(QuizDto.QuestionRequest.class));
        }

        @Test
        @WithMockUser(roles = "TEACHER")
        void testDeleteQuestion_ValidId_DeletesSuccessfully() throws Exception {
                // Given
                doNothing().when(questionService).deleteQuestion(quizId, questionId);

                // When & Then
                mockMvc.perform(delete("/quizzes/{quizId}/questions/{questionId}", quizId, questionId)
                                .with(csrf()))
                                .andExpect(status().isNoContent());

                verify(questionService).deleteQuestion(quizId, questionId);
        }

        @Test
        @WithMockUser(roles = "STUDENT")
        void testDeleteQuestion_AsStudent_ThrowsAccessDenied() throws Exception {
                // When & Then
                mockMvc.perform(delete("/quizzes/{quizId}/questions/{questionId}", quizId, questionId)
                                .with(csrf()))
                                .andExpect(status().isForbidden());

                verify(questionService, never()).deleteQuestion(any(UUID.class), any(UUID.class));
        }

        @Test
        @WithMockUser(roles = "TEACHER")
        void testCreateQuestion_InvalidData_ReturnsBadRequest() throws Exception {
                // Given - missing required fields
                questionRequest.setQuestionText(null);

                // When & Then
                mockMvc.perform(post("/quizzes/{quizId}/questions", quizId)
                                .contentType(MediaType.APPLICATION_JSON)
                                .content(objectMapper.writeValueAsString(questionRequest))
                                .with(csrf()))
                                .andExpect(status().isBadRequest());

                verify(questionService, never()).createQuestion(any(UUID.class), any(QuizDto.QuestionRequest.class));
        }

        @Test
        @WithMockUser
        void testGetQuestions_EmptyList_ReturnsEmptyArray() throws Exception {
                // Given
                when(questionService.getQuestionsByQuiz(quizId)).thenReturn(Arrays.asList());

                // When & Then
                mockMvc.perform(get("/quizzes/{quizId}/questions", quizId)
                                .with(csrf()))
                                .andExpect(status().isOk())
                                .andExpect(jsonPath("$").isArray())
                                .andExpect(jsonPath("$").isEmpty());

                verify(questionService).getQuestionsByQuiz(quizId);
        }

        @Test
        @WithMockUser(roles = "TEACHER")
        void testUpdateQuestion_NonExistentQuestion_ThrowsException() throws Exception {
                // Given
                when(questionService.updateQuestion(eq(quizId), eq(questionId), any(QuizDto.QuestionRequest.class)))
                                .thenThrow(new RuntimeException("Question not found"));

                // When & Then
                mockMvc.perform(put("/quizzes/{quizId}/questions/{questionId}", quizId, questionId)
                                .contentType(MediaType.APPLICATION_JSON)
                                .content(objectMapper.writeValueAsString(questionRequest))
                                .with(csrf()))
                                .andExpect(status().is4xxClientError());

                verify(questionService).updateQuestion(eq(quizId), eq(questionId), any(QuizDto.QuestionRequest.class));
        }

        @Test
        @WithMockUser(roles = "TEACHER")
        void testCreateQuestion_WithZeroPoints_CreatesSuccessfully() throws Exception {
                // Given
                questionRequest.setPoints(0);
                questionResponse.setPoints(0);
                when(questionService.createQuestion(eq(quizId), any(QuizDto.QuestionRequest.class)))
                                .thenReturn(questionResponse);

                // When & Then
                mockMvc.perform(post("/quizzes/{quizId}/questions", quizId)
                                .contentType(MediaType.APPLICATION_JSON)
                                .content(objectMapper.writeValueAsString(questionRequest))
                                .with(csrf()))
                                .andExpect(status().isCreated())
                                .andExpect(jsonPath("$.points").value(0));

                verify(questionService).createQuestion(eq(quizId), any(QuizDto.QuestionRequest.class));
        }

        @Test
        @WithMockUser(roles = "TEACHER")
        void testDeleteQuestion_NonExistentQuestion_ThrowsException() throws Exception {
                // Given
                doThrow(new RuntimeException("Question not found"))
                                .when(questionService).deleteQuestion(quizId, questionId);

                // When & Then
                mockMvc.perform(delete("/quizzes/{quizId}/questions/{questionId}", quizId, questionId)
                                .with(csrf()))
                                .andExpect(status().is4xxClientError());

                verify(questionService).deleteQuestion(quizId, questionId);
        }
}
