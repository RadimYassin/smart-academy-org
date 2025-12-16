import { post, get } from './apiClient';
import { ENDPOINTS } from './services';

export interface LessonProgressResponse {
    lessonId: string;
    lessonTitle: string;
    completed: boolean;
    completedAt?: string;
}

export interface CourseProgressResponse {
    courseId: string;
    courseTitle: string;
    totalLessons: number;
    completedLessons: number;
    completionRate: number;
}

export const progressApi = {
    /**
     * Mark a lesson as complete
     */
    markLessonComplete: async (lessonId: string): Promise<LessonProgressResponse> => {
        return post<LessonProgressResponse, void>(ENDPOINTS.PROGRESS.LESSON_COMPLETE(lessonId), undefined);
    },

    /**
     * Get lesson progress for current student
     */
    getLessonProgress: async (lessonId: string): Promise<LessonProgressResponse> => {
        return get<LessonProgressResponse>(ENDPOINTS.PROGRESS.LESSON_PROGRESS(lessonId));
    },

    /**
     * Get course progress for current student
     */
    getCourseProgress: async (courseId: string): Promise<CourseProgressResponse> => {
        return get<CourseProgressResponse>(ENDPOINTS.PROGRESS.COURSE_PROGRESS(courseId));
    },

    /**
     * Get all lesson progress for a course
     * Returns a list of LessonProgress, one for each lesson in the course
     * Creates LessonProgress records for lessons that don't have one yet
     */
    getAllLessonProgressForCourse: async (courseId: string): Promise<LessonProgressResponse[]> => {
        return get<LessonProgressResponse[]>(ENDPOINTS.PROGRESS.ALL_LESSON_PROGRESS(courseId));
    },
};

