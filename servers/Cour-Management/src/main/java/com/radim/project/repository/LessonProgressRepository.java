package com.radim.project.repository;

import com.radim.project.entity.LessonProgress;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface LessonProgressRepository extends JpaRepository<LessonProgress, UUID> {

    Optional<LessonProgress> findByLesson_IdAndStudentId(UUID lessonId, Long studentId);

    List<LessonProgress> findByStudentIdAndLesson_Module_Course_Id(Long studentId, UUID courseId);

    long countByStudentIdAndLesson_Module_Course_IdAndCompletedTrue(Long studentId, UUID courseId);

    @Query("SELECT COUNT(l) FROM Lesson l WHERE l.module.course.id = :courseId")
    long countTotalLessonsByCourseId(@Param("courseId") UUID courseId);
}
