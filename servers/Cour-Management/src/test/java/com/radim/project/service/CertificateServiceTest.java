package com.radim.project.service;

import com.radim.project.dto.CertificateDto;
import com.radim.project.entity.Certificate;
import com.radim.project.entity.Course;
import com.radim.project.entity.Quiz;
import com.radim.project.entity.QuizAttempt;
import com.radim.project.repository.CertificateRepository;
import com.radim.project.repository.CourseRepository;
import com.radim.project.repository.QuizAttemptRepository;
import com.radim.project.repository.QuizRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.test.util.ReflectionTestUtils;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class CertificateServiceTest {

    @Mock
    private CertificateRepository certificateRepository;
    @Mock
    private CourseRepository courseRepository;
    @Mock
    private QuizRepository quizRepository;
    @Mock
    private QuizAttemptRepository quizAttemptRepository;
    @Mock
    private ProgressService progressService;
    @Mock
    private PdfGenerationService pdfGenerationService;

    @InjectMocks
    private CertificateService certificateService;

    private UUID courseId;
    private Long studentId;
    private Course course;

    @BeforeEach
    void setUp() {
        courseId = UUID.randomUUID();
        studentId = 1L;
        course = Course.builder()
                .id(courseId)
                .title("Certified Java Developer")
                .build();

        ReflectionTestUtils.setField(certificateService, "completionThreshold", 80.0);
    }

    @Test
    void checkEligibility_ShouldBeEligible() {
        when(courseRepository.findById(courseId)).thenReturn(Optional.of(course));
        when(progressService.calculateCompletionRate(courseId, studentId)).thenReturn(85.0);
        when(quizRepository.findByCourse_IdAndMandatoryTrue(courseId)).thenReturn(List.of());

        CertificateDto.CertificateEligibilityResponse response = certificateService.checkEligibility(courseId,
                studentId);

        assertThat(response.getEligible()).isTrue();
        assertThat(response.getCompletionRequirementMet()).isTrue();
    }

    @Test
    void checkEligibility_ShouldNotBeEligible_WhenCompletionLow() {
        when(courseRepository.findById(courseId)).thenReturn(Optional.of(course));
        when(progressService.calculateCompletionRate(courseId, studentId)).thenReturn(75.0);
        when(quizRepository.findByCourse_IdAndMandatoryTrue(courseId)).thenReturn(List.of());

        CertificateDto.CertificateEligibilityResponse response = certificateService.checkEligibility(courseId,
                studentId);

        assertThat(response.getEligible()).isFalse();
        assertThat(response.getMissingRequirements()).contains("Course completion 75.0% (required: 80.0%)");
    }

    @Test
    void checkEligibility_ShouldNotBeEligible_WhenMandatoryQuizFailed() {
        Quiz quiz = Quiz.builder().id(UUID.randomUUID()).title("Final Project").passingScore(80).build();
        QuizAttempt attempt = QuizAttempt.builder().percentage(70.0).build();

        when(courseRepository.findById(courseId)).thenReturn(Optional.of(course));
        when(progressService.calculateCompletionRate(courseId, studentId)).thenReturn(100.0);
        when(quizRepository.findByCourse_IdAndMandatoryTrue(courseId)).thenReturn(List.of(quiz));
        when(quizAttemptRepository.findByQuiz_IdAndStudentIdOrderByPercentageDesc(any(), eq(studentId)))
                .thenReturn(List.of(attempt));

        CertificateDto.CertificateEligibilityResponse response = certificateService.checkEligibility(courseId,
                studentId);

        assertThat(response.getEligible()).isFalse();
        assertThat(response.getMissingRequirements())
                .anyMatch(r -> r.contains("Final Project") && r.contains("not passed"));
    }

    @Test
    void generateCertificate_ShouldSuccess() throws Exception {
        when(certificateRepository.findByCourse_IdAndStudentId(courseId, studentId)).thenReturn(Optional.empty());
        when(courseRepository.findById(courseId)).thenReturn(Optional.of(course));
        when(progressService.calculateCompletionRate(courseId, studentId)).thenReturn(90.0);
        when(quizRepository.findByCourse_IdAndMandatoryTrue(courseId)).thenReturn(List.of());

        Certificate certificate = Certificate.builder()
                .id(UUID.randomUUID())
                .course(course)
                .studentId(studentId)
                .verificationCode("ABC12345")
                .build();

        when(certificateRepository.save(any(Certificate.class))).thenReturn(certificate);
        when(pdfGenerationService.generateCertificatePdf(any(), any())).thenReturn("uploads/cert.pdf");

        CertificateDto.CertificateResponse response = certificateService.generateCertificate(courseId, studentId);

        assertThat(response).isNotNull();
        verify(certificateRepository, times(2)).save(any());
        verify(pdfGenerationService).generateCertificatePdf(any(), any());
    }

    @Test
    void verifyCertificate_ShouldReturnValid() {
        String code = "VERIFY_ME";
        Certificate certificate = Certificate.builder()
                .id(UUID.randomUUID())
                .course(course)
                .studentId(studentId)
                .verificationCode(code)
                .issuedAt(LocalDateTime.now())
                .build();

        when(certificateRepository.findByVerificationCode(code)).thenReturn(Optional.of(certificate));

        CertificateDto.CertificateVerificationResponse response = certificateService.verifyCertificate(code);

        assertThat(response.getValid()).isTrue();
        assertThat(response.getStudentId()).isEqualTo(studentId);
    }

    @Test
    void verifyCertificate_ShouldReturnInvalid() {
        when(certificateRepository.findByVerificationCode("WRONG")).thenReturn(Optional.empty());

        CertificateDto.CertificateVerificationResponse response = certificateService.verifyCertificate("WRONG");

        assertThat(response.getValid()).isFalse();
    }
}
