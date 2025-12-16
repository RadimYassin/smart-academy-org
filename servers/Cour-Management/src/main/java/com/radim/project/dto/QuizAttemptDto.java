package com.radim.project.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

public class QuizAttemptDto {

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class SubmitRequest {
        private List<AnswerSubmission> answers;

        @Data
        @NoArgsConstructor
        @AllArgsConstructor
        public static class AnswerSubmission {
            private UUID questionId;
            private UUID selectedOptionId;
        }
    }

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class AttemptResponse {
        private UUID id;
        private UUID quizId;
        private String quizTitle;
        private Long studentId;
        private Integer score;
        private Integer maxScore;
        private Double percentage;
        private Boolean passed;
        private LocalDateTime startedAt;
        private LocalDateTime submittedAt;
        private List<AnswerDetail> answers; // Only shown after submission
    }

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class AnswerDetail {
        private UUID questionId;
        private String questionContent;
        private UUID selectedOptionId;
        private UUID correctOptionId;
        private Boolean isCorrect;
    }

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class StudentScoreSummary {
        private Long studentId;
        private UUID quizId;
        private String quizTitle;
        private Integer totalAttempts;
        private Double bestScore;
        private Double latestScore;
        private LocalDateTime lastAttemptDate;
    }
}
