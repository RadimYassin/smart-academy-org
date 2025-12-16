package com.radim.project.repository;

import com.radim.project.entity.StudentClass;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface StudentClassRepository extends JpaRepository<StudentClass, UUID> {

    List<StudentClass> findByTeacherId(Long teacherId);

    boolean existsByIdAndTeacherId(UUID id, Long teacherId);
}
