package radim.ma.dto;

import jakarta.validation.constraints.NotNull;
import lombok.Builder;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;

public class CreditDto {

    @Data
    @Builder
    public static class CreditBalanceResponse {
        private Long userId;
        private BigDecimal balance;
        private LocalDateTime lastUpdated;
    }

    @Data
    public static class UpdateCreditRequest {
        @NotNull(message = "Student ID is required")
        private Long studentId;

        @NotNull(message = "Amount is required")
        private BigDecimal amount;
    }

    @Data
    public static class DeductCreditRequest {
        @NotNull(message = "Amount is required")
        private Double amount;
    }
}
