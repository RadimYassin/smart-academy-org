/**
 * Token Utilities
 * 
 * Utilities for decoding and extracting information from JWT tokens
 */

import { jwtDecode } from 'jwt-decode';

interface JWTPayload {
    sub: string; // email
    userId: number;
    roles: string[]; // e.g., ["ROLE_TEACHER"]
    iat: number;
    exp: number;
}

interface DecodedUser {
    id: number;
    email: string;
    role: 'TEACHER' | 'STUDENT' | 'ADMIN';
}

/**
 * Decode JWT access token and extract user information
 */
export const decodeAccessToken = (token: string): DecodedUser | null => {
    try {
        const decoded = jwtDecode<JWTPayload>(token);

        console.log('[TokenUtils] Decoded JWT:', decoded);

        // Extract role from roles array (e.g., "ROLE_TEACHER" -> "TEACHER")
        const role = decoded.roles?.[0]?.replace('ROLE_', '') as 'TEACHER' | 'STUDENT' | 'ADMIN';

        console.log('[TokenUtils] Extracted role:', role);

        return {
            id: decoded.userId,
            email: decoded.sub,
            role: role || 'STUDENT', // Default to STUDENT if no role found
        };
    } catch (error) {
        console.error('[TokenUtils] Failed to decode token:', error);
        return null;
    }
};

/**
 * Check if token is expired
 */
export const isTokenExpired = (token: string): boolean => {
    try {
        const decoded = jwtDecode<JWTPayload>(token);
        const currentTime = Date.now() / 1000;
        return decoded.exp < currentTime;
    } catch (error) {
        return true;
    }
};
