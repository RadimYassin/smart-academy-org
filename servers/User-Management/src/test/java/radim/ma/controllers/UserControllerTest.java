package radim.ma.controllers;

import com.fasterxml.jackson.databind.ObjectMapper;
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
import radim.ma.dto.UserDto;
import radim.ma.entities.Role;
import radim.ma.services.UserService;

import java.util.Arrays;
import java.util.List;

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

@WebMvcTest(UserController.class)
@ActiveProfiles("test")
@ContextConfiguration(classes = { UserController.class, UserControllerTest.TestSecurityConfig.class })
@DisplayName("UserController Integration Tests")
class UserControllerTest {

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
        private UserService userService;

        private UserDto studentDto;
        private UserDto teacherDto;

        @BeforeEach
        void setUp() {
                studentDto = UserDto.builder()
                                .id(1L)
                                .email("student@example.com")
                                .firstName("John")
                                .lastName("Doe")
                                .role(Role.STUDENT)
                                .build();

                teacherDto = UserDto.builder()
                                .id(2L)
                                .email("teacher@example.com")
                                .firstName("Jane")
                                .lastName("Smith")
                                .role(Role.TEACHER)
                                .build();
        }

        @Test
        @WithMockUser(roles = "ADMIN")
        @DisplayName("Should get all users when admin")
        void getAllUsers_AsAdmin_Success() throws Exception {
                // Given
                List<UserDto> users = Arrays.asList(studentDto, teacherDto);
                when(userService.getAllUsers()).thenReturn(users);

                // When & Then
                mockMvc.perform(get("/api/v1/users")
                                .contentType(MediaType.APPLICATION_JSON))
                                .andDo(print())
                                .andExpect(status().isOk())
                                .andExpect(jsonPath("$", hasSize(2)))
                                .andExpect(jsonPath("$[0].email", is("student@example.com")))
                                .andExpect(jsonPath("$[1].email", is("teacher@example.com")));

                verify(userService).getAllUsers();
        }

        @Test
        @WithMockUser(roles = "STUDENT")
        @DisplayName("Should return 403 when student tries to get all users")
        void getAllUsers_AsStudent_Forbidden() throws Exception {
                // When & Then
                mockMvc.perform(get("/api/v1/users")
                                .contentType(MediaType.APPLICATION_JSON))
                                .andDo(print())
                                .andExpect(status().isForbidden());
        }

        @Test
        @WithMockUser(roles = "TEACHER")
        @DisplayName("Should get all students when teacher")
        void getAllStudents_AsTeacher_Success() throws Exception {
                // Given
                List<UserDto> students = Arrays.asList(studentDto);
                when(userService.getUsersByRole(Role.STUDENT)).thenReturn(students);

                // When & Then
                mockMvc.perform(get("/api/v1/users/students")
                                .contentType(MediaType.APPLICATION_JSON))
                                .andDo(print())
                                .andExpect(status().isOk())
                                .andExpect(jsonPath("$", hasSize(1)))
                                .andExpect(jsonPath("$[0].role", is("STUDENT")));

                verify(userService).getUsersByRole(Role.STUDENT);
        }

        @Test
        @WithMockUser(roles = "ADMIN")
        @DisplayName("Should get all students when admin")
        void getAllStudents_AsAdmin_Success() throws Exception {
                // Given
                List<UserDto> students = Arrays.asList(studentDto);
                when(userService.getUsersByRole(Role.STUDENT)).thenReturn(students);

                // When & Then
                mockMvc.perform(get("/api/v1/users/students")
                                .contentType(MediaType.APPLICATION_JSON))
                                .andExpect(status().isOk())
                                .andExpect(jsonPath("$", hasSize(1)));
        }

        @Test
        @WithMockUser(roles = "ADMIN")
        @DisplayName("Should get user by ID")
        void getUserById_Success() throws Exception {
                // Given
                Long userId = 1L;
                when(userService.getUserById(userId)).thenReturn(studentDto);

                // When & Then
                mockMvc.perform(get("/api/v1/users/{id}", userId)
                                .contentType(MediaType.APPLICATION_JSON))
                                .andDo(print())
                                .andExpect(status().isOk())
                                .andExpect(jsonPath("$.id", is(1)))
                                .andExpect(jsonPath("$.email", is("student@example.com")))
                                .andExpect(jsonPath("$.firstName", is("John")));

                verify(userService).getUserById(userId);
        }

