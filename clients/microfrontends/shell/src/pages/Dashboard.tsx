import React, { useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import RemoteApp from '../components/RemoteApp';
import { useAuth } from '../contexts/AuthContext';
import { courseApi } from '../api/courseApi';
import { enrollmentApi } from '../api/enrollmentApi';

const Dashboard: React.FC = () => {
    const { user } = useAuth();
    const navigate = useNavigate();

    useEffect(() => {
        // Handler for messages from dashboard microfrontend
        const handleMessage = async (event: MessageEvent) => {
            const iframe = document.querySelector('iframe[src*="5002"]') as HTMLIFrameElement;
            if (!iframe || !iframe.contentWindow) return;

            try {
                // Fetch student's enrolled courses
                if (event.data.type === 'FETCH_MY_COURSES') {
                    console.log('[Shell Dashboard] Fetching student courses');
                    if (!user?.id || user?.role !== 'STUDENT') {
                        iframe.contentWindow.postMessage({
                            type: 'MY_COURSES_ERROR',
                            error: 'User not authenticated or not a student'
                        }, '*');
                        return;
                    }

                    try {
                        // Get enrollments first
                        const enrollments = await enrollmentApi.getMyCourses();
                        console.log('[Shell Dashboard] Enrollments loaded:', enrollments);

                        // Extract course IDs from enrollments and fetch full course details
                        const courseIds = enrollments.map(e => e.courseId);
                        const coursePromises = courseIds.map(courseId => 
                            courseApi.getCourseById(courseId).catch(err => {
                                console.warn(`[Shell Dashboard] Failed to fetch course ${courseId}:`, err);
                                return null;
                            })
                        );
                        const courses = (await Promise.all(coursePromises)).filter(c => c !== null) as any[];

                        console.log('[Shell Dashboard] Courses loaded:', courses);
                        iframe.contentWindow.postMessage({
                            type: 'MY_COURSES_LOADED',
                            enrollments,
                            courses
                        }, '*');
                    } catch (error: any) {
                        console.error('[Shell Dashboard] Error fetching student courses:', error);
                        iframe.contentWindow.postMessage({
                            type: 'MY_COURSES_ERROR',
                            error: error.message || 'Failed to load courses'
                        }, '*');
                    }
                }

                // Open student course view - navigate to fullscreen page
                if (event.data.type === 'OPEN_STUDENT_COURSE') {
                    console.log('[Shell Dashboard] Opening student course view:', event.data.courseId);
                    navigate(`/student/courses/${event.data.courseId}`);
                }
            } catch (error) {
                console.error('[Shell Dashboard] Unexpected error:', error);
            }
        };

        window.addEventListener('message', handleMessage);

        // Trigger course fetch after iframe loads if student
        const timer = setTimeout(() => {
            const iframe = document.querySelector('iframe[src*="5002"]') as HTMLIFrameElement;
            if (iframe && iframe.contentWindow && user?.role === 'STUDENT') {
                setTimeout(() => {
                    iframe.contentWindow?.postMessage({ type: 'FETCH_MY_COURSES' }, '*');
                }, 100);
            }
        }, 300);

        return () => {
            window.removeEventListener('message', handleMessage);
            clearTimeout(timer);
        };
    }, [user, navigate]);

    return <RemoteApp moduleName="dashboard" />;
};

export default Dashboard;
