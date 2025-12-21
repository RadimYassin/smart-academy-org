package com.radim.project.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.radim.project.dto.CourseDto;
import com.radim.project.entity.enums.CourseLevel;
import com.radim.project.service.CourseService;
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

import static org.hamcrest.Matchers.hasSize;
import static org.hamcrest.Matchers.is;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.csrf;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultHandlers.print;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@WebMvcTest(CourseController.class)
@ContextConfiguration(classes = { CourseController.class, CourseControllerTest.TestSecurityConfig.class })
@DisplayName("CourseController Integration Tests")
class CourseControllerTest {

    @Configuration
    @EnableWebSecurity
    @EnableMethodSecurity
    static class TestSecurityConfig {
        @Bean
        public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
            http
                    .csrf(AbstractHttpConfigurer::disable)
                    .authorizeHttpRequests(auth -> auth.anyRequest().permitAll());
            return http.build();
        }
    }

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @MockBean
    private CourseService courseService;

    private CourseDto.Response courseResponse;
    private CourseDto.Request courseRequest;
    private final UUID courseId = UUID.randomUUID();

    @BeforeEach
    void setUp() {
        courseResponse = CourseDto.Response.builder()
                .id(courseId)
                .title("Introduction to Java")
                .description("Learn Java programming")
                .category("Programming")
                .level(CourseLevel.BEGINNER)
                .thumbnailUrl("http://example.com/thumb.jpg")
                .teacherId(1L)
                .build();

        courseRequest = CourseDto.Request.builder()
                .title("Introduction to Java")
                .description("Learn Java programming")
                .category("Programming")
                .level(CourseLevel.BEGINNER)
                .thumbnailUrl("http://example.com/thumb.jpg")
                .build();
    }

    @Test
    @DisplayName("Should get all courses successfully")
    void getAllCourses_Success() throws Exception {
        // Given
        List<CourseDto.Response> courses = Arrays.asList(courseResponse);
        when(courseService.getAllCourses()).thenReturn(courses);

        // When & Then
        mockMvc.perform(get("/courses")
                .contentType(MediaType.APPLICATION_JSON))
                .andDo(print())
                .andExpect(status().isOk())
                .andExpect(jsonPath("$", hasSize(1)))
                .andExpect(jsonPath("$[0].title", is("Introduction to Java")));

        verify(courseService).getAllCourses();
    }

    @Test
    @DisplayName("Should get course by ID successfully")
    void getCourseById_Success() throws Exception {
        // Given
        when(courseService.getCourseById(courseId)).thenReturn(courseResponse);

        // When & Then
        mockMvc.perform(get("/courses/{courseId}", courseId)
                .contentType(MediaType.APPLICATION_JSON))
                .andDo(print())
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.title", is("Introduction to Java")))
                .andExpect(jsonPath("$.category", is("Programming")));

        verify(courseService).getCourseById(courseId);
    }

    @Test
    @WithMockUser(roles = "TEACHER")
    @DisplayName("Should get courses by teacher ID when authorized")
    void getCoursesByTeacherId_AsTeacher_Success() throws Exception {
        // Given
        Long teacherId = 1L;
        List<CourseDto.Response> courses = Arrays.asList(courseResponse);
        when(courseService.getCoursesByTeacherId(teacherId)).thenReturn(courses);

        // When & Then
        mockMvc.perform(get("/courses/teacher/{teacherId}", teacherId)
                .contentType(MediaType.APPLICATION_JSON))
                .andDo(print())
                .andExpect(status().isOk())
                .andExpect(jsonPath("$", hasSize(1)));

        verify(courseService).getCoursesByTeacherId(teacherId);
    }

    @Test
    @WithMockUser(roles = "STUDENT")
    @DisplayName("Should return 403 when student tries to access teacher courses")
    void getCoursesByTeacherId_AsStudent_Forbidden() throws Exception {
        // When & Then
        mockMvc.perform(get("/courses/teacher/{teacherId}", 1L)
                .contentType(MediaType.APPLICATION_JSON))
                .andDo(print())
                .andExpect(status().isForbidden());
    }

    @Test
    @WithMockUser(roles = "TEACHER")
    @DisplayName("Should create course successfully as teacher")
    void createCourse_AsTeacher_Success() throws Exception {
        // Given
        when(courseService.createCourse(any(CourseDto.Request.class))).thenReturn(courseResponse);

        // When & Then
        mockMvc.perform(post("/courses")
                .with(csrf())
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(courseRequest)))
                .andDo(print())
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.title", is("Introduction to Java")))
                .andExpect(jsonPath("$.level", is("BEGINNER")));

        verify(courseService).createCourse(any(CourseDto.Request.class));
    }

    @Test
    @WithMockUser(roles = "STUDENT")
    @DisplayName("Should return 403 when student tries to create course")
    void createCourse_AsStudent_Forbidden() throws Exception {
        // When & Then
        mockMvc.perform(post("/courses")
                .with(csrf())
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(courseRequest)))
                .andDo(print())
                .andExpect(status().isForbidden());
    }

    @Test
    @WithMockUser(roles = "TEACHER")
    @DisplayName("Should return 400 when creating course with invalid data")
    void createCourse_InvalidData_BadRequest() throws Exception {
        // Given - Invalid course with missing required title (less than 3 chars)
        CourseDto.Request invalidRequest = CourseDto.Request.builder()
                .title("AB") // Too short
                .description("Test description")
                .category("Programming")
                .level(CourseLevel.BEGINNER)
                .build();

        // When & Then
        mockMvc.perform(post("/courses")
                .with(csrf())
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(invalidRequest)))
                .andDo(print())
                .andExpect(status().isBadRequest());
    }

    @Test
    @WithMockUser(roles = "TEACHER")
    @DisplayName("Should update course successfully as teacher")
    void updateCourse_AsTeacher_Success() throws Exception {
        // Given
        when(courseService.updateCourse(eq(courseId), any(CourseDto.Request.class)))
                .thenReturn(courseResponse);

        // When & Then
        mockMvc.perform(put("/courses/{courseId}", courseId)
                .with(csrf())
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(courseRequest)))
                .andDo(print())
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.title", is("Introduction to Java")));

        verify(courseService).updateCourse(eq(courseId), any(CourseDto.Request.class));
    }

    @Test
    @WithMockUser(roles = "TEACHER")
    @DisplayName("Should delete course successfully as teacher")
    void deleteCourse_AsTeacher_Success() throws Exception {
        // When & Then
        mockMvc.perform(delete("/courses/{courseId}", courseId)
                .with(csrf()))
                .andDo(print())
                .andExpect(status().isNoContent());

        verify(courseService).deleteCourse(courseId);
    }

    @Test
    @WithMockUser(roles = "STUDENT")
    @DisplayName("Should return 403 when student tries to delete course")
    void deleteCourse_AsStudent_Forbidden() throws Exception {
        // When & Then
        mockMvc.perform(delete("/courses/{courseId}", courseId)
                .with(csrf()))
                .andExpect(status().isForbidden());
    }
}
