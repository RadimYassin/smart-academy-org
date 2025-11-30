package com.radim.project.dto;

import com.radim.project.entity.enums.ContentType;
import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.UUID;

public class ContentDto {

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class Request {
        @NotNull
        private ContentType type;
        private String textContent;
        private String pdfUrl;
        private String videoUrl;
        private String imageUrl;
        private UUID quizId;
        private int orderIndex;
    }

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class Response {
        private UUID id;
        private UUID lessonId;
        private ContentType type;
        private String textContent;
        private String pdfUrl;
        private String videoUrl;
        private String imageUrl;
        private UUID quizId;
        private int orderIndex;
        private LocalDateTime createdAt;
        private LocalDateTime updatedAt;
    }
}