        @Test
        @WithMockUser(roles = "STUDENT")
        @DisplayName("Should allow student to get user by ID")
        void getUserById_AsStudent_Success() throws Exception {
                // Given
                Long userId = 1L;
                when(userService.getUserById(userId)).thenReturn(studentDto);

                // When & Then
                mockMvc.perform(get("/api/v1/users/{id}", userId)
                                .contentType(MediaType.APPLICATION_JSON))
                                .andExpect(status().isOk());
        }

        @Test
        @WithMockUser(roles = "ADMIN")
        @DisplayName("Should update user")
        void updateUser_Success() throws Exception {
                // Given
                Long userId = 1L;
                UserDto updateDto = UserDto.builder()
                                .firstName("UpdatedName")
                                .lastName("UpdatedLastName")
                                .build();

                UserDto updatedUser = UserDto.builder()
                                .id(userId)
                                .email("student@example.com")
                                .firstName("UpdatedName")
                                .lastName("UpdatedLastName")
                                .role(Role.STUDENT)
                                .build();

                when(userService.updateUser(eq(userId), any(UserDto.class))).thenReturn(updatedUser);

                // When & Then
                mockMvc.perform(put("/api/v1/users/{id}", userId)
                                .with(csrf())
                                .contentType(MediaType.APPLICATION_JSON)
                                .content(objectMapper.writeValueAsString(updateDto)))
                                .andDo(print())
                                .andExpect(status().isOk())
                                .andExpect(jsonPath("$.firstName", is("UpdatedName")))
                                .andExpect(jsonPath("$.lastName", is("UpdatedLastName")));

                verify(userService).updateUser(eq(userId), any(UserDto.class));
        }

        @Test
        @WithMockUser(roles = "STUDENT")
        @DisplayName("Should allow student to update user")
        void updateUser_AsStudent_Success() throws Exception {
                // Given
                Long userId = 1L;
                UserDto updateDto = UserDto.builder()
                                .firstName("UpdatedName")
                                .build();

                when(userService.updateUser(eq(userId), any(UserDto.class))).thenReturn(studentDto);

                // When & Then
                mockMvc.perform(put("/api/v1/users/{id}", userId)
                                .with(csrf())
                                .contentType(MediaType.APPLICATION_JSON)
                                .content(objectMapper.writeValueAsString(updateDto)))
                                .andExpect(status().isOk());
        }

        @Test
        @WithMockUser(roles = "ADMIN")
        @DisplayName("Should delete user")
        void deleteUser_Success() throws Exception {
                // Given
                Long userId = 1L;

                // When & Then
                mockMvc.perform(delete("/api/v1/users/{id}", userId)
                                .with(csrf()))
                                .andDo(print())
                                .andExpect(status().isNoContent());

                verify(userService).deleteUser(userId);
        }

        @Test
        @WithMockUser(roles = "STUDENT")
        @DisplayName("Should return 403 when student tries to delete user")
        void deleteUser_AsStudent_Forbidden() throws Exception {
                // When & Then
                mockMvc.perform(delete("/api/v1/users/{id}", 1L)
                                .with(csrf()))
                                .andExpect(status().isForbidden());
        }

        @Test
        @WithMockUser(roles = "ADMIN")
        @DisplayName("Should restore deleted user")
        void restoreUser_Success() throws Exception {
                // Given
                Long userId = 1L;

                // When & Then
                mockMvc.perform(post("/api/v1/users/{id}/restore", userId)
                                .with(csrf()))
                                .andDo(print())
                                .andExpect(status().isOk());

                verify(userService).restoreUser(userId);
        }

        @Test
        @WithMockUser(roles = "TEACHER")
        @DisplayName("Should return 403 when teacher tries to restore user")
        void restoreUser_AsTeacher_Forbidden() throws Exception {
                // When & Then
                mockMvc.perform(post("/api/v1/users/{id}/restore", 1L)
                                .with(csrf()))
                                .andExpect(status().isForbidden());
        }
}
