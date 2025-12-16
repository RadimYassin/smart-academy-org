package com.radim.project.controller;

import com.radim.project.dto.EnrollmentDto;
import com.radim.project.service.EnrollmentService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/enrollments")
@RequiredArgsConstructor
@Tag(name = "Enrollment Management", description = "APIs for managing course enrollments")
public class EnrollmentController {

    private final EnrollmentService enrollmentService;

    @PostMapping("/student")
    @PreAuthorize("hasRole('TEACHER')")
    @Operation(summary = "Assign student to course", description = "Teacher can assign individual student to their course")
    public ResponseEntity<EnrollmentDto.EnrollmentResponse> assignStudent(
            @Valid @RequestBody EnrollmentDto.AssignStudentRequest request,
            Authentication authentication) {
        Long teacherId = extractUserId(authentication);
        EnrollmentDto.EnrollmentResponse response = enrollmentService.assignStudentToCourse(
                request.getCourseId(), request.getStudentId(), teacherId);
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

    @PostMapping("/class")
    @PreAuthorize("hasRole('TEACHER')")
    @Operation(summary = "Assign class to course", description = "Teacher can assign entire class to their course")
    public ResponseEntity<List<EnrollmentDto.EnrollmentResponse>> assignClass(
            @Valid @RequestBody EnrollmentDto.AssignClassRequest request,
            Authentication authentication) {
        Long teacherId = extractUserId(authentication);
        List<EnrollmentDto.EnrollmentResponse> responses = enrollmentService.assignClassToCourse(
                request.getCourseId(), request.getClassId(), teacherId);
        return ResponseEntity.status(HttpStatus.CREATED).body(responses);
    }

    @GetMapping("/my-courses")
    @PreAuthorize("hasRole('STUDENT')")
    @Operation(summary = "Get student's courses", description = "Student can view their enrolled courses")
    public ResponseEntity<List<EnrollmentDto.EnrollmentResponse>> getMyEnrollments(Authentication authentication) {
        Long studentId = extractUserId(authentication);
        List<EnrollmentDto.EnrollmentResponse> enrollments = enrollmentService.getStudentEnrollments(studentId);
        return ResponseEntity.ok(enrollments);
    }

    @GetMapping("/courses/{courseId}")
    @PreAuthorize("hasRole('TEACHER')")
    @Operation(summary = "Get course enrollments", description = "Teacher can view all enrollments for their course")
    public ResponseEntity<List<EnrollmentDto.EnrollmentResponse>> getCourseEnrollments(
            @PathVariable UUID courseId,
            Authentication authentication) {
        Long teacherId = extractUserId(authentication);
        List<EnrollmentDto.EnrollmentResponse> enrollments = enrollmentService.getCourseEnrollments(courseId,
                teacherId);
        return ResponseEntity.ok(enrollments);
    }

    @DeleteMapping("/courses/{courseId}/students/{studentId}")
    @PreAuthorize("hasRole('TEACHER')")
    @Operation(summary = "Unenroll student", description = "Teacher can remove student from their course")
    public ResponseEntity<Void> unenrollStudent(
            @PathVariable UUID courseId,
            @PathVariable Long studentId,
            Authentication authentication) {
        Long teacherId = extractUserId(authentication);
        enrollmentService.unenrollStudent(courseId, studentId, teacherId);
        return ResponseEntity.noContent().build();
    }

    private Long extractUserId(Authentication authentication) {
        return Long.parseLong(authentication.getName());
    }
}
