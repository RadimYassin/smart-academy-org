package com.radim.project.service;

import com.radim.project.dto.ProgressDto;
import com.radim.project.entity.Course;
import com.radim.project.entity.Lesson;
import com.radim.project.entity.LessonProgress;
import com.radim.project.entity.Module;
import com.radim.project.repository.CourseRepository;
import com.radim.project.repository.LessonProgressRepository;
import com.radim.project.repository.LessonRepository;
import com.radim.project.repository.ModuleRepository;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.*;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
public class ProgressService {

    private final LessonProgressRepository lessonProgressRepository;
    private final LessonRepository lessonRepository;
    private final CourseRepository courseRepository;
    private final ModuleRepository moduleRepository;

    @Transactional
    public ProgressDto.LessonProgressResponse markLessonComplete(UUID lessonId, Long studentId) {
        log.info("Marking lesson {} as complete for student {}", lessonId, studentId);

        Lesson lesson = lessonRepository.findById(lessonId)
                .orElseThrow(() -> new RuntimeException("Lesson not found"));

        // Find or create progress record
        LessonProgress progress = lessonProgressRepository
                .findByLesson_IdAndStudentId(lessonId, studentId)
                .orElse(LessonProgress.builder()
                        .lesson(lesson)
                        .studentId(studentId)
                        .build());

        // Mark as completed (idempotent)
        progress.markCompleted();
        LessonProgress saved = lessonProgressRepository.save(progress);

        return toLessonProgressResponse(saved);
    }

    public ProgressDto.LessonProgressResponse getLessonProgress(UUID lessonId, Long studentId) {
        log.info("Fetching progress for lesson {} and student {}", lessonId, studentId);

        Lesson lesson = lessonRepository.findById(lessonId)
                .orElseThrow(() -> new RuntimeException("Lesson not found"));

        LessonProgress progress = lessonProgressRepository
                .findByLesson_IdAndStudentId(lessonId, studentId)
                .orElse(LessonProgress.builder()
                        .lesson(lesson)
                        .studentId(studentId)
                        .completed(false)
                        .build());

        return toLessonProgressResponse(progress);
    }

    public ProgressDto.CourseProgressResponse getCourseProgress(UUID courseId, Long studentId) {
        log.info("Calculating course progress for course {} and student {}", courseId, studentId);

        Course course = courseRepository.findById(courseId)
                .orElseThrow(() -> new RuntimeException("Course not found"));

        long totalLessons = lessonProgressRepository.countTotalLessonsByCourseId(courseId);
        long completedLessons = lessonProgressRepository
                .countByStudentIdAndLesson_Module_Course_IdAndCompletedTrue(studentId, courseId);

        double completionRate = 0.0;
        if (totalLessons > 0) {
            completionRate = (completedLessons * 100.0) / totalLessons;
        }

        return ProgressDto.CourseProgressResponse.builder()
                .courseId(courseId)
                .courseTitle(course.getTitle())
                .totalLessons(totalLessons)
                .completedLessons(completedLessons)
                .completionRate(Math.round(completionRate * 100.0) / 100.0) // Round to 2 decimals
                .build();
    }

    public double calculateCompletionRate(UUID courseId, Long studentId) {
        ProgressDto.CourseProgressResponse progress = getCourseProgress(courseId, studentId);
        return progress.getCompletionRate();
    }

    /**
     * Get all lesson progress for a specific course and student
     * This ensures each lesson has its own LessonProgress record
     * Creates LessonProgress records for lessons that don't have one yet
     */
    @Transactional
    public List<ProgressDto.LessonProgressResponse> getAllLessonProgressForCourse(UUID courseId, Long studentId) {
        log.info("Fetching all lesson progress for course {} and student {}", courseId, studentId);

        Course course = courseRepository.findById(courseId)
                .orElseThrow(() -> new RuntimeException("Course not found"));

        // Load modules for this course
        List<Module> modules = moduleRepository.findByCourseIdOrderByOrderIndexAsc(courseId);
        if (modules == null || modules.isEmpty()) {
            log.info("No modules found for course {}", courseId);
            return new ArrayList<>();
        }

        // Get all lessons from all modules
        List<Lesson> allLessons = new ArrayList<>();
        for (Module module : modules) {
            List<Lesson> moduleLessons = lessonRepository.findByModuleIdOrderByOrderIndexAsc(module.getId());
            if (moduleLessons != null && !moduleLessons.isEmpty()) {
                allLessons.addAll(moduleLessons);
            }
        }

        if (allLessons.isEmpty()) {
            log.info("No lessons found for course {}", courseId);
            return new ArrayList<>();
        }

        // Get all existing progress records for this course and student
        List<LessonProgress> progressList = lessonProgressRepository
                .findByStudentIdAndLesson_Module_Course_Id(studentId, courseId);

        // Create a map of existing progress by lesson ID
        Map<UUID, LessonProgress> progressMap = progressList.stream()
                .collect(Collectors.toMap(
                        p -> p.getLesson().getId(),
                        p -> p
                ));

        // Ensure every lesson has a progress record (create if missing)
        List<ProgressDto.LessonProgressResponse> result = new ArrayList<>();
        for (Lesson lesson : allLessons) {
            LessonProgress progress = progressMap.get(lesson.getId());
            if (progress == null) {
                // Create a new progress record for this lesson if it doesn't exist
                log.debug("Creating new LessonProgress for lesson {} and student {}", lesson.getId(), studentId);
                progress = LessonProgress.builder()
                        .lesson(lesson)
                        .studentId(studentId)
                        .completed(false)
                        .build();
                progress = lessonProgressRepository.save(progress);
            }
            result.add(toLessonProgressResponse(progress));
        }

        log.info("Returning {} lesson progress records for course {} and student {}", 
                result.size(), courseId, studentId);
        return result;
    }

    private ProgressDto.LessonProgressResponse toLessonProgressResponse(LessonProgress progress) {
        return ProgressDto.LessonProgressResponse.builder()
                .lessonId(progress.getLesson().getId())
                .lessonTitle(progress.getLesson().getTitle())
                .completed(progress.getCompleted())
                .completedAt(progress.getCompletedAt())
                .build();
    }
}
