package com.radim.project.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.radim.project.dto.ClassDto;
import com.radim.project.service.StudentClassService;
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

@WebMvcTest(StudentClassController.class)
@ActiveProfiles("test")
@ContextConfiguration(classes = { StudentClassController.class, StudentClassControllerTest.TestSecurityConfig.class })
@DisplayName("StudentClassController Web Layer Tests")
class StudentClassControllerTest {

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
        private StudentClassService studentClassService;

        @MockBean
        private com.radim.project.security.JwtService jwtService;

        private ClassDto.ClassResponse classResponse;
        private final UUID classId = UUID.randomUUID();
        private final Long teacherId = 1L;

        @BeforeEach
        void setUp() {
                classResponse = ClassDto.ClassResponse.builder()
                                .id(classId)
                                .name("Java Class 101")
                                .description("Beginner Java class")
                                .teacherId(teacherId)
                                .studentCount(10)
                                .build();
        }

        @Test
        @WithMockUser(username = "1", roles = "TEACHER")
        @DisplayName("Should get teacher's classes")
        void getTeacherClasses_Success() throws Exception {
                // Given
                List<ClassDto.ClassResponse> classes = Arrays.asList(classResponse);
                when(studentClassService.getClassesByTeacher(teacherId)).thenReturn(classes);

                // When & Then
                mockMvc.perform(get("/api/classes")
                                .contentType(MediaType.APPLICATION_JSON))
                                .andExpect(status().isOk())
                                .andExpect(jsonPath("$", hasSize(1)))
                                .andExpect(jsonPath("$[0].name", is("Java Class 101")));

                verify(studentClassService).getClassesByTeacher(teacherId);
        }

        @Test
        @WithMockUser(username = "1", roles = "TEACHER")
        @DisplayName("Should create class as teacher")
        void createClass_AsTeacher_Success() throws Exception {
                // Given
                ClassDto.CreateClassRequest request = ClassDto.CreateClassRequest.builder()
                                .name("Java Class 101")
                                .description("Beginner Java class")
                                .build();
                when(studentClassService.createClass(any(ClassDto.CreateClassRequest.class), any(Long.class)))
                                .thenReturn(classResponse);

                // When & Then
                mockMvc.perform(post("/api/classes")
                                .with(csrf())
                                .contentType(MediaType.APPLICATION_JSON)
                                .content(objectMapper.writeValueAsString(request)))
                                .andExpect(status().isCreated())
                                .andExpect(jsonPath("$.name", is("Java Class 101")));

                verify(studentClassService).createClass(any(ClassDto.CreateClassRequest.class), any(Long.class));
        }

        @Test
        @WithMockUser(roles = "STUDENT")
        @DisplayName("Should deny student from creating class")
        void createClass_AsStudent_Forbidden() throws Exception {
                ClassDto.CreateClassRequest request = ClassDto.CreateClassRequest.builder()
                                .name("Java Class 101")
                                .build();

                mockMvc.perform(post("/api/classes")
                                .with(csrf())
                                .contentType(MediaType.APPLICATION_JSON)
                                .content(objectMapper.writeValueAsString(request)))
                                .andExpect(status().isForbidden());

                verify(studentClassService, never()).createClass(any(), any());
        }

        @Test
        @WithMockUser(username = "1", roles = "TEACHER")
        @DisplayName("Should update class as teacher")
        void updateClass_AsTeacher_Success() throws Exception {
                // Given
                ClassDto.UpdateClassRequest request = ClassDto.UpdateClassRequest.builder()
                                .name("Java Class 102")
                                .description("Updated description")
                                .build();
                when(studentClassService.updateClass(any(UUID.class), any(ClassDto.UpdateClassRequest.class),
                                any(Long.class)))
                                .thenReturn(classResponse);

                // When & Then
                mockMvc.perform(put("/api/classes/{classId}", classId)
                                .with(csrf())
                                .contentType(MediaType.APPLICATION_JSON)
                                .content(objectMapper.writeValueAsString(request)))
                                .andExpect(status().isOk());

                verify(studentClassService).updateClass(any(UUID.class), any(ClassDto.UpdateClassRequest.class),
                                any(Long.class));
        }

        @Test
        @WithMockUser(username = "1", roles = "TEACHER")
        @DisplayName("Should delete class as teacher")
        void deleteClass_AsTeacher_Success() throws Exception {
                mockMvc.perform(delete("/api/classes/{classId}", classId)
                                .with(csrf())
                                .contentType(MediaType.APPLICATION_JSON))
                                .andExpect(status().isNoContent());

                verify(studentClassService).deleteClass(classId, teacherId);
        }
}
