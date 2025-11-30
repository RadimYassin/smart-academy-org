package com.radim.project.service;

import com.radim.project.dto.LessonDto;
import com.radim.project.entity.Lesson;
import com.radim.project.entity.Module;
import com.radim.project.repository.LessonRepository;
import com.radim.project.repository.ModuleRepository;
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
public class LessonService {

    private final LessonRepository lessonRepository;
    private final ModuleRepository moduleRepository;

    public List<LessonDto.Response> getLessonsByModule(UUID moduleId) {
        return lessonRepository.findByModuleIdOrderByOrderIndexAsc(moduleId).stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }

    public LessonDto.Response getLessonById(UUID lessonId) {
        Lesson lesson = lessonRepository.findById(lessonId)
                .orElseThrow(() -> new RuntimeException("Lesson not found"));
        return mapToResponse(lesson);
    }

    @Transactional
    public LessonDto.Response createLesson(UUID moduleId, LessonDto.Request request) {
        Module module = moduleRepository.findById(moduleId)
                .orElseThrow(() -> new RuntimeException("Module not found"));

        validateOwnership(module.getCourse().getTeacherId());

        Lesson lesson = Lesson.builder()
                .module(module)
                .title(request.getTitle())
                .summary(request.getSummary())
                .orderIndex(request.getOrderIndex())
                .build();

        Lesson savedLesson = lessonRepository.save(lesson);
        return mapToResponse(savedLesson);
    }

    @Transactional
    public LessonDto.Response updateLesson(UUID moduleId, UUID lessonId, LessonDto.Request request) {
        Lesson lesson = lessonRepository.findById(lessonId)
                .orElseThrow(() -> new RuntimeException("Lesson not found"));

        if (!lesson.getModule().getId().equals(moduleId)) {
            throw new RuntimeException("Lesson does not belong to the specified module");
        }

        validateOwnership(lesson.getModule().getCourse().getTeacherId());

        lesson.setTitle(request.getTitle());
        lesson.setSummary(request.getSummary());
        lesson.setOrderIndex(request.getOrderIndex());

        Lesson updatedLesson = lessonRepository.save(lesson);
        return mapToResponse(updatedLesson);
    }

    @Transactional
    public void deleteLesson(UUID moduleId, UUID lessonId) {
        Lesson lesson = lessonRepository.findById(lessonId)
                .orElseThrow(() -> new RuntimeException("Lesson not found"));

        if (!lesson.getModule().getId().equals(moduleId)) {
            throw new RuntimeException("Lesson does not belong to the specified module");
        }

        validateOwnership(lesson.getModule().getCourse().getTeacherId());

        lessonRepository.delete(lesson);
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

    private LessonDto.Response mapToResponse(Lesson lesson) {
        return LessonDto.Response.builder()
                .id(lesson.getId())
                .moduleId(lesson.getModule().getId())
                .title(lesson.getTitle())
                .summary(lesson.getSummary())
                .orderIndex(lesson.getOrderIndex())
                .createdAt(lesson.getCreatedAt())
                .updatedAt(lesson.getUpdatedAt())
                .build();
    }
}
