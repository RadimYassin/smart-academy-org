import React, { useEffect } from 'react';
import RemoteApp from '../components/RemoteApp';
import { useAuth } from '../contexts/AuthContext';
import { courseApi } from '../api/courseApi';

const Courses: React.FC = () => {
    const { user } = useAuth();

    useEffect(() => {
        // Handler for messages from courses microfrontend
        const handleMessage = async (event: MessageEvent) => {
            const iframe = document.querySelector('iframe[src*="5004"]') as HTMLIFrameElement;
            if (!iframe || !iframe.contentWindow) return;

            console.log('[Shell Courses] Received message from iframe:', event.data);

            try {
                // Fetch teacher's courses
                if (event.data.type === 'FETCH_TEACHER_COURSES') {
                    console.log('[Shell Courses] Fetching courses for teacher:', user?.id);
                    if (!user?.id) {
                        iframe.contentWindow.postMessage({
                            type: 'TEACHER_COURSES_ERROR',
                            error: 'User ID not found'
                        }, '*');
                        return;
                    }

                    try {
                        const courses = await courseApi.getTeacherCourses(user.id);
                        console.log('[Shell Courses] Courses loaded:', courses);
                        iframe.contentWindow.postMessage({
                            type: 'TEACHER_COURSES_LOADED',
                            courses
                        }, '*');
                    } catch (error: any) {
                        console.error('[Shell Courses] Error fetching courses:', error);
                        iframe.contentWindow.postMessage({
                            type: 'TEACHER_COURSES_ERROR',
                            error: error.message || 'Failed to load courses'
                        }, '*');
                    }
                }

                // Create course
                if (event.data.type === 'CREATE_COURSE') {
                    console.log('[Shell Courses] Creating course:', event.data.course);
                    try {
                        const newCourse = await courseApi.createCourse(event.data.course);
                        console.log('[Shell Courses] Course created:', newCourse);
                        iframe.contentWindow.postMessage({
                            type: 'COURSE_CREATED',
                            course: newCourse
                        }, '*');
                    } catch (error: any) {
                        console.error('[Shell Courses] Error creating course:', error);
                        iframe.contentWindow.postMessage({
                            type: 'COURSE_ERROR',
                            error: error.message || 'Failed to create course'
                        }, '*');
                    }
                }

                // Update course
                if (event.data.type === 'UPDATE_COURSE') {
                    console.log('[Shell Courses] Updating course:', event.data.courseId, event.data.course);
                    try {
                        const updatedCourse = await courseApi.updateCourse(
                            event.data.courseId,
                            event.data.course
                        );
                        console.log('[Shell Courses] Course updated:', updatedCourse);
                        iframe.contentWindow.postMessage({
                            type: 'COURSE_UPDATED',
                            course: updatedCourse
                        }, '*');
                    } catch (error: any) {
                        console.error('[Shell Courses] Error updating course:', error);
                        iframe.contentWindow.postMessage({
                            type: 'COURSE_ERROR',
                            error: error.message || 'Failed to update course'
                        }, '*');
                    }
                }

                // Delete course
                if (event.data.type === 'DELETE_COURSE') {
                    console.log('[Shell Courses] Deleting course:', event.data.courseId);
                    try {
                        await courseApi.deleteCourse(event.data.courseId);
                        console.log('[Shell Courses] Course deleted');
                        iframe.contentWindow.postMessage({
                            type: 'COURSE_DELETED',
                            courseId: event.data.courseId
                        }, '*');
                    } catch (error: any) {
                        console.error('[Shell Courses] Error deleting course:', error);
                        iframe.contentWindow.postMessage({
                            type: 'COURSE_ERROR',
                            error: error.message || 'Failed to delete course'
                        }, '*');
                    }
                }
            } catch (error) {
                console.error('[Shell Courses] Unexpected error:', error);
            }
        };

        window.addEventListener('message', handleMessage);

        // Send initial view and trigger course load after iframe loads
        const timer = setTimeout(() => {
            const iframe = document.querySelector('iframe[src*="5004"]') as HTMLIFrameElement;
            if (iframe && iframe.contentWindow) {
                const view = user?.role === 'TEACHER' ? 'manage' : 'explore';
                console.log('[Shell Courses] Sending view to iframe:', view, 'for role:', user?.role);
                iframe.contentWindow.postMessage({ type: 'SET_VIEW', view }, '*');
            }
        }, 300);

        return () => {
            window.removeEventListener('message', handleMessage);
            clearTimeout(timer);
        };
    }, [user]);

    return <RemoteApp moduleName="courses" />;
};

export default Courses;
