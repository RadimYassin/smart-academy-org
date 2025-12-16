/**
 * User Management API Service
 * 
 * Handles all user-related API calls
 */

import { get, put, del, post } from './apiClient';
import { ENDPOINTS } from './services';
import type { User, UserDto } from './types';

// ============================================================================
// User API
// ============================================================================

export const userApi = {
    /**
     * Get all users (Admin only)
     */
    getAllUsers: async (): Promise<UserDto[]> => {
        return get<UserDto[]>(ENDPOINTS.USERS.BASE);
    },

    /**
     * Get user by ID
     */
    getUserById: async (userId: number): Promise<UserDto> => {
        return get<UserDto>(ENDPOINTS.USERS.BY_ID(userId));
    },

    /**
     * Update user
     */
    updateUser: async (userId: number, userData: Partial<UserDto>): Promise<UserDto> => {
        return put<UserDto, Partial<UserDto>>(
            ENDPOINTS.USERS.BY_ID(userId),
            userData
        );
    },

    /**
     * Delete user (soft delete, Admin only)
     */
    deleteUser: async (userId: number): Promise<void> => {
        return del<void>(ENDPOINTS.USERS.BY_ID(userId));
    },

    /**
     * Restore deleted user (Admin only)
     */
    restoreUser: async (userId: number): Promise<void> => {
        return post<void>(ENDPOINTS.USERS.RESTORE(userId));
    },

    /**
     * Get current user profile
     * Assumes the backend can extract user ID from JWT token
     */
    getCurrentUser: async (): Promise<User> => {
        // Adjust this endpoint based on your backend implementation
        return get<User>(`${ENDPOINTS.USERS.BASE}/me`);
    },

    /**
     * Get all students (Admin and Teachers only)
     */
    getAllStudents: async (): Promise<UserDto[]> => {
        return get<UserDto[]>(ENDPOINTS.USERS.STUDENTS);
    },
};
