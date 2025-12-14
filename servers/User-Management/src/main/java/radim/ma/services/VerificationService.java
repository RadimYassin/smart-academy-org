package radim.ma.services;

public interface VerificationService {

    /**
     * Verify user's email using OTP code
     * 
     * @param email User's email address
     * @param code  OTP verification code
     */
    void verifyEmail(String email, String code);

    /**
     * Resend verification code to user's email
     * 
     * @param email User's email address
     */
    void resendVerificationCode(String email);
}
