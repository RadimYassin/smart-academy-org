package radim.ma.services;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.crypto.password.PasswordEncoder;
import radim.ma.dto.AuthRequest;
import radim.ma.dto.AuthResponse;
import radim.ma.dto.RegisterRequest;
import radim.ma.entities.RefreshToken;
import radim.ma.entities.Role;
import radim.ma.entities.User;
import radim.ma.repositories.RefreshTokenRepository;
import radim.ma.repositories.UserRepository;
import radim.ma.security.JwtUtil;
import radim.ma.service.EmailService;
import radim.ma.service.OTPService;

import java.time.Instant;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class AuthServiceTest {

    @Mock
    private UserRepository userRepository;
    @Mock
    private PasswordEncoder passwordEncoder;
    @Mock
    private JwtUtil jwtUtil;
    @Mock
    private AuthenticationManager authenticationManager;
    @Mock
    private RefreshTokenRepository refreshTokenRepository;
    @Mock
    private EmailService emailService;
    @Mock
    private OTPService otpService;
    @Mock
    private CreditService creditService;

    @InjectMocks
    private AuthService authService;

    private User user;
    private RegisterRequest registerRequest;
    private AuthRequest authRequest;

    @BeforeEach
    void setUp() {
        user = User.builder()
                .id(1L)
                .email("test@example.com")
                .password("encodedPassword")
                .firstName("John")
                .lastName("Doe")
                .role(Role.STUDENT)
                .isVerified(false)
                .build();

        registerRequest = RegisterRequest.builder()
                .email("test@example.com")
                .password("Password123!")
                .firstName("John")
                .lastName("Doe")
                .role(Role.STUDENT)
                .build();

        authRequest = AuthRequest.builder()
                .email("test@example.com")
                .password("Password123!")
                .build();
    }

    @Test
    void register_ShouldSucceed_WhenEmailDoesNotExist() {
        // Arrange
        when(userRepository.existsByEmail(anyString())).thenReturn(false);
        when(passwordEncoder.encode(anyString())).thenReturn("encodedPassword");
        when(otpService.generateOTP()).thenReturn("123456");
        when(userRepository.save(any(User.class))).thenReturn(user);
        when(jwtUtil.generateToken(any(), any())).thenReturn("jwtToken");
        when(refreshTokenRepository.save(any(RefreshToken.class))).thenReturn(
                RefreshToken.builder().token("refreshToken").build());

        // Act
        AuthResponse response = authService.register(registerRequest);

        // Assert
        assertThat(response).isNotNull();
        assertThat(response.getEmail()).isEqualTo(user.getEmail());
        assertThat(response.getAccessToken()).isEqualTo("jwtToken");
        verify(emailService).sendVerificationEmail(anyString(), anyString(), anyString());
        verify(creditService).initializeCreditAccount(anyLong());
    }

    @Test
    void register_ShouldThrowException_WhenEmailExists() {
        // Arrange
        when(userRepository.existsByEmail(anyString())).thenReturn(true);

        // Act & Assert
        assertThatThrownBy(() -> authService.register(registerRequest))
                .isInstanceOf(RuntimeException.class)
                .hasMessage("Email already exists");
    }

    @Test
    void authenticate_ShouldSucceed_WhenCredentialsAreValidAndUserVerified() {
        // Arrange
        user.setIsVerified(true);
        when(userRepository.findByEmail(anyString())).thenReturn(Optional.of(user));
        when(jwtUtil.generateToken(any(), any())).thenReturn("jwtToken");
        when(refreshTokenRepository.save(any(RefreshToken.class))).thenReturn(
                RefreshToken.builder().token("refreshToken").build());

        // Act
        AuthResponse response = authService.authenticate(authRequest);

        // Assert
        assertThat(response).isNotNull();
        assertThat(response.getAccessToken()).isEqualTo("jwtToken");
        verify(authenticationManager).authenticate(any(UsernamePasswordAuthenticationToken.class));
        verify(emailService).sendLoginNotificationEmail(anyString(), anyString(), any(), any());
    }

    @Test
    void authenticate_ShouldThrowException_WhenUserNotVerified() {
        // Arrange
        user.setIsVerified(false);
        when(userRepository.findByEmail(anyString())).thenReturn(Optional.of(user));

        // Act & Assert
        assertThatThrownBy(() -> authService.authenticate(authRequest))
                .isInstanceOf(RuntimeException.class)
                .hasMessageContaining("Email not verified");
    }

    @Test
    void refreshToken_ShouldSucceed_WhenTokenIsValid() {
        // Arrange
        RefreshToken refreshToken = RefreshToken.builder()
                .token("validToken")
                .user(user)
                .expiryDate(Instant.now().plusSeconds(3600))
                .build();
        when(refreshTokenRepository.findByToken("validToken")).thenReturn(Optional.of(refreshToken));
        when(jwtUtil.generateToken(any(), any())).thenReturn("newJwtToken");

        // Act
        AuthResponse response = authService.refreshToken("validToken");

        // Assert
        assertThat(response).isNotNull();
        assertThat(response.getAccessToken()).isEqualTo("newJwtToken");
        assertThat(response.getRefreshToken()).isEqualTo("validToken");
    }

    @Test
    void refreshToken_ShouldThrowException_WhenTokenIsExpired() {
        // Arrange
        RefreshToken refreshToken = RefreshToken.builder()
                .token("expiredToken")
                .expiryDate(Instant.now().minusSeconds(3600))
                .build();
        when(refreshTokenRepository.findByToken("expiredToken")).thenReturn(Optional.of(refreshToken));

        // Act & Assert
        assertThatThrownBy(() -> authService.refreshToken("expiredToken"))
                .isInstanceOf(RuntimeException.class)
                .hasMessageContaining("expired");
        verify(refreshTokenRepository).delete(refreshToken);
    }

    @Test
    void refreshToken_ShouldThrowException_WhenTokenNotFound() {
        // Arrange
        when(refreshTokenRepository.findByToken(anyString())).thenReturn(Optional.empty());

        // Act & Assert
        assertThatThrownBy(() -> authService.refreshToken("nonExistent"))
                .isInstanceOf(RuntimeException.class)
                .hasMessageContaining("not in database");
    }
}
