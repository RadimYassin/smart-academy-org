import { describe, it, expect, vi, beforeEach } from 'vitest';
import { authApi } from '../authApi';
import { tokenManager } from '../apiClient';
import * as apiClient from '../apiClient';

// Mock the apiClient
vi.mock('../apiClient', async () => {
    const actual = await vi.importActual('../apiClient');
    return {
        ...actual,
        post: vi.fn(),
        tokenManager: {
            setTokens: vi.fn(),
            getAccessToken: vi.fn(),
            getRefreshToken: vi.fn(),
            clearTokens: vi.fn(),
        },
    };
});

vi.mock('../tokenUtils', () => ({
    decodeAccessToken: vi.fn((token) => ({
        id: 1,
        email: 'test@example.com',
        role: 'TEACHER',
    })),
}));

describe('authApi', () => {
    beforeEach(() => {
        vi.clearAllMocks();
    });

    describe('login', () => {
        it('successfully logs in and saves tokens', async () => {
            const mockResponse = {
                access_token: 'mock-access-token',
                refresh_token: 'mock-refresh-token',
                token_type: 'Bearer',
            };

            vi.mocked(apiClient.post).mockResolvedValueOnce(mockResponse);

            const credentials = {
                email: 'test@example.com',
                password: 'password123',
            };

            const result = await authApi.login(credentials);

            expect(apiClient.post).toHaveBeenCalledWith(
                expect.stringContaining('/login'),
                credentials
            );

            expect(tokenManager.setTokens).toHaveBeenCalledWith(
                'mock-access-token',
                'mock-refresh-token'
            );

            expect(result).toHaveProperty('access_token');
            expect(result).toHaveProperty('decodedUser');
        });

        it('handles login failure', async () => {
            vi.mocked(apiClient.post).mockRejectedValueOnce(
                new Error('Invalid credentials')
            );

            const credentials = {
                email: 'wrong@example.com',
                password: 'wrongpass',
            };

            await expect(authApi.login(credentials)).rejects.toThrow('Invalid credentials');
        });

        it('handles missing tokens in response', async () => {
            const mockResponse = {
                access_token: '',
                refresh_token: '',
                token_type: 'Bearer',
            };

            vi.mocked(apiClient.post).mockResolvedValueOnce(mockResponse);

            const credentials = {
                email: 'test@example.com',
                password: 'password123',
            };

            const result = await authApi.login(credentials);

            expect(tokenManager.setTokens).not.toHaveBeenCalled();
            expect(result).not.toHaveProperty('decodedUser');
        });
    });

    describe('register', () => {
        it('successfully registers a new user', async () => {
            const mockResponse = {
                access_token: 'mock-access-token',
                refresh_token: 'mock-refresh-token',
                token_type: 'Bearer',
            };

            vi.mocked(apiClient.post).mockResolvedValueOnce(mockResponse);

            const userData = {
                firstName: 'John',
                lastName: 'Doe',
                email: 'john@example.com',
                password: 'password123',
                role: 'TEACHER' as const,
            };

            const result = await authApi.register(userData);

            expect(apiClient.post).toHaveBeenCalledWith(
                expect.stringContaining('/register'),
                userData
            );

            expect(tokenManager.setTokens).toHaveBeenCalledWith(
                'mock-access-token',
                'mock-refresh-token'
            );

            expect(result).toEqual(mockResponse);
        });

        it('handles registration without tokens', async () => {
            const mockResponse = {
                access_token: '',
                refresh_token: '',
                token_type: 'Bearer',
            };

            vi.mocked(apiClient.post).mockResolvedValueOnce(mockResponse);

            const userData = {
                firstName: 'John',
                lastName: 'Doe',
                email: 'john@example.com',
                password: 'password123',
                role: 'TEACHER' as const,
            };

            await authApi.register(userData);

            expect(tokenManager.setTokens).not.toHaveBeenCalled();
        });
    });

    describe('refreshToken', () => {
        it('refreshes the access token', async () => {
            const mockResponse = {
                access_token: 'new-access-token',
                token_type: 'Bearer',
            };

            vi.mocked(apiClient.post).mockResolvedValueOnce(mockResponse);

            const result = await authApi.refreshToken('old-refresh-token');

            expect(apiClient.post).toHaveBeenCalledWith(
                expect.stringContaining('/refresh-token'),
                { refreshToken: 'old-refresh-token' }
            );

            expect(result).toEqual(mockResponse);
        });
    });

    describe('logout', () => {
        it('clears tokens from localStorage', async () => {
            const removeItemSpy = vi.spyOn(Storage.prototype, 'removeItem');

            await authApi.logout();

            expect(removeItemSpy).toHaveBeenCalledWith('accessToken');
            expect(removeItemSpy).toHaveBeenCalledWith('refreshToken');

            removeItemSpy.mockRestore();
        });
    });
});
