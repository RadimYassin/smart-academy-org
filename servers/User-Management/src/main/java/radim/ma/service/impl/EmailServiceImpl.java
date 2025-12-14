package radim.ma.service.impl;

import jakarta.mail.MessagingException;
import jakarta.mail.internet.MimeMessage;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.MimeMessageHelper;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;
import radim.ma.service.EmailService;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

@Service
@RequiredArgsConstructor
@Slf4j
public class EmailServiceImpl implements EmailService {

    private final JavaMailSender mailSender;

    @Value("${application.mail.from}")
    private String fromEmail;

    @Value("${application.mail.from-name}")
    private String fromName;

    @Override
    @Async
    public void sendWelcomeEmail(String to, String firstName, String lastName) {
        try {
            MimeMessage message = mailSender.createMimeMessage();
            MimeMessageHelper helper = new MimeMessageHelper(message, true, "UTF-8");

            helper.setFrom(fromEmail, fromName);
            helper.setTo(to);
            helper.setSubject("Welcome to Smart Academy! 🎓");

            String htmlContent = buildWelcomeEmailTemplate(firstName, lastName);
            helper.setText(htmlContent, true);

            mailSender.send(message);
            log.info("Welcome email sent successfully to: {}", to);
        } catch (MessagingException e) {
            log.error("Failed to send welcome email to: {}. Error: {}", to, e.getMessage());
        } catch (Exception e) {
            log.error("Unexpected error sending welcome email to: {}. Error: {}", to, e.getMessage());
        }
    }

    @Override
    @Async
    public void sendLoginNotificationEmail(String to, String firstName, String ipAddress, String userAgent) {
        try {
            MimeMessage message = mailSender.createMimeMessage();
            MimeMessageHelper helper = new MimeMessageHelper(message, true, "UTF-8");

            helper.setFrom(fromEmail, fromName);
            helper.setTo(to);
            helper.setSubject("New Login to Your Smart Academy Account 🔐");

            String htmlContent = buildLoginNotificationTemplate(firstName, ipAddress, userAgent);
            helper.setText(htmlContent, true);

            mailSender.send(message);
            log.info("Login notification email sent successfully to: {}", to);
        } catch (MessagingException e) {
            log.error("Failed to send login notification to: {}. Error: {}", to, e.getMessage());
        } catch (Exception e) {
            log.error("Unexpected error sending login notification to: {}. Error: {}", to, e.getMessage());
        }
    }

