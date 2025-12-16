/**
 * Course Management API Service
 * 
 * Handles all course-related API calls
 */

import { get, post, put, del } from './apiClient';
import { ENDPOINTS } from './services';
import type {
    Course,
    CreateCourseRequest,
    Module,
    Lesson,
    Quiz,
    QuizAttempt,
} from './types';

// ============================================================================
// Course API
// ============================================================================

export const courseApi = {
    /**
     * Get all courses
     */
    getAllCourses: async (): Promise<Course[]> => {
        return get<Course[]>(ENDPOINTS.COURSES.BASE);
    },

    /**
     * Get courses by teacher ID
     */
    getTeacherCourses: async (teacherId: number): Promise<Course[]> => {
        return get<Course[]>(`${ENDPOINTS.COURSES.BASE}/teacher/${teacherId}`);
    },

    /**
     * Get course by ID
     */
    getCourseById: async (courseId: string): Promise<Course> => {
        return get<Course>(ENDPOINTS.COURSES.BY_ID(courseId));
    },

    /**
     * Create new course (Teacher/Admin)
     */
    createCourse: async (courseData: CreateCourseRequest): Promise<Course> => {
        return post<Course, CreateCourseRequest>(
            ENDPOINTS.COURSES.BASE,
            courseData
        );
    },

    /**
     * Update course (Teacher/Admin)
     */
    updateCourse: async (
        courseId: string,
        courseData: Partial<CreateCourseRequest>
    ): Promise<Course> => {
        return put<Course, Partial<CreateCourseRequest>>(
            ENDPOINTS.COURSES.BY_ID(courseId),
            courseData
        );
    },

    /**
     * Delete course (Teacher/Admin)
     */
    deleteCourse: async (courseId: string): Promise<void> => {
        return del<void>(ENDPOINTS.COURSES.BY_ID(courseId));
    },
};

// ============================================================================
// Module API
// ============================================================================

export const moduleApi = {
    /**
     * Get all modules
     */
    getAllModules: async (): Promise<Module[]> => {
        return get<Module[]>(ENDPOINTS.MODULES.BASE);
    },

    /**
     * Get module by ID
     */
    getModuleById: async (moduleId: string): Promise<Module> => {
        return get<Module>(ENDPOINTS.MODULES.BY_ID(moduleId));
    },

    /**
     * Create new module
     */
    createModule: async (moduleData: Partial<Module>): Promise<Module> => {
        return post<Module, Partial<Module>>(ENDPOINTS.MODULES.BASE, moduleData);
    },

    /**
     * Update module
     */
    updateModule: async (
        moduleId: string,
        moduleData: Partial<Module>
    ): Promise<Module> => {
        return put<Module, Partial<Module>>(
            ENDPOINTS.MODULES.BY_ID(moduleId),
            moduleData
        );
    },

    /**
     * Delete module
     */
    deleteModule: async (moduleId: string): Promise<void> => {
        return del<void>(ENDPOINTS.MODULES.BY_ID(moduleId));
    },
};

// ============================================================================
// Lesson API
// ============================================================================

export const lessonApi = {
    /**
     * Get all lessons
     */
    getAllLessons: async (): Promise<Lesson[]> => {
        return get<Lesson[]>(ENDPOINTS.LESSONS.BASE);
    },

    /**
     * Get lesson by ID
     */
    getLessonById: async (lessonId: string): Promise<Lesson> => {
        return get<Lesson>(ENDPOINTS.LESSONS.BY_ID(lessonId));
    },

    /**
     * Create new lesson
     */
    createLesson: async (lessonData: Partial<Lesson>): Promise<Lesson> => {
        return post<Lesson, Partial<Lesson>>(ENDPOINTS.LESSONS.BASE, lessonData);
    },

    /**
     * Update lesson
     */
    updateLesson: async (
        lessonId: string,
        lessonData: Partial<Lesson>
    ): Promise<Lesson> => {
        return put<Lesson, Partial<Lesson>>(
            ENDPOINTS.LESSONS.BY_ID(lessonId),
            lessonData
        );
    },

    /**
     * Delete lesson
     */
    deleteLesson: async (lessonId: string): Promise<void> => {
        return del<void>(ENDPOINTS.LESSONS.BY_ID(lessonId));
    },
};

// ============================================================================
// Quiz API
// ============================================================================

export const quizApi = {
    /**
     * Get all quizzes
     */
    getAllQuizzes: async (): Promise<Quiz[]> => {
        return get<Quiz[]>(ENDPOINTS.QUIZZES.BASE);
    },

    /**
     * Get quiz by ID
     */
    getQuizById: async (quizId: string): Promise<Quiz> => {
        return get<Quiz>(ENDPOINTS.QUIZZES.BY_ID(quizId));
    },

    /**
     * Create new quiz
     */
    createQuiz: async (quizData: Partial<Quiz>): Promise<Quiz> => {
        return post<Quiz, Partial<Quiz>>(ENDPOINTS.QUIZZES.BASE, quizData);
    },

    /**
     * Submit quiz attempt (Student)
     */
    submitQuizAttempt: async (attemptData: Partial<QuizAttempt>): Promise<QuizAttempt> => {
        return post<QuizAttempt, Partial<QuizAttempt>>(
            ENDPOINTS.QUIZ_ATTEMPTS.BASE,
            attemptData
        );
    },

    /**
     * Get quiz attempt by ID
     */
    getQuizAttemptById: async (attemptId: string): Promise<QuizAttempt> => {
        return get<QuizAttempt>(ENDPOINTS.QUIZ_ATTEMPTS.BY_ID(attemptId));
    },
};
