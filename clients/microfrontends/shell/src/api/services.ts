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
    EDUBOT_SERVICE: '/edubot-service',
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
        STUDENTS: `${SERVICES.USER_SERVICE}/api/v1/users/students`,
    },

    // Course Management Endpoints
    COURSES: {
        BASE: `${SERVICES.COURSE_SERVICE}/courses`,
        BY_ID: (id: string) => `${SERVICES.COURSE_SERVICE}/courses/${id}`,
    },

    // Module Endpoints
    MODULES: {
        BASE: (courseId: string) => `${SERVICES.COURSE_SERVICE}/courses/${courseId}/modules`,
        BY_ID: (courseId: string, moduleId: string) => `${SERVICES.COURSE_SERVICE}/courses/${courseId}/modules/${moduleId}`,
    },

    // Lesson Endpoints
    LESSONS: {
        BASE: (moduleId: string) => `${SERVICES.COURSE_SERVICE}/modules/${moduleId}/lessons`,
        BY_ID: (moduleId: string, lessonId: string) => `${SERVICES.COURSE_SERVICE}/modules/${moduleId}/lessons/${lessonId}`,
        BY_ID_ONLY: (lessonId: string) => `${SERVICES.COURSE_SERVICE}/lessons/${lessonId}`,
    },

    // Lesson Content Endpoints
    LESSON_CONTENT: {
        BASE: (lessonId: string) => `${SERVICES.COURSE_SERVICE}/lessons/${lessonId}/content`,
        BY_ID: (lessonId: string, contentId: string) => `${SERVICES.COURSE_SERVICE}/lessons/${lessonId}/content/${contentId}`,
    },

    // Quiz Endpoints
    QUIZZES: {
        BASE: (courseId: string) => `${SERVICES.COURSE_SERVICE}/courses/${courseId}/quizzes`,
        BY_ID: (courseId: string, quizId: string) => `${SERVICES.COURSE_SERVICE}/courses/${courseId}/quizzes/${quizId}`,
    },

    // Question Endpoints
    QUESTIONS: {
        BASE: (quizId: string) => `${SERVICES.COURSE_SERVICE}/quizzes/${quizId}/questions`,
        BY_ID: (quizId: string, questionId: string) => `${SERVICES.COURSE_SERVICE}/quizzes/${quizId}/questions/${questionId}`,
    },

    // Quiz Attempts
    QUIZ_ATTEMPTS: {
        BASE: `${SERVICES.COURSE_SERVICE}/quiz-attempts`,
        BY_ID: (id: string) => `${SERVICES.COURSE_SERVICE}/quiz-attempts/${id}`,
    },

    // Student Classes Endpoints
    CLASSES: {
        BASE: `${SERVICES.COURSE_SERVICE}/api/classes`,
        BY_ID: (classId: string) => `${SERVICES.COURSE_SERVICE}/api/classes/${classId}`,
        STUDENTS: (classId: string) => `${SERVICES.COURSE_SERVICE}/api/classes/${classId}/students`,
        STUDENT_BY_ID: (classId: string, studentId: number) => `${SERVICES.COURSE_SERVICE}/api/classes/${classId}/students/${studentId}`,
    },

    // Enrollment Endpoints
    ENROLLMENTS: {
        BASE: `${SERVICES.COURSE_SERVICE}/api/enrollments`,
        STUDENT: `${SERVICES.COURSE_SERVICE}/api/enrollments/student`,
        CLASS: `${SERVICES.COURSE_SERVICE}/api/enrollments/class`,
        BY_COURSE: (courseId: string) => `${SERVICES.COURSE_SERVICE}/api/enrollments/courses/${courseId}`,
        UNENROLL_STUDENT: (courseId: string, studentId: number) => `${SERVICES.COURSE_SERVICE}/api/enrollments/courses/${courseId}/students/${studentId}`,
        MY_COURSES: `${SERVICES.COURSE_SERVICE}/api/enrollments/my-courses`,
    },

    // Progress Tracking Endpoints
    PROGRESS: {
        LESSON_COMPLETE: (lessonId: string) => `${SERVICES.COURSE_SERVICE}/api/progress/lessons/${lessonId}/complete`,
        LESSON_PROGRESS: (lessonId: string) => `${SERVICES.COURSE_SERVICE}/api/progress/lessons/${lessonId}`,
        COURSE_PROGRESS: (courseId: string) => `${SERVICES.COURSE_SERVICE}/api/progress/courses/${courseId}`,
        ALL_LESSON_PROGRESS: (courseId: string) => `${SERVICES.COURSE_SERVICE}/api/progress/courses/${courseId}/lessons`,
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

    // EduBot AI Assistant Endpoints
    EDUBOT: {
        CHAT_ASK: `${SERVICES.EDUBOT_SERVICE}/chat/ask`,
        HEALTH: `${SERVICES.EDUBOT_SERVICE}/health`,
    },
} as const;

/**
 * Type helper to get all service keys
 */
export type ServiceKey = keyof typeof SERVICES;
