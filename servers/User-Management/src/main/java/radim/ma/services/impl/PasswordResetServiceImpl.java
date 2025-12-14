package radim.ma.services.impl;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import radim.ma.entities.User;
import radim.ma.repositories.UserRepository;
import radim.ma.service.EmailService;
import radim.ma.service.OTPService;
import radim.ma.services.PasswordResetService;

@Service
@RequiredArgsConstructor
@Slf4j
public class PasswordResetServiceImpl implements PasswordResetService {

    private final UserRepository userRepository;
    private final OTPService otpService;
    private final EmailService emailService;
    private final PasswordEncoder passwordEncoder;

    @Override
    @Transactional
    public void requestPasswordReset(String email) {
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("User not found"));

        // Generate OTP for password reset
        String otpCode = otpService.generateOTP();
        user.setPasswordResetCode(otpCode);
        user.setPasswordResetExpiry(otpService.generateExpiryTime());
        userRepository.save(user);

        // Send password reset email
        emailService.sendPasswordResetEmail(user.getEmail(), user.getFirstName(), otpCode);

        log.info("Password reset code sent to: {}", email);
    }

    @Override
    @Transactional
    public void resetPassword(String email, String code, String newPassword) {
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("User not found"));

        if (user.getPasswordResetCode() == null || !user.getPasswordResetCode().equals(code)) {
            throw new RuntimeException("Invalid reset code");
        }

        if (otpService.isExpired(user.getPasswordResetExpiry())) {
            throw new RuntimeException("Reset code has expired. Please request a new code.");
        }

        // Update password and clear reset code
        user.setPassword(passwordEncoder.encode(newPassword));
        user.setPasswordResetCode(null);
        user.setPasswordResetExpiry(null);
        userRepository.save(user);

        log.info("Password reset successfully for user: {}", email);
    }
}
