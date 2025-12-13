package com.radim.project.repository;

import com.radim.project.entity.QuizAttempt;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface QuizAttemptRepository extends JpaRepository<QuizAttempt, UUID> {
    List<QuizAttempt> findByStudentId(Long studentId);

    List<QuizAttempt> findByQuizId(UUID quizId);

    List<QuizAttempt> findByStudentIdAndQuizId(Long studentId, UUID quizId);

    Long countByStudentIdAndQuizId(Long studentId, UUID quizId);
}
