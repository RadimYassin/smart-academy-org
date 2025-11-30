package com.radim.project.controller;

import com.radim.project.dto.LessonDto;
import com.radim.project.service.LessonService;
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
@RequiredArgsConstructor
@Tag(name = "Lessons", description = "Lesson management APIs")
public class LessonController {

    private final LessonService lessonService;

    @GetMapping("/modules/{moduleId}/lessons")
    @Operation(summary = "List lessons for a module")
    public ResponseEntity<List<LessonDto.Response>> getLessons(@PathVariable UUID moduleId) {
        return ResponseEntity.ok(lessonService.getLessonsByModule(moduleId));
    }

    @GetMapping("/lessons/{lessonId}")
    @Operation(summary = "Get lesson by ID")
    public ResponseEntity<LessonDto.Response> getLessonById(@PathVariable UUID lessonId) {
        return ResponseEntity.ok(lessonService.getLessonById(lessonId));
    }

    @PostMapping("/modules/{moduleId}/lessons")
    @PreAuthorize("hasAnyRole('TEACHER', 'ADMIN')")
    @Operation(summary = "Create a new lesson")
    public ResponseEntity<LessonDto.Response> createLesson(@PathVariable UUID moduleId,
            @Valid @RequestBody LessonDto.Request request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(lessonService.createLesson(moduleId, request));
    }

    @PutMapping("/modules/{moduleId}/lessons/{lessonId}")
    @PreAuthorize("hasAnyRole('TEACHER', 'ADMIN')")
    @Operation(summary = "Update a lesson")
    public ResponseEntity<LessonDto.Response> updateLesson(@PathVariable UUID moduleId, @PathVariable UUID lessonId,
            @Valid @RequestBody LessonDto.Request request) {
        return ResponseEntity.ok(lessonService.updateLesson(moduleId, lessonId, request));
    }

    @DeleteMapping("/modules/{moduleId}/lessons/{lessonId}")
    @PreAuthorize("hasAnyRole('TEACHER', 'ADMIN')")
    @Operation(summary = "Delete a lesson")
    public ResponseEntity<Void> deleteLesson(@PathVariable UUID moduleId, @PathVariable UUID lessonId) {
        lessonService.deleteLesson(moduleId, lessonId);
        return ResponseEntity.noContent().build();
    }
}
