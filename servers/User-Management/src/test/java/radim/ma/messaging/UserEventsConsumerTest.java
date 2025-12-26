package radim.ma.messaging;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import radim.ma.events.UserCreatedEvent;
import radim.ma.service.EmailService;

import java.time.LocalDateTime;

import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class UserEventsConsumerTest {

    @Mock
    private EmailService emailService;

    @InjectMocks
    private UserEventsConsumer userEventsConsumer;

    private UserCreatedEvent event;

    @BeforeEach
    void setUp() {
        event = UserCreatedEvent.builder()
                .userId(1L)
                .email("test@example.com")
                .firstName("John")
                .lastName("Doe")
                .otpCode("123456")
                .timestamp(LocalDateTime.now())
                .build();
    }

    @Test
    void testHandleUserCreated_ValidEvent_SendsEmails() {
        // Given
        doNothing().when(emailService).sendVerificationEmail(anyString(), anyString(), anyString());
        doNothing().when(emailService).sendWelcomeEmail(anyString(), anyString(), anyString());

        // When
        userEventsConsumer.handleUserCreated(event);

        // Then
        verify(emailService).sendVerificationEmail("test@example.com", "John", "123456");
        verify(emailService).sendWelcomeEmail("test@example.com", "John", "Doe");
    }

    @Test
    void testHandleUserCreated_EmailFailure_LogsErrorAndThrows() {
        // Given
        doThrow(new RuntimeException("Email service unavailable"))
                .when(emailService).sendVerificationEmail(anyString(), anyString(), anyString());

        // When & Then
        assertThatThrownBy(() -> userEventsConsumer.handleUserCreated(event))
                .isInstanceOf(RuntimeException.class)
                .hasMessage("Email service unavailable");

        verify(emailService).sendVerificationEmail("test@example.com", "John", "123456");
        verify(emailService, never()).sendWelcomeEmail(anyString(), anyString(), anyString());
    }

    @Test
    void testHandleUserCreated_WelcomeEmailFailure_LogsErrorAndThrows() {
        // Given
        doNothing().when(emailService).sendVerificationEmail(anyString(), anyString(), anyString());
        doThrow(new RuntimeException("Welcome email failed"))
                .when(emailService).sendWelcomeEmail(anyString(), anyString(), anyString());

        // When & Then
        assertThatThrownBy(() -> userEventsConsumer.handleUserCreated(event))
                .isInstanceOf(RuntimeException.class)
                .hasMessage("Welcome email failed");

        verify(emailService).sendVerificationEmail("test@example.com", "John", "123456");
        verify(emailService).sendWelcomeEmail("test@example.com", "John", "Doe");
    }

    @Test
    void testHandleUserCreated_InvalidEvent_HandlesGracefully() {
        // Given
        UserCreatedEvent invalidEvent = UserCreatedEvent.builder()
                .userId(null)
                .email(null)
                .firstName(null)
                .lastName(null)
                .otpCode(null)
                .timestamp(LocalDateTime.now())
                .build();

        doNothing().when(emailService).sendVerificationEmail(any(), any(), any());
        doNothing().when(emailService).sendWelcomeEmail(any(), any(), any());

        // When
        userEventsConsumer.handleUserCreated(invalidEvent);

        // Then
        verify(emailService).sendVerificationEmail(null, null, null);
        verify(emailService).sendWelcomeEmail(null, null, null);
    }

    @Test
    void testHandleUserCreated_MultipleEvents_ProcessesAll() {
        // Given
        UserCreatedEvent event1 = UserCreatedEvent.builder()
                .userId(1L)
                .email("user1@example.com")
                .firstName("User")
                .lastName("One")
                .otpCode("111111")
                .timestamp(LocalDateTime.now())
                .build();

        UserCreatedEvent event2 = UserCreatedEvent.builder()
                .userId(2L)
                .email("user2@example.com")
                .firstName("User")
                .lastName("Two")
                .otpCode("222222")
                .timestamp(LocalDateTime.now())
                .build();

        doNothing().when(emailService).sendVerificationEmail(anyString(), anyString(), anyString());
        doNothing().when(emailService).sendWelcomeEmail(anyString(), anyString(), anyString());

        // When
        userEventsConsumer.handleUserCreated(event1);
        userEventsConsumer.handleUserCreated(event2);

        // Then
        verify(emailService).sendVerificationEmail("user1@example.com", "User", "111111");
        verify(emailService).sendWelcomeEmail("user1@example.com", "User", "One");
        verify(emailService).sendVerificationEmail("user2@example.com", "User", "222222");
        verify(emailService).sendWelcomeEmail("user2@example.com", "User", "Two");
    }

    @Test
    void testHandleUserCreated_EmptyOtpCode_SendsEmailWithEmptyCode() {
        // Given
        event.setOtpCode("");
        doNothing().when(emailService).sendVerificationEmail(anyString(), anyString(), anyString());
        doNothing().when(emailService).sendWelcomeEmail(anyString(), anyString(), anyString());

        // When
        userEventsConsumer.handleUserCreated(event);

        // Then
        verify(emailService).sendVerificationEmail("test@example.com", "John", "");
        verify(emailService).sendWelcomeEmail("test@example.com", "John", "Doe");
    }
}
