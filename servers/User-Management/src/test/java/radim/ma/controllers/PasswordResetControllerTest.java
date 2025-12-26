package radim.ma.controllers;

import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;
import radim.ma.config.TestSecurityConfig;
import radim.ma.dto.ForgotPasswordRequest;
import radim.ma.dto.ResetPasswordRequest;
import radim.ma.services.PasswordResetService;
import org.springframework.context.annotation.Import;

import static org.mockito.ArgumentMatchers.anyString;
// Removed unused import
import static org.mockito.Mockito.*;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@WebMvcTest(PasswordResetController.class)
@Import(TestSecurityConfig.class)
class PasswordResetControllerTest {

        @Autowired
        private MockMvc mockMvc;

        @Autowired
        private ObjectMapper objectMapper;

        @MockBean
        private PasswordResetService passwordResetService;

        @MockBean
        private radim.ma.security.JwtUtil jwtUtil;

        // Security mocks removed

        private ForgotPasswordRequest forgotPasswordRequest;
        private ResetPasswordRequest resetPasswordRequest;

        @BeforeEach
        void setUp() {
                forgotPasswordRequest = new ForgotPasswordRequest();
                forgotPasswordRequest.setEmail("test@example.com");

                resetPasswordRequest = new ResetPasswordRequest();
                resetPasswordRequest.setEmail("test@example.com");
                resetPasswordRequest.setCode("123456");
                resetPasswordRequest.setNewPassword("NewPassword123@");

        }

        @Test
        void testForgotPassword_ValidEmail_SendsResetCode() throws Exception {
                // Given
                doNothing().when(passwordResetService).requestPasswordReset(anyString());

                // When & Then
                mockMvc.perform(post("/api/v1/auth/forgot-password")
                                .contentType(MediaType.APPLICATION_JSON)
                                .content(objectMapper.writeValueAsString(forgotPasswordRequest)))
                                .andExpect(status().isOk())
                                .andExpect(jsonPath("$.message")
                                                .value("Password reset code has been sent to your email"));

                verify(passwordResetService).requestPasswordReset("test@example.com");
        }

        @Test
        void testForgotPassword_InvalidEmail_ThrowsException() throws Exception {
                // Given
                doThrow(new RuntimeException("User not found"))
                                .when(passwordResetService).requestPasswordReset(anyString());

                // When & Then
                mockMvc.perform(post("/api/v1/auth/forgot-password")
                                .contentType(MediaType.APPLICATION_JSON)
                                .content(objectMapper.writeValueAsString(forgotPasswordRequest)))
                                .andExpect(status().is4xxClientError());

                verify(passwordResetService).requestPasswordReset("test@example.com");
        }

        @Test
        void testForgotPassword_NullEmail_ReturnsBadRequest() throws Exception {
                // Given
                forgotPasswordRequest.setEmail(null);

                // When & Then
                mockMvc.perform(post("/api/v1/auth/forgot-password")
                                .contentType(MediaType.APPLICATION_JSON)
                                .content(objectMapper.writeValueAsString(forgotPasswordRequest)))
                                .andExpect(status().isBadRequest());

                verify(passwordResetService, never()).requestPasswordReset(anyString());
        }

        @Test
        void testResetPassword_ValidCode_ResetsPassword() throws Exception {
                // Given
                doNothing().when(passwordResetService).resetPassword(anyString(), anyString(), anyString());

                // When & Then
                mockMvc.perform(post("/api/v1/auth/reset-password")
                                .contentType(MediaType.APPLICATION_JSON)
                                .content(objectMapper.writeValueAsString(resetPasswordRequest)))
                                .andExpect(status().isOk())
                                .andExpect(jsonPath("$.message")
                                                .value("Password reset successfully! You can now log in with your new password."));

                verify(passwordResetService).resetPassword("test@example.com", "123456", "NewPassword123@");
        }

        @Test
        void testResetPassword_InvalidCode_ThrowsException() throws Exception {
                // Given
                doThrow(new RuntimeException("Invalid or expired code"))
                                .when(passwordResetService).resetPassword(anyString(), anyString(), anyString());

                // When & Then
                mockMvc.perform(post("/api/v1/auth/reset-password")
                                .contentType(MediaType.APPLICATION_JSON)
                                .content(objectMapper.writeValueAsString(resetPasswordRequest)))
                                .andExpect(status().is4xxClientError());

                verify(passwordResetService).resetPassword("test@example.com", "123456", "NewPassword123@");
        }

        @Test
        void testResetPassword_ExpiredCode_ThrowsException() throws Exception {
                // Given
                doThrow(new RuntimeException("Code has expired"))
                                .when(passwordResetService).resetPassword(anyString(), anyString(), anyString());

                // When & Then
                mockMvc.perform(post("/api/v1/auth/reset-password")
                                .contentType(MediaType.APPLICATION_JSON)
                                .content(objectMapper.writeValueAsString(resetPasswordRequest)))
                                .andExpect(status().is4xxClientError());

                verify(passwordResetService).resetPassword("test@example.com", "123456", "NewPassword123@");
        }

        @Test
        void testResetPassword_MissingFields_ReturnsBadRequest() throws Exception {
                // Given
                resetPasswordRequest.setCode(null);

                // When & Then
                mockMvc.perform(post("/api/v1/auth/reset-password")
                                .contentType(MediaType.APPLICATION_JSON)
                                .content(objectMapper.writeValueAsString(resetPasswordRequest)))
                                .andExpect(status().isBadRequest());

                verify(passwordResetService, never()).resetPassword(anyString(), anyString(), anyString());
        }

        @Test
        void testResetPassword_EmptyPassword_ReturnsBadRequest() throws Exception {
                // Given
                resetPasswordRequest.setNewPassword("");

                // When & Then
                mockMvc.perform(post("/api/v1/auth/reset-password")
                                .contentType(MediaType.APPLICATION_JSON)
                                .content(objectMapper.writeValueAsString(resetPasswordRequest)))
                                .andExpect(status().isBadRequest());

                verify(passwordResetService, never()).resetPassword(anyString(), anyString(), anyString());
        }
}
