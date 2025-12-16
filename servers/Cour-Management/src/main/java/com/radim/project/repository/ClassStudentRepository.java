package com.radim.project.repository;

import com.radim.project.entity.ClassStudent;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface ClassStudentRepository extends JpaRepository<ClassStudent, UUID> {

    List<ClassStudent> findByStudentClassId(UUID classId);

    boolean existsByStudentClassIdAndStudentId(UUID classId, Long studentId);

    void deleteByStudentClassIdAndStudentId(UUID classId, Long studentId);
}
