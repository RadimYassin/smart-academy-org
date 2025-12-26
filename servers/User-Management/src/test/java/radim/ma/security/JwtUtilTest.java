package radim.ma.security;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
// Removed unused import
import io.jsonwebtoken.io.Decoders;
import io.jsonwebtoken.security.Keys;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.User;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.test.util.ReflectionTestUtils;

import java.security.Key;
import java.util.*;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

@ExtendWith(MockitoExtension.class)
class JwtUtilTest {

    @InjectMocks
    private JwtUtil jwtUtil;

    private UserDetails userDetails;
    private String secretKey;
    private long jwtExpiration;
    private long refreshExpiration;

    @BeforeEach
    void setUp() {
        // Use a test secret key (base64 encoded, minimum 256 bits for HS256)
        secretKey = "dGVzdC1zZWNyZXQta2V5LWZvci1qd3QtdG9rZW4tdGVzdGluZy1wdXJwb3Nlcy1vbmx5LW1pbmltdW0tMjU2LWJpdHM=";
        jwtExpiration = 3600000; // 1 hour
        refreshExpiration = 86400000; // 24 hours

        // Set private fields using reflection
        ReflectionTestUtils.setField(jwtUtil, "secretKey", secretKey);
        ReflectionTestUtils.setField(jwtUtil, "jwtExpiration", jwtExpiration);
        ReflectionTestUtils.setField(jwtUtil, "refreshExpiration", refreshExpiration);

        // Create test user details
        Collection<GrantedAuthority> authorities = Collections.singletonList(
                new SimpleGrantedAuthority("ROLE_STUDENT"));
        userDetails = new User("test@example.com", "password", authorities);
    }

    @Test
    void testGenerateToken_ValidUserDetails_ReturnsToken() {
        // When
        String token = jwtUtil.generateToken(userDetails);

        // Then
        assertThat(token).isNotNull();
        assertThat(token).isNotEmpty();
        assertThat(token.split("\\.")).hasSize(3); // JWT has 3 parts: header.payload.signature
    }

    @Test
    void testGenerateToken_WithExtraClaims_ReturnsTokenWithClaims() {
        // Given
        Map<String, Object> extraClaims = new HashMap<>();
        extraClaims.put("userId", 123L);
        extraClaims.put("role", "STUDENT");

        // When
        String token = jwtUtil.generateToken(extraClaims, userDetails);

        // Then
        assertThat(token).isNotNull();
        assertThat(token).isNotEmpty();

        // Verify claims are present
        Claims claims = extractAllClaims(token);
        assertThat(claims.get("userId", Integer.class)).isEqualTo(123);
        assertThat(claims.get("role", String.class)).isEqualTo("STUDENT");
    }

    @Test
    void testExtractUsername_ValidToken_ReturnsUsername() {
        // Given
        String token = jwtUtil.generateToken(userDetails);

        // When
        String username = jwtUtil.extractUsername(token);

        // Then
        assertThat(username).isEqualTo("test@example.com");
    }

    @Test
    void testExtractClaim_ValidToken_ReturnsCorrectClaim() {
        // Given
        Map<String, Object> extraClaims = new HashMap<>();
        extraClaims.put("customClaim", "customValue");
        String token = jwtUtil.generateToken(extraClaims, userDetails);

        // When
        String customClaim = jwtUtil.extractClaim(token, claims -> claims.get("customClaim", String.class));

        // Then
        assertThat(customClaim).isEqualTo("customValue");
    }

    @Test
    void testIsTokenValid_ValidToken_ReturnsTrue() {
        // Given
        String token = jwtUtil.generateToken(userDetails);

        // When
        boolean isValid = jwtUtil.isTokenValid(token, userDetails);

        // Then
        assertThat(isValid).isTrue();
    }

    @Test
    void testIsTokenValid_WrongUsername_ReturnsFalse() {
        // Given
        String token = jwtUtil.generateToken(userDetails);

        Collection<GrantedAuthority> authorities = Collections.singletonList(
                new SimpleGrantedAuthority("ROLE_STUDENT"));
        UserDetails differentUser = new User("different@example.com", "password", authorities);

        // When
        boolean isValid = jwtUtil.isTokenValid(token, differentUser);

        // Then
        assertThat(isValid).isFalse();
    }

