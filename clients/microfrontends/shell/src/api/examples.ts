/**
 * API Usage Examples
 * 
 * This file demonstrates how to use the API system in your components
 */

import {
    authApi,
    userApi,
    courseApi,
    analyticsApi,
    profilerApi,
    predictorApi,
    recommendationApi,
    handleApiError,
    type LoginRequest,
    type RegisterRequest,
    type CreateCourseRequest,
} from './index';

// ============================================================================
// EXAMPLE 1: User Login
// ============================================================================

export const loginExample = async () => {
    try {
        const credentials: LoginRequest = {
            email: 'teacher@example.com',
            password: 'SecurePass123!',
        };

        const response = await authApi.login(credentials);

        // Tokens are automatically stored in localStorage
        console.log('Login successful:', response.user);
        console.log('Access Token:', response.accessToken);

        // Navigate to dashboard
        // router.push('/dashboard');
    } catch (error) {
        const errorMessage = handleApiError(error);
        console.error('Login failed:', errorMessage);
        // Show error to user (toast/snackbar)
    }
};

// ============================================================================
// EXAMPLE 2: User Registration
// ============================================================================

export const registerExample = async () => {
    try {
        const userData: RegisterRequest = {
            email: 'newteacher@example.com',
            password: 'SecurePass123!',
            firstName: 'John',
            lastName: 'Doe',
            role: 'TEACHER',
        };

        const response = await authApi.register(userData);
        console.log('Registration successful:', response.user);
    } catch (error) {
        console.error('Registration failed:', handleApiError(error));
    }
};

// ============================================================================
// EXAMPLE 3: Fetch All Courses
// ============================================================================

export const fetchCoursesExample = async () => {
    try {
        const courses = await courseApi.getAllCourses();
        console.log(`Found ${courses.length} courses:`);
        courses.forEach(course => {
            console.log(`- ${course.title} (${course.level})`);
        });
        return courses;
    } catch (error) {
        console.error('Failed to fetch courses:', handleApiError(error));
        return [];
    }
};

// ============================================================================
// EXAMPLE 4: Create a New Course (Teacher)
// ============================================================================

export const createCourseExample = async () => {
    try {
        const courseData: CreateCourseRequest = {
            title: 'Introduction to Python Programming',
            description: 'Learn Python from scratch with hands-on projects',
            category: 'Programming',
            level: 'BEGINNER',
            thumbnailUrl: 'https://example.com/python-course.jpg',
        };

        const newCourse = await courseApi.createCourse(courseData);
        console.log('Course created successfully:', newCourse.id);
        return newCourse;
    } catch (error) {
        console.error('Failed to create course:', handleApiError(error));
        throw error;
    }
};

// ============================================================================
// EXAMPLE 5: Get Student Analytics
// ============================================================================

export const getStudentAnalyticsExample = async (studentId: string) => {
    try {
        // Get engagement stats
        const engagement = await analyticsApi.getEngagementStats(studentId);
        console.log('Engagement Score:', engagement.engagement_score);

        // Get AI-generated profile
        const profile = await profilerApi.getStudentProfile(studentId);
        console.log('Student Profile:', profile.profile_type);

        // Get risk prediction
        const risk = await predictorApi.predictRisk(studentId);
        console.log('Risk Level:', risk.risk_level);

        // Get personalized recommendations
        const recommendations = await recommendationApi.getRecommendations(studentId);
        console.log('Recommendations:', recommendations.recommendations.length);

        return {
            engagement,
            profile,
            risk,
            recommendations,
        };
    } catch (error) {
        console.error('Failed to fetch analytics:', handleApiError(error));
        return null;
    }
};

// ============================================================================
// EXAMPLE 6: React Component Usage with useState
// ============================================================================

/*
import React, { useState, useEffect } from 'react';
import { courseApi, handleApiError, type Course } from '@/api';

export const CourseList: React.FC = () => {
  const [courses, setCourses] = useState<Course[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    const loadCourses = async () => {
      try {
        setLoading(true);
        setError(null);
        const data = await courseApi.getAllCourses();
        setCourses(data);
      } catch (err) {
        setError(handleApiError(err));
      } finally {
        setLoading(false);
      }
    };

    loadCourses();
  }, []);

  if (loading) return <div>Loading...</div>;
  if (error) return <div>Error: {error}</div>;

  return (
    <div>
      {courses.map(course => (
        <div key={course.id}>{course.title}</div>
      ))}
    </div>
  );
};
*/

// ============================================================================
// EXAMPLE 7: Error Handling Patterns
// ============================================================================

export const errorHandlingExample = async () => {
    try {
        const user = await userApi.getUserById(999);
        console.log(user);
    } catch (error) {
        // Get user-friendly error message
        const message = handleApiError(error);

        // Handle specific error types
        if (message.includes('not found')) {
            console.log('User does not exist');
        } else if (message.includes('Unauthorized')) {
            console.log('Please log in again');
        } else {
            console.log('An error occurred:', message);
        }
    }
};

// ============================================================================
// EXAMPLE 8: Update User Profile
// ============================================================================

export const updateProfileExample = async (userId: number) => {
    try {
        const updatedUser = await userApi.updateUser(userId, {
            firstName: 'Jane',
            lastName: 'Smith',
        });

        console.log('Profile updated successfully:', updatedUser);
        return updatedUser;
    } catch (error) {
        console.error('Failed to update profile:', handleApiError(error));
        throw error;
    }
};

// ============================================================================
// EXAMPLE 9: Logout
// ============================================================================

export const logoutExample = async () => {
    try {
        await authApi.logout();
        console.log('Logged out successfully');
        // Redirect to login page
        // window.location.href = '/login';
    } catch (error) {
        console.error('Logout error:', handleApiError(error));
    }
};

// ============================================================================
// EXAMPLE 10: Advanced - Multiple Parallel Requests
// ============================================================================

export const fetchDashboardDataExample = async (userId: number, studentId: string) => {
    try {
        // Fetch multiple endpoints in parallel
        const [user, courses, analytics, recommendations] = await Promise.all([
            userApi.getUserById(userId),
            courseApi.getAllCourses(),
            analyticsApi.getEngagementStats(studentId),
            recommendationApi.getRecommendations(studentId),
        ]);

        return {
            user,
            courses,
            analytics,
            recommendations,
        };
    } catch (error) {
        console.error('Failed to load dashboard:', handleApiError(error));
        return null;
    }
};
