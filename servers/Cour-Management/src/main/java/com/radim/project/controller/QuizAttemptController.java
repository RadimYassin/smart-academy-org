package com.radim.project.controller;

import com.radim.project.dto.QuizAttemptDto;
import com.radim.project.service.QuizAttemptService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/quiz-attempts")
@RequiredArgsConstructor
@Tag(name = "Quiz Attempts", description = "Student quiz attempt and scoring endpoints")
public class QuizAttemptController {

    private final QuizAttemptService quizAttemptService;

    @Operation(summary = "Start a new quiz attempt", description = "Student starts taking a quiz")
    @PostMapping("/start/{quizId}")
    public ResponseEntity<QuizAttemptDto.AttemptResponse> startQuiz(@PathVariable UUID quizId) {
        return ResponseEntity.ok(quizAttemptService.startQuizAttempt(quizId));
    }

    @Operation(summary = "Submit quiz answers", description = "Student submits answers and receives score")
    @PostMapping("/{attemptId}/submit")
    public ResponseEntity<QuizAttemptDto.AttemptResponse> submitQuiz(
            @PathVariable UUID attemptId,
            @RequestBody QuizAttemptDto.SubmitRequest request) {
        return ResponseEntity.ok(quizAttemptService.submitQuizAttempt(attemptId, request));
    }

    @Operation(summary = "Get student's all attempts", description = "Retrieve all quiz attempts by a student")
    @GetMapping("/student/{studentId}")
    public ResponseEntity<List<QuizAttemptDto.AttemptResponse>> getStudentAttempts(
            @PathVariable Long studentId) {
        return ResponseEntity.ok(quizAttemptService.getStudentAttempts(studentId));
    }

    @Operation(summary = "Get all attempts for a quiz", description = "Teacher view: all student attempts for a quiz")
    @GetMapping("/quiz/{quizId}")
    public ResponseEntity<List<QuizAttemptDto.AttemptResponse>> getQuizAttempts(
            @PathVariable UUID quizId) {
        return ResponseEntity.ok(quizAttemptService.getQuizAttempts(quizId));
    }

    @Operation(summary = "Get student attempts for a specific quiz", description = "Retrieve student's attempts for a specific quiz")
    @GetMapping("/student/{studentId}/quiz/{quizId}")
    public ResponseEntity<List<QuizAttemptDto.AttemptResponse>> getStudentQuizAttempts(
            @PathVariable Long studentId,
            @PathVariable UUID quizId) {
        return ResponseEntity.ok(quizAttemptService.getStudentQuizAttempts(studentId, quizId));
    }

    @Operation(summary = "Get attempt details", description = "Get detailed attempt information including answers")
    @GetMapping("/{attemptId}")
    public ResponseEntity<QuizAttemptDto.AttemptResponse> getAttemptDetails(
            @PathVariable UUID attemptId) {
        return ResponseEntity.ok(quizAttemptService.getAttemptDetails(attemptId));
    }
}
