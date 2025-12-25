package com.radim.project.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.radim.project.dto.ModuleDto;
import com.radim.project.service.ModuleService;
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

@WebMvcTest(ModuleController.class)
@ActiveProfiles("test")
@ContextConfiguration(classes = { ModuleController.class, ModuleControllerTest.TestSecurityConfig.class })
@DisplayName("ModuleController Web Layer Tests")
class ModuleControllerTest {

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
        private ModuleService moduleService;

        private ModuleDto.Response moduleResponse;
        private ModuleDto.Request moduleRequest;
        private final UUID courseId = UUID.randomUUID();
        private final UUID moduleId = UUID.randomUUID();

        @BeforeEach
        void setUp() {
                moduleResponse = ModuleDto.Response.builder()
                                .id(moduleId)
                                .courseId(courseId)
                                .title("Module 1: Introduction")
                                .orderIndex(1)
                                .build();

                moduleRequest = ModuleDto.Request.builder()
                                .title("Module 1: Introduction")
                                .orderIndex(1)
                                .build();
        }

        @Test
        @DisplayName("Should get all modules for a course")
        void getModules_Success() throws Exception {
                // Given
                List<ModuleDto.Response> modules = Arrays.asList(moduleResponse);
                when(moduleService.getModulesByCourse(courseId)).thenReturn(modules);

                // When & Then
                mockMvc.perform(get("/courses/{courseId}/modules", courseId)
                                .contentType(MediaType.APPLICATION_JSON))
                                .andExpect(status().isOk())
                                .andExpect(jsonPath("$", hasSize(1)))
                                .andExpect(jsonPath("$[0].title", is("Module 1: Introduction")));

                verify(moduleService).getModulesByCourse(courseId);
        }

        @Test
        @WithMockUser(roles = "TEACHER")
        @DisplayName("Should create module as teacher")
        void createModule_AsTeacher_Success() throws Exception {
                // Given
                when(moduleService.createModule(any(UUID.class), any(ModuleDto.Request.class)))
                                .thenReturn(moduleResponse);

                // When & Then
                mockMvc.perform(post("/courses/{courseId}/modules", courseId)
                                .with(csrf())
                                .contentType(MediaType.APPLICATION_JSON)
                                .content(objectMapper.writeValueAsString(moduleRequest)))
                                .andExpect(status().isCreated())
                                .andExpect(jsonPath("$.title", is("Module 1: Introduction")));

                verify(moduleService).createModule(any(UUID.class), any(ModuleDto.Request.class));
        }

        @Test
        @WithMockUser(roles = "STUDENT")
        @DisplayName("Should return 403 when student tries to create module")
        void createModule_AsStudent_Forbidden() throws Exception {
                mockMvc.perform(post("/courses/{courseId}/modules", courseId)
                                .with(csrf())
                                .contentType(MediaType.APPLICATION_JSON)
                                .content(objectMapper.writeValueAsString(moduleRequest)))
                                .andExpect(status().isForbidden());

                verify(moduleService, never()).createModule(any(), any());
        }

        @Test
        @WithMockUser(roles = "TEACHER")
        @DisplayName("Should update module as teacher")
        void updateModule_AsTeacher_Success() throws Exception {
                // Given
                when(moduleService.updateModule(any(UUID.class), any(UUID.class), any(ModuleDto.Request.class)))
                                .thenReturn(moduleResponse);

                // When & Then
                mockMvc.perform(put("/courses/{courseId}/modules/{moduleId}", courseId, moduleId)
                                .with(csrf())
                                .contentType(MediaType.APPLICATION_JSON)
                                .content(objectMapper.writeValueAsString(moduleRequest)))
                                .andExpect(status().isOk());

                verify(moduleService).updateModule(any(UUID.class), any(UUID.class), any(ModuleDto.Request.class));
        }

        @Test
        @WithMockUser(roles = "TEACHER")
        @DisplayName("Should delete module as teacher")
        void deleteModule_AsTeacher_Success() throws Exception {
                mockMvc.perform(delete("/courses/{courseId}/modules/{moduleId}", courseId, moduleId)
                                .with(csrf())
                                .contentType(MediaType.APPLICATION_JSON))
                                .andExpect(status().isNoContent());

                verify(moduleService).deleteModule(courseId, moduleId);
        }
}
