package com.radim.project.dto;

import com.radim.project.entity.enums.QuizDifficulty;
import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

public class QuizDto {

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class Request {
        @NotBlank
        private String title;
        private String description;
        private QuizDifficulty difficulty;
    }

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class Response {
        private UUID id;
        private UUID courseId;
        private String title;
        private String description;
        private QuizDifficulty difficulty;
        private LocalDateTime createdAt;
        private LocalDateTime updatedAt;
    }

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class QuestionRequest {
        @NotBlank
        private String content;
        @NotNull
        @Size(min = 4, max = 4)
        private List<String> options;
        @Min(0)
        @Max(3)
        private int correctOptionIndex;
    }

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class QuestionResponse {
        private UUID id;
        private UUID quizId;
        private String content;
        private List<String> options;
        private int correctOptionIndex;
    }
}
