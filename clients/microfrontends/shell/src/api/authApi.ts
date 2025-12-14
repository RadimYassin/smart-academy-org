/**
 * Authentication API Service
 * 
 * Handles all authentication-related API calls
 */

import { post, tokenManager } from './apiClient';
import { ENDPOINTS } from './services';
import { decodeAccessToken } from './tokenUtils';
import type {
    LoginRequest,
    RegisterRequest,
    AuthResponse,
    RefreshTokenRequest,
    RefreshTokenResponse,
} from './types';

// ============================================================================
// Authentication API
// ============================================================================

export const authApi = {
    /**
     * Login user
     */
    login: async (credentials: LoginRequest): Promise<AuthResponse & { decodedUser?: any }> => {
        console.log('[AuthAPI] Login called with email:', credentials.email);

        const response = await post<AuthResponse, LoginRequest>(
            ENDPOINTS.AUTH.LOGIN,
            credentials
        );

        console.log('[AuthAPI] Login response received:', {
            hasAccessToken: !!response.access_token,
            hasRefreshToken: !!response.refresh_token,
            tokenLength: response.access_token?.length,
        });

        // Save tokens to cookies
        if (response.access_token && response.refresh_token) {
            console.log('[AuthAPI] Saving tokens to cookies...');
            tokenManager.setTokens(response.access_token, response.refresh_token);
            console.log('[AuthAPI] Tokens saved successfully');

            // Decode token to extract user info
            const decodedUser = decodeAccessToken(response.access_token);
            console.log('[AuthAPI] Decoded user:', decodedUser);

            return {
                ...response,
                decodedUser,
            };
        } else {
            console.error('[AuthAPI] Missing tokens in response!', response);
        }

        return response;
    },

    /**
     * Register new user (Teacher)
     */
    register: async (userData: RegisterRequest): Promise<AuthResponse> => {
        console.log('[AuthAPI] Register called');

        const response = await post<AuthResponse, RegisterRequest>(
            ENDPOINTS.AUTH.REGISTER,
            userData
        );

        console.log('[AuthAPI] Register response:', {
            hasAccessToken: !!response.access_token,
            hasRefreshToken: !!response.refresh_token,
        });

        // Save tokens to cookies if provided (some APIs don't return tokens on register)
        if (response.access_token && response.refresh_token) {
            console.log('[AuthAPI] Saving registration tokens...');
            tokenManager.setTokens(response.access_token, response.refresh_token);
        }

        return response;
    },

    /**
     * Refresh access token
     * Note: This is handled automatically by the API client interceptor,
     * but can be called manually if needed
     */
    refreshToken: async (refreshToken: string): Promise<RefreshTokenResponse> => {
        return post<RefreshTokenResponse, RefreshTokenRequest>(
            ENDPOINTS.AUTH.REFRESH_TOKEN,
            { refreshToken }
        );
    },

    /**
     * Logout user (if backend has logout endpoint)
     */
    logout: async (): Promise<void> => {
        // If your backend has a logout endpoint, uncomment:
        // return post(ENDPOINTS.AUTH.LOGOUT);

        // For now, just clear local storage
        localStorage.removeItem('accessToken');
        localStorage.removeItem('refreshToken');
    },

    /**
     * Verify email with verification code
     */
    verifyEmail: async (email: string, code: string): Promise<AuthResponse> => {
        return post<AuthResponse>(`${ENDPOINTS.AUTH.BASE}/verify-email`, {
            email,
            code,
        });
    },

    /**
     * Resend verification code
     */
    resendVerificationCode: async (email: string): Promise<void> => {
        return post(`${ENDPOINTS.AUTH.BASE}/resend-otp`, {
            email,
        });
    },

    /**
     * Request password reset - sends code to email
     */
    forgotPassword: async (email: string): Promise<void> => {
        return post(`${ENDPOINTS.AUTH.BASE}/forgot-password`, {
            email,
        });
    },

    /**
     * Reset password with code
     */
    resetPassword: async (email: string, code: string, newPassword: string): Promise<void> => {
        return post(`${ENDPOINTS.AUTH.BASE}/reset-password`, {
            email,
            code,
            newPassword,
        });
    },
};
