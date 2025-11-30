package com.radim.project.repository;

import com.radim.project.entity.LessonContent;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface LessonContentRepository extends JpaRepository<LessonContent, UUID> {
    List<LessonContent> findByLessonIdOrderByOrderIndexAsc(UUID lessonId);
}
