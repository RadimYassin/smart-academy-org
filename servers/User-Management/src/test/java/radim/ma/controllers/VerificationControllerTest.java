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
import radim.ma.dto.ResendOTPRequest;
import radim.ma.dto.VerificationRequest;
import radim.ma.services.VerificationService;

import org.springframework.context.annotation.Import;

import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.*;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@WebMvcTest(VerificationController.class)
@Import(TestSecurityConfig.class)
class VerificationControllerTest {

        @Autowired
        private MockMvc mockMvc;

        @Autowired
        private ObjectMapper objectMapper;

        @MockBean
        private VerificationService verificationService;

        @MockBean
        private radim.ma.security.JwtUtil jwtUtil;

        // Security mocks removed

        private VerificationRequest verificationRequest;
        private ResendOTPRequest resendOTPRequest;

        @BeforeEach
        void setUp() {
                verificationRequest = new VerificationRequest();
                verificationRequest.setEmail("test@example.com");
                verificationRequest.setCode("123456");

                resendOTPRequest = new ResendOTPRequest();
                resendOTPRequest.setEmail("test@example.com");

        }

        @Test
        void testVerifyEmail_ValidCode_VerifiesSuccessfully() throws Exception {
                // Given
                doNothing().when(verificationService).verifyEmail(anyString(), anyString());

                // When & Then
                mockMvc.perform(post("/api/v1/auth/verify-email")
                                .contentType(MediaType.APPLICATION_JSON)
                                .content(objectMapper.writeValueAsString(verificationRequest)))
                                .andExpect(status().isOk())
                                .andExpect(jsonPath("$.message")
                                                .value("Email verified successfully! You can now log in."))
                                .andExpect(jsonPath("$.verified").value(true));

                verify(verificationService).verifyEmail("test@example.com", "123456");
        }

        @Test
        void testVerifyEmail_InvalidCode_ThrowsException() throws Exception {
                // Given
                doThrow(new RuntimeException("Invalid verification code"))
                                .when(verificationService).verifyEmail(anyString(), anyString());

                // When & Then
                mockMvc.perform(post("/api/v1/auth/verify-email")
                                .contentType(MediaType.APPLICATION_JSON)
                                .content(objectMapper.writeValueAsString(verificationRequest)))
                                .andExpect(status().is4xxClientError());

                verify(verificationService).verifyEmail("test@example.com", "123456");
        }

        @Test
        void testVerifyEmail_ExpiredCode_ThrowsException() throws Exception {
                // Given
                doThrow(new RuntimeException("Verification code has expired"))
                                .when(verificationService).verifyEmail(anyString(), anyString());

                // When & Then
                mockMvc.perform(post("/api/v1/auth/verify-email")
                                .contentType(MediaType.APPLICATION_JSON)
                                .content(objectMapper.writeValueAsString(verificationRequest)))
                                .andExpect(status().is4xxClientError());

                verify(verificationService).verifyEmail("test@example.com", "123456");
        }

        @Test
        void testVerifyEmail_AlreadyVerified_ThrowsException() throws Exception {
                // Given
                doThrow(new RuntimeException("Email already verified"))
                                .when(verificationService).verifyEmail(anyString(), anyString());

                // When & Then
                mockMvc.perform(post("/api/v1/auth/verify-email")
                                .contentType(MediaType.APPLICATION_JSON)
                                .content(objectMapper.writeValueAsString(verificationRequest)))
                                .andExpect(status().is4xxClientError());

                verify(verificationService).verifyEmail("test@example.com", "123456");
        }

        @Test
        void testVerifyEmail_MissingCode_ReturnsBadRequest() throws Exception {
                // Given
                verificationRequest.setCode(null);

                // When & Then
                mockMvc.perform(post("/api/v1/auth/verify-email")
                                .contentType(MediaType.APPLICATION_JSON)
                                .content(objectMapper.writeValueAsString(verificationRequest)))
                                .andExpect(status().isBadRequest());

                verify(verificationService, never()).verifyEmail(anyString(), anyString());
        }

        @Test
        void testVerifyEmail_MissingEmail_ReturnsBadRequest() throws Exception {
                // Given
                verificationRequest.setEmail(null);

                // When & Then
                mockMvc.perform(post("/api/v1/auth/verify-email")
                                .contentType(MediaType.APPLICATION_JSON)
                                .content(objectMapper.writeValueAsString(verificationRequest)))
                                .andExpect(status().isBadRequest());

                verify(verificationService, never()).verifyEmail(anyString(), anyString());
        }

        @Test
        void testResendOTP_ValidEmail_SendsNewCode() throws Exception {
                // Given
                doNothing().when(verificationService).resendVerificationCode(anyString());

                // When & Then
                mockMvc.perform(post("/api/v1/auth/resend-otp")
                                .contentType(MediaType.APPLICATION_JSON)
                                .content(objectMapper.writeValueAsString(resendOTPRequest)))
                                .andExpect(status().isOk())
                                .andExpect(jsonPath("$.message")
                                                .value("Verification code has been sent to your email"));

                verify(verificationService).resendVerificationCode("test@example.com");
        }

        @Test
        void testResendOTP_AlreadyVerified_ThrowsException() throws Exception {
                // Given
                doThrow(new RuntimeException("Email already verified"))
                                .when(verificationService).resendVerificationCode(anyString());

                // When & Then
                mockMvc.perform(post("/api/v1/auth/resend-otp")
                                .contentType(MediaType.APPLICATION_JSON)
                                .content(objectMapper.writeValueAsString(resendOTPRequest)))
                                .andExpect(status().is4xxClientError());

                verify(verificationService).resendVerificationCode("test@example.com");
        }

        @Test
        void testResendOTP_UserNotFound_ThrowsException() throws Exception {
                // Given
                doThrow(new RuntimeException("User not found"))
                                .when(verificationService).resendVerificationCode(anyString());

                // When & Then
                mockMvc.perform(post("/api/v1/auth/resend-otp")
                                .contentType(MediaType.APPLICATION_JSON)
                                .content(objectMapper.writeValueAsString(resendOTPRequest)))
                                .andExpect(status().is4xxClientError());

                verify(verificationService).resendVerificationCode("test@example.com");
        }

        @Test
        void testResendOTP_MissingEmail_ReturnsBadRequest() throws Exception {
                // Given
                resendOTPRequest.setEmail(null);

                // When & Then
                mockMvc.perform(post("/api/v1/auth/resend-otp")
                                .contentType(MediaType.APPLICATION_JSON)
                                .content(objectMapper.writeValueAsString(resendOTPRequest)))
                                .andExpect(status().isBadRequest());

                verify(verificationService, never()).resendVerificationCode(anyString());
        }

        @Test
        void testVerifyEmail_EmptyCode_ReturnsBadRequest() throws Exception {
                // Given
                verificationRequest.setCode("");

                // When & Then
                mockMvc.perform(post("/api/v1/auth/verify-email")
                                .contentType(MediaType.APPLICATION_JSON)
                                .content(objectMapper.writeValueAsString(verificationRequest)))
                                .andExpect(status().isBadRequest());

                verify(verificationService, never()).verifyEmail(anyString(), anyString());
        }
}
