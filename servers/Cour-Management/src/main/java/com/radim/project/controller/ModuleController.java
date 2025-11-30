package com.radim.project.controller;

import com.radim.project.dto.ModuleDto;
import com.radim.project.service.ModuleService;
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
@RequestMapping("/courses/{courseId}/modules")
@RequiredArgsConstructor
@Tag(name = "Modules", description = "Module management APIs")
public class ModuleController {

    private final ModuleService moduleService;

    @GetMapping
    @Operation(summary = "List modules for a course")
    public ResponseEntity<List<ModuleDto.Response>> getModules(@PathVariable UUID courseId) {
        return ResponseEntity.ok(moduleService.getModulesByCourse(courseId));
    }

    @PostMapping
    @PreAuthorize("hasAnyRole('TEACHER', 'ADMIN')")
    @Operation(summary = "Create a new module")
    public ResponseEntity<ModuleDto.Response> createModule(@PathVariable UUID courseId,
            @Valid @RequestBody ModuleDto.Request request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(moduleService.createModule(courseId, request));
    }

    @PutMapping("/{moduleId}")
    @PreAuthorize("hasAnyRole('TEACHER', 'ADMIN')")
    @Operation(summary = "Update a module")
    public ResponseEntity<ModuleDto.Response> updateModule(@PathVariable UUID courseId, @PathVariable UUID moduleId,
            @Valid @RequestBody ModuleDto.Request request) {
        return ResponseEntity.ok(moduleService.updateModule(courseId, moduleId, request));
    }

    @DeleteMapping("/{moduleId}")
    @PreAuthorize("hasAnyRole('TEACHER', 'ADMIN')")
    @Operation(summary = "Delete a module")
    public ResponseEntity<Void> deleteModule(@PathVariable UUID courseId, @PathVariable UUID moduleId) {
        moduleService.deleteModule(courseId, moduleId);
        return ResponseEntity.noContent().build();
    }
}
