/**
 * Enrollment API Service
 * 
 * Handles all enrollment-related API calls (assigning students/classes to courses)
 */

import { get, post, del } from './apiClient';
import { ENDPOINTS } from './services';
import type {
    AssignStudentRequest,
    AssignClassRequest,
    Enrollment,
} from './types';

// ============================================================================
// Enrollment API
// ============================================================================

export const enrollmentApi = {
    /**
     * Assign a single student to a course
     */
    assignStudent: async (request: AssignStudentRequest): Promise<Enrollment> => {
        return post<Enrollment, AssignStudentRequest>(ENDPOINTS.ENROLLMENTS.STUDENT, request);
    },

    /**
     * Assign an entire class to a course
     */
    assignClass: async (request: AssignClassRequest): Promise<Enrollment[]> => {
        return post<Enrollment[], AssignClassRequest>(ENDPOINTS.ENROLLMENTS.CLASS, request);
    },

    /**
     * Get all enrollments for a specific course
     */
    getCourseEnrollments: async (courseId: string): Promise<Enrollment[]> => {
        return get<Enrollment[]>(ENDPOINTS.ENROLLMENTS.BY_COURSE(courseId));
    },

    /**
     * Unenroll a student from a course
     */
    unenrollStudent: async (courseId: string, studentId: number): Promise<void> => {
        return del<void>(ENDPOINTS.ENROLLMENTS.UNENROLL_STUDENT(courseId, studentId));
    },

    /**
     * Get current student's enrolled courses
     */
    getMyCourses: async (): Promise<Enrollment[]> => {
        return get<Enrollment[]>(ENDPOINTS.ENROLLMENTS.MY_COURSES);
    },
};

