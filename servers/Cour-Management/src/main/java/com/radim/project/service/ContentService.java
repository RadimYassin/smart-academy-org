package com.radim.project.service;

import com.radim.project.dto.ContentDto;
import com.radim.project.entity.Lesson;
import com.radim.project.entity.LessonContent;
import com.radim.project.repository.LessonContentRepository;
import com.radim.project.repository.LessonRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class ContentService {

    private final LessonContentRepository contentRepository;
    private final LessonRepository lessonRepository;

    public List<ContentDto.Response> getContentByLesson(UUID lessonId) {
        return contentRepository.findByLessonIdOrderByOrderIndexAsc(lessonId).stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }

    @Transactional
    public ContentDto.Response createContent(UUID lessonId, ContentDto.Request request) {
        Lesson lesson = lessonRepository.findById(lessonId)
                .orElseThrow(() -> new RuntimeException("Lesson not found"));

        validateOwnership(lesson.getModule().getCourse().getTeacherId());
        validateContent(request);

        LessonContent content = LessonContent.builder()
                .lesson(lesson)
                .type(request.getType())
                .textContent(request.getTextContent())
                .pdfUrl(request.getPdfUrl())
                .videoUrl(request.getVideoUrl())
                .imageUrl(request.getImageUrl())
                .quizId(request.getQuizId())
                .orderIndex(request.getOrderIndex())
                .build();

        LessonContent savedContent = contentRepository.save(content);
        return mapToResponse(savedContent);
    }

    @Transactional
    public ContentDto.Response updateContent(UUID lessonId, UUID contentId, ContentDto.Request request) {
        LessonContent content = contentRepository.findById(contentId)
                .orElseThrow(() -> new RuntimeException("Content not found"));

        if (!content.getLesson().getId().equals(lessonId)) {
            throw new RuntimeException("Content does not belong to the specified lesson");
        }

        validateOwnership(content.getLesson().getModule().getCourse().getTeacherId());
        validateContent(request);

        content.setType(request.getType());
        content.setTextContent(request.getTextContent());
        content.setPdfUrl(request.getPdfUrl());
        content.setVideoUrl(request.getVideoUrl());
        content.setImageUrl(request.getImageUrl());
        content.setQuizId(request.getQuizId());
        content.setOrderIndex(request.getOrderIndex());

        LessonContent updatedContent = contentRepository.save(content);
        return mapToResponse(updatedContent);
    }

    @Transactional
    public void deleteContent(UUID lessonId, UUID contentId) {
        LessonContent content = contentRepository.findById(contentId)
                .orElseThrow(() -> new RuntimeException("Content not found"));

        if (!content.getLesson().getId().equals(lessonId)) {
            throw new RuntimeException("Content does not belong to the specified lesson");
        }

        validateOwnership(content.getLesson().getModule().getCourse().getTeacherId());

        contentRepository.delete(content);
    }

    private void validateContent(ContentDto.Request request) {
        switch (request.getType()) {
            case PDF:
                if (request.getPdfUrl() == null || request.getPdfUrl().isBlank()) {
                    throw new IllegalArgumentException("PDF URL is required for PDF content");
                }
                break;
            case TEXT:
                if (request.getTextContent() == null || request.getTextContent().isBlank()) {
                    throw new IllegalArgumentException("Text content is required for TEXT content");
                }
                break;
            case VIDEO:
                if (request.getVideoUrl() == null || request.getVideoUrl().isBlank()) {
                    throw new IllegalArgumentException("Video URL is required for VIDEO content");
                }
                break;
            case IMAGE:
                if (request.getImageUrl() == null || request.getImageUrl().isBlank()) {
                    throw new IllegalArgumentException("Image URL is required for IMAGE content");
                }
                break;
            case QUIZ:
                if (request.getQuizId() == null) {
                    throw new IllegalArgumentException("Quiz ID is required for QUIZ content");
                }
                break;
        }
    }

    private void validateOwnership(Long teacherId) {
        Long currentUserId = getCurrentUserId();
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        boolean isAdmin = auth.getAuthorities().stream()
                .anyMatch(a -> a.getAuthority().equals("ROLE_ADMIN"));

        if (!isAdmin && !teacherId.equals(currentUserId)) {
            throw new AccessDeniedException("You are not the owner of this course");
        }
    }

    private Long getCurrentUserId() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        try {
            return Long.parseLong((String) authentication.getPrincipal());
        } catch (Exception e) {
            throw new RuntimeException("Invalid User ID");
        }
    }

    private ContentDto.Response mapToResponse(LessonContent content) {
        return ContentDto.Response.builder()
                .id(content.getId())
                .lessonId(content.getLesson().getId())
                .type(content.getType())
                .textContent(content.getTextContent())
                .pdfUrl(content.getPdfUrl())
                .videoUrl(content.getVideoUrl())
                .imageUrl(content.getImageUrl())
                .quizId(content.getQuizId())
                .orderIndex(content.getOrderIndex())
                .createdAt(content.getCreatedAt())
                .updatedAt(content.getUpdatedAt())
                .build();
    }
}
