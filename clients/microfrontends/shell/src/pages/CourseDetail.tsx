import React, { useEffect, useState } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import RemoteApp from '../components/RemoteApp';
import { useAuth } from '../contexts/AuthContext';
import { courseApi, moduleApi, lessonApi, lessonContentApi, quizApi, questionApi } from '../api/courseApi';

const CourseDetail: React.FC = () => {
    const { courseId } = useParams<{ courseId: string }>();
    const navigate = useNavigate();
    const { user } = useAuth();
    const [course, setCourse] = useState<any>(null);

    useEffect(() => {
        if (!courseId) {
            navigate('/teacher/courses');
            return;
        }

        // Load course details
        const loadCourse = async () => {
            try {
                const courseData = await courseApi.getCourseById(courseId);
                setCourse(courseData);
            } catch (error) {
                console.error('Error loading course:', error);
                navigate('/teacher/courses');
            }
        };

        loadCourse();
    }, [courseId, navigate]);

    useEffect(() => {
        // Handler for messages from courses microfrontend
        const handleMessage = async (event: MessageEvent) => {
            const iframe = document.querySelector('iframe[src*="5004"]') as HTMLIFrameElement;
            if (!iframe || !iframe.contentWindow) return;

            console.log('[Shell CourseDetail] Received message from iframe:', event.data);

            try {
                // Fetch course content (modules and quizzes)
                if (event.data.type === 'FETCH_COURSE_CONTENT') {
                    console.log('[Shell CourseDetail] Fetching course content for course:', event.data.courseId);
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

                        console.log('[Shell CourseDetail] Course content loaded:', { modules: modulesWithLessons, quizzes: quizzesWithQuestions });
                        iframe.contentWindow.postMessage({
                            type: 'COURSE_CONTENT_LOADED',
                            modules: modulesWithLessons,
                            quizzes: quizzesWithQuestions
                        }, '*');
                    } catch (error: any) {
                        console.error('[Shell CourseDetail] Error fetching course content:', error);
                        iframe.contentWindow.postMessage({
                            type: 'COURSE_CONTENT_ERROR',
                            error: error.message || 'Failed to load course content'
                        }, '*');
                    }
                }

                // Create module
                if (event.data.type === 'CREATE_MODULE') {
                    console.log('[Shell CourseDetail] Creating module:', event.data.module);
                    try {
                        const newModule = await moduleApi.createModule(event.data.courseId, event.data.module);
                        console.log('[Shell CourseDetail] Module created:', newModule);
                        iframe.contentWindow.postMessage({
                            type: 'MODULE_CREATED',
                            module: newModule
                        }, '*');
                    } catch (error: any) {
                        console.error('[Shell CourseDetail] Error creating module:', error);
                        iframe.contentWindow.postMessage({
                            type: 'COURSE_ERROR',
                            error: error.message || 'Failed to create module'
                        }, '*');
                    }
                }

                // Create lesson
                if (event.data.type === 'CREATE_LESSON') {
                    console.log('[Shell CourseDetail] Creating lesson:', event.data.lesson);
                    try {
                        const newLesson = await lessonApi.createLesson(event.data.moduleId, event.data.lesson);
                        console.log('[Shell CourseDetail] Lesson created:', newLesson);
                        iframe.contentWindow.postMessage({
                            type: 'LESSON_CREATED',
                            lesson: newLesson,
                            moduleId: event.data.moduleIdForResponse || event.data.moduleId
                        }, '*');
                    } catch (error: any) {
                        console.error('[Shell CourseDetail] Error creating lesson:', error);
                        iframe.contentWindow.postMessage({
                            type: 'COURSE_ERROR',
                            error: error.message || 'Failed to create lesson'
                        }, '*');
                    }
                }

                // Create lesson content
                if (event.data.type === 'CREATE_CONTENT') {
                    console.log('[Shell CourseDetail] Creating content:', event.data.content);
                    try {
                        const newContent = await lessonContentApi.createContent(event.data.lessonId, event.data.content);
                        console.log('[Shell CourseDetail] Content created:', newContent);
                        iframe.contentWindow.postMessage({
                            type: 'CONTENT_CREATED',
                            content: newContent,
                            lessonId: event.data.lessonIdForResponse || event.data.lessonId,
                            moduleId: event.data.moduleIdForResponse
                        }, '*');
                    } catch (error: any) {
                        console.error('[Shell CourseDetail] Error creating content:', error);
                        iframe.contentWindow.postMessage({
                            type: 'COURSE_ERROR',
                            error: error.message || 'Failed to create content'
                        }, '*');
                    }
                }

                // Create quiz
                if (event.data.type === 'CREATE_QUIZ') {
                    console.log('[Shell CourseDetail] Creating quiz:', event.data.quiz);
                    try {
                        const newQuiz = await quizApi.createQuiz(event.data.courseId, event.data.quiz);
                        console.log('[Shell CourseDetail] Quiz created:', newQuiz);
                        iframe.contentWindow.postMessage({
                            type: 'QUIZ_CREATED',
                            quiz: newQuiz
                        }, '*');
                    } catch (error: any) {
                        console.error('[Shell CourseDetail] Error creating quiz:', error);
                        iframe.contentWindow.postMessage({
                            type: 'COURSE_ERROR',
                            error: error.message || 'Failed to create quiz'
                        }, '*');
                    }
                }

                // Create question
                if (event.data.type === 'CREATE_QUESTION') {
                    console.log('[Shell CourseDetail] Creating question:', event.data.question);
                    try {
                        const newQuestion = await questionApi.createQuestion(event.data.quizId, event.data.question);
                        console.log('[Shell CourseDetail] Question created:', newQuestion);
                        iframe.contentWindow.postMessage({
                            type: 'QUESTION_CREATED',
                            question: newQuestion,
                            quizId: event.data.quizIdForResponse || event.data.quizId
                        }, '*');
                    } catch (error: any) {
                        console.error('[Shell CourseDetail] Error creating question:', error);
                        iframe.contentWindow.postMessage({
                            type: 'COURSE_ERROR',
                            error: error.message || 'Failed to create question'
                        }, '*');
                    }
                }

                // Handle back navigation
                if (event.data.type === 'COURSE_DETAIL_BACK') {
                    navigate('/teacher/courses');
                }
            } catch (error) {
                console.error('[Shell CourseDetail] Unexpected error:', error);
            }
        };

        window.addEventListener('message', handleMessage);

        // Send course data and trigger content load after iframe loads
        const timer = setTimeout(() => {
            const iframe = document.querySelector('iframe[src*="5004"]') as HTMLIFrameElement;
            if (iframe && iframe.contentWindow && course && courseId) {
                // Send course data to open detail view
                iframe.contentWindow.postMessage({
                    type: 'OPEN_COURSE_DETAIL',
                    courseId: courseId,
                    course: course
                }, '*');
            }
        }, 300);

        return () => {
            window.removeEventListener('message', handleMessage);
            clearTimeout(timer);
        };
    }, [course, courseId, navigate]);

    return <RemoteApp moduleName="courses" />;
};

export default CourseDetail;

