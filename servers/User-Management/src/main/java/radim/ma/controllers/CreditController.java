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

    private String extractTokenFromRequest(HttpServletRequest request) {
        String bearerToken = request.getHeader("Authorization");
        if (bearerToken != null && bearerToken.startsWith("Bearer ")) {
            return bearerToken.substring(7);
        }
        throw new RuntimeException("JWT token not found in request headers");
    }
}
