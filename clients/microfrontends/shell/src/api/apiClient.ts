/**
 * API Client - Core Axios Instance with Advanced Interceptors
 * 
 * Features:
 * - Automatic JWT token attachment
 * - Auto-refresh token on 401 errors
 * - Request queuing during token refresh
 * - Global error handling
 * - Type-safe wrapper functions
 */

import axios, { AxiosError, type AxiosInstance, type AxiosRequestConfig, type InternalAxiosRequestConfig } from 'axios';
import Cookies from 'js-cookie';
import { ENDPOINTS } from './services';
import type { RefreshTokenRequest, RefreshTokenResponse } from './types';

// ============================================================================
// Constants
// ============================================================================

const API_BASE_URL = 'http://localhost:8888';
const ACCESS_TOKEN_KEY = 'accessToken';
const REFRESH_TOKEN_KEY = 'refreshToken';

// Cookie options
const COOKIE_OPTIONS = {
    expires: 7, // 7 days
    sameSite: 'strict' as const,
    secure: false, // Set to true in production with HTTPS
};

// ============================================================================
// Token Management Utilities
// ============================================================================

export const tokenManager = {
    getAccessToken: (): string | null => {
        return Cookies.get(ACCESS_TOKEN_KEY) || null;
    },

    getRefreshToken: (): string | null => {
        return Cookies.get(REFRESH_TOKEN_KEY) || null;
    },

    setTokens: (accessToken: string, refreshToken: string): void => {
        Cookies.set(ACCESS_TOKEN_KEY, accessToken, COOKIE_OPTIONS);
        Cookies.set(REFRESH_TOKEN_KEY, refreshToken, COOKIE_OPTIONS);
        console.log('[TokenManager] Tokens saved to cookies');
    },

    clearTokens: (): void => {
        Cookies.remove(ACCESS_TOKEN_KEY);
        Cookies.remove(REFRESH_TOKEN_KEY);
        console.log('[TokenManager] Tokens cleared from cookies');
    },
};

// ============================================================================
// Token Refresh Queue
// ============================================================================

let isRefreshing = false;
let failedQueue: Array<{
    resolve: (value?: unknown) => void;
    reject: (reason?: unknown) => void;
}> = [];

const processQueue = (error: AxiosError | null, token: string | null = null): void => {
    failedQueue.forEach((promise) => {
        if (error) {
            promise.reject(error);
        } else {
            promise.resolve(token);
        }
    });

    failedQueue = [];
};

// ============================================================================
// Axios Instance Configuration
// ============================================================================

const apiClient: AxiosInstance = axios.create({
    baseURL: API_BASE_URL,
    headers: {
        'Content-Type': 'application/json',
    },
    timeout: 30000, // 30 seconds
});

// ============================================================================
// Public Endpoints - Don't require JWT token
// ============================================================================

const PUBLIC_ENDPOINTS = [
    '/api/v1/auth/login',
    '/api/v1/auth/register',
    '/api/v1/auth/forgot-password',
    '/api/v1/auth/reset-password',
    '/api/v1/auth/verify-email',
    '/api/v1/auth/resend-otp',
    '/api/v1/auth/refresh-token', // Refresh token endpoint doesn't use Bearer token
];

const isPublicEndpoint = (url: string | undefined): boolean => {
    if (!url) return false;
    return PUBLIC_ENDPOINTS.some(endpoint => url.includes(endpoint));
};

// ============================================================================
// Request Interceptor - Attach JWT Token (only for protected endpoints)
// ============================================================================

apiClient.interceptors.request.use(
    (config: InternalAxiosRequestConfig) => {
        // Only add token for protected endpoints
        if (!isPublicEndpoint(config.url)) {
        const token = tokenManager.getAccessToken();

        if (token && config.headers) {
            config.headers.Authorization = `Bearer ${token}`;
            }
        } else {
            // For public endpoints, explicitly remove Authorization header if present
            if (config.headers) {
                delete config.headers.Authorization;
            }
        }

        // Log request in development
        if (import.meta.env.MODE === 'development') {
            console.log(`[API Request] ${config.method?.toUpperCase()} ${config.url}`, {
                data: config.data,
                params: config.params,
                isPublic: isPublicEndpoint(config.url),
            });
        }

        return config;
    },
    (error) => {
        console.error('[API Request Error]', error);
        return Promise.reject(error);
    }
);

// ============================================================================
// Response Interceptor - Auto Refresh Token on 401
// ============================================================================

