/**
 * Analytics & AI Services API
 * 
 * Handles all AI/ML and analytics-related API calls
 */

import { get, post } from './apiClient';
import { ENDPOINTS } from './services';
import type {
    EngagementStats,
    StudentProfile,
    RiskPrediction,
    RecommendationsResponse,
} from './types';

// ============================================================================
// Analytics API - PrepaData Service
// ============================================================================

export const analyticsApi = {
    /**
     * Trigger data processing pipeline
     */
    processData: async (): Promise<{ status: string; job_id: string }> => {
        return post(ENDPOINTS.ANALYTICS.PROCESS_DATA);
    },

    /**
     * Get student engagement statistics
     */
    getEngagementStats: async (studentId: string): Promise<EngagementStats> => {
        return get<EngagementStats>(ENDPOINTS.ANALYTICS.ENGAGEMENT_STATS(studentId));
    },
};

// ============================================================================
// Student Profiler API
// ============================================================================

export const profilerApi = {
    /**
     * Get AI-generated student profile
     */
    getStudentProfile: async (studentId: string): Promise<StudentProfile> => {
        return get<StudentProfile>(ENDPOINTS.ANALYTICS.STUDENT_PROFILE(studentId));
    },

    /**
     * Trigger student clustering (Admin/Teacher only)
     */
    clusterStudents: async (): Promise<{
        status: string;
        clusters_found: number;
        cluster_distribution?: Record<string, number>;
    }> => {
        return post(ENDPOINTS.ANALYTICS.CLUSTER_STUDENTS);
    },
};

// ============================================================================
// Path Predictor API
// ============================================================================

export const predictorApi = {
    /**
     * Predict student failure risk
     */
    predictRisk: async (studentId: string): Promise<RiskPrediction> => {
        return get<RiskPrediction>(ENDPOINTS.ANALYTICS.PREDICT_RISK(studentId));
    },
};

// ============================================================================
// Recommendation Builder API
// ============================================================================

export const recommendationApi = {
    /**
     * Get personalized learning recommendations
     */
    getRecommendations: async (studentId: string): Promise<RecommendationsResponse> => {
        return get<RecommendationsResponse>(ENDPOINTS.ANALYTICS.RECOMMENDATIONS(studentId));
    },
};
