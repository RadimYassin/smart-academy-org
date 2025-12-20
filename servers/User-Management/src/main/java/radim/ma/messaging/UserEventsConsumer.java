package radim.ma.messaging;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.amqp.rabbit.annotation.RabbitListener;
import org.springframework.stereotype.Component;
import radim.ma.events.UserCreatedEvent;
import radim.ma.service.EmailService;

@Component

@RequiredArgsConstructor

@Slf4j

public class UserEventsConsumer {

    private final EmailService emailService;

    /**
     * Listen to user.created events from RabbitMQ
     * and send emails using existing EmailService
     */
    @RabbitListener(queues = "user-events")
    public void handleUserCreated(UserCreatedEvent event) {
        try {
            log.info("📨 Received user.created event for: {}", event.getEmail());

            // Send verification email using existing EmailService
            emailService.sendVerificationEmail(
                    event.getEmail(),
                    event.getFirstName(),
                    event.getOtpCode());

            // Send welcome email using existing EmailService
            emailService.sendWelcomeEmail(
                    event.getEmail(),
                    event.getFirstName(),
                    event.getLastName());

            log.info("✅ Emails sent successfully to: {}", event.getEmail());

        } catch (Exception e) {
            log.error("❌ Failed to process user.created event for: {}. Error: {}",
                    event.getEmail(), e.getMessage());
            // Exception will cause message to be requeued (if configured)
            throw e;
        }
    }
}
