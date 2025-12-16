package com.radim.project.repository;

import com.radim.project.entity.Quiz;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface QuizRepository extends JpaRepository<Quiz, UUID> {

    List<Quiz> findByCourseId(UUID courseId);

    List<Quiz> findByCourse_Id(UUID courseId);

    List<Quiz> findByCourse_IdAndMandatoryTrue(UUID courseId);
}
