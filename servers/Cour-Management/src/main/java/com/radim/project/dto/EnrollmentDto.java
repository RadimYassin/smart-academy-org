package com.radim.project.dto;

import com.radim.project.entity.enums.AssignmentType;
import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.UUID;

public class EnrollmentDto {

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class AssignStudentRequest {
        @NotNull
        private UUID courseId;

        @NotNull
        private Long studentId;
    }

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class AssignClassRequest {
        @NotNull
        private UUID courseId;

        @NotNull
        private UUID classId;
    }

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class EnrollmentResponse {
        private UUID id;
        private UUID courseId;
        private String courseTitle;
        private Long studentId;
        private UUID classId;
        private String className;
        private Long assignedBy;
        private AssignmentType assignmentType;
        private LocalDateTime enrolledAt;
    }
}
