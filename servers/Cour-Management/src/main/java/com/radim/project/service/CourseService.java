package com.radim.project.service;

import com.radim.project.dto.CourseDto;
import com.radim.project.entity.Course;
import com.radim.project.repository.CourseRepository;
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
public class CourseService {

    private final CourseRepository courseRepository;

    public List<CourseDto.Response> getAllCourses() {
        return courseRepository.findAll().stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }

    public CourseDto.Response getCourseById(UUID courseId) {
        Course course = courseRepository.findById(courseId)
                .orElseThrow(() -> new RuntimeException("Course not found"));
        return mapToResponse(course);
    }

    public List<CourseDto.Response> getCoursesByTeacherId(Long teacherId) {
        return courseRepository.findByTeacherId(teacherId).stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }

    @Transactional
    public CourseDto.Response createCourse(CourseDto.Request request) {
        Long teacherId = getCurrentUserId();

        Course course = Course.builder()
                .title(request.getTitle())
                .description(request.getDescription())
                .category(request.getCategory())
                .level(request.getLevel())
                .thumbnailUrl(request.getThumbnailUrl())
                .teacherId(teacherId)
                .build();

        Course savedCourse = courseRepository.save(course);
        return mapToResponse(savedCourse);
    }

    @Transactional
    public CourseDto.Response updateCourse(UUID courseId, CourseDto.Request request) {
        Course course = courseRepository.findById(courseId)
                .orElseThrow(() -> new RuntimeException("Course not found"));

        validateOwnership(course);

        course.setTitle(request.getTitle());
        course.setDescription(request.getDescription());
        course.setCategory(request.getCategory());
        course.setLevel(request.getLevel());
        course.setThumbnailUrl(request.getThumbnailUrl());

        Course updatedCourse = courseRepository.save(course);
        return mapToResponse(updatedCourse);
    }

    @Transactional
    public void deleteCourse(UUID courseId) {
        Course course = courseRepository.findById(courseId)
                .orElseThrow(() -> new RuntimeException("Course not found"));

        validateOwnership(course);

        courseRepository.delete(course);
    }

    private void validateOwnership(Course course) {
        Long currentUserId = getCurrentUserId();
        // Allow ADMIN to bypass ownership check if needed, but requirements say
        // "Teacher... can Create/Update/Delete courses they own"
        // Assuming ADMIN can do everything, but let's stick to strict ownership for
        // TEACHER.
        // If user is ADMIN, maybe allow? Let's check roles.
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        boolean isAdmin = auth.getAuthorities().stream()
                .anyMatch(a -> a.getAuthority().equals("ROLE_ADMIN"));

        if (!isAdmin && !course.getTeacherId().equals(currentUserId)) {
            throw new AccessDeniedException("You are not the owner of this course");
        }
    }

    private Long getCurrentUserId() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication == null || !authentication.isAuthenticated()) {
            throw new RuntimeException("User not authenticated");
        }
        // In JwtAuthenticationFilter we set principal as userId (String) or userEmail.
        // We should try to parse it as Long.
        try {
            return Long.parseLong((String) authentication.getPrincipal());
        } catch (NumberFormatException e) {
            // Fallback or error if subject is not Long.
            throw new RuntimeException("Invalid User ID in token");
        }
    }

    private CourseDto.Response mapToResponse(Course course) {
        return CourseDto.Response.builder()
                .id(course.getId())
                .title(course.getTitle())
                .description(course.getDescription())
                .category(course.getCategory())
                .level(course.getLevel())
                .thumbnailUrl(course.getThumbnailUrl())
                .teacherId(course.getTeacherId())
                .createdAt(course.getCreatedAt())
                .updatedAt(course.getUpdatedAt())
                .build();
    }
}