    private String buildWelcomeEmailTemplate(String firstName, String lastName) {
        String registrationDate = LocalDateTime.now().format(DateTimeFormatter.ofPattern("MMMM dd, yyyy 'at' HH:mm"));

        // Using String.format instead of .formatted() to avoid issues with # and %
        return String.format(
                """
                        <!DOCTYPE html>
                        <html>
                        <head>
                            <meta charset="UTF-8">
                            <meta name="viewport" content="width=device-width, initial-scale=1.0">
                            <style>
                                body {
                                    font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
                                    line-height: 1.6;
                                    color: #333;
                                    margin: 0;
                                    padding: 0;
                                    background-color: #f4f4f4;
                                }
                                .container {
                                    max-width: 600px;
                                    margin: 20px auto;
                                    background: #ffffff;
                                    border-radius: 10px;
                                    overflow: hidden;
                                    box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
                                }
                                .header {
                                    background: linear-gradient(135deg, #667eea 0%%, #764ba2 100%%);
                                    color: white;
                                    padding: 40px 20px;
                                    text-align: center;
                                }
                                .header h1 {
                                    margin: 0;
                                    font-size: 32px;
                                }
                                .content {
                                    padding: 40px 30px;
                                }
                                .content h2 {
                                    color: #667eea;
                                   margin-top: 0;
                                }
                                .welcome-message {
                                    background: #f8f9ff;
                                    border-left: 4px solid #667eea;
                                    padding: 20px;
                                    margin: 20px 0;
                                    border-radius: 4px;
                                }
                                .features {
                                    margin: 30px 0;
                                }
                                .feature {
                                    margin: 15px 0;
                                    padding-left: 30px;
                                    position: relative;
                                }
                                .feature:before {
                                    content: "✓";
                                    position: absolute;
                                    left: 0;
                                    color: #667eea;
                                    font-weight: bold;
                                    font-size: 20px;
                                }
                                .footer {
                                    background: #f8f9fa;
                                    padding: 20px;
                                    text-align: center;
                                    color: #666;
                                    font-size: 14px;
                                }
                            </style>
                        </head>
                        <body>
                            <div class="container">
                                <div class="header">
                                    <h1>🎓 Smart Academy</h1>
                                    <p>Welcome to Your Learning Journey!</p>
                                </div>
                                <div class="content">
                                    <h2>Hello %s %s! 👋</h2>
                                    <div class="welcome-message">
                                        <p><strong>Congratulations!</strong> Your Smart Academy account has been created successfully.</p>
                                    </div>
                                    <p>We're excited to have you join our community of learners. Get ready to explore a world of knowledge and opportunities!</p>

                                    <div class="features">
                                        <h3>What you can do now:</h3>
                                        <div class="feature">Browse our extensive course catalog</div>
                                        <div class="feature">Take interactive quizzes to test your knowledge</div>
                                        <div class="feature">Track your learning progress</div>
                                        <div class="feature">Get personalized course recommendations</div>
                                        <div class="feature">Join a community of passionate learners</div>
                                    </div>

                                    <p><strong>Your account details:</strong></p>
                                    <ul>
                                        <li><strong>Name:</strong> %s %s</li>
                                        <li><strong>Registration Date:</strong> %s</li>
                                    </ul>

                                    <p>If you have any questions or need assistance, our support team is always here to help!</p>

                                    <p>Happy Learning! 🚀</p>
                                </div>
                                <div class="footer">
                                    <p>&copy; 2025 Smart Academy. All rights reserved.</p>
                                    <p>This is an automated message. Please do not reply to this email.</p>
                                </div>
                            </div>
                        </body>
                        </html>
                        """,
                firstName, lastName, firstName, lastName, registrationDate);
    }

    private String buildLoginNotificationTemplate(String firstName, String ipAddress, String userAgent) {
        String loginTime = LocalDateTime.now().format(DateTimeFormatter.ofPattern("MMMM dd, yyyy 'at' HH:mm:ss"));
        String ip = ipAddress != null ? ipAddress : "Unknown";
        String device = extractDeviceInfo(userAgent);

        return String.format(
                """
                        <!DOCTYPE html>
                        <html>
                        <head>
                            <meta charset="UTF-8">
                            <meta name="viewport" content="width=device-width, initial-scale=1.0">
                            <style>
                                body {
                                    font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
                                    line-height: 1.6;
                                    color: #333;
                                    margin: 0;
                                    padding: 0;
                                    background-color: #f4f4f4;
                                }
                                .container {
                                    max-width: 600px;
                                    margin: 20px auto;
                                    background: #ffffff;
                                    border-radius: 10px;
                                    overflow: hidden;
                                    box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
                                }
                                .header {
                                    background: linear-gradient(135deg, #11998e 0%%, #38ef7d 100%%);
                                    color: white;
                                    padding: 30px 20px;
                                    text-align: center;
                                }
                                .header h1 {
                                    margin: 0;
                                    font-size: 28px;
                                }
                                .content {
                                    padding: 40px 30px;
                                }
                                .alert-box {
                                    background: #e8f5e9;
                                    border-left: 4px solid #11998e;
                                    padding: 20px;
                                    margin: 20px 0;
                                    border-radius: 4px;
                                }
                                .info-table {
                                    width: 100%%;
                                    margin: 20px 0;
                                    border-collapse: collapse;
                                }
                                .info-table td {
                                    padding: 12px;
                                    border-bottom: 1px solid #eee;
                                }
                                .info-table td:first-child {
                                    font-weight: bold;
                                    width: 140px;
                                    color: #666;
                                }
                                .security-note {
                                    background: #fff3cd;
                                    border: 1px solid #ffc107;
                                    padding: 15px;
                                    border-radius: 4px;
                                    margin: 20px 0;
                                }
                                .footer {
                                    background: #f8f9fa;
                                    padding: 20px;
                                    text-align: center;
                                    color: #666;
                                    font-size: 14px;
                                }
                            </style>
                        </head>
                        <body>
                            <div class="container">
                                <div class="header">
                                    <h1>🔐 Login Notification</h1>
                                </div>
                                <div class="content">
                                    <h2>Hello %s! 👋</h2>
                                    <div class="alert-box">
                                        <p><strong>New login detected</strong> to your Smart Academy account.</p>
                                    </div>

                                    <p>We detected a new sign-in to your account. Here are the details:</p>

                                    <table class="info-table">
                                        <tr>
                                            <td>📅 Date & Time:</td>
                                            <td>%s</td>
                                        </tr>
                                        <tr>
                                            <td>🌐 IP Address:</td>
                                            <td>%s</td>
                                        </tr>
                                        <tr>
                                            <td>💻 Device:</td>
                                            <td>%s</td>
                                        </tr>
                                    </table>

                                    <div class="security-note">
                                        <p><strong>⚠️ Security Notice:</strong></p>
                                        <p>If this was you, you can safely ignore this email. If you don't recognize this login, please secure your account immediately by changing your password.</p>
                                    </div>

                                    <p>Stay safe and happy learning! 🚀</p>
                                </div>
                                <div class="footer">
                                    <p>&copy; 2025 Smart Academy. All rights reserved.</p>
                                    <p>This is an automated security notification.</p>
                                </div>
                            </div>
                        </body>
                        </html>
                        """,
                firstName, loginTime, ip, device);
    }

