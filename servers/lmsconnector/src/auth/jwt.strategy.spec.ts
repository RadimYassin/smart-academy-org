import { Test, TestingModule } from '@nestjs/testing';
import { JwtStrategy } from './jwt.strategy';
import { ConfigService } from '@nestjs/config';
import { UnauthorizedException } from '@nestjs/common';

describe('JwtStrategy', () => {
    let strategy: JwtStrategy;

    beforeEach(async () => {
        const module: TestingModule = await Test.createTestingModule({
            providers: [
                JwtStrategy,
                {
                    provide: ConfigService,
                    useValue: {
                        get: jest.fn().mockReturnValue('test-secret'),
                    },
                },
            ],
        }).compile();

        strategy = module.get<JwtStrategy>(JwtStrategy);
    });

    it('should be defined', () => {
        expect(strategy).toBeDefined();
    });

    describe('validate', () => {
        it('should return user info when payload is valid', async () => {
            const payload = {
                sub: 123,
                username: 'testuser',
                email: 'test@example.com',
                roles: ['admin'],
            };

            const result = await strategy.validate(payload);

            expect(result).toEqual({
                userId: 123,
                username: 'testuser',
                email: 'test@example.com',
                roles: ['admin'],
            });
        });

        it('should default roles to empty array if missing', async () => {
            const payload = {
                sub: 123,
                username: 'testuser',
                email: 'test@example.com',
            };

            const result = await strategy.validate(payload);
            expect(result.roles).toEqual([]);
        });

        it('should throw UnauthorizedException if payload is null', async () => {
            await expect(strategy.validate(null)).rejects.toThrow(UnauthorizedException);
        });
    });
});
