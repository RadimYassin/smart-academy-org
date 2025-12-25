package com.radim.project.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.radim.project.dto.EnrollmentDto;
import com.radim.project.service.EnrollmentService;
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

@WebMvcTest(EnrollmentController.class)
@ActiveProfiles("test")
@ContextConfiguration(classes = { EnrollmentController.class, EnrollmentControllerTest.TestSecurityConfig.class })
@DisplayName("EnrollmentController Web Layer Tests")
class EnrollmentControllerTest {

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
    private EnrollmentService enrollmentService;

    private EnrollmentDto.EnrollmentResponse enrollmentResponse;
    private final UUID courseId = UUID.randomUUID();
    private final Long studentId = 100L;
    private final Long teacherId = 1L;

    @BeforeEach
    void setUp() {
        enrollmentResponse = EnrollmentDto.EnrollmentResponse.builder()
                .id(UUID.randomUUID())
                .courseId(courseId)
                .studentId(studentId)
                .assignedBy(teacherId)
                .build();
    }

    @Test
    @WithMockUser(username = "1", roles = "TEACHER")
    @DisplayName("Should assign student to course as teacher")
    void assignStudent_AsTeacher_Success() throws Exception {
        // Given
        EnrollmentDto.AssignStudentRequest request = EnrollmentDto.AssignStudentRequest.builder()
                .courseId(courseId)
                .studentId(studentId)
                .build();

        when(enrollmentService.assignStudentToCourse(any(UUID.class), any(Long.class), any(Long.class)))
                .thenReturn(enrollmentResponse);

        // When & Then
        mockMvc.perform(post("/api/enrollments/student")
                .with(csrf())
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.studentId", is(studentId.intValue())));

        verify(enrollmentService).assignStudentToCourse(any(UUID.class), any(Long.class), any(Long.class));
    }

    @Test
    @WithMockUser(username = "1", roles = "TEACHER")
    @DisplayName("Should get course enrollments as teacher")
    void getCourseEnrollments_AsTeacher_Success() throws Exception {
        // Given
        List<EnrollmentDto.EnrollmentResponse> enrollments = Arrays.asList(enrollmentResponse);
        when(enrollmentService.getCourseEnrollments(courseId, teacherId)).thenReturn(enrollments);

        // When & Then
        mockMvc.perform(get("/api/enrollments/courses/{courseId}", courseId)
                .contentType(MediaType.APPLICATION_JSON))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$", hasSize(1)));

        verify(enrollmentService).getCourseEnrollments(courseId, teacherId);
    }

    @Test
    @WithMockUser(username = "100", roles = "STUDENT")
    @DisplayName("Should get student enrollments")
    void getStudentEnrollments_AsStudent_Success() throws Exception {
        // Given
        List<EnrollmentDto.EnrollmentResponse> enrollments = Arrays.asList(enrollmentResponse);
        when(enrollmentService.getStudentEnrollments(studentId)).thenReturn(enrollments);

        // When & Then
        mockMvc.perform(get("/api/enrollments/my-courses")
                .contentType(MediaType.APPLICATION_JSON))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$", hasSize(1)));

        verify(enrollmentService).getStudentEnrollments(studentId);
    }

    @Test
    @WithMockUser(username = "1", roles = "TEACHER")
    @DisplayName("Should unenroll student as teacher")
    void unenrollStudent_AsTeacher_Success() throws Exception {
        // When & Then
        mockMvc.perform(delete("/api/enrollments/courses/{courseId}/students/{studentId}", courseId, studentId)
                .with(csrf())
                .contentType(MediaType.APPLICATION_JSON))
                .andExpect(status().isNoContent());

        verify(enrollmentService).unenrollStudent(courseId, studentId, teacherId);
    }
}
