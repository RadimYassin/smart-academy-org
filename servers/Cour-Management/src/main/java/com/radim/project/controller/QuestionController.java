package com.radim.project.controller;

import com.radim.project.dto.QuizDto;
import com.radim.project.service.QuestionService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/quizzes/{quizId}/questions")
@RequiredArgsConstructor
@Tag(name = "Questions", description = "Question management APIs")
public class QuestionController {

    private final QuestionService questionService;

    @GetMapping
    @Operation(summary = "List questions for a quiz")
    public ResponseEntity<List<QuizDto.QuestionResponse>> getQuestions(@PathVariable UUID quizId) {
        return ResponseEntity.ok(questionService.getQuestionsByQuiz(quizId));
    }

    @PostMapping
    @PreAuthorize("hasAnyRole('TEACHER', 'ADMIN')")
    @Operation(summary = "Add a question to a quiz")
    public ResponseEntity<QuizDto.QuestionResponse> createQuestion(@PathVariable UUID quizId,
            @Valid @RequestBody QuizDto.QuestionRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(questionService.createQuestion(quizId, request));
    }

    @PutMapping("/{questionId}")
    @PreAuthorize("hasAnyRole('TEACHER', 'ADMIN')")
    @Operation(summary = "Update a question")
    public ResponseEntity<QuizDto.QuestionResponse> updateQuestion(@PathVariable UUID quizId,
            @PathVariable UUID questionId, @Valid @RequestBody QuizDto.QuestionRequest request) {
        return ResponseEntity.ok(questionService.updateQuestion(quizId, questionId, request));
    }

    @DeleteMapping("/{questionId}")
    @PreAuthorize("hasAnyRole('TEACHER', 'ADMIN')")
    @Operation(summary = "Delete a question")
    public ResponseEntity<Void> deleteQuestion(@PathVariable UUID quizId, @PathVariable UUID questionId) {
        questionService.deleteQuestion(quizId, questionId);
        return ResponseEntity.noContent().build();
    }
}
