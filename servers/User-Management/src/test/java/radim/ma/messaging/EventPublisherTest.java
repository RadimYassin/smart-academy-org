package radim.ma.messaging;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.amqp.rabbit.core.RabbitTemplate;
import radim.ma.config.RabbitMQConfig;
import radim.ma.entities.User;
import radim.ma.events.UserCreatedEvent;

import java.time.LocalDateTime;

import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class EventPublisherTest {

    @Mock
    private RabbitTemplate rabbitTemplate;

    @InjectMocks
    private EventPublisher eventPublisher;

    private User user;

    @BeforeEach
    void setUp() {
        user = User.builder()
                .id(1L)
                .email("test@example.com")
                .firstName("John")
                .lastName("Doe")
                .build();
    }

    @Test
    void testPublishUserCreated_ValidUser_PublishesEvent() {
        // Given
        String otpCode = "123456";
        doNothing().when(rabbitTemplate).convertAndSend(anyString(), anyString(), any(UserCreatedEvent.class));

        // When
        eventPublisher.publishUserCreated(user, otpCode);

        // Then
        verify(rabbitTemplate).convertAndSend(
                eq(RabbitMQConfig.EVENTS_EXCHANGE),
                eq(RabbitMQConfig.USER_CREATED_ROUTING_KEY),
                argThat((UserCreatedEvent event) -> event.getUserId().equals(1L) &&
                        event.getEmail().equals("test@example.com") &&
                        event.getFirstName().equals("John") &&
                        event.getLastName().equals("Doe") &&
                        event.getOtpCode().equals("123456") &&
                        event.getTimestamp() != null));
    }

    @Test
    void testPublishUserCreated_RabbitMQFailure_LogsErrorButDoesNotThrow() {
        // Given
        String otpCode = "123456";
        doThrow(new RuntimeException("RabbitMQ connection failed"))
                .when(rabbitTemplate).convertAndSend(anyString(), anyString(), any(UserCreatedEvent.class));

        // When - should not throw exception
        eventPublisher.publishUserCreated(user, otpCode);

        // Then
        verify(rabbitTemplate).convertAndSend(
                eq(RabbitMQConfig.EVENTS_EXCHANGE),
                eq(RabbitMQConfig.USER_CREATED_ROUTING_KEY),
                any(UserCreatedEvent.class));
        // Verify that the method completed without throwing
    }

    @Test
    void testPublishUserCreated_NullOtpCode_PublishesEventWithNullOtp() {
        // Given
        doNothing().when(rabbitTemplate).convertAndSend(anyString(), anyString(), any(UserCreatedEvent.class));

        // When
        eventPublisher.publishUserCreated(user, null);

        // Then
        verify(rabbitTemplate).convertAndSend(
                eq(RabbitMQConfig.EVENTS_EXCHANGE),
                eq(RabbitMQConfig.USER_CREATED_ROUTING_KEY),
                argThat((UserCreatedEvent event) -> event.getOtpCode() == null));
    }

    @Test
    void testPublishEmailVerification_ValidData_LogsDebugMessage() {
        // Given
        String email = "test@example.com";
        String firstName = "John";
        String otpCode = "123456";

        // When
        eventPublisher.publishEmailVerification(email, firstName, otpCode);

        // Then
        // This method currently only logs, so we just verify it doesn't throw
        // In the future, if it publishes events, we would verify the RabbitTemplate
        // call
        verifyNoInteractions(rabbitTemplate);
    }

    @Test
    void testPublishUserCreated_UserWithMinimalData_PublishesEvent() {
        // Given
        User minimalUser = User.builder()
                .id(2L)
                .email("minimal@example.com")
                .firstName("Min")
                .lastName("User")
                .build();
        String otpCode = "654321";
        doNothing().when(rabbitTemplate).convertAndSend(anyString(), anyString(), any(UserCreatedEvent.class));

        // When
        eventPublisher.publishUserCreated(minimalUser, otpCode);

        // Then
        verify(rabbitTemplate).convertAndSend(
                eq(RabbitMQConfig.EVENTS_EXCHANGE),
                eq(RabbitMQConfig.USER_CREATED_ROUTING_KEY),
                argThat((UserCreatedEvent event) -> event.getUserId().equals(2L) &&
                        event.getEmail().equals("minimal@example.com") &&
                        event.getFirstName().equals("Min") &&
                        event.getLastName().equals("User")));
    }

    @Test
    void testPublishUserCreated_EventHasTimestamp_TimestampIsRecent() {
        // Given
        String otpCode = "123456";
        LocalDateTime beforePublish = LocalDateTime.now().minusSeconds(1);
        doNothing().when(rabbitTemplate).convertAndSend(anyString(), anyString(), any(UserCreatedEvent.class));

        // When
        eventPublisher.publishUserCreated(user, otpCode);
        LocalDateTime afterPublish = LocalDateTime.now().plusSeconds(1);

        // Then
        verify(rabbitTemplate).convertAndSend(
                eq(RabbitMQConfig.EVENTS_EXCHANGE),
                eq(RabbitMQConfig.USER_CREATED_ROUTING_KEY),
                argThat((UserCreatedEvent event) -> event.getTimestamp().isAfter(beforePublish) &&
                        event.getTimestamp().isBefore(afterPublish)));
    }
}
