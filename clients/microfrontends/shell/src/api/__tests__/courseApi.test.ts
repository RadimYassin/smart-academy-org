import { describe, it, expect, vi } from 'vitest';
import { courseApi } from '../courseApi';
import * as apiClient from '../apiClient';

// Mock the apiClient
vi.mock('../apiClient', async () => {
    const actual = await vi.importActual('../apiClient');
    return {
        ...actual,
        get: vi.fn(),
        post: vi.fn(),
        put: vi.fn(),
        del: vi.fn(),
    };
});

describe('courseApi', () => {
    beforeEach(() => {
        vi.clearAllMocks();
    });

    describe('getCourseById', () => {
        it('fetches a course by ID', async () => {
            const mockCourse = {
                id: 1,
                title: 'React Basics',
                description: 'Learn React fundamentals',
                teacherId: 1,
            };

            vi.mocked(apiClient.get).mockResolvedValueOnce(mockCourse);

            const result = await courseApi.getCourseById(1);

            expect(apiClient.get).toHaveBeenCalledWith(
                expect.stringContaining('/courses/1')
            );
            expect(result).toEqual(mockCourse);
        });

        it('handles fetch error', async () => {
            vi.mocked(apiClient.get).mockRejectedValueOnce(
                new Error('Course not found')
            );

            await expect(courseApi.getCourseById(999)).rejects.toThrow('Course not found');
        });
    });

    describe('getAllCourses', () => {
        it('fetches all courses', async () => {
            const mockCourses = [
                { id: 1, title: 'React Basics', description: 'Learn React', teacherId: 1 },
                { id: 2, title: 'TypeScript', description: 'Learn TS', teacherId: 1 },
            ];

            vi.mocked(apiClient.get).mockResolvedValueOnce(mockCourses);

            const result = await courseApi.getAllCourses();

            expect(apiClient.get).toHaveBeenCalledWith(
                expect.stringContaining('/courses')
            );
            expect(result).toEqual(mockCourses);
            expect(result).toHaveLength(2);
        });

        it('handles empty course list', async () => {
            vi.mocked(apiClient.get).mockResolvedValueOnce([]);

            const result = await courseApi.getAllCourses();

            expect(result).toEqual([]);
            expect(result).toHaveLength(0);
        });
    });
});
