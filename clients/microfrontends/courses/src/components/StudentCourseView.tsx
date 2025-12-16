import React, { useState, useEffect, useMemo } from 'react';
import { 
    ArrowLeft, BookOpen, FileText, Video, Image as ImageIcon, 
    Play, ChevronDown, ChevronRight, HelpCircle, Layers, CheckCircle2, 
    Circle, Clock, Award, Menu, X, List, ChevronLeft, Sparkles, Loader
} from 'lucide-react';
import { motion, AnimatePresence, useSpring, useTransform } from 'framer-motion';
import type { Course, Module, Lesson, LessonContent, Quiz, Question } from '../../shell/src/api/types';

interface StudentCourseViewProps {
    course: Course;
    theme?: 'light' | 'dark';
    onBack?: () => void;
}

interface ProgressState {
    completedLessons: Set<string>;
    completionRate: number;
}

const StudentCourseView: React.FC<StudentCourseViewProps> = ({ course: initialCourse, theme = 'light', onBack }) => {
    const [course, setCourse] = useState<Course | null>(initialCourse || null);
    const [modules, setModules] = useState<Module[]>([]);
    const [quizzes, setQuizzes] = useState<Quiz[]>([]);
    const [expandedModules, setExpandedModules] = useState<Set<string>>(new Set());
    const [expandedLessons, setExpandedLessons] = useState<Set<string>>(new Set());
    const [isLoading, setIsLoading] = useState(true);
    const [error, setError] = useState<string | null>(null);
    const [sidebarOpen, setSidebarOpen] = useState(true);
    const [selectedContent, setSelectedContent] = useState<{ type: 'lesson' | 'quiz', id: string, lessonId?: string, moduleId?: string, contentIndex?: number } | null>(null);
    const [completedLessons, setCompletedLessons] = useState<Set<string>>(new Set());
    const [isMarkingComplete, setIsMarkingComplete] = useState(false);

    // Calculate all content items for navigation
    const allContentItems = useMemo(() => {
        const items: Array<{ type: 'lesson' | 'quiz', id: string, lessonId?: string, moduleId?: string, contentIndex?: number, title: string }> = [];
        
        modules.forEach(module => {
            module.lessons?.forEach(lesson => {
                lesson.contents?.forEach((content, idx) => {
                    items.push({
                        type: 'lesson',
                        id: content.id,
                        lessonId: lesson.id,
                        moduleId: module.id,
                        contentIndex: idx,
                        title: `${lesson.title} - ${content.type}`
                    });
                });
            });
        });
        
        quizzes.forEach(quiz => {
            items.push({
                type: 'quiz',
                id: quiz.id,
                title: quiz.title
            });
        });
        
        return items;
    }, [modules, quizzes]);

    // Calculate current index for navigation
    const currentIndex = useMemo(() => {
        if (!selectedContent) return -1;
        return allContentItems.findIndex(item => 
            item.id === selectedContent.id && item.type === selectedContent.type
        );
    }, [selectedContent, allContentItems]);

    // Calculate progress
    const progress = useMemo(() => {
        const totalLessons = modules.reduce((acc, m) => acc + (m.lessons?.length || 0), 0);
        const completed = completedLessons.size;
        return totalLessons > 0 ? Math.round((completed / totalLessons) * 100) : 0;
    }, [modules, completedLessons]);

    // Smooth progress animation
    const progressSpring = useSpring(0, { stiffness: 100, damping: 30 });
    const progressWidth = useTransform(progressSpring, (value) => `${value}%`);

    useEffect(() => {
        progressSpring.set(progress);
    }, [progress, progressSpring]);

    // Find the selected content - must be before conditional returns
    const selectedContentData = useMemo(() => {
        let selectedLesson: Lesson | null = null;
        let selectedModule: Module | null = null;
        let selectedContentItem: LessonContent | null = null;
        let selectedQuiz: Quiz | null = null;

        if (selectedContent?.type === 'lesson' && selectedContent.lessonId) {
            selectedModule = modules.find(m => m.id === selectedContent.moduleId) || null;
            selectedLesson = selectedModule?.lessons?.find(l => l.id === selectedContent.lessonId) || null;
            selectedContentItem = selectedLesson?.contents?.find(c => c.id === selectedContent.id) || null;
        } else if (selectedContent?.type === 'quiz') {
            selectedQuiz = quizzes.find(q => q.id === selectedContent.id) || null;
        }

        return { selectedLesson, selectedModule, selectedContentItem, selectedQuiz };
    }, [selectedContent, modules, quizzes]);

    // Check if current content is the last item in the lesson - must be before conditional returns
    const isLastContentInLesson = useMemo(() => {
        const { selectedLesson, selectedContentItem } = selectedContentData;
        if (!selectedLesson || !selectedContentItem || !selectedContent?.lessonId) {
            return false;
        }
        const lessonContents = selectedLesson.contents || [];
        if (lessonContents.length === 0) return false;
        
        // Find the index of current content in the lesson
        const currentContentIndex = lessonContents.findIndex(c => c.id === selectedContentItem?.id);
        
        // Check if it's the last content item in this lesson
        return currentContentIndex === lessonContents.length - 1;
    }, [selectedContentData, selectedContent?.lessonId]);

    // Listen for course data
    useEffect(() => {
        const handleOpenCourse = (event: MessageEvent) => {
            if (event.data.type === 'OPEN_STUDENT_COURSE' && event.data.course) {
                setCourse(event.data.course);
                setIsLoading(true);
                window.parent.postMessage({
                    type: 'FETCH_COURSE_CONTENT',
                    courseId: event.data.course.id
                }, '*');
            }
        };

        window.addEventListener('message', handleOpenCourse);
        
        if (course) {
            loadCourseContent();
        }

        return () => {
            window.removeEventListener('message', handleOpenCourse);
        };
    }, []);

    useEffect(() => {
        if (course) {
            loadCourseContent();
        }
    }, [course?.id]);

    const loadCourseContent = () => {
        if (!course) return;
        
        setIsLoading(true);
        setError(null);

        window.parent.postMessage({
            type: 'FETCH_COURSE_CONTENT',
            courseId: course.id
        }, '*');

        // Also fetch progress
        window.parent.postMessage({
            type: 'FETCH_COURSE_PROGRESS',
            courseId: course.id
        }, '*');
    };

    useEffect(() => {
        const handleMessage = (event: MessageEvent) => {
            if (event.data.type === 'COURSE_CONTENT_LOADED') {
                setModules(event.data.modules || []);
                setQuizzes(event.data.quizzes || []);
                setIsLoading(false);
                
                // Auto-expand first module
                if (event.data.modules && event.data.modules.length > 0) {
                    setExpandedModules(new Set([event.data.modules[0].id]));
                    
                    // Auto-expand first lesson if exists
                    const firstModule = event.data.modules[0];
                    if (firstModule.lessons && firstModule.lessons.length > 0) {
                        setExpandedLessons(new Set([firstModule.lessons[0].id]));
                    }
                }
            }

            if (event.data.type === 'COURSE_PROGRESS_LOADED') {
                // Extract completed lesson IDs from the allLessonProgress array
                const completedLessonIds = event.data.allLessonProgress
                    ?.filter((lp: any) => lp.completed)
                    .map((lp: any) => lp.lessonId) || event.data.completedLessons || [];
                const completed = new Set(completedLessonIds);
                setCompletedLessons(completed);
                console.log('[StudentCourseView] Course progress loaded:', {
                    totalProgress: event.data.allLessonProgress?.length || 0,
                    completedCount: completed.size
                });
            }

            if (event.data.type === 'COURSE_CONTENT_ERROR') {
                setError(event.data.error);
                setIsLoading(false);
            }

            if (event.data.type === 'LESSON_MARKED_COMPLETE') {
                setCompletedLessons(prev => new Set([...prev, event.data.lessonId]));
                setIsMarkingComplete(false);
            }
        };

        window.addEventListener('message', handleMessage);
        return () => window.removeEventListener('message', handleMessage);
    }, [course?.id]);

    const toggleModule = (moduleId: string) => {
        setExpandedModules(prev => {
            const newSet = new Set(prev);
            if (newSet.has(moduleId)) {
                newSet.delete(moduleId);
            } else {
                newSet.add(moduleId);
            }
            return newSet;
        });
    };

    const toggleLesson = (lessonId: string) => {
        setExpandedLessons(prev => {
            const newSet = new Set(prev);
            if (newSet.has(lessonId)) {
                newSet.delete(lessonId);
            } else {
                newSet.add(lessonId);
            }
            return newSet;
        });
    };

    const getContentIcon = (type: string) => {
        switch (type) {
            case 'VIDEO':
                return <Video size={18} className="text-red-500" />;
            case 'IMAGE':
                return <ImageIcon size={18} className="text-blue-500" />;
            case 'TEXT':
                return <FileText size={18} className="text-green-500" />;
            case 'PDF':
                return <FileText size={18} className="text-orange-500" />;
            default:
                return <FileText size={18} className="text-gray-500" />;
        }
    };

    const handleBack = () => {
        setSelectedContent(null);
        if (onBack) {
            onBack();
        } else {
            window.parent.postMessage({
                type: 'STUDENT_COURSE_BACK'
            }, '*');
        }
    };

    const handleContentClick = (content: LessonContent, lessonId: string, moduleId: string, contentIndex: number) => {
        setSelectedContent({ 
            type: 'lesson', 
            id: content.id, 
            lessonId, 
            moduleId,
            contentIndex 
        });
        // Auto-collapse sidebar on mobile for better focus
        if (window.innerWidth < 1024) {
            setSidebarOpen(false);
        }
    };

    const handleQuizClick = (quiz: Quiz) => {
        setSelectedContent({ type: 'quiz', id: quiz.id });
        if (window.innerWidth < 1024) {
            setSidebarOpen(false);
        }
    };

    const navigateContent = (direction: 'prev' | 'next') => {
        if (currentIndex === -1) return;
        
        const newIndex = direction === 'next' ? currentIndex + 1 : currentIndex - 1;
        if (newIndex >= 0 && newIndex < allContentItems.length) {
            const item = allContentItems[newIndex];
            setSelectedContent({
                type: item.type,
                id: item.id,
                lessonId: item.lessonId,
                moduleId: item.moduleId,
                contentIndex: item.contentIndex
            });
        }
    };

    const handleMarkComplete = async () => {
        // Always mark the lesson as complete, not individual content
        if (!selectedContent || selectedContent.type !== 'lesson' || !selectedContent.lessonId) return;
        
        setIsMarkingComplete(true);
        
        // Get the lesson from the selected content to display its title
        const lesson = selectedModule?.lessons?.find(l => l.id === selectedContent?.lessonId);
        
        window.parent.postMessage({
            type: 'MARK_LESSON_COMPLETE',
            lessonId: selectedContent.lessonId,
            lessonTitle: lesson?.title || 'Lesson'
        }, '*');
    };

    const isLessonCompleted = (lessonId: string) => {
        return completedLessons.has(lessonId);
    };

    // Helper function to check if URL is YouTube
    const isYouTubeUrl = (url: string): boolean => {
        if (!url) return false;
        const youtubeRegex = /^(https?:\/\/)?(www\.)?(youtube\.com|youtu\.be)\/.+/;
        return youtubeRegex.test(url);
    };

    // Helper function to convert YouTube URL to embed URL
    const getYouTubeEmbedUrl = (url: string): string => {
        if (!url) return '';
        
        // Extract video ID from various YouTube URL formats
        let videoId = '';
        
        // Format: https://www.youtube.com/watch?v=VIDEO_ID
        const watchMatch = url.match(/(?:youtube\.com\/watch\?v=|youtu\.be\/)([^&\n?#]+)/);
        if (watchMatch) {
            videoId = watchMatch[1];
        }
        
        // Format: https://www.youtube.com/embed/VIDEO_ID
        const embedMatch = url.match(/youtube\.com\/embed\/([^&\n?#]+)/);
        if (embedMatch) {
            videoId = embedMatch[1];
        }
        
        // If no match found, try to extract from URL path
        if (!videoId) {
            const pathMatch = url.match(/youtu\.be\/([^&\n?#]+)/);
            if (pathMatch) {
                videoId = pathMatch[1];
            }
        }
        
        if (!videoId) {
            console.warn('[StudentCourseView] Could not extract YouTube video ID from URL:', url);
            return url; // Fallback to original URL
        }
        
        return `https://www.youtube.com/embed/${videoId}?rel=0&modestbranding=1`;
    };

    if (isLoading) {
        return (
            <div className="fixed inset-0 bg-gradient-to-br from-purple-50 via-indigo-50 to-blue-50 dark:from-gray-900 dark:via-gray-800 dark:to-gray-900 flex items-center justify-center z-50">
                <motion.div 
                    initial={{ opacity: 0, scale: 0.9 }}
                    animate={{ opacity: 1, scale: 1 }}
                    className="text-center"
                >
                    <div className="relative">
                        <div className="animate-spin rounded-full h-20 w-20 border-4 border-purple-200 dark:border-purple-900 border-t-purple-600 mx-auto mb-6"></div>
                        <Sparkles className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 text-purple-500 animate-pulse" size={24} />
                    </div>
                    <p className="text-gray-600 dark:text-gray-400 text-lg font-medium">Loading course content...</p>
                    <p className="text-gray-500 dark:text-gray-500 text-sm mt-2">Please wait</p>
                </motion.div>
            </div>
        );
    }

    if (error) {
        return (
            <div className="fixed inset-0 bg-gradient-to-br from-purple-50 to-indigo-50 dark:from-gray-900 dark:to-gray-800 flex items-center justify-center z-50 p-8">
                <motion.div 
                    initial={{ opacity: 0, y: 20 }}
                    animate={{ opacity: 1, y: 0 }}
                    className="bg-white dark:bg-gray-800 rounded-2xl shadow-2xl p-8 max-w-md w-full text-center"
                >
                    <div className="w-16 h-16 bg-red-100 dark:bg-red-900/20 rounded-full flex items-center justify-center mx-auto mb-4">
                        <X size={32} className="text-red-500" />
                    </div>
                    <p className="text-red-500 mb-4 text-lg font-semibold">{error}</p>
                    <button
                        onClick={loadCourseContent}
                        className="px-6 py-3 bg-purple-600 text-white rounded-lg hover:bg-purple-700 transition-all font-medium shadow-lg hover:shadow-xl transform hover:-translate-y-0.5"
                    >
                        Try Again
                    </button>
                </motion.div>
            </div>
        );
    }

    if (!course) {
        return (
            <div className="fixed inset-0 bg-gradient-to-br from-purple-50 to-indigo-50 dark:from-gray-900 dark:to-gray-800 flex items-center justify-center z-50">
                <div className="text-center">
                    <p className="text-gray-600 dark:text-gray-400 text-lg">Course not found</p>
                    <button
                        onClick={handleBack}
                        className="mt-4 px-6 py-3 bg-purple-600 text-white rounded-lg hover:bg-purple-700 transition-colors font-medium"
                    >
                        Go Back
                    </button>
                </div>
            </div>
        );
    }

    // Use the pre-computed selected content data
    const { selectedLesson, selectedModule, selectedContentItem, selectedQuiz } = selectedContentData;

    const totalLessons = modules.reduce((acc, m) => acc + (m.lessons?.length || 0), 0);
    const totalQuizzes = quizzes.length;
    const hasPrevious = currentIndex > 0;
    const hasNext = currentIndex < allContentItems.length - 1;
    const isCurrentLessonCompleted = selectedContent?.type === 'lesson' && selectedContent.lessonId 
        ? isLessonCompleted(selectedContent.lessonId) 
        : false;

    return (
        <div className="fixed inset-0 bg-gradient-to-br from-purple-50 via-indigo-50 to-blue-50 dark:from-gray-900 dark:via-gray-800 dark:to-gray-900 overflow-hidden flex flex-col z-50">
            {/* Top Header Bar - Enhanced */}
            <motion.div 
                initial={{ y: -100 }}
                animate={{ y: 0 }}
                className="bg-white/95 dark:bg-gray-800/95 backdrop-blur-xl border-b border-gray-200/50 dark:border-gray-700/50 px-4 sm:px-6 py-3 sm:py-4 flex items-center justify-between shadow-lg"
            >
                <div className="flex items-center gap-2 sm:gap-4 flex-1 min-w-0">
                    <motion.button
                        whileHover={{ scale: 1.05 }}
                        whileTap={{ scale: 0.95 }}
                        onClick={() => setSidebarOpen(!sidebarOpen)}
                        className="p-2 hover:bg-gray-100 dark:hover:bg-gray-700 rounded-lg transition-colors flex-shrink-0"
                    >
                        {sidebarOpen ? <X size={20} /> : <Menu size={20} />}
                    </motion.button>
                    <motion.button
                        whileHover={{ scale: 1.05 }}
                        whileTap={{ scale: 0.95 }}
                        onClick={handleBack}
                        className="flex items-center gap-2 text-gray-600 dark:text-gray-400 hover:text-gray-900 dark:hover:text-white transition-colors flex-shrink-0"
                    >
                        <ArrowLeft size={20} />
                        <span className="hidden sm:inline">Back</span>
                    </motion.button>
                    <div className="h-6 w-px bg-gray-300 dark:bg-gray-600 hidden sm:block"></div>
                    <h1 className="text-lg sm:text-xl font-bold text-gray-900 dark:text-white truncate min-w-0 flex-1">
                        {course.title}
                    </h1>
                </div>
                <div className="hidden md:flex items-center gap-4 text-sm text-gray-600 dark:text-gray-400 flex-shrink-0">
                    <div className="flex items-center gap-2">
                        <BookOpen size={16} />
                        <span>{modules.length}</span>
                    </div>
                    <div className="flex items-center gap-2">
                        <Layers size={16} />
                        <span>{totalLessons}</span>
                    </div>
                    <div className="flex items-center gap-2">
                        <HelpCircle size={16} />
                        <span>{totalQuizzes}</span>
                    </div>
                </div>
            </motion.div>

            <div className="flex-1 flex overflow-hidden">
                {/* Sidebar - Enhanced with smooth animations */}
                <AnimatePresence mode="wait">
                    {sidebarOpen && (
                        <motion.div
                            initial={{ x: -400, opacity: 0 }}
                            animate={{ x: 0, opacity: 1 }}
                            exit={{ x: -400, opacity: 0 }}
                            transition={{ 
                                type: 'spring', 
                                damping: 30, 
                                stiffness: 300,
                                mass: 0.8
                            }}
                            className="w-80 bg-white/95 dark:bg-gray-800/95 backdrop-blur-xl border-r border-gray-200/50 dark:border-gray-700/50 overflow-y-auto overflow-x-hidden"
                            style={{ scrollbarWidth: 'thin' }}
                        >
                            <div className="p-4 sm:p-6">
                                {/* Course Info Card - Enhanced */}
                                <motion.div 
                                    initial={{ scale: 0.95, opacity: 0 }}
                                    animate={{ scale: 1, opacity: 1 }}
                                    transition={{ delay: 0.1 }}
                                    className="bg-gradient-to-br from-purple-500 via-indigo-600 to-blue-600 rounded-2xl p-5 sm:p-6 mb-6 text-white shadow-xl relative overflow-hidden"
                                >
                                    <div className="absolute top-0 right-0 w-32 h-32 bg-white/10 rounded-full -mr-16 -mt-16 blur-2xl"></div>
                                    <div className="relative z-10">
                                        <div className="flex items-center gap-3 mb-3">
                                            <motion.div 
                                                whileHover={{ rotate: 360, scale: 1.1 }}
                                                transition={{ duration: 0.6 }}
                                                className="w-12 h-12 bg-white/20 rounded-xl flex items-center justify-center backdrop-blur-sm"
                                            >
                                                <BookOpen size={24} />
                                            </motion.div>
                                            <div>
                                                <p className="font-semibold text-sm opacity-90">{course.category}</p>
                                                <p className="text-xs opacity-75 bg-white/20 px-2 py-0.5 rounded-full inline-block mt-1">
                                                    {course.level}
                                                </p>
                                            </div>
                                        </div>
                                        <p className="text-sm opacity-90 line-clamp-2 leading-relaxed">{course.description}</p>
                                    </div>
                                </motion.div>

                                {/* Progress Summary - Enhanced with animation */}
                                <motion.div 
                                    initial={{ scale: 0.95, opacity: 0 }}
                                    animate={{ scale: 1, opacity: 1 }}
                                    transition={{ delay: 0.2 }}
                                    className="bg-gradient-to-br from-gray-50 to-gray-100 dark:from-gray-700/50 dark:to-gray-800/50 rounded-xl p-4 sm:p-5 mb-6 border border-gray-200/50 dark:border-gray-600/50"
                                >
                                    <div className="flex items-center justify-between mb-3">
                                        <span className="text-sm font-semibold text-gray-700 dark:text-gray-300">Progress</span>
                                        <span className="text-lg font-bold text-purple-600 dark:text-purple-400">{progress}%</span>
                                    </div>
                                    <div className="w-full bg-gray-200 dark:bg-gray-600 rounded-full h-3 overflow-hidden shadow-inner">
                                        <motion.div 
                                            style={{ width: progressWidth }}
                                            className="bg-gradient-to-r from-purple-500 via-indigo-500 to-blue-500 h-3 rounded-full shadow-lg relative"
                                        >
                                            <motion.div 
                                                animate={{ x: ['-100%', '100%'] }}
                                                transition={{ 
                                                    repeat: Infinity, 
                                                    duration: 2,
                                                    ease: 'linear'
                                                }}
                                                className="absolute inset-0 bg-gradient-to-r from-transparent via-white/30 to-transparent"
                                            />
                                        </motion.div>
                                    </div>
                                    <p className="text-xs text-gray-500 dark:text-gray-400 mt-2">
                                        {completedLessons.size} of {totalLessons} lessons completed
                                    </p>
                                </motion.div>

                                {/* Modules - Enhanced */}
                                <div className="space-y-3">
                                    <h3 className="text-xs font-bold text-gray-700 dark:text-gray-300 uppercase tracking-wider mb-3 flex items-center gap-2">
                                        <Layers size={14} />
                                        <span>Modules & Lessons</span>
                                    </h3>
                                    {modules
                                        .sort((a, b) => a.orderIndex - b.orderIndex)
                                        .map((module, moduleIdx) => {
                                            const moduleLessons = module.lessons || [];
                                            const moduleCompleted = moduleLessons.filter(l => isLessonCompleted(l.id)).length;
                                            const moduleProgress = moduleLessons.length > 0 
                                                ? Math.round((moduleCompleted / moduleLessons.length) * 100) 
                                                : 0;

                                            return (
                                                <motion.div 
                                                    key={module.id}
                                                    initial={{ opacity: 0, y: 10 }}
                                                    animate={{ opacity: 1, y: 0 }}
                                                    transition={{ delay: 0.1 * moduleIdx }}
                                                    className="border border-gray-200 dark:border-gray-700 rounded-xl overflow-hidden bg-white dark:bg-gray-800/50 shadow-sm hover:shadow-md transition-shadow"
                                                >
                                                    <button
                                                        onClick={() => toggleModule(module.id)}
                                                        className="w-full px-4 py-3 bg-gradient-to-r from-gray-50 to-white dark:from-gray-700/50 dark:to-gray-800 hover:from-purple-50 hover:to-indigo-50 dark:hover:from-purple-900/20 dark:hover:to-indigo-900/20 transition-all flex items-center justify-between group"
                                                    >
                                                        <div className="flex items-center gap-3 flex-1 min-w-0">
                                                            <div className="w-8 h-8 rounded-lg bg-gradient-to-br from-purple-500 to-indigo-600 text-white flex items-center justify-center font-bold text-sm shadow-md flex-shrink-0">
                                                                {moduleIdx + 1}
                                                            </div>
                                                            <div className="flex-1 min-w-0">
                                                                <span className="font-semibold text-gray-900 dark:text-white text-sm text-left block truncate">
                                                                    {module.title}
                                                                </span>
                                                                <span className="text-xs text-gray-500 dark:text-gray-400">
                                                                    {moduleProgress}% complete
                                                                </span>
                                                            </div>
                                                        </div>
                                                        <motion.div
                                                            animate={{ rotate: expandedModules.has(module.id) ? 180 : 0 }}
                                                            transition={{ duration: 0.2 }}
                                                        >
                                                            <ChevronDown size={18} className="text-gray-500 flex-shrink-0" />
                                                        </motion.div>
                                                    </button>

                                                    <AnimatePresence>
                                                        {expandedModules.has(module.id) && module.lessons && (
                                                            <motion.div
                                                                initial={{ height: 0, opacity: 0 }}
                                                                animate={{ height: 'auto', opacity: 1 }}
                                                                exit={{ height: 0, opacity: 0 }}
                                                                transition={{ duration: 0.3, ease: 'easeInOut' }}
                                                                className="bg-white dark:bg-gray-800 border-t border-gray-100 dark:border-gray-700"
                                                            >
                                                                {module.lessons
                                                                    .sort((a, b) => a.orderIndex - b.orderIndex)
                                                                    .map((lesson, lessonIdx) => {
                                                                        const isCompleted = isLessonCompleted(lesson.id);
                                                                        const isActive = selectedContent?.lessonId === lesson.id;

                                                                        return (
                                                                            <div key={lesson.id} className="border-t border-gray-100 dark:border-gray-700 first:border-t-0">
                                                                                <button
                                                                                    onClick={() => toggleLesson(lesson.id)}
                                                                                    className={`w-full px-4 py-2.5 pl-12 hover:bg-gray-50 dark:hover:bg-gray-700/50 transition-all flex items-center justify-between group ${
                                                                                        isActive ? 'bg-purple-50 dark:bg-purple-900/20' : ''
                                                                                    }`}
                                                                                >
                                                                                    <div className="flex items-center gap-2 flex-1 min-w-0">
                                                                                        {isCompleted ? (
                                                                                            <CheckCircle2 size={14} className="text-green-500 flex-shrink-0" />
                                                                                        ) : (
                                                                                            <Circle size={14} className="text-gray-400 flex-shrink-0" />
                                                                                        )}
                                                                                        <span className={`text-sm flex-1 text-left truncate ${
                                                                                            isActive 
                                                                                                ? 'text-purple-700 dark:text-purple-300 font-semibold' 
                                                                                                : 'text-gray-700 dark:text-gray-300'
                                                                                        }`}>
                                                                                            {lesson.title}
                                                                                        </span>
                                                                                    </div>
                                                                                    <motion.div
                                                                                        animate={{ rotate: expandedLessons.has(lesson.id) ? 90 : 0 }}
                                                                                        transition={{ duration: 0.2 }}
                                                                                    >
                                                                                        <ChevronRight size={14} className="text-gray-400 flex-shrink-0" />
                                                                                    </motion.div>
                                                                                </button>

                                                                                <AnimatePresence>
                                                                                    {expandedLessons.has(lesson.id) && lesson.contents && (
                                                                                        <motion.div
                                                                                            initial={{ height: 0 }}
                                                                                            animate={{ height: 'auto' }}
                                                                                            exit={{ height: 0 }}
                                                                                            transition={{ duration: 0.25 }}
                                                                                            className="bg-gray-50/50 dark:bg-gray-700/30"
                                                                                        >
                                                                                            {lesson.contents
                                                                                                .sort((a, b) => a.orderIndex - b.orderIndex)
                                                                                                .map((content, contentIdx) => {
                                                                                                    const isContentActive = selectedContent?.id === content.id;
                                                                                                    return (
                                                                                                        <motion.button
                                                                                                            key={content.id}
                                                                                                            whileHover={{ x: 4 }}
                                                                                                            onClick={() => handleContentClick(content, lesson.id, module.id, contentIdx)}
                                                                                                            className={`w-full px-4 py-2 pl-16 hover:bg-purple-100 dark:hover:bg-purple-900/30 transition-all flex items-center gap-3 text-left ${
                                                                                                                isContentActive 
                                                                                                                    ? 'bg-purple-100 dark:bg-purple-900/30 border-l-2 border-purple-500' 
                                                                                                                    : ''
                                                                                                            }`}
                                                                                                        >
                                                                                                            {getContentIcon(content.type)}
                                                                                                            <span className="text-xs text-gray-600 dark:text-gray-400 flex-1 truncate">
                                                                                                                {content.type === 'TEXT' && content.textContent
                                                                                                                    ? content.textContent.substring(0, 35) + '...'
                                                                                                                    : `${content.type} Content`}
                                                                                                            </span>
                                                                                                            <Play size={12} className="text-purple-500 flex-shrink-0" />
                                                                                                        </motion.button>
                                                                                                    );
                                                                                                })}
                                                                                        </motion.div>
                                                                                    )}
                                                                                </AnimatePresence>
                                                                            </div>
                                                                        );
                                                                    })}
                                                            </motion.div>
                                                        )}
                                                    </AnimatePresence>
                                                </motion.div>
                                            );
                                        })}
                                </div>

                                {/* Quizzes - Enhanced */}
                                {quizzes.length > 0 && (
                                    <motion.div 
                                        initial={{ opacity: 0 }}
                                        animate={{ opacity: 1 }}
                                        transition={{ delay: 0.3 }}
                                        className="mt-6 space-y-2"
                                    >
                                        <h3 className="text-xs font-bold text-gray-700 dark:text-gray-300 uppercase tracking-wider mb-3 flex items-center gap-2">
                                            <HelpCircle size={14} />
                                            <span>Quizzes</span>
                                        </h3>
                                        {quizzes.map((quiz) => {
                                            const isActive = selectedContent?.id === quiz.id && selectedContent?.type === 'quiz';
                                            return (
                                                <motion.button
                                                    key={quiz.id}
                                                    whileHover={{ scale: 1.02, x: 4 }}
                                                    whileTap={{ scale: 0.98 }}
                                                    onClick={() => handleQuizClick(quiz)}
                                                    className={`w-full px-4 py-3 bg-gradient-to-r from-orange-50 to-amber-50 dark:from-orange-900/20 dark:to-amber-900/20 border-2 rounded-xl hover:shadow-lg transition-all flex items-center gap-3 group ${
                                                        isActive 
                                                            ? 'border-orange-500 shadow-lg' 
                                                            : 'border-orange-200 dark:border-orange-800'
                                                    }`}
                                                >
                                                    <div className="w-10 h-10 rounded-xl bg-gradient-to-br from-orange-500 to-amber-500 text-white flex items-center justify-center shadow-md flex-shrink-0">
                                                        <HelpCircle size={20} />
                                                    </div>
                                                    <div className="flex-1 text-left min-w-0">
                                                        <p className="font-semibold text-gray-900 dark:text-white text-sm truncate">
                                                            {quiz.title}
                                                        </p>
                                                        <p className="text-xs text-gray-600 dark:text-gray-400">
                                                            {quiz.questions?.length || 0} questions
                                                        </p>
                                                    </div>
                                                    <ChevronRight size={18} className="text-orange-500 group-hover:translate-x-1 transition-transform flex-shrink-0" />
                                                </motion.button>
                                            );
                                        })}
                                    </motion.div>
                                )}
                            </div>
                        </motion.div>
                    )}
                </AnimatePresence>

                {/* Main Content Area - Enhanced with better transitions */}
                <div className="flex-1 overflow-y-auto bg-white dark:bg-gray-900 relative">
                    <AnimatePresence mode="wait">
                        {selectedContent ? (
                            selectedContent.type === 'lesson' && selectedContentItem ? (
                                <motion.div
                                    key={`lesson-${selectedContent.id}`}
                                    initial={{ opacity: 0, x: 30 }}
                                    animate={{ opacity: 1, x: 0 }}
                                    exit={{ opacity: 0, x: -30 }}
                                    transition={{ 
                                        type: 'spring',
                                        damping: 25,
                                        stiffness: 300
                                    }}
                                    className="h-full"
                                >
                                    {/* Lesson Content Header - Enhanced */}
                                    <div className="sticky top-0 z-10 bg-gradient-to-r from-white via-white to-white/95 dark:from-gray-900 dark:via-gray-900 dark:to-gray-900/95 backdrop-blur-xl border-b border-gray-200 dark:border-gray-700 px-4 sm:px-8 lg:px-12 py-4 sm:py-6 shadow-sm">
                                        <div className="max-w-5xl mx-auto">
                                            <div className="flex items-center gap-3 mb-2">
                                                <motion.button
                                                    whileHover={{ scale: 1.1, x: -2 }}
                                                    whileTap={{ scale: 0.95 }}
                                                    onClick={() => {
                                                        setSelectedContent(null);
                                                        setSidebarOpen(true);
                                                    }}
                                                    className="p-2 hover:bg-gray-100 dark:hover:bg-gray-800 rounded-lg transition-colors"
                                                >
                                                    <ArrowLeft size={20} />
                                                </motion.button>
                                                <div className="h-6 w-px bg-gray-300 dark:bg-gray-700"></div>
                                                <div className="flex-1 min-w-0">
                                                    <p className="text-xs sm:text-sm text-purple-600 dark:text-purple-400 font-medium truncate">
                                                        {selectedModule?.title}
                                                    </p>
                                                    <p className="text-base sm:text-lg font-bold text-gray-900 dark:text-white truncate">
                                                        {selectedLesson?.title}
                                                    </p>
                                                </div>
                                                {isCurrentLessonCompleted && (
                                                    <motion.div
                                                        initial={{ scale: 0 }}
                                                        animate={{ scale: 1 }}
                                                        className="w-8 h-8 rounded-full bg-green-500 flex items-center justify-center"
                                                    >
                                                        <CheckCircle2 size={20} className="text-white" />
                                                    </motion.div>
                                                )}
                                            </div>
                                        </div>
                                    </div>

                                    {/* Content Display - Enhanced */}
                                    <div className="max-w-5xl mx-auto p-4 sm:p-8 lg:p-12">
                                        {/* Lesson Completion Info Banner */}
                                        {selectedLesson && (
                                            <motion.div 
                                                initial={{ y: -10, opacity: 0 }}
                                                animate={{ y: 0, opacity: 1 }}
                                                className={`mb-4 p-4 rounded-xl border-2 ${
                                                    isCurrentLessonCompleted
                                                        ? 'bg-green-50 dark:bg-green-900/20 border-green-300 dark:border-green-700'
                                                        : 'bg-blue-50 dark:bg-blue-900/20 border-blue-300 dark:border-blue-700'
                                                }`}
                                            >
                                                <div className="flex items-center gap-3">
                                                    {isCurrentLessonCompleted ? (
                                                        <>
                                                            <CheckCircle2 size={20} className="text-green-600 dark:text-green-400" />
                                                            <div>
                                                                <p className="font-semibold text-green-900 dark:text-green-300">
                                                                    Lesson Completed
                                                                </p>
                                                                <p className="text-sm text-green-700 dark:text-green-400">
                                                                    You've completed "{selectedLesson.title}"
                                                                </p>
                                                            </div>
                                                        </>
                                                    ) : (
                                                        <>
                                                            <Circle size={20} className="text-blue-600 dark:text-blue-400" />
                                                            <div>
                                                                <p className="font-semibold text-blue-900 dark:text-blue-300">
                                                                    Lesson in Progress
                                                                </p>
                                                                <p className="text-sm text-blue-700 dark:text-blue-400">
                                                                    Complete all content and click "Mark Lesson Complete" below
                                                                </p>
                                                            </div>
                                                        </>
                                                    )}
                                                </div>
                                            </motion.div>
                                        )}

                                        <motion.div 
                                            initial={{ y: 20, opacity: 0 }}
                                            animate={{ y: 0, opacity: 1 }}
                                            transition={{ delay: 0.1 }}
                                            className="bg-gradient-to-br from-purple-50 via-indigo-50 to-blue-50 dark:from-gray-800 dark:via-gray-700 rounded-3xl p-6 sm:p-8 lg:p-10 mb-6 shadow-xl border border-purple-100 dark:border-gray-600"
                                        >
                                            <div className="flex items-center gap-3 mb-6">
                                                <div className="w-10 h-10 rounded-xl bg-white dark:bg-gray-800 flex items-center justify-center shadow-md">
                                                    {getContentIcon(selectedContentItem.type)}
                                                </div>
                                                <div className="flex-1">
                                                    <span className="text-sm font-semibold text-gray-700 dark:text-gray-300 uppercase tracking-wide">
                                                        {selectedContentItem.type} Content
                                                    </span>
                                                    <p className="text-xs text-gray-500 dark:text-gray-400 mt-1">
                                                        Part of lesson: {selectedLesson?.title || 'Lesson'}
                                                    </p>
                                                </div>
                                            </div>
                                            
                                            {selectedContentItem.type === 'TEXT' && selectedContentItem.textContent && (
                                                <motion.div 
                                                    initial={{ opacity: 0 }}
                                                    animate={{ opacity: 1 }}
                                                    transition={{ delay: 0.2 }}
                                                    className="prose dark:prose-invert max-w-none"
                                                >
                                                    <div className="whitespace-pre-wrap text-gray-800 dark:text-gray-200 leading-relaxed text-base sm:text-lg">
                                                        {selectedContentItem.textContent}
                                                    </div>
                                                </motion.div>
                                            )}
                                            
                                            {selectedContentItem.type === 'VIDEO' && selectedContentItem.videoUrl && (
                                                <motion.div 
                                                    initial={{ opacity: 0, scale: 0.95 }}
                                                    animate={{ opacity: 1, scale: 1 }}
                                                    transition={{ delay: 0.2 }}
                                                    className="aspect-video rounded-2xl overflow-hidden bg-black shadow-2xl"
                                                >
                                                    {isYouTubeUrl(selectedContentItem.videoUrl) ? (
                                                        <iframe
                                                            src={getYouTubeEmbedUrl(selectedContentItem.videoUrl)}
                                                            title="YouTube video player"
                                                            allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share"
                                                            allowFullScreen
                                                            className="w-full h-full"
                                                        />
                                                    ) : (
                                                        <video 
                                                            src={selectedContentItem.videoUrl} 
                                                            controls 
                                                            className="w-full h-full"
                                                            preload="metadata"
                                                        >
                                                            Your browser does not support video playback.
                                                        </video>
                                                    )}
                                                </motion.div>
                                            )}
                                            
                                            {selectedContentItem.type === 'IMAGE' && selectedContentItem.imageUrl && (
                                                <motion.div 
                                                    initial={{ opacity: 0, scale: 0.95 }}
                                                    animate={{ opacity: 1, scale: 1 }}
                                                    transition={{ delay: 0.2 }}
                                                    className="rounded-2xl overflow-hidden shadow-2xl bg-gray-100 dark:bg-gray-800"
                                                >
                                                    <img 
                                                        src={selectedContentItem.imageUrl} 
                                                        alt="Lesson content"
                                                        className="w-full h-auto max-h-[80vh] object-contain mx-auto"
                                                        loading="lazy"
                                                        onError={(e) => {
                                                            const target = e.target as HTMLImageElement;
                                                            target.style.display = 'none';
                                                            const parent = target.parentElement;
                                                            if (parent) {
                                                                parent.innerHTML = `
                                                                    <div class="p-8 text-center text-gray-500 dark:text-gray-400">
                                                                        <p class="mb-2">Failed to load image</p>
                                                                        <a href="${selectedContentItem.imageUrl}" target="_blank" rel="noopener noreferrer" 
                                                                           class="text-blue-600 dark:text-blue-400 hover:underline">
                                                                            Open image in new tab
                                                                        </a>
                                                                    </div>
                                                                `;
                                                            }
                                                        }}
                                                    />
                                                </motion.div>
                                            )}

                                            {selectedContentItem.type === 'PDF' && selectedContentItem.pdfUrl && (
                                                <motion.div 
                                                    initial={{ opacity: 0, scale: 0.95 }}
                                                    animate={{ opacity: 1, scale: 1 }}
                                                    transition={{ delay: 0.2 }}
                                                    className="rounded-2xl overflow-hidden shadow-2xl bg-gray-100 dark:bg-gray-800"
                                                >
                                                    <div className="aspect-[4/3] w-full">
                                                        <iframe
                                                            src={selectedContentItem.pdfUrl}
                                                            title="PDF Viewer"
                                                            className="w-full h-full border-0"
                                                            style={{ minHeight: '600px' }}
                                                        />
                                                    </div>
                                                    <div className="p-4 bg-white dark:bg-gray-800 border-t border-gray-200 dark:border-gray-700">
                                                        <a
                                                            href={selectedContentItem.pdfUrl}
                                                            target="_blank"
                                                            rel="noopener noreferrer"
                                                            className="inline-flex items-center gap-2 text-blue-600 dark:text-blue-400 hover:text-blue-700 dark:hover:text-blue-300 font-medium"
                                                        >
                                                            <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                                                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M10 6H6a2 2 0 00-2 2v10a2 2 0 002 2h10a2 2 0 002-2v-4M14 4h6m0 0v6m0-6L10 14" />
                                                            </svg>
                                                            Open PDF in new tab
                                                        </a>
                                                    </div>
                                                </motion.div>
                                            )}
                                        </motion.div>

                                        {/* Navigation Buttons - Enhanced with smooth transitions */}
                                        <motion.div 
                                            initial={{ y: 20, opacity: 0 }}
                                            animate={{ y: 0, opacity: 1 }}
                                            transition={{ delay: 0.3 }}
                                            className="flex items-center justify-between gap-4"
                                        >
                                            <motion.button 
                                                whileHover={{ scale: 1.05, x: -4 }}
                                                whileTap={{ scale: 0.95 }}
                                                disabled={!hasPrevious}
                                                onClick={() => navigateContent('prev')}
                                                className={`px-4 sm:px-6 py-3 rounded-xl font-semibold transition-all flex items-center gap-2 ${
                                                    hasPrevious
                                                        ? 'bg-gray-100 dark:bg-gray-800 text-gray-700 dark:text-gray-300 hover:bg-gray-200 dark:hover:bg-gray-700 shadow-md hover:shadow-lg'
                                                        : 'bg-gray-50 dark:bg-gray-800/50 text-gray-400 dark:text-gray-600 cursor-not-allowed'
                                                }`}
                                            >
                                                <ChevronLeft size={20} />
                                                <span className="hidden sm:inline">Previous</span>
                                            </motion.button>
                                            
                                            {/* Show "Mark as Complete" button only on the last content item of the lesson */}
                                            {isLastContentInLesson && (
                                                <motion.button 
                                                    whileHover={{ scale: 1.05 }}
                                                    whileTap={{ scale: 0.95 }}
                                                    disabled={isMarkingComplete || isCurrentLessonCompleted}
                                                    onClick={handleMarkComplete}
                                                    className={`px-6 sm:px-8 py-3 bg-gradient-to-r from-purple-600 to-indigo-600 text-white rounded-xl font-semibold shadow-lg hover:shadow-xl transition-all flex items-center gap-2 ${
                                                        isMarkingComplete || isCurrentLessonCompleted
                                                            ? 'opacity-50 cursor-not-allowed'
                                                            : 'hover:from-purple-700 hover:to-indigo-700'
                                                    }`}
                                                    title={`Mark lesson "${selectedLesson?.title || 'Lesson'}" as complete`}
                                                >
                                                    {isMarkingComplete ? (
                                                        <>
                                                            <Loader className="animate-spin" size={18} />
                                                            <span className="hidden sm:inline">Marking Lesson...</span>
                                                        </>
                                                    ) : isCurrentLessonCompleted ? (
                                                        <>
                                                            <CheckCircle2 size={18} />
                                                            <span>Lesson Completed</span>
                                                        </>
                                                    ) : (
                                                        <>
                                                            <CheckCircle2 size={18} />
                                                            <span>Mark Lesson Complete</span>
                                                        </>
                                                    )}
                                                </motion.button>
                                            )}
                                            
                                            <motion.button 
                                                whileHover={{ scale: 1.05, x: 4 }}
                                                whileTap={{ scale: 0.95 }}
                                                disabled={!hasNext}
                                                onClick={() => navigateContent('next')}
                                                className={`px-4 sm:px-6 py-3 rounded-xl font-semibold transition-all flex items-center gap-2 ${
                                                    hasNext
                                                        ? 'bg-gray-100 dark:bg-gray-800 text-gray-700 dark:text-gray-300 hover:bg-gray-200 dark:hover:bg-gray-700 shadow-md hover:shadow-lg'
                                                        : 'bg-gray-50 dark:bg-gray-800/50 text-gray-400 dark:text-gray-600 cursor-not-allowed'
                                                }`}
                                            >
                                                <span className="hidden sm:inline">Next</span>
                                                <ChevronRight size={20} />
                                            </motion.button>
                                        </motion.div>

                                        {/* Progress Indicator */}
                                        <motion.div 
                                            initial={{ opacity: 0 }}
                                            animate={{ opacity: 1 }}
                                            transition={{ delay: 0.4 }}
                                            className="mt-6 text-center text-sm text-gray-500 dark:text-gray-400"
                                        >
                                            {currentIndex + 1} of {allContentItems.length}
                                        </motion.div>
                                    </div>
                                </motion.div>
                            ) : selectedContent.type === 'quiz' && selectedQuiz ? (
                                <motion.div
                                    key={`quiz-${selectedContent.id}`}
                                    initial={{ opacity: 0, x: 30 }}
                                    animate={{ opacity: 1, x: 0 }}
                                    exit={{ opacity: 0, x: -30 }}
                                    transition={{ 
                                        type: 'spring',
                                        damping: 25,
                                        stiffness: 300
                                    }}
                                    className="h-full"
                                >
                                    {/* Quiz Header - Enhanced */}
                                    <div className="sticky top-0 z-10 bg-gradient-to-r from-white via-white to-white/95 dark:from-gray-900 dark:via-gray-900 dark:to-gray-900/95 backdrop-blur-xl border-b border-gray-200 dark:border-gray-700 px-4 sm:px-8 lg:px-12 py-4 sm:py-6 shadow-sm">
                                        <div className="max-w-4xl mx-auto">
                                            <div className="flex items-center gap-3 mb-2">
                                                <motion.button
                                                    whileHover={{ scale: 1.1, x: -2 }}
                                                    whileTap={{ scale: 0.95 }}
                                                    onClick={() => {
                                                        setSelectedContent(null);
                                                        setSidebarOpen(true);
                                                    }}
                                                    className="p-2 hover:bg-gray-100 dark:hover:bg-gray-800 rounded-lg transition-colors"
                                                >
                                                    <ArrowLeft size={20} />
                                                </motion.button>
                                                <div className="h-6 w-px bg-gray-300 dark:bg-gray-700"></div>
                                                <div>
                                                    <p className="text-xs sm:text-sm text-orange-600 dark:text-orange-400 font-medium">
                                                        Quiz
                                                    </p>
                                                    <p className="text-base sm:text-lg font-bold text-gray-900 dark:text-white">
                                                        {selectedQuiz.title}
                                                    </p>
                                                </div>
                                            </div>
                                        </div>
                                    </div>

                                    {/* Quiz Content - Enhanced */}
                                    <div className="max-w-4xl mx-auto p-4 sm:p-8 lg:p-12">
                                        <motion.div 
                                            initial={{ y: 20, opacity: 0 }}
                                            animate={{ y: 0, opacity: 1 }}
                                            className="bg-gradient-to-br from-orange-50 via-amber-50 to-yellow-50 dark:from-gray-800 dark:via-gray-700 rounded-3xl p-6 sm:p-8 lg:p-10 mb-6 shadow-xl border border-orange-100 dark:border-gray-600"
                                        >
                                            <div className="flex items-center gap-4 mb-6">
                                                <div className="w-12 h-12 rounded-xl bg-gradient-to-br from-orange-500 to-amber-500 text-white flex items-center justify-center shadow-lg">
                                                    <HelpCircle size={24} />
                                                </div>
                                                <div>
                                                    <p className="font-bold text-gray-900 dark:text-white text-lg">
                                                        {selectedQuiz.description || 'Test your knowledge'}
                                                    </p>
                                                    <p className="text-sm text-gray-600 dark:text-gray-400">
                                                        {selectedQuiz.questions?.length || 0} questions • {selectedQuiz.difficulty || 'MEDIUM'} difficulty
                                                    </p>
                                                </div>
                                            </div>

                                            {selectedQuiz.questions && selectedQuiz.questions.length > 0 ? (
                                                <motion.div 
                                                    initial={{ opacity: 0 }}
                                                    animate={{ opacity: 1 }}
                                                    transition={{ staggerChildren: 0.1 }}
                                                    className="space-y-6"
                                                >
                                                    {selectedQuiz.questions.map((question: Question, qIdx: number) => (
                                                        <motion.div 
                                                            key={question.id}
                                                            initial={{ y: 20, opacity: 0 }}
                                                            animate={{ y: 0, opacity: 1 }}
                                                            className="bg-white dark:bg-gray-800 rounded-2xl p-5 sm:p-6 border-2 border-gray-200 dark:border-gray-700 hover:border-orange-300 dark:hover:border-orange-700 transition-colors shadow-md"
                                                        >
                                                            <div className="flex items-start gap-4 mb-4">
                                                                <div className="w-10 h-10 rounded-xl bg-gradient-to-br from-orange-500 to-amber-500 text-white flex items-center justify-center font-bold shadow-md flex-shrink-0">
                                                                    {qIdx + 1}
                                                                </div>
                                                                <p className="text-gray-900 dark:text-white font-semibold text-base sm:text-lg flex-1 leading-relaxed">
                                                                    {question.content || (question as any).questionText || 'Question'}
                                                                </p>
                                                            </div>
                                                            
                                                            {question.options && question.options.length > 0 && (
                                                                <div className="space-y-2 ml-14">
                                                                    {question.options.map((option) => (
                                                                        <motion.label
                                                                            key={option.id}
                                                                            whileHover={{ scale: 1.02, x: 4 }}
                                                                            whileTap={{ scale: 0.98 }}
                                                                            className="flex items-center gap-3 p-3 sm:p-4 bg-gray-50 dark:bg-gray-700/50 rounded-xl cursor-pointer hover:bg-orange-50 dark:hover:bg-orange-900/20 transition-all border border-transparent hover:border-orange-200 dark:hover:border-orange-800"
                                                                        >
                                                                            <input
                                                                                type="radio"
                                                                                name={`question-${question.id}`}
                                                                                className="w-5 h-5 text-orange-500 focus:ring-orange-500 focus:ring-2"
                                                                            />
                                                                            <span className="text-gray-700 dark:text-gray-300 flex-1 text-sm sm:text-base">
                                                                                {option.text || (option as any).optionText || 'Option'}
                                                                            </span>
                                                                        </motion.label>
                                                                    ))}
                                                                </div>
                                                            )}
                                                        </motion.div>
                                                    ))}
                                                </motion.div>
                                            ) : (
                                                <p className="text-gray-600 dark:text-gray-400 text-center py-12">
                                                    No questions available for this quiz yet.
                                                </p>
                                            )}

                                            <motion.div 
                                                initial={{ opacity: 0, y: 20 }}
                                                animate={{ opacity: 1, y: 0 }}
                                                transition={{ delay: 0.5 }}
                                                className="mt-8 pt-6 border-t border-gray-200 dark:border-gray-700"
                                            >
                                                <motion.button 
                                                    whileHover={{ scale: 1.02 }}
                                                    whileTap={{ scale: 0.98 }}
                                                    className="w-full px-6 py-4 bg-gradient-to-r from-orange-500 via-amber-500 to-orange-600 text-white rounded-xl hover:from-orange-600 hover:via-amber-600 hover:to-orange-700 transition-all font-bold text-lg shadow-xl hover:shadow-2xl"
                                                >
                                                    Submit Quiz
                                                </motion.button>
                                            </motion.div>
                                        </motion.div>
                                    </div>
                                </motion.div>
                            ) : null
                        ) : (
                            <motion.div
                                key="welcome"
                                initial={{ opacity: 0, scale: 0.95 }}
                                animate={{ opacity: 1, scale: 1 }}
                                exit={{ opacity: 0, scale: 0.95 }}
                                transition={{ duration: 0.3 }}
                                className="h-full flex items-center justify-center p-8"
                            >
                                <div className="text-center max-w-2xl">
                                    <motion.div 
                                        animate={{ 
                                            scale: [1, 1.1, 1],
                                            rotate: [0, 5, -5, 0]
                                        }}
                                        transition={{ 
                                            duration: 4,
                                            repeat: Infinity,
                                            repeatType: 'reverse'
                                        }}
                                        className="w-32 h-32 bg-gradient-to-br from-purple-400 via-indigo-500 to-blue-500 rounded-full flex items-center justify-center mx-auto mb-6 shadow-2xl"
                                    >
                                        <Play size={48} className="text-white ml-2" />
                                    </motion.div>
                                    <motion.h2 
                                        initial={{ y: 20, opacity: 0 }}
                                        animate={{ y: 0, opacity: 1 }}
                                        transition={{ delay: 0.2 }}
                                        className="text-3xl sm:text-4xl font-bold text-gray-900 dark:text-white mb-4"
                                    >
                                        Welcome to {course.title}!
                                    </motion.h2>
                                    <motion.p 
                                        initial={{ y: 20, opacity: 0 }}
                                        animate={{ y: 0, opacity: 1 }}
                                        transition={{ delay: 0.3 }}
                                        className="text-lg text-gray-600 dark:text-gray-400 mb-8 leading-relaxed"
                                    >
                                        Select a module, lesson, or quiz from the sidebar to start your learning journey.
                                    </motion.p>
                                    <motion.div 
                                        initial={{ y: 20, opacity: 0 }}
                                        animate={{ y: 0, opacity: 1 }}
                                        transition={{ delay: 0.4 }}
                                        className="flex items-center justify-center gap-4 text-sm text-gray-500 dark:text-gray-400 flex-wrap"
                                    >
                                        <div className="flex items-center gap-2">
                                            <BookOpen size={16} />
                                            <span>{modules.length} Modules</span>
                                        </div>
                                        <div className="w-1 h-1 bg-gray-400 rounded-full"></div>
                                        <div className="flex items-center gap-2">
                                            <Layers size={16} />
                                            <span>{totalLessons} Lessons</span>
                                        </div>
                                        <div className="w-1 h-1 bg-gray-400 rounded-full"></div>
                                        <div className="flex items-center gap-2">
                                            <HelpCircle size={16} />
                                            <span>{totalQuizzes} Quizzes</span>
                                        </div>
                                    </motion.div>
                                </div>
                            </motion.div>
                        )}
                    </AnimatePresence>
                </div>
            </div>
        </div>
    );
};

export default StudentCourseView;
