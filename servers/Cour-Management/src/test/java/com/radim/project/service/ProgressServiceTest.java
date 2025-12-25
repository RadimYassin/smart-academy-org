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
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class ProgressServiceTest {

    @Mock
    private LessonProgressRepository lessonProgressRepository;
    @Mock
    private LessonRepository lessonRepository;
    @Mock
    private CourseRepository courseRepository;
    @Mock
    private ModuleRepository moduleRepository;

    @InjectMocks
    private ProgressService progressService;

    private UUID lessonId;
    private Long studentId;
    private Lesson lesson;

    @BeforeEach
    void setUp() {
        lessonId = UUID.randomUUID();
        studentId = 1L;
        lesson = Lesson.builder()
                .id(lessonId)
                .title("Intro to Java")
                .build();
    }

    @Test
    void markLessonComplete_ShouldCreateProgress_WhenNotExist() {
        when(lessonRepository.findById(lessonId)).thenReturn(Optional.of(lesson));
        when(lessonProgressRepository.findByLesson_IdAndStudentId(lessonId, studentId)).thenReturn(Optional.empty());
        when(lessonProgressRepository.save(any(LessonProgress.class))).thenAnswer(i -> i.getArgument(0));

        ProgressDto.LessonProgressResponse response = progressService.markLessonComplete(lessonId, studentId);

        assertThat(response.getCompleted()).isTrue();
        verify(lessonProgressRepository).save(any(LessonProgress.class));
    }

    @Test
    void markLessonComplete_ShouldUpdateProgress_WhenExists() {
        LessonProgress progress = LessonProgress.builder()
                .lesson(lesson)
                .studentId(studentId)
                .completed(false)
                .build();

        when(lessonRepository.findById(lessonId)).thenReturn(Optional.of(lesson));
        when(lessonProgressRepository.findByLesson_IdAndStudentId(lessonId, studentId))
                .thenReturn(Optional.of(progress));
        when(lessonProgressRepository.save(any(LessonProgress.class))).thenReturn(progress);

        ProgressDto.LessonProgressResponse response = progressService.markLessonComplete(lessonId, studentId);

        assertThat(response.getCompleted()).isTrue();
    }

    @Test
    void getCourseProgress_ShouldCalculateCorrectly() {
        UUID courseId = UUID.randomUUID();
        Course course = Course.builder().id(courseId).title("Java Course").build();

        when(courseRepository.findById(courseId)).thenReturn(Optional.of(course));
        when(lessonProgressRepository.countTotalLessonsByCourseId(courseId)).thenReturn(10L);
        when(lessonProgressRepository.countByStudentIdAndLesson_Module_Course_IdAndCompletedTrue(studentId, courseId))
                .thenReturn(7L);

        ProgressDto.CourseProgressResponse response = progressService.getCourseProgress(courseId, studentId);

        assertThat(response.getCompletionRate()).isEqualTo(70.0);
        assertThat(response.getCompletedLessons()).isEqualTo(7L);
    }

    @Test
    void getAllLessonProgressForCourse_ShouldSyncMissingProgress() {
        UUID courseId = UUID.randomUUID();
        Course course = Course.builder().id(courseId).build();
        UUID moduleId = UUID.randomUUID();
        Module module = Module.builder().id(moduleId).build();

        when(courseRepository.findById(courseId)).thenReturn(Optional.of(course));
        when(moduleRepository.findByCourseIdOrderByOrderIndexAsc(courseId)).thenReturn(List.of(module));
        when(lessonRepository.findByModuleIdOrderByOrderIndexAsc(moduleId)).thenReturn(List.of(lesson));
        when(lessonProgressRepository.findByStudentIdAndCourseIdWithLesson(studentId, courseId)).thenReturn(List.of());
        when(lessonProgressRepository.save(any(LessonProgress.class))).thenAnswer(i -> i.getArgument(0));

        List<ProgressDto.LessonProgressResponse> responses = progressService.getAllLessonProgressForCourse(courseId,
                studentId);

        assertThat(responses).hasSize(1);
        assertThat(responses.get(0).getLessonId()).isEqualTo(lessonId);
        verify(lessonProgressRepository).save(any(LessonProgress.class));
    }
}
