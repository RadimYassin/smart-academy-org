import { Module } from '@nestjs/common';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { JwtModule } from '@nestjs/jwt';
import { PassportModule } from '@nestjs/passport';
import { JwtStrategy } from './jwt.strategy';

/**
 * Authentication Module
 * Provides JWT authentication functionality shared across all microservices
 */
@Module({
    imports: [
        PassportModule.register({ defaultStrategy: 'jwt' }),
        JwtModule.registerAsync({
            imports: [ConfigModule],
            useFactory: async (configService: ConfigService) => {
                const expiresInMs = configService.get<number>('jwt.expiresIn') || 86400000;
                // Convert milliseconds to seconds for JWT
                const expiresInSeconds = Math.floor(expiresInMs / 1000);

                return {
                    secret: configService.get<string>('jwt.secret'),
                    signOptions: {
                        expiresIn: `${expiresInSeconds}s`,
                    },
                };
            },
            inject: [ConfigService],
        }),
    ],
    providers: [JwtStrategy],
    exports: [JwtModule, PassportModule],
})
export class AuthModule { }
