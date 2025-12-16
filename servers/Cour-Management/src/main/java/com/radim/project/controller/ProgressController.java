package com.radim.project.controller;

import com.radim.project.dto.ProgressDto;
import com.radim.project.service.ProgressService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.UUID;

@RestController
@RequestMapping("/api/progress")
@RequiredArgsConstructor
@Tag(name = "Progress Tracking", description = "APIs for tracking student lesson and course progress")
public class ProgressController {

    private final ProgressService progressService;

    @PostMapping("/lessons/{lessonId}/complete")
    @PreAuthorize("hasRole('STUDENT')")
    @Operation(summary = "Mark lesson complete", description = "Student can mark a lesson as completed")
    public ResponseEntity<ProgressDto.LessonProgressResponse> markLessonComplete(
            @PathVariable UUID lessonId,
            Authentication authentication) {
        Long studentId = extractUserId(authentication);
        ProgressDto.LessonProgressResponse response = progressService.markLessonComplete(lessonId, studentId);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/lessons/{lessonId}")
    @PreAuthorize("hasRole('STUDENT')")
    @Operation(summary = "Get lesson progress", description = "Student can view their progress for a specific lesson")
    public ResponseEntity<ProgressDto.LessonProgressResponse> getLessonProgress(
            @PathVariable UUID lessonId,
            Authentication authentication) {
        Long studentId = extractUserId(authentication);
        ProgressDto.LessonProgressResponse response = progressService.getLessonProgress(lessonId, studentId);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/courses/{courseId}")
    @PreAuthorize("hasAnyRole('STUDENT', 'TEACHER')")
    @Operation(summary = "Get course progress", description = "Student can view their own progress, teacher can view student progress")
    public ResponseEntity<ProgressDto.CourseProgressResponse> getCourseProgress(
            @PathVariable UUID courseId,
            @RequestParam(required = false) Long studentId,
            Authentication authentication) {
        Long userId = extractUserId(authentication);

        // If studentId is provided, teacher can view that student's progress
        // Otherwise, student views their own progress
        Long targetStudentId = (studentId != null) ? studentId : userId;

        ProgressDto.CourseProgressResponse response = progressService.getCourseProgress(courseId, targetStudentId);
        return ResponseEntity.ok(response);
    }

    private Long extractUserId(Authentication authentication) {
        return Long.parseLong(authentication.getName());
    }
}
