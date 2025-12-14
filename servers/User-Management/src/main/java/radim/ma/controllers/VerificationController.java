package radim.ma.controllers;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import radim.ma.dto.ResendOTPRequest;
import radim.ma.dto.VerificationRequest;
import radim.ma.services.VerificationService;

import java.util.Map;

@RestController
@RequestMapping("/api/v1/auth")
@RequiredArgsConstructor
@Tag(name = "Email Verification", description = "Email verification and OTP management endpoints")
public class VerificationController {

    private final VerificationService verificationService;

    @PostMapping("/verify-email")
    @Operation(summary = "Verify email address", description = "Verify user's email address using the OTP code sent to their email")
    public ResponseEntity<?> verifyEmail(@Valid @RequestBody VerificationRequest request) {
        verificationService.verifyEmail(request.getEmail(), request.getCode());
        return ResponseEntity.ok(Map.of(
                "message", "Email verified successfully! You can now log in.",
                "verified", true));
    }

    @PostMapping("/resend-otp")
    @Operation(summary = "Resend verification code", description = "Resend OTP code to user's email address")
    public ResponseEntity<?> resendOTP(@Valid @RequestBody ResendOTPRequest request) {
        verificationService.resendVerificationCode(request.getEmail());
        return ResponseEntity.ok(Map.of(
                "message", "Verification code has been sent to your email"));
    }
}
