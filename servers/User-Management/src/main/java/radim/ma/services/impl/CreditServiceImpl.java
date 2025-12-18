package radim.ma.services.impl;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import radim.ma.dto.CreditDto;
import radim.ma.entities.StudentCredit;
import radim.ma.repositories.StudentCreditRepository;
import radim.ma.repositories.UserRepository;
import radim.ma.services.CreditService;

import java.math.BigDecimal;

@Service
@RequiredArgsConstructor
@Slf4j
public class CreditServiceImpl implements CreditService {

    private final StudentCreditRepository creditRepository;
    private final UserRepository userRepository;

    @Override
    @Transactional(readOnly = true)
    public CreditDto.CreditBalanceResponse getBalance(Long studentId) {
        StudentCredit credit = creditRepository.findByUserId(studentId)
                .orElseGet(() -> initializeAndGet(studentId));

        return CreditDto.CreditBalanceResponse.builder()
                .userId(credit.getUserId())
                .balance(credit.getBalance())
                .lastUpdated(credit.getUpdatedAt())
                .build();
    }

    @Override
    @Transactional
    public void updateCredits(Long studentId, BigDecimal amount) {
        // Verify user exists
        if (!userRepository.existsById(studentId)) {
            throw new RuntimeException("Student not found with ID: " + studentId);
        }

        StudentCredit credit = creditRepository.findByUserId(studentId)
                .orElseGet(() -> initializeAndGet(studentId));

        BigDecimal newBalance = credit.getBalance().add(amount);

        // Prevent negative balance
        if (newBalance.compareTo(BigDecimal.ZERO) < 0) {
            throw new RuntimeException("Insufficient balance. Current balance: " + credit.getBalance()
                    + ", attempted deduction: " + amount.abs());
        }

        credit.setBalance(newBalance);
        creditRepository.save(credit);
        log.info("Updated credits for student {}: new balance = {}", studentId, credit.getBalance());
    }

    @Override
    @Transactional
    public void initializeCreditAccount(Long userId) {
        if (!creditRepository.existsByUserId(userId)) {
            StudentCredit credit = StudentCredit.builder()
                    .userId(userId)
                    .balance(BigDecimal.ZERO)
                    .build();
            creditRepository.save(credit);
            log.info("Initialized credit account for user {}", userId);
        }
    }

    private StudentCredit initializeAndGet(Long userId) {
        initializeCreditAccount(userId);
        return creditRepository.findByUserId(userId)
                .orElseThrow(() -> new RuntimeException("Failed to initialize credit account"));
    }
}
