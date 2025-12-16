package com.radim.project.service;

import com.radim.project.dto.QuizAttemptDto;
import com.radim.project.entity.*;
import com.radim.project.repository.*;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class QuizAttemptService {

    private final QuizAttemptRepository quizAttemptRepository;
    private final StudentAnswerRepository studentAnswerRepository;
    private final QuizRepository quizRepository;
    private final QuestionRepository questionRepository;

    /**
     * Student starts a quiz attempt
     */
    @Transactional
    public QuizAttemptDto.AttemptResponse startQuizAttempt(UUID quizId) {
        Long studentId = getCurrentStudentId();

        Quiz quiz = quizRepository.findById(quizId)
                .orElseThrow(() -> new RuntimeException("Quiz not found"));

        QuizAttempt attempt = QuizAttempt.builder()
                .quiz(quiz)
                .studentId(studentId)
                .score(0)
                .maxScore(quiz.getQuestions().size()) // 1 point per question
                .percentage(0.0)
                .passed(false)
                .startedAt(LocalDateTime.now())
                .studentAnswers(new ArrayList<>())
                .build();

        QuizAttempt savedAttempt = quizAttemptRepository.save(attempt);

        return mapToResponseWithoutAnswers(savedAttempt);
    }

    /**
     * Student submits quiz answers
     */
    @Transactional
    public QuizAttemptDto.AttemptResponse submitQuizAttempt(UUID attemptId, QuizAttemptDto.SubmitRequest request) {
        Long studentId = getCurrentStudentId();

        QuizAttempt attempt = quizAttemptRepository.findById(attemptId)
                .orElseThrow(() -> new RuntimeException("Quiz attempt not found"));

        // Verify ownership
        if (!attempt.getStudentId().equals(studentId)) {
            throw new RuntimeException("Not authorized to submit this attempt");
        }

        // Check if already submitted
        if (attempt.getSubmittedAt() != null) {
            throw new RuntimeException("Quiz already submitted");
        }

        // Process each answer
        int correctCount = 0;
        List<StudentAnswer> studentAnswers = new ArrayList<>();

        for (QuizAttemptDto.SubmitRequest.AnswerSubmission submission : request.getAnswers()) {
            Question question = questionRepository.findById(submission.getQuestionId())
                    .orElseThrow(() -> new RuntimeException("Question not found: " + submission.getQuestionId()));

            // Check if the selected option is correct
            boolean isCorrect = question.getOptions().stream()
                    .anyMatch(opt -> opt.getId().equals(submission.getSelectedOptionId()) && opt.getIsCorrect());

            if (isCorrect) {
                correctCount++;
            }

            StudentAnswer answer = StudentAnswer.builder()
                    .quizAttempt(attempt)
                    .question(question)
                    .selectedOptionId(submission.getSelectedOptionId())
                    .isCorrect(isCorrect)
                    .build();

            studentAnswers.add(answer);
        }

        // Save all answers
        studentAnswerRepository.saveAll(studentAnswers);

        // Update attempt with score
        attempt.setScore(correctCount);
        attempt.setSubmittedAt(LocalDateTime.now());
        attempt.calculatePercentage();
        attempt.determinePassed();

        QuizAttempt updatedAttempt = quizAttemptRepository.save(attempt);

        return mapToResponseWithAnswers(updatedAttempt, studentAnswers);
    }

    /**
     * Get student's quiz attempt history
     */
    public List<QuizAttemptDto.AttemptResponse> getStudentAttempts(Long studentId) {
        return quizAttemptRepository.findByStudentId(studentId).stream()
                .map(this::mapToResponseWithoutAnswers)
                .collect(Collectors.toList());
    }

    /**
     * Get all attempts for a specific quiz
     */
    public List<QuizAttemptDto.AttemptResponse> getQuizAttempts(UUID quizId) {
        return quizAttemptRepository.findByQuizId(quizId).stream()
                .map(this::mapToResponseWithoutAnswers)
                .collect(Collectors.toList());
    }

    /**
     * Get detailed attempt with answers
     */
    public QuizAttemptDto.AttemptResponse getAttemptDetails(UUID attemptId) {
        QuizAttempt attempt = quizAttemptRepository.findById(attemptId)
                .orElseThrow(() -> new RuntimeException("Attempt not found"));

        List<StudentAnswer> answers = studentAnswerRepository.findByQuizAttemptId(attemptId);

        return mapToResponseWithAnswers(attempt, answers);
    }

    /**
     * Get student's attempts for a specific quiz
     */
    public List<QuizAttemptDto.AttemptResponse> getStudentQuizAttempts(Long studentId, UUID quizId) {
        return quizAttemptRepository.findByStudentIdAndQuiz_Id(studentId, quizId).stream()
                .map(this::mapToResponseWithoutAnswers)
                .collect(Collectors.toList());
    }

    // Helper methods
    private Long getCurrentStudentId() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        try {
            return Long.parseLong((String) authentication.getPrincipal());
        } catch (Exception e) {
            throw new RuntimeException("Invalid User ID");
        }
    }

    private QuizAttemptDto.AttemptResponse mapToResponseWithoutAnswers(QuizAttempt attempt) {
        return QuizAttemptDto.AttemptResponse.builder()
                .id(attempt.getId())
                .quizId(attempt.getQuiz().getId())
                .quizTitle(attempt.getQuiz().getTitle())
                .studentId(attempt.getStudentId())
                .score(attempt.getScore())
                .maxScore(attempt.getMaxScore())
                .percentage(attempt.getPercentage())
                .passed(attempt.getPassed())
                .startedAt(attempt.getStartedAt())
                .submittedAt(attempt.getSubmittedAt())
                .build();
    }

    private QuizAttemptDto.AttemptResponse mapToResponseWithAnswers(QuizAttempt attempt, List<StudentAnswer> answers) {
        List<QuizAttemptDto.AnswerDetail> answerDetails = answers.stream()
                .map(answer -> {
                    UUID correctOptionId = answer.getQuestion().getOptions().stream()
                            .filter(QuestionOption::getIsCorrect)
                            .map(QuestionOption::getId)
                            .findFirst()
                            .orElse(null);

                    return QuizAttemptDto.AnswerDetail.builder()
                            .questionId(answer.getQuestion().getId())
                            .questionContent(answer.getQuestion().getQuestionText())
                            .selectedOptionId(answer.getSelectedOptionId())
                            .correctOptionId(correctOptionId)
                            .isCorrect(answer.getIsCorrect())
                            .build();
                })
                .collect(Collectors.toList());

        return QuizAttemptDto.AttemptResponse.builder()
                .id(attempt.getId())
                .quizId(attempt.getQuiz().getId())
                .quizTitle(attempt.getQuiz().getTitle())
                .studentId(attempt.getStudentId())
                .score(attempt.getScore())
                .maxScore(attempt.getMaxScore())
                .percentage(attempt.getPercentage())
                .passed(attempt.getPassed())
                .startedAt(attempt.getStartedAt())
                .submittedAt(attempt.getSubmittedAt())
                .answers(answerDetails)
                .build();
    }
}
