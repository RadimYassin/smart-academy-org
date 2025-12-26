package radim.ma.config;

import org.springframework.boot.test.context.TestConfiguration;
import org.springframework.context.annotation.Bean;
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.web.SecurityFilterChain;

@TestConfiguration
@EnableWebSecurity
@EnableMethodSecurity
public class TestSecurityConfig {

    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http.csrf(csrf -> csrf.disable())
                .authorizeHttpRequests(auth -> auth
                        .requestMatchers("/api/credits/balance", "/api/credits/deduct", "/api/credits/reward/**")
                        .hasAnyRole("STUDENT", "TEACHER", "ADMIN")
                        .requestMatchers("/api/credits/**").hasAnyRole("TEACHER", "ADMIN")
                        .anyRequest().permitAll());
        return http.build();
    }
}
