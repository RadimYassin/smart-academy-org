package com.radim.project.controller;

import com.radim.project.dto.QuizDto;
import com.radim.project.service.QuizService;
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
@RequestMapping("/courses/{courseId}/quizzes")
@RequiredArgsConstructor
@Tag(name = "Quizzes", description = "Quiz management APIs")
public class QuizController {

    private final QuizService quizService;

    @GetMapping
    @Operation(summary = "List quizzes for a course")
    public ResponseEntity<List<QuizDto.Response>> getQuizzes(@PathVariable UUID courseId) {
        return ResponseEntity.ok(quizService.getQuizzesByCourse(courseId));
    }

    @GetMapping("/{quizId}")
    @Operation(summary = "Get quiz by ID")
    public ResponseEntity<QuizDto.Response> getQuizById(@PathVariable UUID courseId, @PathVariable UUID quizId) {
        // courseId is in path but not strictly needed if quizId is unique, but good for
        // validation if we wanted
        return ResponseEntity.ok(quizService.getQuizById(quizId));
    }

    @PostMapping
    @PreAuthorize("hasAnyRole('TEACHER', 'ADMIN')")
    @Operation(summary = "Create a new quiz")
    public ResponseEntity<QuizDto.Response> createQuiz(@PathVariable UUID courseId,
            @Valid @RequestBody QuizDto.Request request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(quizService.createQuiz(courseId, request));
    }

    @PutMapping("/{quizId}")
    @PreAuthorize("hasAnyRole('TEACHER', 'ADMIN')")
    @Operation(summary = "Update a quiz")
    public ResponseEntity<QuizDto.Response> updateQuiz(@PathVariable UUID courseId, @PathVariable UUID quizId,
            @Valid @RequestBody QuizDto.Request request) {
        return ResponseEntity.ok(quizService.updateQuiz(courseId, quizId, request));
    }

    @DeleteMapping("/{quizId}")
    @PreAuthorize("hasAnyRole('TEACHER', 'ADMIN')")
    @Operation(summary = "Delete a quiz")
    public ResponseEntity<Void> deleteQuiz(@PathVariable UUID courseId, @PathVariable UUID quizId) {
        quizService.deleteQuiz(courseId, quizId);
        return ResponseEntity.noContent().build();
    }
}
