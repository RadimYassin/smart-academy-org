import { registerAs } from '@nestjs/config';

/**
 * JWT Configuration
 * Must match the configuration in User-Management and Course-Management services
 * for cross-service token validation
 */
export default registerAs('jwt', () => ({
    // Secret key for JWT signing and verification
    // MUST be the same across all microservices
    secret: process.env.JWT_SECRET || '404E635266556A586E3272357538782F413F4428472B4B6250645367566B5970',

    // Token expiration time in milliseconds (default: 24 hours)
    expiresIn: parseInt(process.env.JWT_EXPIRATION || '86400000', 10),

    // Refresh token expiration time in milliseconds (default: 7 days)
    refreshExpiresIn: parseInt(process.env.JWT_REFRESH_EXPIRATION || '604800000', 10),
}));
