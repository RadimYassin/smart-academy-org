package com.radim.project.service;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.radim.project.dto.QuizDto;
import com.radim.project.entity.Question;
import com.radim.project.entity.Quiz;
import com.radim.project.repository.QuestionRepository;
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
public class QuestionService {

    private final QuestionRepository questionRepository;
    private final QuizRepository quizRepository;
    private final ObjectMapper objectMapper;

    public List<QuizDto.QuestionResponse> getQuestionsByQuiz(UUID quizId) {
        return questionRepository.findByQuizId(quizId).stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }

    @Transactional
    public QuizDto.QuestionResponse createQuestion(UUID quizId, QuizDto.QuestionRequest request) {
        Quiz quiz = quizRepository.findById(quizId)
                .orElseThrow(() -> new RuntimeException("Quiz not found"));

        validateOwnership(quiz.getCourse().getTeacherId());

        Question question = Question.builder()
                .quiz(quiz)
                .content(request.getContent())
                .correctOptionIndex(request.getCorrectOptionIndex())
                .build();

        question.setOptionsList(request.getOptions());

        Question savedQuestion = questionRepository.save(question);
        return mapToResponse(savedQuestion);
    }

    @Transactional
    public QuizDto.QuestionResponse updateQuestion(UUID quizId, UUID questionId, QuizDto.QuestionRequest request) {
        Question question = questionRepository.findById(questionId)
                .orElseThrow(() -> new RuntimeException("Question not found"));

        if (!question.getQuiz().getId().equals(quizId)) {
            throw new RuntimeException("Question does not belong to the specified quiz");
        }

        validateOwnership(question.getQuiz().getCourse().getTeacherId());

        question.setContent(request.getContent());
        question.setCorrectOptionIndex(request.getCorrectOptionIndex());
        question.setOptionsList(request.getOptions());

        Question updatedQuestion = questionRepository.save(question);
        return mapToResponse(updatedQuestion);
    }

    @Transactional
    public void deleteQuestion(UUID quizId, UUID questionId) {
        Question question = questionRepository.findById(questionId)
                .orElseThrow(() -> new RuntimeException("Question not found"));

        if (!question.getQuiz().getId().equals(quizId)) {
            throw new RuntimeException("Question does not belong to the specified quiz");
        }

        validateOwnership(question.getQuiz().getCourse().getTeacherId());

        questionRepository.delete(question);
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

    private QuizDto.QuestionResponse mapToResponse(Question question) {
        return QuizDto.QuestionResponse.builder()
                .id(question.getId())
                .quizId(question.getQuiz().getId())
                .content(question.getContent())
                .options(question.getOptionsList())
                .correctOptionIndex(question.getCorrectOptionIndex())
                .build();
    }
}
