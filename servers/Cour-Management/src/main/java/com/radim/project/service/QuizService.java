package com.radim.project.service;

import com.radim.project.dto.QuizDto;
import com.radim.project.entity.Course;
import com.radim.project.entity.Quiz;
import com.radim.project.repository.CourseRepository;
import com.radim.project.repository.QuizRepository;
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
public class QuizService {

    private final QuizRepository quizRepository;
    private final CourseRepository courseRepository;

    public List<QuizDto.Response> getQuizzesByCourse(UUID courseId) {
        return quizRepository.findByCourseId(courseId).stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }

    public QuizDto.Response getQuizById(UUID quizId) {
        Quiz quiz = quizRepository.findById(quizId)
                .orElseThrow(() -> new RuntimeException("Quiz not found"));
        return mapToResponse(quiz);
    }

    @Transactional
    public QuizDto.Response createQuiz(UUID courseId, QuizDto.Request request) {
        Course course = courseRepository.findById(courseId)
                .orElseThrow(() -> new RuntimeException("Course not found"));

        validateOwnership(course.getTeacherId());

        Quiz quiz = Quiz.builder()
                .course(course)
                .title(request.getTitle())
                .description(request.getDescription())
                .difficulty(request.getDifficulty())
                .build();

        Quiz savedQuiz = quizRepository.save(quiz);
        return mapToResponse(savedQuiz);
    }

    @Transactional
    public QuizDto.Response updateQuiz(UUID courseId, UUID quizId, QuizDto.Request request) {
        Quiz quiz = quizRepository.findById(quizId)
                .orElseThrow(() -> new RuntimeException("Quiz not found"));

        if (!quiz.getCourse().getId().equals(courseId)) {
            throw new RuntimeException("Quiz does not belong to the specified course");
        }

        validateOwnership(quiz.getCourse().getTeacherId());

        quiz.setTitle(request.getTitle());
        quiz.setDescription(request.getDescription());
        quiz.setDifficulty(request.getDifficulty());

        Quiz updatedQuiz = quizRepository.save(quiz);
        return mapToResponse(updatedQuiz);
    }

    @Transactional
    public void deleteQuiz(UUID courseId, UUID quizId) {
        Quiz quiz = quizRepository.findById(quizId)
                .orElseThrow(() -> new RuntimeException("Quiz not found"));

        if (!quiz.getCourse().getId().equals(courseId)) {
            throw new RuntimeException("Quiz does not belong to the specified course");
        }

        validateOwnership(quiz.getCourse().getTeacherId());

        quizRepository.delete(quiz);
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

    private QuizDto.Response mapToResponse(Quiz quiz) {
        return QuizDto.Response.builder()
                .id(quiz.getId())
                .courseId(quiz.getCourse().getId())
                .title(quiz.getTitle())
                .description(quiz.getDescription())
                .difficulty(quiz.getDifficulty())
                .createdAt(quiz.getCreatedAt())
                .updatedAt(quiz.getUpdatedAt())
                .build();
    }
}
