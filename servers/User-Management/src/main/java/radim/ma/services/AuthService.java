package radim.ma.services;

import lombok.RequiredArgsConstructor;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
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

import java.time.Instant;
import java.util.HashMap;
import java.util.Map;
import java.util.UUID;
import java.util.stream.Collectors;
import org.springframework.security.core.GrantedAuthority;

@Service
@RequiredArgsConstructor
public class AuthService {

        private final UserRepository userRepository;
        private final PasswordEncoder passwordEncoder;
        private final JwtUtil jwtUtil;
        private final AuthenticationManager authenticationManager;
        private final RefreshTokenRepository refreshTokenRepository;
        private final EmailService emailService;
        private final radim.ma.service.OTPService otpService;
        private final CreditService creditService;

        public AuthResponse register(RegisterRequest request) {
                if (userRepository.existsByEmail(request.getEmail())) {
                        throw new RuntimeException("Email already exists");
                }

                var user = User.builder()
                                .firstName(request.getFirstName())
                                .lastName(request.getLastName())
                                .email(request.getEmail())
                                .password(passwordEncoder.encode(request.getPassword()))
                                .role(request.getRole() != null ? request.getRole() : Role.STUDENT)
                                .isVerified(false)
                                .build();

                // Generate OTP for email verification
                String otpCode = otpService.generateOTP();
                user.setVerificationCode(otpCode);
                user.setVerificationCodeExpiry(otpService.generateExpiryTime());

                var savedUser = userRepository.save(user);

                // Initialize credit account with zero balance
                creditService.initializeCreditAccount(savedUser.getId());

                // Send verification email with OTP
                emailService.sendVerificationEmail(
                                savedUser.getEmail(),
                                savedUser.getFirstName(),
                                otpCode);

                Map<String, Object> extraClaims = new HashMap<>();
                extraClaims.put("userId", savedUser.getId());
                extraClaims.put("roles", savedUser.getAuthorities().stream()
                                .map(GrantedAuthority::getAuthority)
                                .collect(Collectors.toList()));
                var jwtToken = jwtUtil.generateToken(extraClaims, savedUser);
                var refreshToken = createRefreshToken(savedUser);

                return AuthResponse.builder()
                                .accessToken(jwtToken)
                                .refreshToken(refreshToken.getToken())
                                .isVerified(false)
                                .email(savedUser.getEmail())
                                .firstName(savedUser.getFirstName())
                                .lastName(savedUser.getLastName())
                                .role(savedUser.getRole().name())
                                .build();
        }

        public AuthResponse authenticate(AuthRequest request) {
                authenticationManager.authenticate(
                                new UsernamePasswordAuthenticationToken(
                                                request.getEmail(),
                                                request.getPassword()));
                var user = userRepository.findByEmail(request.getEmail())
                                .orElseThrow();

                // Check if email is verified
                if (!user.getIsVerified()) {
                        throw new RuntimeException(
                                        "Email not verified. Please check your email for verification code.");
                }

                // Send login notification email asynchronously
                emailService.sendLoginNotificationEmail(
                                user.getEmail(),
                                user.getFirstName(),
                                null, // IP address can be extracted from HttpServletRequest if needed
                                null // User agent can be extracted from HttpServletRequest if needed
                );

                Map<String, Object> extraClaims = new HashMap<>();
                extraClaims.put("userId", user.getId());
                extraClaims.put("roles", user.getAuthorities().stream()
                                .map(GrantedAuthority::getAuthority)
                                .collect(Collectors.toList()));
                var jwtToken = jwtUtil.generateToken(extraClaims, user);
                var refreshToken = createRefreshToken(user);

                return AuthResponse.builder()
                                .accessToken(jwtToken)
                                .refreshToken(refreshToken.getToken())
                                .isVerified(true)
                                .email(user.getEmail())
                                .firstName(user.getFirstName())
                                .lastName(user.getLastName())
                                .role(user.getRole().name())
                                .build();
        }

        public AuthResponse refreshToken(String requestRefreshToken) {
                return refreshTokenRepository.findByToken(requestRefreshToken)
                                .map(token -> {
                                        if (token.getExpiryDate().isBefore(Instant.now())) {
                                                refreshTokenRepository.delete(token);
                                                throw new RuntimeException(
                                                                "Refresh token was expired. Please make a new signin request");
                                        }
                                        return token;
                                })
                                .map(RefreshToken::getUser)
                                .map(user -> {
                                        Map<String, Object> extraClaims = new HashMap<>();
                                        extraClaims.put("userId", user.getId());
                                        extraClaims.put("roles", user.getAuthorities().stream()
                                                        .map(GrantedAuthority::getAuthority)
                                                        .collect(Collectors.toList()));
                                        String accessToken = jwtUtil.generateToken(extraClaims, user);
                                        return AuthResponse.builder()
                                                        .accessToken(accessToken)
                                                        .refreshToken(requestRefreshToken)
                                                        .email(user.getEmail())
                                                        .firstName(user.getFirstName())
                                                        .lastName(user.getLastName())
                                                        .role(user.getRole().name())
                                                        .isVerified(user.getIsVerified())
                                                        .build();
                                }).orElseThrow(() -> new RuntimeException("Refresh token is not in database!"));
        }

        private RefreshToken createRefreshToken(User user) {
                // Delete existing token if any
                // refreshTokenRepository.deleteByUser(user); // Need Transactional if doing
                // this

                RefreshToken refreshToken = RefreshToken.builder()
                                .user(user)
                                .token(UUID.randomUUID().toString())
                                .expiryDate(Instant.now().plusMillis(604800000)) // 7 days
                                .build();
                return refreshTokenRepository.save(refreshToken);
        }
}
