package com.radim.project.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.radim.project.dto.LessonDto;
import com.radim.project.service.LessonService;
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

@WebMvcTest(LessonController.class)
@ContextConfiguration(classes = { LessonController.class, LessonControllerTest.TestSecurityConfig.class })
@DisplayName("LessonController Web Layer Tests")
class LessonControllerTest {

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
    private LessonService lessonService;

    private LessonDto.Response lessonResponse;
    private LessonDto.Request lessonRequest;
    private final UUID moduleId = UUID.randomUUID();
    private final UUID lessonId = UUID.randomUUID();

    @BeforeEach
    void setUp() {
        lessonResponse = LessonDto.Response.builder()
                .id(lessonId)
                .moduleId(moduleId)
                .title("Lesson 1: Variables")
                .orderIndex(1)
                .build();

        lessonRequest = LessonDto.Request.builder()
                .title("Lesson 1: Variables")
                .orderIndex(1)
                .build();
    }

    @Test
    @DisplayName("Should get all lessons for a module")
    void getLessons_Success() throws Exception {
        // Given
        List<LessonDto.Response> lessons = Arrays.asList(lessonResponse);
        when(lessonService.getLessonsByModule(moduleId)).thenReturn(lessons);

        // When & Then
        mockMvc.perform(get("/modules/{moduleId}/lessons", moduleId)
                .contentType(MediaType.APPLICATION_JSON))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$", hasSize(1)))
                .andExpect(jsonPath("$[0].title", is("Lesson 1: Variables")));

        verify(lessonService).getLessonsByModule(moduleId);
    }

    @Test
    @WithMockUser(roles = "TEACHER")
    @DisplayName("Should create lesson as teacher")
    void createLesson_AsTeacher_Success() throws Exception {
        // Given
        when(lessonService.createLesson(any(UUID.class), any(LessonDto.Request.class)))
                .thenReturn(lessonResponse);

        // When & Then
        mockMvc.perform(post("/modules/{moduleId}/lessons", moduleId)
                .with(csrf())
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(lessonRequest)))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.title", is("Lesson 1: Variables")));

        verify(lessonService).createLesson(any(UUID.class), any(LessonDto.Request.class));
    }

    @Test
    @WithMockUser(roles = "STUDENT")
    @DisplayName("Should return 403 when student tries to create lesson")
    void createLesson_AsStudent_Forbidden() throws Exception {
        mockMvc.perform(post("/modules/{moduleId}/lessons", moduleId)
                .with(csrf())
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(lessonRequest)))
                .andExpect(status().isForbidden());

        verify(lessonService, never()).createLesson(any(), any());
    }

    @Test
    @WithMockUser(roles = "TEACHER")
    @DisplayName("Should update lesson as teacher")
    void updateLesson_AsTeacher_Success() throws Exception {
        // Given
        when(lessonService.updateLesson(any(UUID.class), any(UUID.class), any(LessonDto.Request.class)))
                .thenReturn(lessonResponse);

        // When & Then
        mockMvc.perform(put("/modules/{moduleId}/lessons/{lessonId}", moduleId, lessonId)
                .with(csrf())
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(lessonRequest)))
                .andExpect(status().isOk());

        verify(lessonService).updateLesson(any(UUID.class), any(UUID.class), any(LessonDto.Request.class));
    }

    @Test
    @WithMockUser(roles = "TEACHER")
    @DisplayName("Should delete lesson as teacher")
    void deleteLesson_AsTeacher_Success() throws Exception {
        mockMvc.perform(delete("/modules/{moduleId}/lessons/{lessonId}", moduleId, lessonId)
                .with(csrf())
                .contentType(MediaType.APPLICATION_JSON))
                .andExpect(status().isNoContent());

        verify(lessonService).deleteLesson(moduleId, lessonId);
    }
}
