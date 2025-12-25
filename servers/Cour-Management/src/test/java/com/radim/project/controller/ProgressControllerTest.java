package com.radim.project.controller;

import com.radim.project.dto.ProgressDto;
import com.radim.project.service.ProgressService;
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

import java.util.UUID;

import static org.hamcrest.Matchers.*;
import static org.mockito.Mockito.*;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.csrf;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@WebMvcTest(ProgressController.class)
@ActiveProfiles(" test\)
@ContextConfiguration(classes = { ProgressController.class, ProgressControllerTest.TestSecurityConfig.class })
@DisplayName("ProgressController Web Layer Tests")
class ProgressControllerTest {

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

    @MockBean
    private ProgressService progressService;

    private ProgressDto.CourseProgressResponse courseProgressResponse;
    private ProgressDto.LessonProgressResponse lessonProgressResponse;
    private final UUID courseId = UUID.randomUUID();
    private final UUID lessonId = UUID.randomUUID();
    private final Long studentId = 100L;

    @BeforeEach
    void setUp() {
        courseProgressResponse = ProgressDto.CourseProgressResponse.builder()
                .courseId(courseId)
                .totalLessons(10L)
                .completedLessons(5L)
                .completionRate(50.0)
                .build();

        lessonProgressResponse = ProgressDto.LessonProgressResponse.builder()
                .lessonId(lessonId)
                .completed(true)
                .build();
    }

    @Test
    @WithMockUser(username = "100", roles = "STUDENT")
    @DisplayName("Should get course progress")
    void getCourseProgress_Success() throws Exception {
        // Given
        when(progressService.getCourseProgress(courseId, studentId)).thenReturn(courseProgressResponse);

        // When & Then
        mockMvc.perform(get("/api/progress/courses/{courseId}", courseId)
                .contentType(MediaType.APPLICATION_JSON))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.completionRate", is(50.0)));

        verify(progressService).getCourseProgress(courseId, studentId);
    }

    @Test
    @WithMockUser(username = "100", roles = "STUDENT")
    @DisplayName("Should mark lesson as complete")
    void markLessonComplete_Success() throws Exception {
        // Given
        when(progressService.markLessonComplete(lessonId, studentId)).thenReturn(lessonProgressResponse);

        // When & Then
        mockMvc.perform(post("/api/progress/lessons/{lessonId}/complete", lessonId)
                .with(csrf())
                .contentType(MediaType.APPLICATION_JSON))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.completed", is(true)));

        verify(progressService).markLessonComplete(lessonId, studentId);
    }

    @Test
    @WithMockUser(username = "100", roles = "STUDENT")
    @DisplayName("Should get lesson progress")
    void getLessonProgress_Success() throws Exception {
        // Given
        when(progressService.getLessonProgress(lessonId, studentId)).thenReturn(lessonProgressResponse);

        // When & Then
        mockMvc.perform(get("/api/progress/lessons/{lessonId}", lessonId)
                .contentType(MediaType.APPLICATION_JSON))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.completed", is(true)));

        verify(progressService).getLessonProgress(lessonId, studentId);
    }
}

