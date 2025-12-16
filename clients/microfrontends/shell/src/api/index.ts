/**
 * API Module - Central Export
 * 
 * Single entry point for all API functionality
 */

// Core API Client
export { default as apiClient, tokenManager, handleApiError } from './apiClient';
export { get, post, put, patch, del } from './apiClient';

// Service Configuration
export { SERVICES, ENDPOINTS } from './services';
export type { ServiceKey } from './services';

// Type Definitions
export * from './types';

// API Services
export { authApi } from './authApi';
export { userApi } from './userApi';
export { 
    courseApi, 
    moduleApi, 
    lessonApi, 
    lessonContentApi, 
    quizApi, 
    questionApi 
} from './courseApi';
export { analyticsApi, profilerApi, predictorApi, recommendationApi } from './analyticsApi';
export { classApi } from './classApi';
export { enrollmentApi } from './enrollmentApi';
