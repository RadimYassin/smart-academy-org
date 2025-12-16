package com.radim.project.dto;

import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.UUID;

public class ProgressDto {

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class MarkLessonCompleteRequest {
        @NotNull
        private UUID lessonId;
    }

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class LessonProgressResponse {
        private UUID lessonId;
        private String lessonTitle;
        private Boolean completed;
        private LocalDateTime completedAt;
    }

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class CourseProgressResponse {
        private UUID courseId;
        private String courseTitle;
        private Long totalLessons;
        private Long completedLessons;
        private Double completionRate;
    }

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class ModuleProgressResponse {
        private UUID moduleId;
        private String moduleTitle;
        private Long totalLessons;
        private Long completedLessons;
        private Double completionRate;
    }
}
