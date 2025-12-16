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
    CreateModuleRequest,
    Lesson,
    CreateLessonRequest,
    LessonContent,
    CreateLessonContentRequest,
    Quiz,
    CreateQuizRequest,
    Question,
    CreateQuestionRequest,
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
     * Get modules for a course
     */
    getModulesByCourse: async (courseId: string): Promise<Module[]> => {
        return get<Module[]>(ENDPOINTS.MODULES.BASE(courseId));
    },

    /**
     * Create new module for a course
     */
    createModule: async (courseId: string, moduleData: CreateModuleRequest): Promise<Module> => {
        return post<Module, CreateModuleRequest>(ENDPOINTS.MODULES.BASE(courseId), moduleData);
    },

    /**
     * Update module
     */
    updateModule: async (
        courseId: string,
        moduleId: string,
        moduleData: Partial<CreateModuleRequest>
    ): Promise<Module> => {
        return put<Module, Partial<CreateModuleRequest>>(
            ENDPOINTS.MODULES.BY_ID(courseId, moduleId),
            moduleData
        );
    },

    /**
     * Delete module
     */
    deleteModule: async (courseId: string, moduleId: string): Promise<void> => {
        return del<void>(ENDPOINTS.MODULES.BY_ID(courseId, moduleId));
    },
};

// ============================================================================
// Lesson API
// ============================================================================

export const lessonApi = {
    /**
     * Get lessons for a module
     */
    getLessonsByModule: async (moduleId: string): Promise<Lesson[]> => {
        return get<Lesson[]>(ENDPOINTS.LESSONS.BASE(moduleId));
    },

    /**
     * Get lesson by ID
     */
    getLessonById: async (lessonId: string): Promise<Lesson> => {
        return get<Lesson>(ENDPOINTS.LESSONS.BY_ID_ONLY(lessonId));
    },

    /**
     * Create new lesson for a module
     */
    createLesson: async (moduleId: string, lessonData: CreateLessonRequest): Promise<Lesson> => {
        return post<Lesson, CreateLessonRequest>(ENDPOINTS.LESSONS.BASE(moduleId), lessonData);
    },

    /**
     * Update lesson
     */
    updateLesson: async (
        moduleId: string,
        lessonId: string,
        lessonData: Partial<CreateLessonRequest>
    ): Promise<Lesson> => {
        return put<Lesson, Partial<CreateLessonRequest>>(
            ENDPOINTS.LESSONS.BY_ID(moduleId, lessonId),
            lessonData
        );
    },

    /**
     * Delete lesson
     */
    deleteLesson: async (moduleId: string, lessonId: string): Promise<void> => {
        return del<void>(ENDPOINTS.LESSONS.BY_ID(moduleId, lessonId));
    },
};

// ============================================================================
// Lesson Content API
// ============================================================================

export const lessonContentApi = {
    /**
     * Get content for a lesson
     */
    getContentByLesson: async (lessonId: string): Promise<LessonContent[]> => {
        return get<LessonContent[]>(ENDPOINTS.LESSON_CONTENT.BASE(lessonId));
    },

    /**
     * Create new lesson content
     */
    createContent: async (lessonId: string, contentData: CreateLessonContentRequest): Promise<LessonContent> => {
        return post<LessonContent, CreateLessonContentRequest>(ENDPOINTS.LESSON_CONTENT.BASE(lessonId), contentData);
    },

    /**
     * Update lesson content
     */
    updateContent: async (
        lessonId: string,
        contentId: string,
        contentData: Partial<CreateLessonContentRequest>
    ): Promise<LessonContent> => {
        return put<LessonContent, Partial<CreateLessonContentRequest>>(
            ENDPOINTS.LESSON_CONTENT.BY_ID(lessonId, contentId),
            contentData
        );
    },

    /**
     * Delete lesson content
     */
    deleteContent: async (lessonId: string, contentId: string): Promise<void> => {
        return del<void>(ENDPOINTS.LESSON_CONTENT.BY_ID(lessonId, contentId));
    },
};

// ============================================================================
// Quiz API
// ============================================================================

export const quizApi = {
    /**
     * Get quizzes for a course
     */
    getQuizzesByCourse: async (courseId: string): Promise<Quiz[]> => {
        return get<Quiz[]>(ENDPOINTS.QUIZZES.BASE(courseId));
    },

    /**
     * Get quiz by ID
     */
    getQuizById: async (courseId: string, quizId: string): Promise<Quiz> => {
        return get<Quiz>(ENDPOINTS.QUIZZES.BY_ID(courseId, quizId));
    },

    /**
     * Create new quiz for a course
     */
    createQuiz: async (courseId: string, quizData: CreateQuizRequest): Promise<Quiz> => {
        return post<Quiz, CreateQuizRequest>(ENDPOINTS.QUIZZES.BASE(courseId), quizData);
    },

    /**
     * Update quiz
     */
    updateQuiz: async (
        courseId: string,
        quizId: string,
        quizData: Partial<CreateQuizRequest>
    ): Promise<Quiz> => {
        return put<Quiz, Partial<CreateQuizRequest>>(
            ENDPOINTS.QUIZZES.BY_ID(courseId, quizId),
            quizData
        );
    },

    /**
     * Delete quiz
     */
    deleteQuiz: async (courseId: string, quizId: string): Promise<void> => {
        return del<void>(ENDPOINTS.QUIZZES.BY_ID(courseId, quizId));
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

// ============================================================================
// Question API
// ============================================================================

export const questionApi = {
    /**
     * Get questions for a quiz
     */
    getQuestionsByQuiz: async (quizId: string): Promise<Question[]> => {
        return get<Question[]>(ENDPOINTS.QUESTIONS.BASE(quizId));
    },

    /**
     * Create new question for a quiz
     */
    createQuestion: async (quizId: string, questionData: CreateQuestionRequest): Promise<Question> => {
        return post<Question, CreateQuestionRequest>(ENDPOINTS.QUESTIONS.BASE(quizId), questionData);
    },

    /**
     * Update question
     */
    updateQuestion: async (
        quizId: string,
        questionId: string,
        questionData: Partial<CreateQuestionRequest>
    ): Promise<Question> => {
        return put<Question, Partial<CreateQuestionRequest>>(
            ENDPOINTS.QUESTIONS.BY_ID(quizId, questionId),
            questionData
        );
    },

    /**
     * Delete question
     */
    deleteQuestion: async (quizId: string, questionId: string): Promise<void> => {
        return del<void>(ENDPOINTS.QUESTIONS.BY_ID(quizId, questionId));
    },
};
