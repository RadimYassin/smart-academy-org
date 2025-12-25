package radim.ma.controllers;

import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.http.MediaType;
import org.springframework.security.authentication.AuthenticationProvider;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.test.web.servlet.MockMvc;
import radim.ma.dto.UserDto;
import radim.ma.entities.Role;
import radim.ma.security.JwtUtil;
import radim.ma.services.UserService;

import java.util.List;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyLong;
import static org.mockito.Mockito.doNothing;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@WebMvcTest(UserController.class)
@AutoConfigureMockMvc(addFilters = false)
class UserControllerTest {

        @Autowired
        private MockMvc mockMvc;

        @MockBean
        private UserService userService;

        @MockBean
        private JwtUtil jwtUtil;

        @MockBean
        private UserDetailsService userDetailsService;

        @MockBean
        private AuthenticationProvider authenticationProvider;

        @Autowired
        private ObjectMapper objectMapper;

        @Test
        void getAllUsers_ShouldReturnList() throws Exception {
                UserDto userDto = UserDto.builder().id(1L).email("admin@test.com").build();
                when(userService.getAllUsers()).thenReturn(List.of(userDto));

                mockMvc.perform(get("/api/v1/users"))
                                .andExpect(status().isOk())
                                .andExpect(jsonPath("$[0].id").value(1L));
        }

        @Test
        void getAllStudents_ShouldReturnList() throws Exception {
                UserDto userDto = UserDto.builder().id(2L).role(Role.STUDENT).build();
                when(userService.getUsersByRole(Role.STUDENT)).thenReturn(List.of(userDto));

                mockMvc.perform(get("/api/v1/users/students"))
                                .andExpect(status().isOk())
                                .andExpect(jsonPath("$[0].id").value(2L));
        }

        @Test
        void getUserById_ShouldReturnUser() throws Exception {
                UserDto userDto = UserDto.builder().id(1L).email("test@test.com").build();
                when(userService.getUserById(1L)).thenReturn(userDto);

                mockMvc.perform(get("/api/v1/users/1"))
                                .andExpect(status().isOk())
                                .andExpect(jsonPath("$.id").value(1L));
        }

        @Test
        void updateUser_ShouldReturnUpdatedUser() throws Exception {
                UserDto userDto = UserDto.builder().firstName("Updated").build();
                when(userService.updateUser(anyLong(), any(UserDto.class))).thenReturn(userDto);

                mockMvc.perform(put("/api/v1/users/1")
                                .contentType(MediaType.APPLICATION_JSON)
                                .content(objectMapper.writeValueAsString(userDto)))
                                .andExpect(status().isOk())
                                .andExpect(jsonPath("$.firstName").value("Updated"));
        }

        @Test
        void deleteUser_ShouldReturnNoContent() throws Exception {
                doNothing().when(userService).deleteUser(1L);

                mockMvc.perform(delete("/api/v1/users/1"))
                                .andExpect(status().isNoContent());
        }

        @Test
        void restoreUser_ShouldReturnOk() throws Exception {
                doNothing().when(userService).restoreUser(1L);

                mockMvc.perform(post("/api/v1/users/1/restore"))
                                .andExpect(status().isOk());
        }
}
