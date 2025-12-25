package com.radim.project.service;

import com.radim.project.entity.Certificate;
import com.radim.project.entity.Course;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.io.TempDir;
import org.springframework.test.util.ReflectionTestUtils;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.time.LocalDateTime;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;

class PdfGenerationServiceTest {

    private PdfGenerationService pdfGenerationService;

    @TempDir
    Path tempDir;

    @BeforeEach
    void setUp() {
        pdfGenerationService = new PdfGenerationService();
        ReflectionTestUtils.setField(pdfGenerationService, "certificateStoragePath", tempDir.toString());
    }

    @Test
    void generateCertificatePdf_ShouldCreateFile() throws IOException {
        UUID certId = UUID.randomUUID();
        Certificate certificate = Certificate.builder()
                .id(certId)
                .studentId(1L)
                .completionRate(95.0)
                .verificationCode("TESTCODE")
                .issuedAt(LocalDateTime.now())
                .build();

        Course course = Course.builder()
                .title("Test Course")
                .build();

        String path = pdfGenerationService.generateCertificatePdf(certificate, course);

        assertThat(path).contains(certId.toString());
        assertThat(Files.exists(Path.of(path))).isTrue();
    }

    @Test
    void loadCertificatePdf_ShouldReturnBytes() throws IOException {
        Path testFile = tempDir.resolve("test.pdf");
        byte[] content = "PDF Content".getBytes();
        Files.write(testFile, content);

        byte[] result = pdfGenerationService.loadCertificatePdf(testFile.toString());

        assertThat(result).isEqualTo(content);
    }
}
