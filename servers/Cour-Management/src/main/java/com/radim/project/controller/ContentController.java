package com.radim.project.controller;

import com.radim.project.dto.ContentDto;
import com.radim.project.service.ContentService;
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
@RequestMapping("/lessons/{lessonId}/content")
@RequiredArgsConstructor
@Tag(name = "Lesson Content", description = "Lesson content management APIs")
public class ContentController {

    private final ContentService contentService;

    @GetMapping
    @Operation(summary = "List content for a lesson")
    public ResponseEntity<List<ContentDto.Response>> getContent(@PathVariable UUID lessonId) {
        return ResponseEntity.ok(contentService.getContentByLesson(lessonId));
    }

    @PostMapping
    @PreAuthorize("hasAnyRole('TEACHER', 'ADMIN')")
    @Operation(summary = "Add content to a lesson")
    public ResponseEntity<ContentDto.Response> createContent(@PathVariable UUID lessonId,
            @Valid @RequestBody ContentDto.Request request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(contentService.createContent(lessonId, request));
    }

    @PutMapping("/{contentId}")
    @PreAuthorize("hasAnyRole('TEACHER', 'ADMIN')")
    @Operation(summary = "Update content")
    public ResponseEntity<ContentDto.Response> updateContent(@PathVariable UUID lessonId, @PathVariable UUID contentId,
            @Valid @RequestBody ContentDto.Request request) {
        return ResponseEntity.ok(contentService.updateContent(lessonId, contentId, request));
    }

    @DeleteMapping("/{contentId}")
    @PreAuthorize("hasAnyRole('TEACHER', 'ADMIN')")
    @Operation(summary = "Delete content")
    public ResponseEntity<Void> deleteContent(@PathVariable UUID lessonId, @PathVariable UUID contentId) {
        contentService.deleteContent(lessonId, contentId);
        return ResponseEntity.noContent().build();
    }
}
