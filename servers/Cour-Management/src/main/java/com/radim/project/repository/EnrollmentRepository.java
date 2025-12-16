package com.radim.project.repository;

import com.radim.project.entity.Enrollment;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface EnrollmentRepository extends JpaRepository<Enrollment, UUID> {

    boolean existsByCourse_IdAndStudentId(UUID courseId, Long studentId);

    List<Enrollment> findByStudentId(Long studentId);

    List<Enrollment> findByCourse_Id(UUID courseId);

    List<Enrollment> findByStudentClass_Id(UUID classId);

    Optional<Enrollment> findByCourse_IdAndStudentId(UUID courseId, Long studentId);

}
