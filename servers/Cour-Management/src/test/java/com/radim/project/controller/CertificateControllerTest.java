package com.radim.project.controller;

import com.radim.project.dto.CertificateDto;
import com.radim.project.service.CertificateService;
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

@WebMvcTest(CertificateController.class)
@ActiveProfiles("test")
@ContextConfiguration(classes = { CertificateController.class, CertificateControllerTest.TestSecurityConfig.class })
@DisplayName("CertificateController Web Layer Tests")
class CertificateControllerTest {

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
        private CertificateService certificateService;

        private CertificateDto.CertificateResponse certificateResponse;
        private final UUID courseId = UUID.randomUUID();
        private final Long studentId = 100L;
        private final String verificationCode = "CERT2024";

        @BeforeEach
        void setUp() {
                certificateResponse = CertificateDto.CertificateResponse.builder()
                                .id(UUID.randomUUID())
                                .courseId(courseId)
                                .studentId(studentId)
                                .verificationCode(verificationCode)
                                .build();
        }

        @Test
        @WithMockUser(username = "100", roles = "STUDENT")
        @DisplayName("Should get student certificates")
        void getStudentCertificates_Success() throws Exception {
                // Given
                List<CertificateDto.CertificateResponse> certificates = Arrays.asList(certificateResponse);
                when(certificateService.getStudentCertificates(studentId)).thenReturn(certificates);

                // When & Then
                mockMvc.perform(get("/api/certificates/my-certificates")
                                .contentType(MediaType.APPLICATION_JSON))
                                .andExpect(status().isOk())
                                .andExpect(jsonPath("$", hasSize(1)));

                verify(certificateService).getStudentCertificates(studentId);
        }

        @Test
        @DisplayName("Should verify certificate by code")
        void verifyCertificate_Success() throws Exception {
                // Given
                CertificateDto.CertificateVerificationResponse verificationResponse = CertificateDto.CertificateVerificationResponse
                                .builder()
                                .certificateId(UUID.randomUUID())
                                .valid(true)
                                .build();
                when(certificateService.verifyCertificate(verificationCode)).thenReturn(verificationResponse);

                // When & Then
                mockMvc.perform(get("/api/certificates/verify/{code}", verificationCode)
                                .contentType(MediaType.APPLICATION_JSON))
                                .andExpect(status().isOk())
                                .andExpect(jsonPath("$.valid", is(true)));

                verify(certificateService).verifyCertificate(verificationCode);
        }

        @Test
        @WithMockUser(username = "100", roles = "STUDENT")
        @DisplayName("Should generate certificate as student")
        void generateCertificate_AsStudent_Success() throws Exception {
                // Given
                when(certificateService.generateCertificate(any(UUID.class), any(Long.class)))
                                .thenReturn(certificateResponse);

                // When & Then
                mockMvc.perform(post("/api/certificates/generate/{courseId}", courseId)
                                .with(csrf())
                                .contentType(MediaType.APPLICATION_JSON))
                                .andExpect(status().isCreated());

                verify(certificateService).generateCertificate(courseId, studentId);
        }

        @Test
        @WithMockUser(username = "100", roles = "STUDENT")
        @DisplayName("Should check certificate eligibility")
        void checkEligibility_Success() throws Exception {
                // Given
                CertificateDto.CertificateEligibilityResponse eligibilityResponse = CertificateDto.CertificateEligibilityResponse
                                .builder()
                                .eligible(true)
                                .completionRate(85.5)
                                .build();
                when(certificateService.checkEligibility(courseId, studentId)).thenReturn(eligibilityResponse);

                // When & Then
                mockMvc.perform(get("/api/certificates/eligibility/{courseId}", courseId)
                                .contentType(MediaType.APPLICATION_JSON))
                                .andExpect(status().isOk())
                                .andExpect(jsonPath("$.eligible", is(true)));

                verify(certificateService).checkEligibility(courseId, studentId);
        }
}
