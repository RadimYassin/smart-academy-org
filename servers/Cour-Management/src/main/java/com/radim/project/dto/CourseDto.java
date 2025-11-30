package com.radim.project.dto;

import com.radim.project.entity.enums.CourseLevel;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.UUID;

public class CourseDto {

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class Request {
        @NotBlank
        @Size(min = 3)
        private String title;
        private String description;
        private String category;
        private CourseLevel level;
        private String thumbnailUrl;
    }

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class Response {
        private UUID id;
        private String title;
        private String description;
        private String category;
        private CourseLevel level;
        private String thumbnailUrl;
        private Long teacherId;
        private LocalDateTime createdAt;
        private LocalDateTime updatedAt;
    }
}
