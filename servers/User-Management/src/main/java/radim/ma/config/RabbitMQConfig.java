package radim.ma.config;

import org.springframework.amqp.core.*;
import org.springframework.amqp.rabbit.connection.ConnectionFactory;
import org.springframework.amqp.rabbit.core.RabbitTemplate;
import org.springframework.amqp.support.converter.Jackson2JsonMessageConverter;
import org.springframework.amqp.support.converter.MessageConverter;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class RabbitMQConfig {

    // Exchange name
    public static final String EVENTS_EXCHANGE = "smart-academy.events";
    public static final String EMAIL_EXCHANGE = "smart-academy.email";

    // Routing keys
    public static final String USER_CREATED_ROUTING_KEY = "user.created";
    public static final String EMAIL_VERIFICATION_ROUTING_KEY = "email.verification";

    // Queues
    public static final String USER_EVENTS_QUEUE = "user-events";
    public static final String EMAIL_QUEUE = "email-queue";

    /**
     * Topic Exchange for events
     */
    @Bean
    public TopicExchange eventsExchange() {
        return new TopicExchange(EVENTS_EXCHANGE);
    }

    /**
     * Direct Exchange for emails
     */
    @Bean
    public DirectExchange emailExchange() {
        return new DirectExchange(EMAIL_EXCHANGE);
    }

    /**
     * Queue for user events
     */
    @Bean
    public Queue userEventsQueue() {
        return QueueBuilder.durable(USER_EVENTS_QUEUE)
                .withArgument("x-message-ttl", 86400000) // 24 hours
                .build();
    }

    /**
     * Queue for emails
     */
    @Bean
    public Queue emailQueue() {
        return QueueBuilder.durable(EMAIL_QUEUE)
                .build();
    }

    /**
     * Binding user events queue to events exchange
     */
    @Bean
    public Binding userEventsBinding() {
        return BindingBuilder
                .bind(userEventsQueue())
                .to(eventsExchange())
                .with("user.*"); // Match user.created, user.updated, etc.
    }

    /**
     * Binding email queue to email exchange
     */
    @Bean
    public Binding emailBinding() {
        return BindingBuilder
                .bind(emailQueue())
                .to(emailExchange())
                .with(EMAIL_VERIFICATION_ROUTING_KEY);
    }

    /**
     * JSON Message Converter
     */
    @Bean
    public MessageConverter jsonMessageConverter() {
        return new Jackson2JsonMessageConverter();
    }

    /**
     * RabbitTemplate with JSON converter
     */
    @Bean
    public RabbitTemplate rabbitTemplate(ConnectionFactory connectionFactory) {
        RabbitTemplate rabbitTemplate = new RabbitTemplate(connectionFactory);
        rabbitTemplate.setMessageConverter(jsonMessageConverter());
        return rabbitTemplate;
    }
}
