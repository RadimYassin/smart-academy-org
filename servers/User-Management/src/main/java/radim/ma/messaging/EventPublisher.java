package radim.ma.messaging;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.amqp.rabbit.core.RabbitTemplate;
import org.springframework.stereotype.Service;
import radim.ma.config.RabbitMQConfig;
import radim.ma.entities.User;
import radim.ma.events.UserCreatedEvent;

import java.time.LocalDateTime;

@Service
@RequiredArgsConstructor
@Slf4j
public class EventPublisher {

    private final RabbitTemplate rabbitTemplate;

    /**
     * Publish user created event
     * This triggers email sending and other async processes
     */
    public void publishUserCreated(User user, String otpCode) {
        try {
            UserCreatedEvent event = UserCreatedEvent.builder()
                    .userId(user.getId())
                    .email(user.getEmail())
                    .firstName(user.getFirstName())
                    .lastName(user.getLastName())
                    .otpCode(otpCode)
                    .timestamp(LocalDateTime.now())
                    .build();

            rabbitTemplate.convertAndSend(
                    RabbitMQConfig.EVENTS_EXCHANGE,
                    RabbitMQConfig.USER_CREATED_ROUTING_KEY,
                    event);

            log.info("📤 Published user.created event for user: {}", user.getEmail());

        } catch (Exception e) {
            log.error("❌ Failed to publish user.created event for user: {}. Error: {}",
                    user.getEmail(), e.getMessage());
            // Don't throw exception - allow user creation to succeed even if event fails
        }
    }

    /**
     * Publish email verification event
     */
    public void publishEmailVerification(String email, String firstName, String otpCode) {
        try {
            // For now, this is handled by user.created event
            // Can be separated later for more granular control
            log.debug("Email verification will be sent via user.created event");

        } catch (Exception e) {
            log.error("❌ Failed to publish email verification event: {}", e.getMessage());
        }
    }
}
