package radim.ma.service;

public interface EmailService {

    /**
     * Send welcome email to newly registered user
     * 
     * @param to        User's email address
     * @param firstName User's first name
     * @param lastName  User's last name
     */
    void sendWelcomeEmail(String to, String firstName, String lastName);

    /**
     * Send login notification email
     * 
     * @param to        User's email address
     * @param firstName User's first name
     * @param ipAddress Login IP address (optional)
     * @param userAgent User agent string (optional)
     */
    void sendLoginNotificationEmail(String to, String firstName, String ipAddress, String userAgent);

    /**
     * Send email verification code (OTP)
     * 
     * @param to        User's email address
     * @param firstName User's first name
     * @param otpCode   6-digit verification code
     */
    void sendVerificationEmail(String to, String firstName, String otpCode);

    /**
     * Send password reset code (OTP)
     * 
     * @param to        User's email address
     * @param firstName User's first name
     * @param otpCode   6-digit reset code
     */
    void sendPasswordResetEmail(String to, String firstName, String otpCode);
}
