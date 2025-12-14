package radim.ma.services.impl;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import radim.ma.entities.User;
import radim.ma.repositories.UserRepository;
import radim.ma.service.EmailService;
import radim.ma.service.OTPService;
import radim.ma.services.VerificationService;

@Service
@RequiredArgsConstructor
@Slf4j
public class VerificationServiceImpl implements VerificationService {

    private final UserRepository userRepository;
    private final OTPService otpService;
    private final EmailService emailService;

    @Override
    @Transactional
    public void verifyEmail(String email, String code) {
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("User not found"));

        if (user.getIsVerified()) {
            throw new RuntimeException("Email already verified");
        }

        if (user.getVerificationCode() == null || !user.getVerificationCode().equals(code)) {
            throw new RuntimeException("Invalid verification code");
        }

        if (otpService.isExpired(user.getVerificationCodeExpiry())) {
            throw new RuntimeException("Verification code has expired. Please request a new code.");
        }

        // Mark as verified and clear OTP
        user.setIsVerified(true);
        user.setVerificationCode(null);
        user.setVerificationCodeExpiry(null);
        userRepository.save(user);

        log.info("User email verified successfully: {}", email);

        // Send welcome email after successful verification
        emailService.sendWelcomeEmail(user.getEmail(), user.getFirstName(), user.getLastName());
    }

    @Override
    @Transactional
    public void resendVerificationCode(String email) {
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("User not found"));

        if (user.getIsVerified()) {
            throw new RuntimeException("Email already verified");
        }

        // Generate new OTP
        String newOtp = otpService.generateOTP();
        user.setVerificationCode(newOtp);
        user.setVerificationCodeExpiry(otpService.generateExpiryTime());
        userRepository.save(user);

        // Send verification email
        emailService.sendVerificationEmail(user.getEmail(), user.getFirstName(), newOtp);

        log.info("Verification code resent to: {}", email);
    }
}
