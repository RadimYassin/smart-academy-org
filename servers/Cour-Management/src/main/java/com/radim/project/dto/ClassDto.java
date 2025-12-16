package com.radim.project.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.UUID;

public class ClassDto {

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class CreateClassRequest {
        @NotBlank
        @Size(min = 3, max = 255)
        private String name;

        private String description;
    }

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class UpdateClassRequest {
        @NotBlank
        @Size(min = 3, max = 255)
        private String name;

        private String description;
    }

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class ClassResponse {
        private UUID id;
        private String name;
        private String description;
        private Long teacherId;
        private Integer studentCount;
        private LocalDateTime createdAt;
        private LocalDateTime updatedAt;
    }

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class AddStudentsRequest {
        private java.util.List<Long> studentIds;
    }

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class ClassStudentResponse {
        private Long studentId;
        private Long addedBy;
        private LocalDateTime addedAt;
    }
}
