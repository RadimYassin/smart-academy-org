package radim.ma.controllers;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import radim.ma.dto.ForgotPasswordRequest;
import radim.ma.dto.ResetPasswordRequest;
import radim.ma.services.PasswordResetService;

import java.util.Map;

@RestController
@RequestMapping("/api/v1/auth")
@RequiredArgsConstructor
@Tag(name = "Password Reset", description = "Forgot password and reset endpoints")
public class PasswordResetController {

    private final PasswordResetService passwordResetService;

    @PostMapping("/forgot-password")
    @Operation(summary = "Request password reset", description = "Request a password reset code sent to email")
    public ResponseEntity<?> forgotPassword(@Valid @RequestBody ForgotPasswordRequest request) {
        passwordResetService.requestPasswordReset(request.getEmail());
        return ResponseEntity.ok(Map.of(
                "message", "Password reset code has been sent to your email"));
    }

    @PostMapping("/reset-password")
    @Operation(summary = "Reset password with code", description = "Reset password using the OTP code sent to email")
    public ResponseEntity<?> resetPassword(@Valid @RequestBody ResetPasswordRequest request) {
        passwordResetService.resetPassword(
                request.getEmail(),
                request.getCode(),
                request.getNewPassword());
        return ResponseEntity.ok(Map.of(
                "message", "Password reset successfully! You can now log in with your new password."));
    }
}
