package com.radim.project.controller;

import com.radim.project.dto.CertificateDto;
import com.radim.project.service.CertificateService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/certificates")
@RequiredArgsConstructor
@Tag(name = "Certificate Management", description = "APIs for certificate generation and verification")
public class CertificateController {

    private final CertificateService certificateService;

    @GetMapping("/eligibility/{courseId}")
    @PreAuthorize("hasRole('STUDENT')")
    @Operation(summary = "Check certificate eligibility", description = "Student can check if they're eligible for a certificate")
    public ResponseEntity<CertificateDto.CertificateEligibilityResponse> checkEligibility(
            @PathVariable UUID courseId,
            Authentication authentication) {
        Long studentId = extractUserId(authentication);
        CertificateDto.CertificateEligibilityResponse response = certificateService.checkEligibility(courseId,
                studentId);
        return ResponseEntity.ok(response);
    }

    @PostMapping("/generate/{courseId}")
    @PreAuthorize("hasRole('STUDENT')")
    @Operation(summary = "Generate certificate", description = "Student can generate their certificate if eligible")
    public ResponseEntity<CertificateDto.CertificateResponse> generateCertificate(
            @PathVariable UUID courseId,
            Authentication authentication) {
        Long studentId = extractUserId(authentication);
        CertificateDto.CertificateResponse response = certificateService.generateCertificate(courseId, studentId);
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

    @GetMapping("/my-certificates")
    @PreAuthorize("hasRole('STUDENT')")
    @Operation(summary = "Get student certificates", description = "Student can view all their certificates")
    public ResponseEntity<List<CertificateDto.CertificateResponse>> getMyCertificates(
            Authentication authentication) {
        Long studentId = extractUserId(authentication);
        List<CertificateDto.CertificateResponse> certificates = certificateService.getStudentCertificates(studentId);
        return ResponseEntity.ok(certificates);
    }

    @GetMapping("/{certificateId}")
    @PreAuthorize("hasAnyRole('STUDENT', 'TEACHER')")
    @Operation(summary = "Get certificate details", description = "Get certificate metadata")
    public ResponseEntity<CertificateDto.CertificateResponse> getCertificate(
            @PathVariable UUID certificateId) {
        CertificateDto.CertificateResponse response = certificateService.getCertificate(certificateId);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/{certificateId}/download")
    @PreAuthorize("hasAnyRole('STUDENT', 'TEACHER')")
    @Operation(summary = "Download certificate PDF", description = "Download certificate as PDF file")
    public ResponseEntity<byte[]> downloadCertificate(
            @PathVariable UUID certificateId) {
        byte[] pdfBytes = certificateService.downloadCertificate(certificateId);

        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_PDF);
        headers.setContentDispositionFormData("attachment", "certificate-" + certificateId + ".pdf");

        return ResponseEntity.ok()
                .headers(headers)
                .body(pdfBytes);
    }

    @GetMapping("/verify/{verificationCode}")
    @Operation(summary = "Verify certificate", description = "Public endpoint to verify certificate authenticity")
    public ResponseEntity<CertificateDto.CertificateVerificationResponse> verifyCertificate(
            @PathVariable String verificationCode) {
        CertificateDto.CertificateVerificationResponse response = certificateService
                .verifyCertificate(verificationCode);
        return ResponseEntity.ok(response);
    }

    private Long extractUserId(Authentication authentication) {
        return Long.parseLong(authentication.getName());
    }
}