    private String extractDeviceInfo(String userAgent) {
        if (userAgent == null || userAgent.isEmpty()) {
            return "Unknown Device";
        }

        // Simple user agent parsing
        if (userAgent.contains("Mobile")) {
            if (userAgent.contains("Android")) {
                return "Android Mobile";
            } else if (userAgent.contains("iPhone") || userAgent.contains("iPad")) {
                return "iOS Device";
            }
            return "Mobile Device";
        } else if (userAgent.contains("Windows")) {
            return "Windows Computer";
        } else if (userAgent.contains("Mac")) {
            return "Mac Computer";
        } else if (userAgent.contains("Linux")) {
            return "Linux Computer";
        }

        return "Web Browser";
    }

    @Override
    @Async
    public void sendVerificationEmail(String to, String firstName, String otpCode) {
        try {
            MimeMessage message = mailSender.createMimeMessage();
            MimeMessageHelper helper = new MimeMessageHelper(message, true, "UTF-8");

            helper.setFrom(fromEmail, fromName);
            helper.setTo(to);
            helper.setSubject("Verify Your Email - Smart Academy ✉️");

            String htmlContent = buildVerificationEmailTemplate(firstName, otpCode);
            helper.setText(htmlContent, true);

            mailSender.send(message);
            log.info("Verification email sent successfully to: {}", to);
        } catch (MessagingException e) {
            log.error("Failed to send verification email to: {}. Error: {}", to, e.getMessage());
        } catch (Exception e) {
            log.error("Unexpected error sending verification email to: {}. Error: {}", to, e.getMessage());
        }
    }