    @Test
    void testIsTokenValid_ExpiredToken_ReturnsFalse() {
        // Given - Create token with past expiration
        // We need to generate a token that is ALREADY expired.
        // We can do this by setting current time to future in JwtUtil or by using a
        // negative expiration
        // However, Jwts parser throws ExpiredJwtException when parsing.

        ReflectionTestUtils.setField(jwtUtil, "jwtExpiration", -1000L); // Negative = already expired
        String expiredToken = jwtUtil.generateToken(userDetails);

        // Reset to normal expiration for validation logic (though validation checks
        // expiration first)
        ReflectionTestUtils.setField(jwtUtil, "jwtExpiration", jwtExpiration);

        // When
        boolean isValid = false;
        try {
            isValid = jwtUtil.isTokenValid(expiredToken, userDetails);
        } catch (io.jsonwebtoken.ExpiredJwtException e) {
            isValid = false;
        }

        // Then
        assertThat(isValid).isFalse();
    }

    @Test
    void testGenerateRefreshToken_ValidUserDetails_ReturnsToken() {
        // When
        String refreshToken = jwtUtil.generateRefreshToken(userDetails);

        // Then
        assertThat(refreshToken).isNotNull();
        assertThat(refreshToken).isNotEmpty();
        assertThat(refreshToken.split("\\.")).hasSize(3);
    }

    @Test
    void testExtractUsername_InvalidToken_ThrowsException() {
        // Given
        String invalidToken = "invalid.token.here";

        // When & Then
        assertThatThrownBy(() -> jwtUtil.extractUsername(invalidToken))
                .isInstanceOf(Exception.class);
    }

    @Test
    void testExtractUsername_MalformedToken_ThrowsException() {
        // Given
        String malformedToken = "malformed-token-without-proper-structure";

        // When & Then
        assertThatThrownBy(() -> jwtUtil.extractUsername(malformedToken))
                .isInstanceOf(Exception.class);
    }

    @Test
    void testIsTokenValid_NullToken_ThrowsException() {
        // When & Then
        assertThatThrownBy(() -> jwtUtil.isTokenValid(null, userDetails))
                .isInstanceOf(Exception.class);
    }

    @Test
    void testGenerateToken_EmptyExtraClaims_ReturnsValidToken() {
        // Given
        Map<String, Object> emptyClaims = new HashMap<>();

        // When
        String token = jwtUtil.generateToken(emptyClaims, userDetails);

        // Then
        assertThat(token).isNotNull();
        assertThat(jwtUtil.extractUsername(token)).isEqualTo("test@example.com");
    }

    @Test
    void testTokenExpiration_ValidToken_HasCorrectExpiration() {
        // Given
        String token = jwtUtil.generateToken(userDetails);

        // When
        Date expiration = jwtUtil.extractClaim(token, Claims::getExpiration);
        Date issuedAt = jwtUtil.extractClaim(token, Claims::getIssuedAt);

        // Then
        assertThat(expiration).isNotNull();
        assertThat(issuedAt).isNotNull();

        long tokenLifetime = expiration.getTime() - issuedAt.getTime();
        assertThat(tokenLifetime).isCloseTo(jwtExpiration, org.assertj.core.data.Offset.offset(1000L));
    }

    @Test
    void testRefreshTokenExpiration_ValidToken_HasCorrectExpiration() {
        // Given
        String refreshToken = jwtUtil.generateRefreshToken(userDetails);

        // When
        Date expiration = jwtUtil.extractClaim(refreshToken, Claims::getExpiration);
        Date issuedAt = jwtUtil.extractClaim(refreshToken, Claims::getIssuedAt);

        // Then
        assertThat(expiration).isNotNull();
        assertThat(issuedAt).isNotNull();

        long tokenLifetime = expiration.getTime() - issuedAt.getTime();
        assertThat(tokenLifetime).isCloseTo(refreshExpiration, org.assertj.core.data.Offset.offset(1000L));
    }

    // Helper method to extract all claims (mimics private method in JwtUtil)
    private Claims extractAllClaims(String token) {
        byte[] keyBytes = Decoders.BASE64.decode(secretKey);
        Key key = Keys.hmacShaKeyFor(keyBytes);

        return Jwts.parserBuilder()
                .setSigningKey(key)
                .build()
                .parseClaimsJws(token)
                .getBody();
    }
}
