package com.radim.project.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

public class CertificateDto {

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class CertificateResponse {
        private UUID id;
        private UUID courseId;
        private String courseTitle;
        private Long studentId;
        private String verificationCode;
        private Double completionRate;
        private LocalDateTime issuedAt;
        private String downloadUrl;
    }

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class CertificateEligibilityResponse {
        private Boolean eligible;
        private Double completionRate;
        private Boolean completionRequirementMet;
        private Boolean mandatoryQuizzesPassed;
        private List<String> missingRequirements;
    }

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class CertificateVerificationResponse {
        private UUID certificateId;
        private UUID courseId;
        private String courseTitle;
        private Long studentId;
        private Double completionRate;
        private LocalDateTime issuedAt;
        private Boolean valid;
    }
}