    private String buildVerificationEmailTemplate(String firstName, String otpCode) {
        return String.format(
                """
                        <!DOCTYPE html>
                        <html>
                        <head>
                            <meta charset="UTF-8">
                            <meta name="viewport" content="width=device-width, initial-scale=1.0">
                            <style>
                                body {
                                    font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
                                    line-height: 1.6;
                                    color: #333;
                                    margin: 0;
                                    padding: 0;
                                    background-color: #f4f4f4;
                                }
                                .container {
                                    max-width: 600px;
                                    margin: 20px auto;
                                    background: #ffffff;
                                    border-radius: 10px;
                                    overflow: hidden;
                                    box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
                                }
                                .header {
                                    background: linear-gradient(135deg, #667eea 0%%, #764ba2 100%%);
                                    color: white;
                                    padding: 40px 20px;
                                    text-align: center;
                                }
                                .header h1 {
                                    margin: 0;
                                    font-size: 32px;
                                }
                                .content {
                                    padding: 40px 30px;
                                }
                                .otp-box {
                                    background: linear-gradient(135deg, #667eea 0%%, #764ba2 100%%);
                                    color: white;
                                    padding: 30px;
                                    margin: 30px 0;
                                    border-radius: 10px;
                                    text-align: center;
                                }
                                .otp-code {
                                    font-size: 48px;
                                    font-weight: bold;
                                    letter-spacing: 8px;
                                    margin: 20px 0;
                                    display: inline-block;
                                    padding: 15px 30px;
                                    background: white;
                                    color: black;
                                    border-radius: 8px;
                                }
                                .expiry-notice {
                                    background: #fff3cd;
                                    border-left: 4px solid #ffc107;
                                    padding: 15px;
                                    margin: 20px 0;
                                    border-radius: 4px;
                                }
                                .security-tips {
                                    background: #f8f9fa;
                                    padding: 20px;
                                    margin: 20px 0;
                                    border-radius: 4px;
                                }
                                .security-tips ul {
                                    margin: 10px 0;
                                    padding-left: 20px;
                                }
                                .security-tips li {
                                    margin: 8px 0;
                                }
                                .footer {
                                    background: #f8f9fa;
                                    padding: 20px;
                                    text-align: center;
                                    color: #666;
                                    font-size: 14px;
                                }
                            </style>
                        </head>
                        <body>
                            <div class="container">
                                <div class="header">
                                    <h1>📧 Email Verification</h1>
                                    <p>Confirm your account</p>
                                </div>
                                <div class="content">
                                    <h2>Hello %s! 👋</h2>
                                    <p>Thank you for registering with Smart Academy! To complete your registration, please verify your email address using the code below:</p>

                                    <div class="otp-box">
                                        <p style="margin: 0; font-size: 18px;">Your Verification Code</p>
                                        <div class="otp-code">%s</div>
                                        <p style="margin: 0; font-size: 14px; opacity: 0.9;">Enter this code to verify your account</p>
                                    </div>

                                    <div class="expiry-notice">
                                        <p style="margin: 0;"><strong>⏰ Time Sensitive!</strong></p>
                                        <p style="margin: 5px 0 0 0;">This code will expire in <strong>10 minutes</strong>. Please verify your email soon!</p>
                                    </div>

                                    <div class="security-tips">
                                        <h3 style="margin-top: 0; color: #667eea;">🔒 Security Tips:</h3>
                                        <ul>
                                            <li>Never share this code with anyone</li>
                                            <li>Smart Academy will never ask for this code via phone or email</li>
                                            <li>If you didn't request this code, please ignore this email</li>
                                        </ul>
                                    </div>

                                    <p>If you have any questions or need assistance, our support team is here to help!</p>

                                    <p>Best regards,<br>The Smart Academy Team 🚀</p>
                                </div>
                                <div class="footer">
                                    <p>&copy; 2025 Smart Academy. All rights reserved.</p>
                                    <p>This is an automated message. Please do not reply to this email.</p>
                                </div>
                            </div>
                        </body>
                        </html>
                        """,
                firstName, otpCode);
    }

    @Override
    @Async
    public void sendPasswordResetEmail(String to, String firstName, String otpCode) {
        try {
            MimeMessage message = mailSender.createMimeMessage();
            MimeMessageHelper helper = new MimeMessageHelper(message, true, "UTF-8");

            helper.setFrom(fromEmail, fromName);
            helper.setTo(to);
            helper.setSubject("Reset Your Password - Smart Academy 🔒");

            String htmlContent = buildPasswordResetEmailTemplate(firstName, otpCode);
            helper.setText(htmlContent, true);

            mailSender.send(message);
            log.info("Password reset email sent successfully to: {}", to);
        } catch (MessagingException e) {
            log.error("Failed to send password reset email to: {}. Error: {}", to, e.getMessage());
        } catch (Exception e) {
            log.error("Unexpected error sending password reset email to: {}. Error: {}", to, e.getMessage());
        }
    }

