package radim.ma.services.impl;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import radim.ma.entities.User;
import radim.ma.repositories.UserRepository;
import radim.ma.service.EmailService;
import radim.ma.service.OTPService;

import java.time.LocalDateTime;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class VerificationServiceImplTest {

    @Mock
    private UserRepository userRepository;
    @Mock
    private OTPService otpService;
    @Mock
    private EmailService emailService;

    @InjectMocks
    private VerificationServiceImpl verificationService;

    private User user;

    @BeforeEach
    void setUp() {
        user = User.builder()
                .email("test@example.com")
                .firstName("John")
                .lastName("Doe")
                .isVerified(false)
                .build();
    }

    @Test
    void verifyEmail_ShouldSuccess() {
        user.setVerificationCode("123456");
        user.setVerificationCodeExpiry(LocalDateTime.now().plusMinutes(10));
        when(userRepository.findByEmail(anyString())).thenReturn(Optional.of(user));
        when(otpService.isExpired(any())).thenReturn(false);

        verificationService.verifyEmail("test@example.com", "123456");

        verify(userRepository).save(user);
        verify(emailService).sendWelcomeEmail(anyString(), anyString(), anyString());
    }

    @Test
    void verifyEmail_ShouldThrowException_WhenAlreadyVerified() {
        user.setIsVerified(true);
        when(userRepository.findByEmail(anyString())).thenReturn(Optional.of(user));

        assertThatThrownBy(() -> verificationService.verifyEmail("test@example.com", "123456"))
                .isInstanceOf(RuntimeException.class)
                .hasMessage("Email already verified");
    }

    @Test
    void verifyEmail_ShouldThrowException_WhenCodeInvalid() {
        user.setVerificationCode("123456");
        when(userRepository.findByEmail(anyString())).thenReturn(Optional.of(user));

        assertThatThrownBy(() -> verificationService.verifyEmail("test@example.com", "wrong"))
                .isInstanceOf(RuntimeException.class)
                .hasMessage("Invalid verification code");
    }

    @Test
    void resendVerificationCode_ShouldSuccess() {
        when(userRepository.findByEmail(anyString())).thenReturn(Optional.of(user));
        when(otpService.generateOTP()).thenReturn("654321");

        verificationService.resendVerificationCode("test@example.com");

        verify(userRepository).save(user);
        verify(emailService).sendVerificationEmail(anyString(), anyString(), anyString());
    }
}
