package radim.ma.service.impl;

import jakarta.mail.internet.MimeMessage;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.test.util.ReflectionTestUtils;

import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class EmailServiceImplTest {

    @Mock
    private JavaMailSender mailSender;

    @InjectMocks
    private EmailServiceImpl emailService;

    @BeforeEach
    void setUp() {
        ReflectionTestUtils.setField(emailService, "fromEmail", "no-reply@smartacademy.org");
        ReflectionTestUtils.setField(emailService, "fromName", "Smart Academy");
    }

    @Test
    void sendWelcomeEmail_ShouldSucceed() {
        // Arrange
        MimeMessage mimeMessage = mock(MimeMessage.class);
        when(mailSender.createMimeMessage()).thenReturn(mimeMessage);

        // Act
        emailService.sendWelcomeEmail("test@example.com", "John", "Doe");

        // Assert
        verify(mailSender).send(any(MimeMessage.class));
    }

    @Test
    void sendLoginNotificationEmail_ShouldSucceed() {
        // Arrange
        MimeMessage mimeMessage = mock(MimeMessage.class);
        when(mailSender.createMimeMessage()).thenReturn(mimeMessage);

        // Act
        emailService.sendLoginNotificationEmail("test@example.com", "John", "127.0.0.1", "Mozilla/5.0");

        // Assert
        verify(mailSender).send(any(MimeMessage.class));
    }

    @Test
    void sendVerificationEmail_ShouldSucceed() {
        // Arrange
        MimeMessage mimeMessage = mock(MimeMessage.class);
        when(mailSender.createMimeMessage()).thenReturn(mimeMessage);

        // Act
        emailService.sendVerificationEmail("test@example.com", "John", "123456");

        // Assert
        verify(mailSender).send(any(MimeMessage.class));
    }

    @Test
    void sendPasswordResetEmail_ShouldSucceed() {
        // Arrange
        MimeMessage mimeMessage = mock(MimeMessage.class);
        when(mailSender.createMimeMessage()).thenReturn(mimeMessage);

        // Act
        emailService.sendPasswordResetEmail("test@example.com", "John", "123456");

        // Assert
        verify(mailSender).send(any(MimeMessage.class));
    }
}