    private String buildPasswordResetEmailTemplate(String firstName, String otpCode) {
        return String.format(
                """
                        <!DOCTYPE html>
                        <html>
                        <head>
                            <meta charset="UTF-8">
                            <meta name="viewport" content="width=device-width, initial-scale=1.0">
                            <style>
                                body {
                                    font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
                                    line-height: 1.6;
                                    color: #333;
                                    margin: 0;
                                    padding: 0;
                                    background-color: #f4f4f4;
                                }
                                .container {
                                    max-width: 600px;
                                    margin: 20px auto;
                                    background: #ffffff;
                                    border-radius: 10px;
                                    overflow: hidden;
                                    box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
                                }
                                .header {
                                    background: linear-gradient(135deg, #f093fb 0%%, #f5576c 100%%);
                                    color: white;
                                    padding: 40px 20px;
                                    text-align: center;
                                }
                                .header h1 {
                                    margin: 0;
                                    font-size: 32px;
                                }
                                .content {
                                    padding: 40px 30px;
                                }
                                .otp-box {
                                    background: linear-gradient(135deg, #f093fb 0%%, #f5576c 100%%);
                                    color: white;
                                    padding: 30px;
                                    margin: 30px 0;
                                    border-radius: 10px;
                                    text-align: center;
                                }
                                .otp-code {
                                    font-size: 48px;
                                    font-weight: bold;
                                    letter-spacing: 8px;
                                    margin: 20px 0;
                                    display: inline-block;
                                    padding: 15px 30px;
                                    background: white;
                                    color: black;
                                    border-radius: 8px;
                                }
                                .warning-box {
                                    background: #fff3cd;
                                    border-left: 4px solid #ffc107;
                                    padding: 15px;
                                    margin: 20px 0;
                                    border-radius: 4px;
                                }
                                .security-tips {
                                    background: #f8f9fa;
                                    padding: 20px;
                                    margin: 20px 0;
                                    border-radius: 4px;
                                }
                                .security-tips ul {
                                    margin: 10px 0;
                                    padding-left: 20px;
                                }
                                .security-tips li {
                                    margin: 8px 0;
                                }
                                .footer {
                                    background: #f8f9fa;
                                    padding: 20px;
                                    text-align: center;
                                    color: #666;
                                    font-size: 14px;
                                }
                            </style>
                        </head>
                        <body>
                            <div class="container">
                                <div class="header">
                                    <h1>🔒 Password Reset</h1>
                                    <p>Secure your account</p>
                                </div>
                                <div class="content">
                                    <h2>Hello %s! 👋</h2>
                                    <p>We received a request to reset your password for your Smart Academy account. Use the code below to reset your password:</p>

                                    <div class="otp-box">
                                        <p style="margin: 0; font-size: 18px;">Your Password Reset Code</p>
                                        <div class="otp-code">%s</div>
                                        <p style="margin: 0; font-size: 14px; opacity: 0.9;">Enter this code to reset your password</p>
                                    </div>

                                    <div class="warning-box">
                                        <p style="margin: 0;"><strong>⏰ Time Sensitive!</strong></p>
                                        <p style="margin: 5px 0 0 0;">This code will expire in <strong>10 minutes</strong>. Please reset your password soon!</p>
                                    </div>

                                    <div class="security-tips">
                                        <h3 style="margin-top: 0; color: #f5576c;">🔒 Security Tips:</h3>
                                        <ul>
                                            <li>Never share this code with anyone</li>
                                            <li>If you didn't request this reset, please ignore this email</li>
                                            <li>Your password won't change until you complete the reset process</li>
                                            <li>Contact support if you have concerns about your account security</li>
                                        </ul>
                                    </div>

                                    <p><strong>Didn't request this?</strong> If you didn't ask to reset your password, you can safely ignore this email. Your password will remain unchanged.</p>

                                    <p>Best regards,<br>The Smart Academy Team 🚀</p>
                                </div>
                                <div class="footer">
                                    <p>&copy; 2025 Smart Academy. All rights reserved.</p>
                                    <p>This is an automated security message.</p>
                                </div>
                            </div>
                        </body>
                        </html>
                        """,
                firstName, otpCode);
    }
}
