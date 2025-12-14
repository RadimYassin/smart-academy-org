package radim.ma.service;

public interface OTPService {

    /**
     * Generate a 6-digit OTP code
     * 
     * @return 6-digit numeric code as String
     */
    String generateOTP();

    /**
     * Generate expiry time for OTP (default: 10 minutes from now)
     * 
     * @return LocalDateTime representing expiry time
     */
    java.time.LocalDateTime generateExpiryTime();

    /**
     * Validate if OTP code is expired
     * 
     * @param expiryTime The expiry timestamp
     * @return true if expired, false otherwise
     */
    boolean isExpired(java.time.LocalDateTime expiryTime);
}
