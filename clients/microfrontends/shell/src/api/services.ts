/**
 * Service Route Constants
 * 
 * Centralized configuration for all backend service prefixes.
 * All requests are routed through the API Gateway.
 */

export const SERVICES = {
    // Core Services
    USER_SERVICE: '/user-management-service',
    COURSE_SERVICE: '/course-service',

    // Integration Services
    LMS_CONNECTOR: '/lmsconnector',

    // AI/ML Services
    PREPA_DATA_SERVICE: '/prepadata-service',
    STUDENT_PROFILER_SERVICE: '/studentprofiler-service',
    PATH_PREDICTOR_SERVICE: '/pathpredictor-service',
    RECO_BUILDER_SERVICE: '/recobuilder-service',
} as const;

/**
 * API Endpoints
 * 
 * Specific endpoint paths organized by service
 */
export const ENDPOINTS = {
    // Authentication Endpoints
    AUTH: {
        BASE: `${SERVICES.USER_SERVICE}/api/v1/auth`,
        LOGIN: `${SERVICES.USER_SERVICE}/api/v1/auth/login`,
        REGISTER: `${SERVICES.USER_SERVICE}/api/v1/auth/register`,
        REFRESH_TOKEN: `${SERVICES.USER_SERVICE}/api/v1/auth/refresh-token`,
        LOGOUT: `${SERVICES.USER_SERVICE}/api/v1/auth/logout`,
    },

    // User Management Endpoints
    USERS: {
        BASE: `${SERVICES.USER_SERVICE}/api/v1/users`,
        BY_ID: (id: number) => `${SERVICES.USER_SERVICE}/api/v1/users/${id}`,
        RESTORE: (id: number) => `${SERVICES.USER_SERVICE}/api/v1/users/${id}/restore`,
    },

    // Course Management Endpoints
    COURSES: {
        BASE: `${SERVICES.COURSE_SERVICE}/courses`,
        BY_ID: (id: string) => `${SERVICES.COURSE_SERVICE}/courses/${id}`,
    },

    // Module Endpoints
    MODULES: {
        BASE: `${SERVICES.COURSE_SERVICE}/modules`,
        BY_ID: (id: string) => `${SERVICES.COURSE_SERVICE}/modules/${id}`,
    },

    // Lesson Endpoints
    LESSONS: {
        BASE: `${SERVICES.COURSE_SERVICE}/lessons`,
        BY_ID: (id: string) => `${SERVICES.COURSE_SERVICE}/lessons/${id}`,
    },

    // Quiz Endpoints
    QUIZZES: {
        BASE: `${SERVICES.COURSE_SERVICE}/quizzes`,
        BY_ID: (id: string) => `${SERVICES.COURSE_SERVICE}/quizzes/${id}`,
    },

    // Quiz Attempts
    QUIZ_ATTEMPTS: {
        BASE: `${SERVICES.COURSE_SERVICE}/quiz-attempts`,
        BY_ID: (id: string) => `${SERVICES.COURSE_SERVICE}/quiz-attempts/${id}`,
    },

    // LMS Connector Endpoints
    LMS: {
        SYNC_STUDENTS: (courseId: number) =>
            `${SERVICES.LMS_CONNECTOR}/ingestion/sync-course-students/${courseId}`,
    },

    // AI/ML Service Endpoints
    ANALYTICS: {
        PROCESS_DATA: `${SERVICES.PREPA_DATA_SERVICE}/process-data`,
        ENGAGEMENT_STATS: (studentId: string) =>
            `${SERVICES.PREPA_DATA_SERVICE}/engagement-stats/${studentId}`,

        STUDENT_PROFILE: (studentId: string) =>
            `${SERVICES.STUDENT_PROFILER_SERVICE}/profile-student/${studentId}`,
        CLUSTER_STUDENTS: `${SERVICES.STUDENT_PROFILER_SERVICE}/cluster-students`,

        PREDICT_RISK: (studentId: string) =>
            `${SERVICES.PATH_PREDICTOR_SERVICE}/predict-risk/${studentId}`,

        RECOMMENDATIONS: (studentId: string) =>
            `${SERVICES.RECO_BUILDER_SERVICE}/recommend/${studentId}`,
    },
} as const;

/**
 * Type helper to get all service keys
 */
export type ServiceKey = keyof typeof SERVICES;
