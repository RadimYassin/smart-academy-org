package radim.ma.controllers;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;
import radim.ma.dto.CreditDto;
import radim.ma.security.JwtUtil;
import radim.ma.services.CreditService;

@RestController
@RequestMapping("/api/credits")
@RequiredArgsConstructor
@Tag(name = "Credit Management", description = "Student credit management by teachers")
public class CreditController {

    private final CreditService creditService;
    private final JwtUtil jwtUtil;

    @GetMapping("/balance")
    @PreAuthorize("hasAnyRole('STUDENT', 'TEACHER', 'ADMIN')")
    @Operation(summary = "Get my credit balance", description = "Students can view their own credit balance")
    public ResponseEntity<CreditDto.CreditBalanceResponse> getMyBalance(HttpServletRequest request) {
        String token = extractTokenFromRequest(request);
        Long userId = jwtUtil.extractClaim(token, claims -> claims.get("userId", Long.class));
        return ResponseEntity.ok(creditService.getBalance(userId));
    }

    @GetMapping("/student/{studentId}")
    @PreAuthorize("hasAnyRole('TEACHER', 'ADMIN')")
    @Operation(summary = "Get student credit balance", description = "Teachers can view any student's credit balance")
    public ResponseEntity<CreditDto.CreditBalanceResponse> getStudentBalance(@PathVariable Long studentId) {
        return ResponseEntity.ok(creditService.getBalance(studentId));
    }

    @PostMapping("/update")
    @PreAuthorize("hasAnyRole('TEACHER', 'ADMIN')")
    @Operation(summary = "Update student credits", description = "Teachers can add or deduct credits (use positive amounts to add, negative to deduct)")
    public ResponseEntity<String> updateCredits(@RequestBody @Valid CreditDto.UpdateCreditRequest request) {
        creditService.updateCredits(request.getStudentId(), request.getAmount());
        return ResponseEntity.ok("Credits updated successfully");
    }

    @PostMapping("/reward/lesson-complete")
    @PreAuthorize("hasAnyRole('STUDENT', 'TEACHER', 'ADMIN')")
    @Operation(summary = "Reward credits for completing a lesson", description = "Students can earn credits by completing lessons")
    public ResponseEntity<CreditDto.CreditBalanceResponse> rewardLessonComplete(HttpServletRequest request) {
        String token = extractTokenFromRequest(request);
        Long userId = jwtUtil.extractClaim(token, claims -> claims.get("userId", Long.class));
        // Add 5 credits for completing a lesson
        creditService.updateCredits(userId, java.math.BigDecimal.valueOf(5));
        return ResponseEntity.ok(creditService.getBalance(userId));
    }

    @PostMapping("/deduct")
    @PreAuthorize("hasAnyRole('STUDENT', 'TEACHER', 'ADMIN')")
    @Operation(summary = "Deduct credits from my account", description = "Students can deduct credits from their own account (e.g., for additional quiz attempts)")
    public ResponseEntity<CreditDto.CreditBalanceResponse> deductCredits(
            HttpServletRequest request,
            @RequestBody @Valid CreditDto.DeductCreditRequest deductRequest) {
        String token = extractTokenFromRequest(request);
        Long userId = jwtUtil.extractClaim(token, claims -> claims.get("userId", Long.class));
        // Deduct credits (amount should be positive, will be converted to negative)
        creditService.updateCredits(userId, java.math.BigDecimal.valueOf(-deductRequest.getAmount()));
        return ResponseEntity.ok(creditService.getBalance(userId));
    }

    private String extractTokenFromRequest(HttpServletRequest request) {
        String bearerToken = request.getHeader("Authorization");
        if (bearerToken != null && bearerToken.startsWith("Bearer ")) {
            return bearerToken.substring(7);
        }
        throw new RuntimeException("JWT token not found in request headers");
    }
}
