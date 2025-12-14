package radim.ma.service.impl;

import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import radim.ma.service.OTPService;

import java.security.SecureRandom;
import java.time.LocalDateTime;

@Service
@Slf4j
public class OTPServiceImpl implements OTPService {

    private static final int OTP_LENGTH = 6;
    private static final int OTP_EXPIRY_MINUTES = 10;
    private static final SecureRandom random = new SecureRandom();

    @Override
    public String generateOTP() {
        // Generate 6-digit OTP
        int otp = 100000 + random.nextInt(900000);
        String otpCode = String.valueOf(otp);
        log.debug("Generated OTP: {}", otpCode);
        return otpCode;
    }

    @Override
    public LocalDateTime generateExpiryTime() {
        return LocalDateTime.now().plusMinutes(OTP_EXPIRY_MINUTES);
    }

    @Override
    public boolean isExpired(LocalDateTime expiryTime) {
        if (expiryTime == null) {
            return true;
        }
        return LocalDateTime.now().isAfter(expiryTime);
    }
}
