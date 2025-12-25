package radim.ma.services.impl;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import radim.ma.dto.CreditDto;
import radim.ma.entities.StudentCredit;
import radim.ma.repositories.StudentCreditRepository;
import radim.ma.repositories.UserRepository;

import java.math.BigDecimal;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class CreditServiceImplTest {

    @Mock
    private StudentCreditRepository creditRepository;

    @Mock
    private UserRepository userRepository;

    @InjectMocks
    private CreditServiceImpl creditService;

    private Long userId = 1L;
    private StudentCredit studentCredit;

    @BeforeEach
    void setUp() {
        studentCredit = StudentCredit.builder()
                .userId(userId)
                .balance(BigDecimal.valueOf(10))
                .build();
    }

    @Test
    void getBalance_ShouldReturnInitialBalance_WhenAccountNotFound() {
        // Arrange
        when(creditRepository.findByUserId(userId)).thenReturn(Optional.empty());

        // Act
        CreditDto.CreditBalanceResponse response = creditService.getBalance(userId);

        // Assert
        assertThat(response.getBalance()).isEqualByComparingTo(BigDecimal.valueOf(10));
        assertThat(response.getUserId()).isEqualTo(userId);
    }

    @Test
    void getBalance_ShouldReturnActualBalance_WhenAccountExists() {
        // Arrange
        studentCredit.setBalance(BigDecimal.valueOf(50));
        when(creditRepository.findByUserId(userId)).thenReturn(Optional.of(studentCredit));

        // Act
        CreditDto.CreditBalanceResponse response = creditService.getBalance(userId);

        // Assert
        assertThat(response.getBalance()).isEqualByComparingTo(BigDecimal.valueOf(50));
    }

    @Test
    void updateCredits_ShouldSucceed_WhenBalanceIsSufficient() {
        // Arrange
        when(userRepository.existsById(userId)).thenReturn(true);
        when(creditRepository.findByUserId(userId)).thenReturn(Optional.of(studentCredit));

        // Act
        creditService.updateCredits(userId, BigDecimal.valueOf(5));

        // Assert
        assertThat(studentCredit.getBalance()).isEqualByComparingTo(BigDecimal.valueOf(15));
        verify(creditRepository).save(studentCredit);
    }

    @Test
    void updateCredits_ShouldThrowException_WhenStudentNotFound() {
        // Arrange
        when(userRepository.existsById(userId)).thenReturn(false);

        // Act & Assert
        assertThatThrownBy(() -> creditService.updateCredits(userId, BigDecimal.ONE))
                .isInstanceOf(RuntimeException.class)
                .hasMessageContaining("Student not found");
    }

    @Test
    void updateCredits_ShouldThrowException_WhenBalanceIsInsufficient() {
        // Arrange
        when(userRepository.existsById(userId)).thenReturn(true);
        when(creditRepository.findByUserId(userId)).thenReturn(Optional.of(studentCredit));

        // Act & Assert
        assertThatThrownBy(() -> creditService.updateCredits(userId, BigDecimal.valueOf(-15)))
                .isInstanceOf(RuntimeException.class)
                .hasMessageContaining("Insufficient balance");
    }

    @Test
    void initializeCreditAccount_ShouldCreateAccount_WhenNotExists() {
        // Arrange
        when(creditRepository.existsByUserId(userId)).thenReturn(false);

        // Act
        creditService.initializeCreditAccount(userId);

        // Assert
        verify(creditRepository).save(any(StudentCredit.class));
    }

    @Test
    void initializeCreditAccount_ShouldNotCreateAccount_WhenExists() {
        // Arrange
        when(creditRepository.existsByUserId(userId)).thenReturn(true);

        // Act
        creditService.initializeCreditAccount(userId);

        // Assert
        verify(creditRepository, never()).save(any(StudentCredit.class));
    }
}
