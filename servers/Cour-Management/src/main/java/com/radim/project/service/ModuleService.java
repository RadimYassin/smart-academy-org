package com.radim.project.service;

import com.radim.project.dto.ModuleDto;
import com.radim.project.entity.Course;
import com.radim.project.entity.Module;
import com.radim.project.repository.CourseRepository;
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
public class ModuleService {

    private final ModuleRepository moduleRepository;
    private final CourseRepository courseRepository;

    public List<ModuleDto.Response> getModulesByCourse(UUID courseId) {
        return moduleRepository.findByCourseIdOrderByOrderIndexAsc(courseId).stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }

    @Transactional
    public ModuleDto.Response createModule(UUID courseId, ModuleDto.Request request) {
        Course course = courseRepository.findById(courseId)
                .orElseThrow(() -> new RuntimeException("Course not found"));

        validateOwnership(course);

        Module module = Module.builder()
                .course(course)
                .title(request.getTitle())
                .description(request.getDescription())
                .orderIndex(request.getOrderIndex())

                .build();

        Module savedModule = moduleRepository.save(module);
        return mapToResponse(savedModule);
    }

    @Transactional
    public ModuleDto.Response updateModule(UUID courseId, UUID moduleId, ModuleDto.Request request) {
        Module module = moduleRepository.findById(moduleId)
                .orElseThrow(() -> new RuntimeException("Module not found"));

        if (!module.getCourse().getId().equals(courseId)) {
            throw new RuntimeException("Module does not belong to the specified course");
        }

        validateOwnership(module.getCourse());

        module.setTitle(request.getTitle());
        module.setDescription(request.getDescription());
        module.setOrderIndex(request.getOrderIndex());

        Module updatedModule = moduleRepository.save(module);
        return mapToResponse(updatedModule);
    }

    @Transactional
    public void deleteModule(UUID courseId, UUID moduleId) {
        Module module = moduleRepository.findById(moduleId)
                .orElseThrow(() -> new RuntimeException("Module not found"));

        if (!module.getCourse().getId().equals(courseId)) {
            throw new RuntimeException("Module does not belong to the specified course");
        }

        validateOwnership(module.getCourse());

        moduleRepository.delete(module);
    }

    private void validateOwnership(Course course) {
        Long currentUserId = getCurrentUserId();
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        boolean isAdmin = auth.getAuthorities().stream()
                .anyMatch(a -> a.getAuthority().equals("ROLE_ADMIN"));

        if (!isAdmin && !course.getTeacherId().equals(currentUserId)) {
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

    private ModuleDto.Response mapToResponse(Module module) {
        return ModuleDto.Response.builder()
                .id(module.getId())
                .courseId(module.getCourse().getId())
                .title(module.getTitle())
                .description(module.getDescription())
                .orderIndex(module.getOrderIndex())
                .createdAt(module.getCreatedAt())
                .updatedAt(module.getUpdatedAt())
                .build();
    }
}
