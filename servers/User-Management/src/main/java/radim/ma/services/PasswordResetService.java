package radim.ma.services;

public interface PasswordResetService {

    /**
     * Request password reset - generates OTP and sends email
     * 
     * @param email User's email address
     */
    void requestPasswordReset(String email);

    /**
     * Reset password using OTP code
     * 
     * @param email       User's email address
     * @param code        OTP code
     * @param newPassword New password
     */
    void resetPassword(String email, String code, String newPassword);
}
