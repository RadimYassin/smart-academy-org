package com.radim.project.service;

import com.radim.project.dto.ProgressDto;
import com.radim.project.entity.Course;
import com.radim.project.entity.Lesson;
import com.radim.project.entity.LessonProgress;
import com.radim.project.repository.CourseRepository;
import com.radim.project.repository.LessonProgressRepository;
import com.radim.project.repository.LessonRepository;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.UUID;

@Service
@RequiredArgsConstructor
@Slf4j
public class ProgressService {

    private final LessonProgressRepository lessonProgressRepository;
    private final LessonRepository lessonRepository;
    private final CourseRepository courseRepository;

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

    private ProgressDto.LessonProgressResponse toLessonProgressResponse(LessonProgress progress) {
        return ProgressDto.LessonProgressResponse.builder()
                .lessonId(progress.getLesson().getId())
                .lessonTitle(progress.getLesson().getTitle())
                .completed(progress.getCompleted())
                .completedAt(progress.getCompletedAt())
                .build();
    }
}
