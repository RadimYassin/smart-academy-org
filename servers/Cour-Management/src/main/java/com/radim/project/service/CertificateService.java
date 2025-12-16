package com.radim.project.service;

import com.radim.project.dto.CertificateDto;
import com.radim.project.entity.Certificate;
import com.radim.project.entity.Course;
import com.radim.project.entity.Quiz;
import com.radim.project.entity.QuizAttempt;
import com.radim.project.repository.*;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
public class CertificateService {

    private final CertificateRepository certificateRepository;
    private final CourseRepository courseRepository;
    private final QuizRepository quizRepository;
    private final QuizAttemptRepository quizAttemptRepository;
    private final ProgressService progressService;
    private final PdfGenerationService pdfGenerationService;

    @Value("${certificate.completion-threshold:80.0}")
    private Double completionThreshold;

    @Value("${certificate.storage-path:uploads/certificates}")
    private String certificateStoragePath;

    public CertificateDto.CertificateEligibilityResponse checkEligibility(UUID courseId, Long studentId) {
        log.info("Checking certificate eligibility for student {} in course {}", studentId, courseId);

        Course course = courseRepository.findById(courseId)
                .orElseThrow(() -> new RuntimeException("Course not found"));

        // 1. Check completion rate
        double completionRate = progressService.calculateCompletionRate(courseId, studentId);
        boolean completionRequirementMet = completionRate >= completionThreshold;

        // 2. Check mandatory quizzes
        List<Quiz> mandatoryQuizzes = quizRepository.findByCourse_IdAndMandatoryTrue(courseId);
        List<String> missingRequirements = new ArrayList<>();
        boolean allMandatoryQuizzesPassed = true;

        for (Quiz quiz : mandatoryQuizzes) {
            // Get student's best attempt for this quiz
            List<QuizAttempt> attempts = quizAttemptRepository
                    .findByQuiz_IdAndStudentIdOrderByPercentageDesc(quiz.getId(), studentId);

            if (attempts.isEmpty()) {
                missingRequirements.add("Quiz not attempted: " + quiz.getTitle());
                allMandatoryQuizzesPassed = false;
                continue;
            }

            QuizAttempt bestAttempt = attempts.get(0);
            if (bestAttempt.getPercentage() < quiz.getPassingScore()) {
                missingRequirements.add(String.format("Quiz '%s' not passed (score: %.1f%%, required: %d%%)",
                        quiz.getTitle(), bestAttempt.getPercentage(), quiz.getPassingScore()));
                allMandatoryQuizzesPassed = false;
            }
        }

        if (!completionRequirementMet) {
            missingRequirements.add(String.format("Course completion %.1f%% (required: %.1f%%)",
                    completionRate, completionThreshold));
        }

        boolean eligible = completionRequirementMet && allMandatoryQuizzesPassed;

        return CertificateDto.CertificateEligibilityResponse.builder()
                .eligible(eligible)
                .completionRate(completionRate)
                .completionRequirementMet(completionRequirementMet)
                .mandatoryQuizzesPassed(allMandatoryQuizzesPassed)
                .missingRequirements(missingRequirements)
                .build();
    }

    @Transactional
    public CertificateDto.CertificateResponse generateCertificate(UUID courseId, Long studentId) {
        log.info("Generating certificate for student {} in course {}", studentId, courseId);

        // Check if certificate already exists (idempotency)
        var existingCert = certificateRepository.findByCourse_IdAndStudentId(courseId, studentId);
        if (existingCert.isPresent()) {
            log.info("Certificate already exists for student {} in course {}", studentId, courseId);
            return toCertificateResponse(existingCert.get());
        }

        // Check eligibility
        CertificateDto.CertificateEligibilityResponse eligibility = checkEligibility(courseId, studentId);
        if (!eligibility.getEligible()) {
            throw new RuntimeException("Student not eligible for certificate: " +
                    String.join(", ", eligibility.getMissingRequirements()));
        }

        Course course = courseRepository.findById(courseId)
                .orElseThrow(() -> new RuntimeException("Course not found"));

        // Generate verification code (8 characters, alphanumeric)
        String verificationCode = generateVerificationCode();

        // Create certificate entity
        Certificate certificate = Certificate.builder()
                .course(course)
                .studentId(studentId)
                .verificationCode(verificationCode)
                .completionRate(eligibility.getCompletionRate())
                .issuedAt(LocalDateTime.now())
                .build();

        Certificate saved = certificateRepository.save(certificate);

        // Generate PDF asynchronously (or synchronously if needed)
        try {
            String pdfPath = pdfGenerationService.generateCertificatePdf(saved, course);
            saved.setPdfUrl(pdfPath);
            certificateRepository.save(saved);
        } catch (Exception e) {
            log.error("Failed to generate PDF for certificate {}", saved.getId(), e);
            // Continue - certificate is created, PDF can be regenerated later
        }

        return toCertificateResponse(saved);
    }

    public CertificateDto.CertificateResponse getCertificate(UUID certificateId) {
        Certificate certificate = certificateRepository.findById(certificateId)
                .orElseThrow(() -> new RuntimeException("Certificate not found"));
        return toCertificateResponse(certificate);
    }

    public byte[] downloadCertificate(UUID certificateId) {
        Certificate certificate = certificateRepository.findById(certificateId)
                .orElseThrow(() -> new RuntimeException("Certificate not found"));

        if (certificate.getPdfUrl() == null) {
            throw new RuntimeException("Certificate PDF not yet generated");
        }

        return pdfGenerationService.loadCertificatePdf(certificate.getPdfUrl());
    }

    public CertificateDto.CertificateVerificationResponse verifyCertificate(String verificationCode) {
        log.info("Verifying certificate with code: {}", verificationCode);

        var certificateOpt = certificateRepository.findByVerificationCode(verificationCode);

        if (certificateOpt.isEmpty()) {
            return CertificateDto.CertificateVerificationResponse.builder()
                    .valid(false)
                    .build();
        }

        Certificate certificate = certificateOpt.get();
        return CertificateDto.CertificateVerificationResponse.builder()
                .certificateId(certificate.getId())
                .courseId(certificate.getCourse().getId())
                .courseTitle(certificate.getCourse().getTitle())
                .studentId(certificate.getStudentId())
                .completionRate(certificate.getCompletionRate())
                .issuedAt(certificate.getIssuedAt())
                .valid(true)
                .build();
    }

    public List<CertificateDto.CertificateResponse> getStudentCertificates(Long studentId) {
        return certificateRepository.findByStudentId(studentId)
                .stream()
                .map(this::toCertificateResponse)
                .collect(Collectors.toList());
    }

    private CertificateDto.CertificateResponse toCertificateResponse(Certificate certificate) {
        return CertificateDto.CertificateResponse.builder()
                .id(certificate.getId())
                .courseId(certificate.getCourse().getId())
                .courseTitle(certificate.getCourse().getTitle())
                .studentId(certificate.getStudentId())
                .verificationCode(certificate.getVerificationCode())
                .completionRate(certificate.getCompletionRate())
                .issuedAt(certificate.getIssuedAt())
                .downloadUrl(certificate.getPdfUrl() != null ? "/api/certificates/" + certificate.getId() + "/download"
                        : null)
                .build();
    }

    private String generateVerificationCode() {
        return UUID.randomUUID().toString().replace("-", "").substring(0, 8).toUpperCase();
    }
}
