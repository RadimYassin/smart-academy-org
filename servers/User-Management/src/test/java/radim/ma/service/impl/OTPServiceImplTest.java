package radim.ma.service.impl;

import org.junit.jupiter.api.Test;
import java.time.LocalDateTime;
import static org.assertj.core.api.Assertions.assertThat;

class OTPServiceImplTest {

    private final OTPServiceImpl otpService = new OTPServiceImpl();

    @Test
    void generateOTP_ShouldReturnSixDigitString() {
        String otp = otpService.generateOTP();
        assertThat(otp).hasSize(6);
        assertThat(otp).containsOnlyDigits();
    }

    @Test
    void generateExpiryTime_ShouldReturnFutureTime() {
        LocalDateTime expiryTime = otpService.generateExpiryTime();
        assertThat(expiryTime).isAfter(LocalDateTime.now());
    }

    @Test
    void isExpired_ShouldReturnTrue_WhenTimeIsPast() {
        LocalDateTime past = LocalDateTime.now().minusMinutes(1);
        assertThat(otpService.isExpired(past)).isTrue();
    }

    @Test
    void isExpired_ShouldReturnFalse_WhenTimeIsFuture() {
        LocalDateTime future = LocalDateTime.now().plusMinutes(1);
        assertThat(otpService.isExpired(future)).isFalse();
    }

    @Test
    void isExpired_ShouldReturnTrue_WhenTimeIsNull() {
        assertThat(otpService.isExpired(null)).isTrue();
    }
}
