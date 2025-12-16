package com.radim.project.repository;

import com.radim.project.entity.Certificate;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface CertificateRepository extends JpaRepository<Certificate, UUID> {

    Optional<Certificate> findByCourse_IdAndStudentId(UUID courseId, Long studentId);

    Optional<Certificate> findByVerificationCode(String verificationCode);

    List<Certificate> findByStudentId(Long studentId);

    boolean existsByCourse_IdAndStudentId(UUID courseId, Long studentId);
}
