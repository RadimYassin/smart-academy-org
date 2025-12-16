package com.radim.project.dto;

import com.radim.project.entity.enums.QuizDifficulty;
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
        private String questionText;

        @NotBlank
        private String questionType;

        @NotNull
        @Size(min = 2, max = 10)
        private List<OptionRequest> options;

        private Integer points;
    }

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class OptionRequest {
        @NotBlank
        private String optionText;

        @NotNull
        private Boolean isCorrect;
    }

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class QuestionResponse {
        private UUID id;
        private UUID quizId;
        private String questionText;
        private String questionType;
        private List<OptionResponse> options;
        private Integer points;
    }

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class OptionResponse {
        private UUID id;
        private String optionText;
        private Boolean isCorrect;
    }
}
