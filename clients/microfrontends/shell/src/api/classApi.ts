/**
 * Student Class Management API Service
 * 
 * Handles all student class-related API calls
 */

import { get, post, put, del } from './apiClient';
import { ENDPOINTS } from './services';
import type {
    StudentClass,
    CreateClassRequest,
    UpdateClassRequest,
    AddStudentsRequest,
    ClassStudent,
} from './types';

// ============================================================================
// Student Class API
// ============================================================================

export const classApi = {
    /**
     * Create a new student class
     */
    createClass: async (request: CreateClassRequest): Promise<StudentClass> => {
        return post<StudentClass, CreateClassRequest>(ENDPOINTS.CLASSES.BASE, request);
    },

    /**
     * Get all classes for the authenticated teacher
     */
    getMyClasses: async (): Promise<StudentClass[]> => {
        return get<StudentClass[]>(ENDPOINTS.CLASSES.BASE);
    },

    /**
     * Get class details by ID
     */
    getClassById: async (classId: string): Promise<StudentClass> => {
        return get<StudentClass>(ENDPOINTS.CLASSES.BY_ID(classId));
    },

    /**
     * Update class details
     */
    updateClass: async (classId: string, request: UpdateClassRequest): Promise<StudentClass> => {
        return put<StudentClass, UpdateClassRequest>(ENDPOINTS.CLASSES.BY_ID(classId), request);
    },

    /**
     * Delete a class
     */
    deleteClass: async (classId: string): Promise<void> => {
        return del<void>(ENDPOINTS.CLASSES.BY_ID(classId));
    },

    /**
     * Add students to a class
     */
    addStudentsToClass: async (classId: string, request: AddStudentsRequest): Promise<void> => {
        return post<void, AddStudentsRequest>(ENDPOINTS.CLASSES.STUDENTS(classId), request);
    },

    /**
     * Get all students in a class
     */
    getClassStudents: async (classId: string): Promise<ClassStudent[]> => {
        return get<ClassStudent[]>(ENDPOINTS.CLASSES.STUDENTS(classId));
    },

    /**
     * Remove a student from a class
     */
    removeStudentFromClass: async (classId: string, studentId: number): Promise<void> => {
        return del<void>(ENDPOINTS.CLASSES.STUDENT_BY_ID(classId, studentId));
    },
};

