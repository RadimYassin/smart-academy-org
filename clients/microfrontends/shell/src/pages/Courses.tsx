import React, { useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import RemoteApp from '../components/RemoteApp';
import { useAuth } from '../contexts/AuthContext';
import { 
    courseApi, 
    moduleApi, 
    lessonApi, 
    lessonContentApi, 
    quizApi, 
    questionApi 
} from '../api/courseApi';
import { enrollmentApi } from '../api/enrollmentApi';
import { progressApi } from '../api/progressApi';

const Courses: React.FC = () => {
    const { user } = useAuth();
    const navigate = useNavigate();

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

                // ====================================================================
                // Course Content Management
                // ====================================================================

                // Fetch course content (modules and quizzes)
                if (event.data.type === 'FETCH_COURSE_CONTENT') {
                    console.log('[Shell Courses] Fetching course content for course:', event.data.courseId);
                    try {
                        const [modules, quizzes] = await Promise.all([
                            moduleApi.getModulesByCourse(event.data.courseId),
                            quizApi.getQuizzesByCourse(event.data.courseId),
                        ]);
                        
                        // For each module, fetch its lessons
                        const modulesWithLessons = await Promise.all(
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

                        // For each quiz, fetch its questions
                        const quizzesWithQuestions = await Promise.all(
                            quizzes.map(async (quiz) => {
                                const questions = await questionApi.getQuestionsByQuiz(quiz.id);
                                return { ...quiz, questions };
                            })
                        );

                        console.log('[Shell Courses] Course content loaded:', { modules: modulesWithLessons, quizzes: quizzesWithQuestions });
                        iframe.contentWindow.postMessage({
                            type: 'COURSE_CONTENT_LOADED',
                            modules: modulesWithLessons,
                            quizzes: quizzesWithQuestions
                        }, '*');
                    } catch (error: any) {
                        console.error('[Shell Courses] Error fetching course content:', error);
                        iframe.contentWindow.postMessage({
                            type: 'COURSE_CONTENT_ERROR',
                            error: error.message || 'Failed to load course content'
                        }, '*');
                    }
                }

                // Create module
                if (event.data.type === 'CREATE_MODULE') {
                    console.log('[Shell Courses] Creating module:', event.data.module);
                    try {
                        const newModule = await moduleApi.createModule(event.data.courseId, event.data.module);
                        console.log('[Shell Courses] Module created:', newModule);
                        iframe.contentWindow.postMessage({
                            type: 'MODULE_CREATED',
                            module: newModule
                        }, '*');
                    } catch (error: any) {
                        console.error('[Shell Courses] Error creating module:', error);
                        iframe.contentWindow.postMessage({
                            type: 'COURSE_ERROR',
                            error: error.message || 'Failed to create module'
                        }, '*');
                    }
                }

                // Create lesson
                if (event.data.type === 'CREATE_LESSON') {
                    console.log('[Shell Courses] Creating lesson:', event.data.lesson);
                    try {
                        const newLesson = await lessonApi.createLesson(event.data.moduleId, event.data.lesson);
                        console.log('[Shell Courses] Lesson created:', newLesson);
                        iframe.contentWindow.postMessage({
                            type: 'LESSON_CREATED',
                            lesson: newLesson,
                            moduleId: event.data.moduleIdForResponse || event.data.moduleId
                        }, '*');
                    } catch (error: any) {
                        console.error('[Shell Courses] Error creating lesson:', error);
                        iframe.contentWindow.postMessage({
                            type: 'COURSE_ERROR',
                            error: error.message || 'Failed to create lesson'
                        }, '*');
                    }
                }

                // Create lesson content
                if (event.data.type === 'CREATE_CONTENT') {
                    console.log('[Shell Courses] Creating content:', event.data.content);
                    try {
                        const newContent = await lessonContentApi.createContent(event.data.lessonId, event.data.content);
                        console.log('[Shell Courses] Content created:', newContent);
                        iframe.contentWindow.postMessage({
                            type: 'CONTENT_CREATED',
                            content: newContent,
                            lessonId: event.data.lessonIdForResponse || event.data.lessonId,
                            moduleId: event.data.moduleIdForResponse
                        }, '*');
                    } catch (error: any) {
                        console.error('[Shell Courses] Error creating content:', error);
                        iframe.contentWindow.postMessage({
                            type: 'COURSE_ERROR',
                            error: error.message || 'Failed to create content'
                        }, '*');
                    }
                }

                // Create quiz
                if (event.data.type === 'CREATE_QUIZ') {
                    console.log('[Shell Courses] Creating quiz:', event.data.quiz);
                    try {
                        const newQuiz = await quizApi.createQuiz(event.data.courseId, event.data.quiz);
                        console.log('[Shell Courses] Quiz created:', newQuiz);
                        iframe.contentWindow.postMessage({
                            type: 'QUIZ_CREATED',
                            quiz: newQuiz
                        }, '*');
                    } catch (error: any) {
                        console.error('[Shell Courses] Error creating quiz:', error);
                        iframe.contentWindow.postMessage({
                            type: 'COURSE_ERROR',
                            error: error.message || 'Failed to create quiz'
                        }, '*');
                    }
                }

                // Create question
                if (event.data.type === 'CREATE_QUESTION') {
                    console.log('[Shell Courses] Creating question:', event.data.question);
                    try {
                        const newQuestion = await questionApi.createQuestion(event.data.quizId, event.data.question);
                        console.log('[Shell Courses] Question created:', newQuestion);
                        iframe.contentWindow.postMessage({
                            type: 'QUESTION_CREATED',
                            question: newQuestion,
                            quizId: event.data.quizIdForResponse || event.data.quizId
                        }, '*');
                    } catch (error: any) {
                        console.error('[Shell Courses] Error creating question:', error);
                        iframe.contentWindow.postMessage({
                            type: 'COURSE_ERROR',
                            error: error.message || 'Failed to create question'
                        }, '*');
                    }
                }

                // Fetch student's enrolled courses
                if (event.data.type === 'FETCH_MY_COURSES') {
                    console.log('[Shell Courses] Fetching student courses');
                    if (!user?.id) {
                        iframe.contentWindow.postMessage({
                            type: 'MY_COURSES_ERROR',
                            error: 'User ID not found'
                        }, '*');
                        return;
                    }

                    try {
                        // Get enrollments first
                        const enrollments = await enrollmentApi.getMyCourses();
                        console.log('[Shell Courses] Enrollments loaded:', enrollments);

                        // Extract course IDs from enrollments and fetch full course details
                        const courseIds = enrollments.map(e => e.courseId);
                        const coursePromises = courseIds.map(courseId => 
                            courseApi.getCourseById(courseId).catch(err => {
                                console.warn(`[Shell Courses] Failed to fetch course ${courseId}:`, err);
                                return null;
                            })
                        );
                        const courses = (await Promise.all(coursePromises)).filter(c => c !== null) as any[];

                        // Fetch progress for each course
                        const courseProgressPromises = courseIds.map(courseId =>
                            progressApi.getCourseProgress(courseId).catch(err => {
                                console.warn(`[Shell Courses] Failed to fetch progress for course ${courseId}:`, err);
                                return null;
                            })
                        );
                        const courseProgresses = await Promise.all(courseProgressPromises);
                        
                        // Create a map of course progress by courseId
                        const progressMap: Record<string, any> = {};
                        courseProgresses.forEach((progress, index) => {
                            if (progress) {
                                progressMap[courseIds[index]] = progress;
                            }
                        });

                        console.log('[Shell Courses] Courses loaded:', courses);
                        console.log('[Shell Courses] Course progress loaded:', progressMap);
                        iframe.contentWindow.postMessage({
                            type: 'MY_COURSES_LOADED',
                            enrollments,
                            courses,
                            courseProgress: progressMap
                        }, '*');
                    } catch (error: any) {
                        console.error('[Shell Courses] Error fetching student courses:', error);
                        iframe.contentWindow.postMessage({
                            type: 'MY_COURSES_ERROR',
                            error: error.message || 'Failed to load courses'
                        }, '*');
                    }
                }

                // Open course detail in new page (for teacher)
                if (event.data.type === 'OPEN_COURSE_DETAIL') {
                    console.log('[Shell Courses] Navigating to course detail:', event.data.courseId);
                    navigate(`/teacher/courses/${event.data.courseId}`);
                }

                // Open student course view - navigate to fullscreen page
                if (event.data.type === 'OPEN_STUDENT_COURSE') {
                    console.log('[Shell Courses] Opening student course view:', event.data.courseId);
                    navigate(`/student/courses/${event.data.courseId}`);
                }

                // Fetch student info
                if (event.data.type === 'FETCH_STUDENT_INFO') {
                    console.log('[Shell Courses] Fetching student info');
                    if (user) {
                        iframe.contentWindow.postMessage({
                            type: 'STUDENT_INFO_LOADED',
                            firstName: user.name?.split(' ')[0] || '',
                            lastName: user.name?.split(' ').slice(1).join(' ') || '',
                            email: user.email || ''
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
                
                // If teacher, automatically trigger course fetch
                if (user?.role === 'TEACHER' && user?.id) {
                    setTimeout(() => {
                        iframe.contentWindow?.postMessage({ type: 'FETCH_TEACHER_COURSES' }, '*');
                    }, 100);
                }
                
                // If student, automatically trigger enrolled courses fetch
                if (user?.role === 'STUDENT' && user?.id) {
                    setTimeout(() => {
                        iframe.contentWindow?.postMessage({ type: 'FETCH_MY_COURSES' }, '*');
                    }, 100);
                }
            }
        }, 300);

        return () => {
            window.removeEventListener('message', handleMessage);
            clearTimeout(timer);
        };
    }, [user, navigate]);

    return <RemoteApp moduleName="courses" />;
};

export default Courses;
