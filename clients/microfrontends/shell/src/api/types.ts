/**
 * API Types and Interfaces
 * 
 * Centralized type definitions for API requests and responses
 */

// ============================================================================
// Authentication Types
// ============================================================================

export interface LoginRequest {
    email: string;
    password: string;
}

export interface RegisterRequest {
    email: string;
    password: string;
    firstName: string;
    lastName: string;
    role: 'TEACHER' | 'STUDENT' | 'ADMIN';
}

export interface AuthResponse {
    access_token: string;
    refresh_token: string;
    is_verified?: boolean;
    user?: User;
}

export interface RefreshTokenRequest {
    refreshToken: string;
}

export interface RefreshTokenResponse {
    accessToken: string;
    refreshToken: string;
}

// ============================================================================
// User Types
// ============================================================================

export interface User {
    id: number;
    email: string;
    firstName: string;
    lastName: string;
    role: 'ADMIN' | 'TEACHER' | 'STUDENT';
    isVerified: boolean;
    createdAt: string;
    updatedAt: string;
}

export interface UserDto {
    id: number;
    email: string;
    firstName: string;
    lastName: string;
    role: string;
    isVerified: boolean;
}

// ============================================================================
// Course Types
// ============================================================================

export interface Course {
    id: string;
    title: string;
    description: string;
    category: string;
    level: 'BEGINNER' | 'INTERMEDIATE' | 'ADVANCED';
    thumbnailUrl: string;
    teacherId: number;
    modules?: Module[];
    createdAt: string;
    updatedAt: string;
}

export interface CreateCourseRequest {
    title: string;
    description: string;
    category: string;
    level: 'BEGINNER' | 'INTERMEDIATE' | 'ADVANCED';
    thumbnailUrl?: string;
}

export interface Module {
    id: string;
    courseId: string;
    title: string;
    description?: string;
    orderIndex: number;
    lessons?: Lesson[];
    createdAt?: string;
    updatedAt?: string;
}

export interface CreateModuleRequest {
    title: string;
    description?: string;
    orderIndex: number;
}

export interface Lesson {
    id: string;
    moduleId: string;
    title: string;
    summary?: string;
    orderIndex: number;
    contents?: LessonContent[];
    createdAt?: string;
    updatedAt?: string;
}

export interface CreateLessonRequest {
    title: string;
    summary?: string;
    orderIndex: number;
}

export interface LessonContent {
    id: string;
    lessonId: string;
    type: 'PDF' | 'TEXT' | 'VIDEO' | 'IMAGE' | 'QUIZ';
    textContent?: string;
    pdfUrl?: string;
    videoUrl?: string;
    imageUrl?: string;
    quizId?: string;
    orderIndex: number;
    createdAt?: string;
    updatedAt?: string;
}

export interface CreateLessonContentRequest {
    type: 'PDF' | 'TEXT' | 'VIDEO' | 'IMAGE' | 'QUIZ';
    textContent?: string;
    pdfUrl?: string;
    videoUrl?: string;
    imageUrl?: string;
    quizId?: string;
    orderIndex: number;
}

export interface Quiz {
    id: string;
    courseId: string;
    title: string;
    description?: string;
    difficulty?: 'EASY' | 'MEDIUM' | 'HARD';
    passingScore?: number;
    mandatory?: boolean;
    questions?: Question[];
    createdAt?: string;
    updatedAt?: string;
}

export interface CreateQuizRequest {
    title: string;
    description?: string;
    difficulty?: 'EASY' | 'MEDIUM' | 'HARD';
    passingScore?: number;
    mandatory?: boolean;
}

export interface Question {
    id: string;
    quizId: string;
    questionText: string;
    questionType: string;
    points?: number;
    options?: QuestionOption[];
}

export interface QuestionOption {
    id: string;
    questionId: string;
    optionText: string;
    isCorrect: boolean;
    optionOrder?: number;
}

export interface CreateQuestionRequest {
    questionText: string;
    questionType: string;
    points?: number;
    options?: Omit<QuestionOption, 'id' | 'questionId'>[];
}

export interface QuizAttempt {
    id: string;
    quizId: string;
    studentId: number;
    score: number;
    passed: boolean;
    startedAt: string;
    completedAt: string;
}

// ============================================================================
// Analytics Types
// ============================================================================

export interface EngagementStats {
    student_id: string;
    engagement_score: number;
    modules_visited: number;
    quizzes_completed: number;
    average_quiz_score?: number;
    time_spent_minutes?: number;
}

export interface StudentProfile {
    student_id: string;
    profile_type: string;
    confidence: number;
    characteristics?: string[];
}

export interface RiskPrediction {
    student_id: string;
    risk_level: 'Low' | 'Medium' | 'High';
    success_probability: number;
    factors?: string[];
    alert_sent: boolean;
}

export interface Recommendation {
    type: 'video' | 'exercise' | 'article' | 'quiz';
    title: string;
    url: string;
    reason?: string;
}

export interface RecommendationsResponse {
    student_id: string;
    recommendations: Recommendation[];
    generated_by?: string;
}

// ============================================================================
// API Error Types
// ============================================================================

export interface ApiError {
    message: string;
    status: number;
    code?: string;
    details?: Record<string, unknown>;
}

export interface ValidationError extends ApiError {
    fields?: Record<string, string[]>;
}

// ============================================================================
// Pagination Types
// ============================================================================

export interface PaginatedRequest {
    page?: number;
    size?: number;
    sort?: string;
}

export interface PaginatedResponse<T> {
    content: T[];
    totalElements: number;
    totalPages: number;
    size: number;
    number: number;
    first: boolean;
    last: boolean;
}

// ============================================================================
// Student Class Types
// ============================================================================

export interface StudentClass {
    id: string;
    name: string;
    description?: string;
    teacherId: number;
    studentCount: number;
    createdAt: string;
    updatedAt: string;
}

export interface CreateClassRequest {
    name: string;
    description?: string;
}

export interface UpdateClassRequest {
    name: string;
    description?: string;
}

export interface AddStudentsRequest {
    studentIds: number[];
}

export interface ClassStudent {
    studentId: number;
    addedBy: number;
    addedAt: string;
}

// ============================================================================
// Enrollment Types
// ============================================================================

export interface AssignStudentRequest {
    courseId: string;
    studentId: number;
}

export interface AssignClassRequest {
    courseId: string;
    classId: string;
}

export type AssignmentType = 'INDIVIDUAL' | 'CLASS';

export interface Enrollment {
    id: string;
    courseId: string;
    courseTitle?: string;
    studentId: number;
    classId?: string;
    className?: string;
    assignedBy: number;
    assignmentType: AssignmentType;
    enrolledAt: string;
}
