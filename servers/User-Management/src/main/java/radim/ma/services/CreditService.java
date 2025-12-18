package radim.ma.services;

import radim.ma.dto.CreditDto;

public interface CreditService {
    CreditDto.CreditBalanceResponse getBalance(Long studentId);

    void updateCredits(Long studentId, java.math.BigDecimal amount);

    void initializeCreditAccount(Long userId);
}
