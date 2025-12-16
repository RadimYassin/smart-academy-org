package com.radim.project.controller;

import com.radim.project.dto.ClassDto;
import com.radim.project.security.JwtService;
import com.radim.project.service.StudentClassService;
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
@RequestMapping("/api/classes")
@RequiredArgsConstructor
@Tag(name = "Class Management", description = "APIs for managing student classes/groups")
public class StudentClassController {

    private final StudentClassService studentClassService;
    private final JwtService jwtService;

    @PostMapping
    @PreAuthorize("hasRole('TEACHER')")
    @Operation(summary = "Create a new class", description = "Teacher can create a new student class/group")
    public ResponseEntity<ClassDto.ClassResponse> createClass(
            @Valid @RequestBody ClassDto.CreateClassRequest request,
            Authentication authentication) {
        Long teacherId = extractTeacherId(authentication);
        ClassDto.ClassResponse response = studentClassService.createClass(request, teacherId);
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

    @GetMapping
    @PreAuthorize("hasRole('TEACHER')")
    @Operation(summary = "Get all classes", description = "Teacher can view all their classes")
    public ResponseEntity<List<ClassDto.ClassResponse>> getMyClasses(Authentication authentication) {
        Long teacherId = extractTeacherId(authentication);
        List<ClassDto.ClassResponse> classes = studentClassService.getClassesByTeacher(teacherId);
        return ResponseEntity.ok(classes);
    }

    @GetMapping("/{classId}")
    @PreAuthorize("hasRole('TEACHER')")
    @Operation(summary = "Get class details", description = "Teacher can view details of their class")
    public ResponseEntity<ClassDto.ClassResponse> getClass(
            @PathVariable UUID classId,
            Authentication authentication) {
        Long teacherId = extractTeacherId(authentication);
        ClassDto.ClassResponse response = studentClassService.getClassById(classId, teacherId);
        return ResponseEntity.ok(response);
    }

    @PutMapping("/{classId}")
    @PreAuthorize("hasRole('TEACHER')")
    @Operation(summary = "Update class", description = "Teacher can update their class details")
    public ResponseEntity<ClassDto.ClassResponse> updateClass(
            @PathVariable UUID classId,
            @Valid @RequestBody ClassDto.UpdateClassRequest request,
            Authentication authentication) {
        Long teacherId = extractTeacherId(authentication);
        ClassDto.ClassResponse response = studentClassService.updateClass(classId, request, teacherId);
        return ResponseEntity.ok(response);
    }

    @DeleteMapping("/{classId}")
    @PreAuthorize("hasRole('TEACHER')")
    @Operation(summary = "Delete class", description = "Teacher can delete their class")
    public ResponseEntity<Void> deleteClass(
            @PathVariable UUID classId,
            Authentication authentication) {
        Long teacherId = extractTeacherId(authentication);
        studentClassService.deleteClass(classId, teacherId);
        return ResponseEntity.noContent().build();
    }

    @PostMapping("/{classId}/students")
    @PreAuthorize("hasRole('TEACHER')")
    @Operation(summary = "Add students to class", description = "Teacher can add students to their class")
    public ResponseEntity<Void> addStudents(
            @PathVariable UUID classId,
            @Valid @RequestBody ClassDto.AddStudentsRequest request,
            Authentication authentication) {
        Long teacherId = extractTeacherId(authentication);
        studentClassService.addStudentsToClass(classId, request.getStudentIds(), teacherId);
        return ResponseEntity.noContent().build();
    }

    @DeleteMapping("/{classId}/students/{studentId}")
    @PreAuthorize("hasRole('TEACHER')")
    @Operation(summary = "Remove student from class", description = "Teacher can remove a student from their class")
    public ResponseEntity<Void> removeStudent(
            @PathVariable UUID classId,
            @PathVariable Long studentId,
            Authentication authentication) {
        Long teacherId = extractTeacherId(authentication);
        studentClassService.removeStudentFromClass(classId, studentId, teacherId);
        return ResponseEntity.noContent().build();
    }

    @GetMapping("/{classId}/students")
    @PreAuthorize("hasRole('TEACHER')")
    @Operation(summary = "Get class students", description = "Teacher can view all students in their class")
    public ResponseEntity<List<ClassDto.ClassStudentResponse>> getClassStudents(
            @PathVariable UUID classId,
            Authentication authentication) {
        Long teacherId = extractTeacherId(authentication);
        List<ClassDto.ClassStudentResponse> students = studentClassService.getClassStudents(classId, teacherId);
        return ResponseEntity.ok(students);
    }

    private Long extractTeacherId(Authentication authentication) {
        return Long.parseLong(authentication.getName());
    }
}
