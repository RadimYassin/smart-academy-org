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
import radim.ma.dto.AuthRequest;
import radim.ma.dto.AuthResponse;
import radim.ma.dto.RefreshTokenRequest;
import radim.ma.dto.RegisterRequest;
import radim.ma.entities.Role;
import radim.ma.security.JwtUtil;
import radim.ma.services.AuthService;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@WebMvcTest(AuthController.class)
@AutoConfigureMockMvc(addFilters = false)
class AuthControllerTest {

        @Autowired
        private MockMvc mockMvc;

        @MockBean
        private AuthService authService;

        @MockBean
        private JwtUtil jwtUtil;

        @MockBean
        private UserDetailsService userDetailsService;

        @MockBean
        private AuthenticationProvider authenticationProvider;

        @Autowired
        private ObjectMapper objectMapper;

        @Test
        void register_ShouldReturnOk() throws Exception {
                RegisterRequest request = RegisterRequest.builder()
                                .email("test@example.com")
                                .password("Password123#")
                                .firstName("John")
                                .lastName("Doe")
                                .role(Role.STUDENT)
                                .build();

                AuthResponse response = AuthResponse.builder()
                                .accessToken("jwtToken")
                                .build();

                when(authService.register(any(RegisterRequest.class))).thenReturn(response);

                mockMvc.perform(post("/api/v1/auth/register")
                                .contentType(MediaType.APPLICATION_JSON)
                                .content(objectMapper.writeValueAsString(request)))
                                .andExpect(status().isOk())
                                .andExpect(jsonPath("$.access_token").value("jwtToken"));
        }

        @Test
        void authenticate_ShouldReturnOk() throws Exception {
                AuthRequest request = AuthRequest.builder()
                                .email("test@example.com")
                                .password("Password123#")
                                .build();

                AuthResponse response = AuthResponse.builder()
                                .accessToken("jwtToken")
                                .build();

                when(authService.authenticate(any(AuthRequest.class))).thenReturn(response);

                mockMvc.perform(post("/api/v1/auth/login")
                                .contentType(MediaType.APPLICATION_JSON)
                                .content(objectMapper.writeValueAsString(request)))
                                .andExpect(status().isOk())
                                .andExpect(jsonPath("$.access_token").value("jwtToken"));
        }

        @Test
        void refreshToken_ShouldReturnOk() throws Exception {
                RefreshTokenRequest request = RefreshTokenRequest.builder()
                                .refreshToken("oldToken")
                                .build();

                AuthResponse response = AuthResponse.builder()
                                .accessToken("newToken")
                                .build();

                when(authService.refreshToken("oldToken")).thenReturn(response);

                mockMvc.perform(post("/api/v1/auth/refresh-token")
                                .contentType(MediaType.APPLICATION_JSON)
                                .content(objectMapper.writeValueAsString(request)))
                                .andExpect(status().isOk())
                                .andExpect(jsonPath("$.access_token").value("newToken"));
        }
}
