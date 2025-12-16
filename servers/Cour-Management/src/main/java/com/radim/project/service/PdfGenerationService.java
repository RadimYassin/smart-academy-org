package com.radim.project.service;

import com.radim.project.entity.Certificate;
import com.radim.project.entity.Course;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.apache.pdfbox.pdmodel.PDDocument;
import org.apache.pdfbox.pdmodel.PDPage;
import org.apache.pdfbox.pdmodel.PDPageContentStream;
import org.apache.pdfbox.pdmodel.common.PDRectangle;
import org.apache.pdfbox.pdmodel.font.PDType1Font;
import org.apache.pdfbox.pdmodel.font.Standard14Fonts;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.time.format.DateTimeFormatter;

@Service
@RequiredArgsConstructor
@Slf4j
public class PdfGenerationService {

    @Value("${certificate.storage-path:uploads/certificates}")
    private String certificateStoragePath;

    public String generateCertificatePdf(Certificate certificate, Course course) throws IOException {
        log.info("Generating PDF certificate for certificate ID: {}", certificate.getId());

        // Ensure storage directory exists
        Path storagePath = Paths.get(certificateStoragePath);
        if (!Files.exists(storagePath)) {
            Files.createDirectories(storagePath);
        }

        String filename = certificate.getId() + ".pdf";
        String fullPath = storagePath.resolve(filename).toString();

        try (PDDocument document = new PDDocument()) {
            PDPage page = new PDPage(PDRectangle.A4);
            document.addPage(page);

            try (PDPageContentStream contentStream = new PDPageContentStream(document, page)) {
                float pageWidth = page.getMediaBox().getWidth();
                float pageHeight = page.getMediaBox().getHeight();
                float margin = 72; // 1 inch margin
                float yPosition = pageHeight - margin;

                // Title
                contentStream.beginText();
                contentStream.setFont(new PDType1Font(Standard14Fonts.FontName.HELVETICA_BOLD), 36);
                String title = "Certificate of Completion";
                float titleWidth = new PDType1Font(Standard14Fonts.FontName.HELVETICA_BOLD).getStringWidth(title) / 1000
                        * 36;
                contentStream.newLineAtOffset((pageWidth - titleWidth) / 2, yPosition);
                contentStream.showText(title);
                contentStream.endText();

                yPosition -= 80;

                // Certificate text
                contentStream.beginText();
                contentStream.setFont(new PDType1Font(Standard14Fonts.FontName.HELVETICA), 14);
                String certText = "This is to certify that";
                float certTextWidth = new PDType1Font(Standard14Fonts.FontName.HELVETICA).getStringWidth(certText)
                        / 1000 * 14;
                contentStream.newLineAtOffset((pageWidth - certTextWidth) / 2, yPosition);
                contentStream.showText(certText);
                contentStream.endText();

                yPosition -= 40;

                // Student ID (placeholder - actual name would come from User service)
                contentStream.beginText();
                contentStream.setFont(new PDType1Font(Standard14Fonts.FontName.HELVETICA_BOLD), 24);
                String studentName = "Student ID: " + certificate.getStudentId();
                float studentNameWidth = new PDType1Font(Standard14Fonts.FontName.HELVETICA_BOLD)
                        .getStringWidth(studentName) / 1000 * 24;
                contentStream.newLineAtOffset((pageWidth - studentNameWidth) / 2, yPosition);
                contentStream.showText(studentName);
                contentStream.endText();

                yPosition -= 50;

                // Course completion text
                contentStream.beginText();
                contentStream.setFont(new PDType1Font(Standard14Fonts.FontName.HELVETICA), 14);
                String completionText = "has successfully completed the course";
                float completionTextWidth = new PDType1Font(Standard14Fonts.FontName.HELVETICA)
                        .getStringWidth(completionText) / 1000 * 14;
                contentStream.newLineAtOffset((pageWidth - completionTextWidth) / 2, yPosition);
                contentStream.showText(completionText);
                contentStream.endText();

                yPosition -= 40;

                // Course title
                contentStream.beginText();
                contentStream.setFont(new PDType1Font(Standard14Fonts.FontName.HELVETICA_BOLD_OBLIQUE), 20);
                String courseTitle = course.getTitle();
                float courseTitleWidth = new PDType1Font(Standard14Fonts.FontName.HELVETICA_BOLD_OBLIQUE)
                        .getStringWidth(courseTitle) / 1000 * 20;
                contentStream.newLineAtOffset((pageWidth - courseTitleWidth) / 2, yPosition);
                contentStream.showText(courseTitle);
                contentStream.endText();

                yPosition -= 50;

                // Completion rate
                contentStream.beginText();
                contentStream.setFont(new PDType1Font(Standard14Fonts.FontName.HELVETICA), 12);
                String completionRate = String.format("with a completion rate of %.1f%%",
                        certificate.getCompletionRate());
                float completionRateWidth = new PDType1Font(Standard14Fonts.FontName.HELVETICA)
                        .getStringWidth(completionRate) / 1000 * 12;
                contentStream.newLineAtOffset((pageWidth - completionRateWidth) / 2, yPosition);
                contentStream.showText(completionRate);
                contentStream.endText();

                yPosition -= 80;

                // Date
                contentStream.beginText();
                contentStream.setFont(new PDType1Font(Standard14Fonts.FontName.HELVETICA), 12);
                DateTimeFormatter formatter = DateTimeFormatter.ofPattern("MMMM dd, yyyy");
                String issueDate = "Issued on: " + certificate.getIssuedAt().format(formatter);
                float issueDateWidth = new PDType1Font(Standard14Fonts.FontName.HELVETICA).getStringWidth(issueDate)
                        / 1000 * 12;
                contentStream.newLineAtOffset((pageWidth - issueDateWidth) / 2, yPosition);
                contentStream.showText(issueDate);
                contentStream.endText();

                yPosition -= 100;

                // Verification code (bottom)
                contentStream.beginText();
                contentStream.setFont(new PDType1Font(Standard14Fonts.FontName.COURIER), 10);
                String verificationText = "Verification Code: " + certificate.getVerificationCode();
                float verificationWidth = new PDType1Font(Standard14Fonts.FontName.COURIER)
                        .getStringWidth(verificationText) / 1000 * 10;
                contentStream.newLineAtOffset((pageWidth - verificationWidth) / 2, margin + 20);
                contentStream.showText(verificationText);
                contentStream.endText();

                // Draw border
                contentStream.setLineWidth(2);
                contentStream.addRect(margin - 10, margin - 10, pageWidth - 2 * (margin - 10),
                        pageHeight - 2 * (margin - 10));
                contentStream.stroke();
            }

            document.save(fullPath);
            log.info("Certificate PDF generated successfully: {}", fullPath);
        }

        return fullPath;
    }

    public byte[] loadCertificatePdf(String pdfPath) {
        try {
            Path path = Paths.get(pdfPath);
            return Files.readAllBytes(path);
        } catch (IOException e) {
            log.error("Failed to load certificate PDF: {}", pdfPath, e);
            throw new RuntimeException("Failed to load certificate PDF", e);
        }
    }
}
