package com.GateWay.GateWay;

import org.springframework.cloud.gateway.route.RouteLocator;
import org.springframework.cloud.gateway.route.builder.RouteLocatorBuilder;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class GatewayConfig {

        @Bean
        public RouteLocator customRouteLocator(RouteLocatorBuilder builder) {
                return builder.routes()
                                // User Management Service
                                .route("user-management", r -> r
                                                .path("/user-management-service/**")
                                                .filters(f -> f.stripPrefix(1))
                                                .uri("http://localhost:8082"))

                                // Course Management Service
                                .route("course-management", r -> r
                                                .path("/course-service/**")
                                                .filters(f -> f.stripPrefix(1))
                                                .uri("http://localhost:8081"))

                                // LMS Connector Service
                                .route("lms-connector", r -> r
                                                .path("/lmsconnector/**")
                                                .filters(f -> f.stripPrefix(1))
                                                .uri("http://localhost:3000"))

                                // Chatbot-edu Service
                                .route("chatbot-edu", r -> r
                                                .path("/chatbot-edu-service/**")
                                                .filters(f -> f.stripPrefix(1))
                                                .uri("http://localhost:8005"))

                                // AI Services
                                // PrepaData Service - Data Preprocessing
                                .route("prepadata-service", r -> r
                                                .path("/prepadata-service/**")
                                                .filters(f -> f.stripPrefix(1))
                                                .uri("http://localhost:8001"))

                                // StudentProfiler Service - Student Clustering
                                .route("studentprofiler-service", r -> r
                                                .path("/studentprofiler-service/**")
                                                .filters(f -> f.stripPrefix(1))
                                                .uri("http://localhost:8002"))

                                // PathPredictor Service - Risk Prediction
                                .route("pathpredictor-service", r -> r
                                                .path("/pathpredictor-service/**")
                                                .filters(f -> f.stripPrefix(1))
                                                .uri("http://localhost:8003"))

                                // RecoBuilder Service - Personalized Recommendations
                                .route("recobuilder-service", r -> r
                                                .path("/recobuilder-service/**")
                                                .filters(f -> f.stripPrefix(1))
                                                .uri("http://localhost:8004"))

                                .build();
        }
}