apiClient.interceptors.response.use(
    (response) => {
        // Log successful responses in development
        if (import.meta.env.MODE === 'development') {
            console.log(`[API Response] ${response.config.method?.toUpperCase()} ${response.config.url}`, {
                status: response.status,
                data: response.data,
            });
        }

        return response;
    },
    async (error: AxiosError) => {
        const originalRequest = error.config as InternalAxiosRequestConfig & { _retry?: boolean };

        // Log errors in development
        if (import.meta.env.MODE === 'development') {
            console.error('[API Response Error]', {
                url: originalRequest?.url,
                status: error.response?.status,
                message: error.message,
                data: error.response?.data,
            });
        }

        // Handle 401 Unauthorized - Token Refresh Logic
        if (error.response?.status === 401 && originalRequest && !originalRequest._retry) {
            // Check if this is the refresh token endpoint itself
            if (originalRequest.url?.includes(ENDPOINTS.AUTH.REFRESH_TOKEN)) {
                // Refresh token is invalid, logout user
                console.error('[Auth] Refresh token is invalid. Logging out...');
                tokenManager.clearTokens();
                window.location.href = '/login';
                return Promise.reject(error);
            }

            // If already refreshing, queue this request
            if (isRefreshing) {
                return new Promise((resolve, reject) => {
                    failedQueue.push({ resolve, reject });
                })
                    .then((token) => {
                        if (originalRequest.headers) {
                            originalRequest.headers.Authorization = `Bearer ${token}`;
                        }
                        return apiClient(originalRequest);
                    })
                    .catch((err) => {
                        return Promise.reject(err);
                    });
            }

            // Mark as retry to prevent infinite loops
            originalRequest._retry = true;
            isRefreshing = true;

            const refreshToken = tokenManager.getRefreshToken();

            if (!refreshToken) {
                // No refresh token available, logout
                console.error('[Auth] No refresh token available. Logging out...');
                tokenManager.clearTokens();
                window.location.href = '/login';
                return Promise.reject(error);
            }

            try {
                // Call refresh token endpoint
                const response = await axios.post<RefreshTokenResponse>(
                    `${API_BASE_URL}${ENDPOINTS.AUTH.REFRESH_TOKEN}`,
                    { refreshToken } as RefreshTokenRequest,
                    {
                        headers: {
                            'Content-Type': 'application/json',
                        },
                    }
                );

                const { accessToken, refreshToken: newRefreshToken } = response.data;

                // Update tokens in storage
                tokenManager.setTokens(accessToken, newRefreshToken);

                // Update the failed request with new token
                if (originalRequest.headers) {
                    originalRequest.headers.Authorization = `Bearer ${accessToken}`;
                }

                // Process queued requests
                processQueue(null, accessToken);

                // Retry the original request
                return apiClient(originalRequest);
            } catch (refreshError) {
                // Refresh failed, logout user
                console.error('[Auth] Token refresh failed. Logging out...', refreshError);
                processQueue(refreshError as AxiosError, null);
                tokenManager.clearTokens();
                window.location.href = '/login';
                return Promise.reject(refreshError);
            } finally {
                isRefreshing = false;
            }
        }

        // Handle other errors
        return Promise.reject(error);
    }
);

// ============================================================================
// Type-Safe Wrapper Functions
// ============================================================================

/**
 * Generic GET request
 */
export const get = async <T = unknown>(
    url: string,
    config?: AxiosRequestConfig
): Promise<T> => {
    const response = await apiClient.get<T>(url, config);
    return response.data;
};

/**
 * Generic POST request
 */
export const post = async <T = unknown, D = unknown>(
    url: string,
    data?: D,
    config?: AxiosRequestConfig
): Promise<T> => {
    const response = await apiClient.post<T>(url, data, config);
    return response.data;
};

/**
 * Generic PUT request
 */
export const put = async <T = unknown, D = unknown>(
    url: string,
    data?: D,
    config?: AxiosRequestConfig
): Promise<T> => {
    const response = await apiClient.put<T>(url, data, config);
    return response.data;
};

/**
 * Generic PATCH request
 */
export const patch = async <T = unknown, D = unknown>(
    url: string,
    data?: D,
    config?: AxiosRequestConfig
): Promise<T> => {
    const response = await apiClient.patch<T>(url, data, config);
    return response.data;
};

/**
 * Generic DELETE request
 */
export const del = async <T = unknown>(
    url: string,
    config?: AxiosRequestConfig
): Promise<T> => {
    const response = await apiClient.delete<T>(url, config);
    return response.data;
};

// ============================================================================
// Error Handler Utility
// ============================================================================

export const handleApiError = (error: unknown): string => {
    if (axios.isAxiosError(error)) {
        const axiosError = error as AxiosError<{ message?: string; error?: string }>;

        // Check for response error message
        if (axiosError.response?.data?.message) {
            return axiosError.response.data.message;
        }

        if (axiosError.response?.data?.error) {
            return axiosError.response.data.error;
        }

        // Check for HTTP status codes
        switch (axiosError.response?.status) {
            case 400:
                return 'Invalid request. Please check your input.';
            case 401:
                return 'Unauthorized. Please login again.';
            case 403:
                return 'Access forbidden. You do not have permission.';
            case 404:
                return 'Resource not found.';
            case 500:
                return 'Server error. Please try again later.';
            case 503:
                return 'Service unavailable. Please try again later.';
            default:
                return axiosError.message || 'An unexpected error occurred.';
        }
    }

    if (error instanceof Error) {
        return error.message;
    }

    return 'An unknown error occurred.';
};

// Export the axios instance for advanced use cases
export default apiClient;
