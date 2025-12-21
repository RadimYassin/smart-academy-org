package radim.ma.services.impl;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.Captor;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.security.crypto.password.PasswordEncoder;
import radim.ma.entities.Role;
import radim.ma.entities.User;
import radim.ma.repositories.UserRepository;
import radim.ma.service.EmailService;
import radim.ma.service.OTPService;

import java.time.LocalDateTime;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
@DisplayName("PasswordResetService Unit Tests")
class PasswordResetServiceImplTest {

    @Mock
    private UserRepository userRepository;

    @Mock
    private OTPService otpService;

    @Mock
    private EmailService emailService;

    @Mock
    private PasswordEncoder passwordEncoder;

    @InjectMocks
    private PasswordResetServiceImpl passwordResetService;

    @Captor
    private ArgumentCaptor<User> userCaptor;

    private User testUser;

    @BeforeEach
    void setUp() {
        testUser = User.builder()
                .id(1L)
                .email("test@example.com")
                .firstName("John")
                .lastName("Doe")
                .password("encodedPassword")
                .role(Role.STUDENT)
                .isVerified(true)
                .build();
    }

    @Test
    @DisplayName("Should successfully request password reset")
    void requestPasswordReset_Success() {
        // Given
        String email = "test@example.com";
        String otpCode = "123456";
        LocalDateTime expiryTime = LocalDateTime.now().plusMinutes(15);

        when(userRepository.findByEmail(email)).thenReturn(Optional.of(testUser));
        when(otpService.generateOTP()).thenReturn(otpCode);
        when(otpService.generateExpiryTime()).thenReturn(expiryTime);
        when(userRepository.save(any(User.class))).thenReturn(testUser);

        // When
        passwordResetService.requestPasswordReset(email);

        // Then
        verify(userRepository).findByEmail(email);
        verify(otpService).generateOTP();
        verify(otpService).generateExpiryTime();

        verify(userRepository).save(userCaptor.capture());
        User savedUser = userCaptor.getValue();
        assertThat(savedUser.getPasswordResetCode()).isEqualTo(otpCode);
        assertThat(savedUser.getPasswordResetExpiry()).isEqualTo(expiryTime);

        verify(emailService).sendPasswordResetEmail(email, "John", otpCode);
    }

    @Test
    @DisplayName("Should throw exception when user not found")
    void requestPasswordReset_UserNotFound() {
        // Given
        String email = "nonexistent@example.com";
        when(userRepository.findByEmail(email)).thenReturn(Optional.empty());

        // When & Then
        assertThatThrownBy(() -> passwordResetService.requestPasswordReset(email))
                .isInstanceOf(RuntimeException.class)
                .hasMessage("User not found");

        verify(userRepository).findByEmail(email);
        verify(otpService, never()).generateOTP();
        verify(emailService, never()).sendPasswordResetEmail(anyString(), anyString(), anyString());
    }

    @Test
    @DisplayName("Should successfully reset password with valid code")
    void resetPassword_Success() {
        // Given
        String email = "test@example.com";
        String resetCode = "123456";
        String newPassword = "NewPassword123";
        String encodedNewPassword = "encodedNewPassword";

        testUser.setPasswordResetCode(resetCode);
        testUser.setPasswordResetExpiry(LocalDateTime.now().plusMinutes(10));

        when(userRepository.findByEmail(email)).thenReturn(Optional.of(testUser));
        when(otpService.isExpired(any(LocalDateTime.class))).thenReturn(false);
        when(passwordEncoder.encode(newPassword)).thenReturn(encodedNewPassword);
        when(userRepository.save(any(User.class))).thenReturn(testUser);

        // When
        passwordResetService.resetPassword(email, resetCode, newPassword);

        // Then
        verify(userRepository).save(userCaptor.capture());
        User savedUser = userCaptor.getValue();

        assertThat(savedUser.getPassword()).isEqualTo(encodedNewPassword);
        assertThat(savedUser.getPasswordResetCode()).isNull();
        assertThat(savedUser.getPasswordResetExpiry()).isNull();
    }

    @Test
    @DisplayName("Should throw exception when reset code is invalid")
    void resetPassword_InvalidCode() {
        // Given
        String email = "test@example.com";
        String invalidCode = "999999";
        testUser.setPasswordResetCode("123456");

        when(userRepository.findByEmail(email)).thenReturn(Optional.of(testUser));

        // When & Then
        assertThatThrownBy(() -> passwordResetService.resetPassword(email, invalidCode, "newPass"))
                .isInstanceOf(RuntimeException.class)
                .hasMessage("Invalid reset code");

        verify(userRepository, never()).save(any(User.class));
    }

    @Test
    @DisplayName("Should throw exception when reset code is expired")
    void resetPassword_ExpiredCode() {
        // Given
        String email = "test@example.com";
        String resetCode = "123456";
        LocalDateTime expiredTime = LocalDateTime.now().minusMinutes(20);

        testUser.setPasswordResetCode(resetCode);
        testUser.setPasswordResetExpiry(expiredTime);

        when(userRepository.findByEmail(email)).thenReturn(Optional.of(testUser));
        when(otpService.isExpired(expiredTime)).thenReturn(true);

        // When & Then
        assertThatThrownBy(() -> passwordResetService.resetPassword(email, resetCode, "newPass"))
                .isInstanceOf(RuntimeException.class)
                .hasMessage("Reset code has expired. Please request a new code.");

        verify(userRepository, never()).save(any(User.class));
    }

    @Test
    @DisplayName("Should throw exception when password reset code is null")
    void resetPassword_NullResetCode() {
        // Given
        String email = "test@example.com";
        String resetCode = "123456";
        testUser.setPasswordResetCode(null);

        when(userRepository.findByEmail(email)).thenReturn(Optional.of(testUser));

        // When & Then
        assertThatThrownBy(() -> passwordResetService.resetPassword(email, resetCode, "newPass"))
                .isInstanceOf(RuntimeException.class)
                .hasMessage("Invalid reset code");

        verify(userRepository, never()).save(any(User.class));
    }
}
