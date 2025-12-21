package com.radim.project.repository;

import com.radim.project.entity.*;
import com.radim.project.entity.enums.CourseLevel;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.orm.jpa.DataJpaTest;
import org.springframework.boot.test.autoconfigure.orm.jpa.TestEntityManager;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;

@DataJpaTest
@DisplayName("CertificateRepository Integration Tests")
class CertificateRepositoryTest {

    @Autowired
    private CertificateRepository certificateRepository;

    @Autowired
    private TestEntityManager entityManager;

    private Course testCourse;
    private Certificate certificate1;
    private final Long studentId1 = 100L;

    @BeforeEach
    void setUp() {
        testCourse = Course.builder()
                .title("Java Certification Course")
                .description("Professional Java")
                .category("Programming")
                .level(CourseLevel.ADVANCED)
                .teacherId(1L)
                .build();
        testCourse = entityManager.persistAndFlush(testCourse);

        certificate1 = Certificate.builder()
                .course(testCourse)
                .studentId(studentId1)
                .verificationCode("CERT-2024-001")
                .completionRate(95.5)
                .issuedAt(LocalDateTime.now())
                .build();
    }

    @Test
    @DisplayName("Should save certificate successfully")
    void save_Success() {
        // When
        Certificate saved = certificateRepository.save(certificate1);

        // Then
        assertThat(saved.getId()).isNotNull();
        assertThat(saved.getVerificationCode()).isEqualTo("CERT-2024-001");
        assertThat(saved.getStudentId()).isEqualTo(studentId1);
    }

    @Test
    @DisplayName("Should find certificate by ID")
    void findById_Success() {
        // Given
        Certificate saved = entityManager.persistAndFlush(certificate1);

        // When
        Optional<Certificate> found = certificateRepository.findById(saved.getId());

        // Then
        assertThat(found).isPresent();
        assertThat(found.get().getVerificationCode()).isEqualTo("CERT-2024-001");
    }

    @Test
    @DisplayName("Should find certificates by student ID")
    void findByStudentId_Success() {
        // Given
        entityManager.persistAndFlush(certificate1);

        // When
        List<Certificate> certificates = certificateRepository.findByStudentId(studentId1);

        // Then
        assertThat(certificates).hasSize(1);
        assertThat(certificates.get(0).getStudentId()).isEqualTo(studentId1);
    }

    @Test
    @DisplayName("Should find certificate by verification code")
    void findByVerificationCode_Success() {
        // Given
        entityManager.persistAndFlush(certificate1);

        // When
        Optional<Certificate> found = certificateRepository.findByVerificationCode("CERT-2024-001");

        // Then
        assertThat(found).isPresent();
        assertThat(found.get().getStudentId()).isEqualTo(studentId1);
    }
}
