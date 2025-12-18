import React, { useEffect, useState, useRef } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import RemoteApp from '../components/RemoteApp';
import { useAuth } from '../contexts/AuthContext';
import { courseApi } from '../api/courseApi';
import { progressApi } from '../api/progressApi';

const StudentCourse: React.FC = () => {
    const { courseId } = useParams<{ courseId: string }>();
    const { user } = useAuth();
    const navigate = useNavigate();
    const [course, setCourse] = useState<any>(null);
    const [isLoading, setIsLoading] = useState(true);
    const [error, setError] = useState<string | null>(null);
    
    // Store modules for progress fetching (use ref so it's accessible in async handlers)
    const modulesRef = useRef<any[]>([]);

    useEffect(() => {
        const fetchCourse = async () => {
            if (!courseId) {
                setError('Course ID is missing.');
                setIsLoading(false);
                return;
            }
            try {
                setIsLoading(true);
                const fetchedCourse = await courseApi.getCourseById(courseId);
                setCourse(fetchedCourse);
            } catch (err: any) {
                console.error('[Shell StudentCourse] Error fetching course:', err);
                setError(err.message || 'Failed to load course');
            } finally {
                setIsLoading(false);
            }
        };
        fetchCourse();
    }, [courseId]);

    useEffect(() => {
        // Handler for messages from courses microfrontend
        const handleMessage = async (event: MessageEvent) => {
            const iframe = document.querySelector('iframe[src*="5004"]') as HTMLIFrameElement;
            if (!iframe || !iframe.contentWindow) return;

            console.log('[Shell StudentCourse] Received message from iframe:', event.data);

            try {
                // Handle back navigation
                if (event.data.type === 'STUDENT_COURSE_BACK') {
                    navigate('/student/explore');
                }

                // Fetch course content (modules and quizzes) - same as teacher view
                if (event.data.type === 'FETCH_COURSE_CONTENT') {
                    console.log('[Shell StudentCourse] Fetching course content for course:', event.data.courseId);
                    try {
                        const { moduleApi, lessonApi, lessonContentApi, quizApi, questionApi } = await import('../api/courseApi');
                        
                        const [modules, quizzes] = await Promise.all([
                            moduleApi.getModulesByCourse(event.data.courseId),
                            quizApi.getQuizzesByCourse(event.data.courseId),
                        ]);
                        
                        // For each module, fetch its lessons
                        const modulesWithLessonsData = await Promise.all(
                            modules.map(async (module) => {
                                const lessons = await lessonApi.getLessonsByModule(module.id);
                                // For each lesson, fetch its content
                                const lessonsWithContent = await Promise.all(
                                    lessons.map(async (lesson) => {
                                        const contents = await lessonContentApi.getContentByLesson(lesson.id);
                                        return { ...lesson, contents };
                                    })
                                );
                                return { ...module, lessons: lessonsWithContent };
                            })
                        );

                        // Store modules for progress fetching
                        modulesRef.current = modulesWithLessonsData;

                        // For each quiz, fetch its questions
                        const quizzesWithQuestions = await Promise.all(
                            quizzes.map(async (quiz) => {
                                const questions = await questionApi.getQuestionsByQuiz(quiz.id);
                                // For each question, fetch its options
                                const questionsWithOptions = await Promise.all(
                                    questions.map(async (question) => {
                                        // Options are already included in question response from backend
                                        return question;
                                    })
                                );
                                return { ...quiz, questions: questionsWithOptions };
                            })
                        );

                        console.log('[Shell StudentCourse] Course content loaded:', { modules: modulesWithLessonsData, quizzes: quizzesWithQuestions });
                        iframe.contentWindow.postMessage({
                            type: 'COURSE_CONTENT_LOADED',
                            modules: modulesWithLessonsData,
                            quizzes: quizzesWithQuestions
                        }, '*');

                        // Trigger progress fetch after content is loaded
                        setTimeout(() => {
                            const progressIframe = document.querySelector('iframe[src*="5004"]') as HTMLIFrameElement;
                            if (progressIframe && progressIframe.contentWindow) {
                                progressIframe.contentWindow.postMessage({
                                    type: 'FETCH_COURSE_PROGRESS',
                                    courseId: event.data.courseId
                                }, '*');
                            }
                        }, 200);
                    } catch (error: any) {
                        console.error('[Shell StudentCourse] Error fetching course content:', error);
                        iframe.contentWindow.postMessage({
                            type: 'COURSE_CONTENT_ERROR',
                            error: error.message || 'Failed to load course content'
                        }, '*');
                    }
                }

                // Fetch course progress - get all lesson progress at once
                if (event.data.type === 'FETCH_COURSE_PROGRESS') {
                    console.log('[Shell StudentCourse] Fetching all lesson progress for course:', event.data.courseId);
                    try {
                        // Fetch all lesson progress in one call - this ensures each lesson has its own LessonProgress
                        const allLessonProgress = await progressApi.getAllLessonProgressForCourse(event.data.courseId);
                        console.log('[Shell StudentCourse] All lesson progress loaded:', allLessonProgress.length);
                        
                        // Extract completed lesson IDs
                        const completedLessons = allLessonProgress
                            .filter(lp => lp.completed)
                            .map(lp => lp.lessonId);

                        // Also get course progress summary
                        let courseProgress = null;
                        try {
                            courseProgress = await progressApi.getCourseProgress(event.data.courseId);
                        } catch (err) {
                            console.warn('[Shell StudentCourse] Failed to fetch course progress summary:', err);
                        }

                        iframe.contentWindow.postMessage({
                            type: 'COURSE_PROGRESS_LOADED',
                            completedLessons,
                            allLessonProgress,
                            progress: courseProgress
                        }, '*');
                    } catch (error: any) {
                        console.error('[Shell StudentCourse] Error fetching lesson progress:', error);
                        // Don't fail the whole load if progress fails
                        iframe.contentWindow.postMessage({
                            type: 'COURSE_PROGRESS_LOADED',
                            completedLessons: [],
                            allLessonProgress: [],
                            progress: null
                        }, '*');
                    }
                }

                // Mark lesson as complete
                if (event.data.type === 'MARK_LESSON_COMPLETE') {
                    console.log('[Shell StudentCourse] Marking lesson as complete:', event.data.lessonId);
                    try {
                        const response = await progressApi.markLessonComplete(event.data.lessonId);
                        iframe.contentWindow.postMessage({
                            type: 'LESSON_MARKED_COMPLETE',
                            lessonId: event.data.lessonId,
                            progress: response
                        }, '*');
                    } catch (error: any) {
                        console.error('[Shell StudentCourse] Error marking lesson complete:', error);
                        iframe.contentWindow.postMessage({
                            type: 'COURSE_ERROR',
                            error: error.message || 'Failed to mark lesson as complete'
                        }, '*');
                    }
                }
            } catch (error) {
                console.error('[Shell StudentCourse] Unexpected error:', error);
            }
        };

        window.addEventListener('message', handleMessage);

        // Send course data and trigger content load after iframe loads
        const timer = setTimeout(async () => {
            const iframe = document.querySelector('iframe[src*="5004"]') as HTMLIFrameElement;
            if (iframe && iframe.contentWindow && course && courseId) {
                // Send course data to open student view
                iframe.contentWindow.postMessage({
                    type: 'OPEN_STUDENT_COURSE',
                    courseId: courseId,
                    course: course
                }, '*');

                // Also fetch and send course progress immediately
                try {
                    const courseProgress = await progressApi.getCourseProgress(courseId);
                    const allLessonProgress = await progressApi.getAllLessonProgressForCourse(courseId);
                    const completedLessons = allLessonProgress
                        .filter(lp => lp.completed)
                        .map(lp => lp.lessonId);

                    iframe.contentWindow.postMessage({
                        type: 'COURSE_PROGRESS_LOADED',
                        completedLessons,
                        allLessonProgress,
                        progress: courseProgress
                    }, '*');
                } catch (err) {
                    console.warn('[Shell StudentCourse] Failed to fetch initial progress:', err);
                }
            }
        }, 300);

        return () => {
            window.removeEventListener('message', handleMessage);
            clearTimeout(timer);
        };
    }, [course, courseId]);

    if (isLoading) {
        return (
            <div className="fixed inset-0 bg-gradient-to-br from-purple-50 to-indigo-50 dark:from-gray-900 dark:to-gray-800 flex items-center justify-center z-50">
                <div className="text-center">
                    <div className="animate-spin rounded-full h-16 w-16 border-b-4 border-purple-600 mx-auto mb-4"></div>
                    <p className="text-gray-600 dark:text-gray-400 text-lg">Loading course...</p>
                </div>
            </div>
        );
    }

    if (error) {
        return (
            <div className="fixed inset-0 bg-gradient-to-br from-purple-50 to-indigo-50 dark:from-gray-900 dark:to-gray-800 flex items-center justify-center z-50 p-8">
                <div className="bg-white dark:bg-gray-800 rounded-2xl shadow-2xl p-8 max-w-md w-full text-center">
                    <p className="text-red-500 mb-4 text-lg">{error}</p>
                    <button
                        onClick={() => window.history.back()}
                        className="px-6 py-3 bg-purple-600 text-white rounded-lg hover:bg-purple-700 transition-colors font-medium"
                    >
                        Go Back
                    </button>
                </div>
            </div>
        );
    }

    if (!course) {
        return (
            <div className="fixed inset-0 bg-gradient-to-br from-purple-50 to-indigo-50 dark:from-gray-900 dark:to-gray-800 flex items-center justify-center z-50">
                <div className="text-center">
                    <p className="text-gray-600 dark:text-gray-400 text-lg">Course not found</p>
                    <button
                        onClick={() => window.history.back()}
                        className="mt-4 px-6 py-3 bg-purple-600 text-white rounded-lg hover:bg-purple-700 transition-colors font-medium"
                    >
                        Go Back
                    </button>
                </div>
            </div>
        );
    }

    return (
        <div className="fixed inset-0 z-50">
            <RemoteApp moduleName="courses" />
        </div>
    );
};

export default StudentCourse;

