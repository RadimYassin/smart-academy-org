package com.radim.project.repository;

import com.radim.project.entity.StudentAnswer;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface StudentAnswerRepository extends JpaRepository<StudentAnswer, UUID> {
    List<StudentAnswer> findByQuizAttemptId(UUID quizAttemptId);
}
