import React, { useState, useEffect } from 'react';
import { 
    ArrowLeft, Plus, Edit, Trash2, BookOpen, FileText, Video, Image as ImageIcon, 
    FileQuestion, ChevronDown, ChevronRight, Play, Layers, HelpCircle, X
} from 'lucide-react';
import { motion, AnimatePresence } from 'framer-motion';
import ModuleFormModal from './ModuleFormModal';
import LessonFormModal from './LessonFormModal';
import ContentFormModal from './ContentFormModal';
import QuizFormModal from './QuizFormModal';
import QuestionFormModal from './QuestionFormModal';

interface Course {
    id: string;
    title: string;
    description: string;
    category: string;
    level: 'BEGINNER' | 'INTERMEDIATE' | 'ADVANCED';
    thumbnailUrl?: string;
    teacherId: number;
}

interface Module {
    id: string;
    title: string;
    description?: string;
    orderIndex: number;
    lessons?: Lesson[];
}

interface Lesson {
    id: string;
    title: string;
    summary?: string;
    orderIndex: number;
    contents?: LessonContent[];
}

interface LessonContent {
    id: string;
    type: 'PDF' | 'TEXT' | 'VIDEO' | 'IMAGE' | 'QUIZ';
    textContent?: string;
    pdfUrl?: string;
    videoUrl?: string;
    imageUrl?: string;
    quizId?: string;
    orderIndex: number;
}

interface Quiz {
    id: string;
    title: string;
    description?: string;
    difficulty?: 'EASY' | 'MEDIUM' | 'HARD';
    passingScore?: number;
    mandatory?: boolean;
    questions?: Question[];
}

interface Question {
    id: string;
    questionText: string;
    questionType: string;
    points?: number;
    options?: QuestionOption[];
}

interface QuestionOption {
    id: string;
    optionText: string;
    isCorrect: boolean;
    optionOrder?: number;
}

interface CourseDetailViewProps {
    course?: Course;
    theme?: 'light' | 'dark';
    onBack?: () => void;
}

const CourseDetailView: React.FC<CourseDetailViewProps> = ({ course: initialCourse, theme = 'light', onBack }) => {
    const [course, setCourse] = useState<Course | null>(initialCourse || null);
    const [modules, setModules] = useState<Module[]>([]);
    const [quizzes, setQuizzes] = useState<Quiz[]>([]);
    const [expandedModules, setExpandedModules] = useState<Set<string>>(new Set());
    const [expandedLessons, setExpandedLessons] = useState<Set<string>>(new Set());
    const [expandedQuizzes, setExpandedQuizzes] = useState<Set<string>>(new Set());
    const [isLoading, setIsLoading] = useState(true);
    const [error, setError] = useState<string | null>(null);

    // Modal states
    const [showModuleModal, setShowModuleModal] = useState(false);
    const [showLessonModal, setShowLessonModal] = useState(false);
    const [showContentModal, setShowContentModal] = useState(false);
    const [showQuizModal, setShowQuizModal] = useState(false);
    const [showQuestionModal, setShowQuestionModal] = useState(false);
    
    const [selectedModule, setSelectedModule] = useState<Module | null>(null);
    const [selectedLesson, setSelectedLesson] = useState<Lesson | null>(null);
    const [selectedQuiz, setSelectedQuiz] = useState<Quiz | null>(null);

    // Listen for OPEN_COURSE_DETAIL message from Shell
    useEffect(() => {
        const handleOpenCourse = (event: MessageEvent) => {
            if (event.data.type === 'OPEN_COURSE_DETAIL' && event.data.course) {
                console.log('[CourseDetailView] Received course data:', event.data.course);
                setCourse(event.data.course);
                // Trigger content load
                setIsLoading(true);
                window.parent.postMessage({
                    type: 'FETCH_COURSE_CONTENT',
                    courseId: event.data.course.id
                }, '*');
            }
        };

        window.addEventListener('message', handleOpenCourse);
        
        // If we already have a course, load content immediately
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

        // Request modules and quizzes from Shell
        window.parent.postMessage({
            type: 'FETCH_COURSE_CONTENT',
            courseId: course.id
        }, '*');
    };

    useEffect(() => {
        const handleMessage = (event: MessageEvent) => {
            if (event.data.type === 'COURSE_CONTENT_LOADED') {
                setModules(event.data.modules || []);
                setQuizzes(event.data.quizzes || []);
                setIsLoading(false);
            }

            if (event.data.type === 'COURSE_CONTENT_ERROR') {
                setError(event.data.error);
                setIsLoading(false);
            }

            if (event.data.type === 'MODULE_CREATED') {
                setModules(prev => [...prev, event.data.module]);
                setShowModuleModal(false);
            }

            if (event.data.type === 'LESSON_CREATED') {
                const newLesson = event.data.lesson;
                const moduleId = event.data.moduleId;
                
                setModules(prev => prev.map(m =>
                    m.id === moduleId
                        ? { ...m, lessons: [...(m.lessons || []), newLesson] }
                        : m
                ));
                setShowLessonModal(false);
                setSelectedModule(null);
                
                // Auto-expand the module to show the new lesson
                if (moduleId) {
                    setExpandedModules(prev => new Set(prev).add(moduleId));
                }
            }

            if (event.data.type === 'CONTENT_CREATED') {
                const newContent = event.data.content;
                const lessonId = event.data.lessonId;
                const moduleId = event.data.moduleId;
                
                setModules(prev => prev.map(m =>
                    m.id === moduleId
                        ? {
                            ...m,
                            lessons: m.lessons?.map(l =>
                                l.id === lessonId
                                    ? { ...l, contents: [...(l.contents || []), newContent] }
                                    : l
                            )
                        }
                        : m
                ));
                setShowContentModal(false);
                setSelectedLesson(null);
                
                // Auto-expand lesson to show new content
                if (lessonId) {
                    setExpandedLessons(prev => new Set(prev).add(lessonId));
                }
                if (moduleId) {
                    setExpandedModules(prev => new Set(prev).add(moduleId));
                }
            }

            if (event.data.type === 'QUIZ_CREATED') {
                setQuizzes(prev => [...prev, event.data.quiz]);
                setShowQuizModal(false);
            }

            if (event.data.type === 'QUESTION_CREATED') {
                const newQuestion = event.data.question;
                const quizId = event.data.quizId;
                
                setQuizzes(prev => prev.map(q =>
                    q.id === quizId
                        ? { ...q, questions: [...(q.questions || []), newQuestion] }
                        : q
                ));
                setShowQuestionModal(false);
                setSelectedQuiz(null);
                
                // Auto-expand quiz to show new question
                if (quizId) {
                    setExpandedQuizzes(prev => new Set(prev).add(quizId));
                }
            }
        };

        window.addEventListener('message', handleMessage);
        return () => window.removeEventListener('message', handleMessage);
    }, []);

    // Handle back button
    const handleBack = () => {
        if (onBack) {
            onBack();
        } else {
            // Send message to Shell to navigate back
            window.parent.postMessage({
                type: 'COURSE_DETAIL_BACK'
            }, '*');
        }
    };

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

    const toggleQuiz = (quizId: string) => {
        setExpandedQuizzes(prev => {
            const newSet = new Set(prev);
            if (newSet.has(quizId)) {
                newSet.delete(quizId);
            } else {
                newSet.add(quizId);
            }
            return newSet;
        });
    };

    const getContentIcon = (type: string) => {
        switch (type) {
            case 'PDF':
                return <FileText size={18} className="text-red-500" />;
            case 'VIDEO':
                return <Video size={18} className="text-blue-500" />;
            case 'IMAGE':
                return <ImageIcon size={18} className="text-green-500" />;
            case 'QUIZ':
                return <FileQuestion size={18} className="text-purple-500" />;
            default:
                return <FileText size={18} className="text-gray-500" />;
        }
    };

    if (!course) {
        return (
            <div className="min-h-screen bg-gradient-to-br from-gray-50 to-gray-100 dark:from-gray-900 dark:to-gray-800 flex items-center justify-center">
                <div className="text-center">
                    <div className="w-16 h-16 border-4 border-primary border-t-transparent rounded-full animate-spin mx-auto mb-4"></div>
                    <p className="text-gray-600 dark:text-gray-400">Loading course...</p>
                </div>
            </div>
        );
    }

    if (isLoading) {
        return (
            <div className="min-h-screen bg-gradient-to-br from-gray-50 to-gray-100 dark:from-gray-900 dark:to-gray-800 flex items-center justify-center">
                <div className="text-center">
                    <div className="w-16 h-16 border-4 border-primary border-t-transparent rounded-full animate-spin mx-auto mb-4"></div>
                    <p className="text-gray-600 dark:text-gray-400">Loading course content...</p>
                </div>
            </div>
        );
    }

    return (
        <div className="min-h-screen bg-gradient-to-br from-gray-50 to-gray-100 dark:from-gray-900 dark:to-gray-800 p-4 sm:p-6 lg:p-8">
            <div className="max-w-7xl mx-auto space-y-6">
                {/* Header */}
                <motion.div
                    initial={{ opacity: 0, y: -20 }}
                    animate={{ opacity: 1, y: 0 }}
                    className="bg-white dark:bg-gray-800 rounded-2xl shadow-lg p-6"
                >
                    <button
                        onClick={handleBack}
                        className="flex items-center gap-2 text-gray-600 dark:text-gray-400 hover:text-gray-900 dark:hover:text-white mb-4 transition-colors"
                    >
                        <ArrowLeft size={20} />
                        <span>Back to Courses</span>
                    </button>

                    <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
                        <div className="flex-1">
                            <h1 className="text-3xl sm:text-4xl font-bold bg-gradient-to-r from-primary to-secondary bg-clip-text text-transparent mb-2">
                                {course.title}
                            </h1>
                            <p className="text-gray-600 dark:text-gray-400 mb-3">{course.description}</p>
                            <div className="flex flex-wrap gap-2">
                                <span className="px-3 py-1 bg-primary/10 text-primary text-sm font-semibold rounded-full">
                                    {course.category}
                                </span>
                                <span className={`px-3 py-1 text-sm font-semibold rounded-full text-white ${
                                    course.level === 'BEGINNER' ? 'bg-green-500' :
                                    course.level === 'INTERMEDIATE' ? 'bg-yellow-500' :
                                    'bg-red-500'
                                }`}>
                                    {course.level}
                                </span>
                            </div>
                        </div>
                    </div>
                </motion.div>

                {/* Quick Stats */}
                <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
                    <motion.div
                        initial={{ opacity: 0, x: -20 }}
                        animate={{ opacity: 1, x: 0 }}
                        className="bg-white dark:bg-gray-800 rounded-xl shadow-lg p-4"
                    >
                        <div className="flex items-center gap-3">
                            <div className="p-3 bg-blue-100 dark:bg-blue-900/30 rounded-lg">
                                <Layers size={24} className="text-blue-600 dark:text-blue-400" />
                            </div>
                            <div>
                                <p className="text-2xl font-bold text-gray-900 dark:text-white">{modules.length}</p>
                                <p className="text-sm text-gray-500 dark:text-gray-400">Modules</p>
                            </div>
                        </div>
                    </motion.div>

                    <motion.div
                        initial={{ opacity: 0, y: -20 }}
                        animate={{ opacity: 1, y: 0 }}
                        className="bg-white dark:bg-gray-800 rounded-xl shadow-lg p-4"
                    >
                        <div className="flex items-center gap-3">
                            <div className="p-3 bg-purple-100 dark:bg-purple-900/30 rounded-lg">
                                <BookOpen size={24} className="text-purple-600 dark:text-purple-400" />
                            </div>
                            <div>
                                <p className="text-2xl font-bold text-gray-900 dark:text-white">
                                    {modules.reduce((sum, m) => sum + (m.lessons?.length || 0), 0)}
                                </p>
                                <p className="text-sm text-gray-500 dark:text-gray-400">Lessons</p>
                            </div>
                        </div>
                    </motion.div>

                    <motion.div
                        initial={{ opacity: 0, x: 20 }}
                        animate={{ opacity: 1, x: 0 }}
                        className="bg-white dark:bg-gray-800 rounded-xl shadow-lg p-4"
                    >
                        <div className="flex items-center gap-3">
                            <div className="p-3 bg-orange-100 dark:bg-orange-900/30 rounded-lg">
                                <HelpCircle size={24} className="text-orange-600 dark:text-orange-400" />
                            </div>
                            <div>
                                <p className="text-2xl font-bold text-gray-900 dark:text-white">{quizzes.length}</p>
                                <p className="text-sm text-gray-500 dark:text-gray-400">Quizzes</p>
                            </div>
                        </div>
                    </motion.div>
                </div>

                {/* Modules Section */}
                <div className="bg-white dark:bg-gray-800 rounded-2xl shadow-lg p-6">
                    <div className="flex items-center justify-between mb-6">
                        <h2 className="text-2xl font-bold text-gray-900 dark:text-white flex items-center gap-2">
                            <Layers size={24} className="text-primary" />
                            Modules & Lessons
                        </h2>
                        <button
                            onClick={() => setShowModuleModal(true)}
                            className="flex items-center gap-2 px-4 py-2 bg-primary text-white rounded-lg hover:bg-primary/90 transition-colors"
                        >
                            <Plus size={18} />
                            Add Module
                        </button>
                    </div>

                    {modules.length === 0 ? (
                        <div className="text-center py-12">
                            <BookOpen size={48} className="text-gray-400 mx-auto mb-4" />
                            <p className="text-gray-600 dark:text-gray-400 mb-4">No modules yet</p>
                            <button
                                onClick={() => setShowModuleModal(true)}
                                className="px-6 py-2 bg-primary text-white rounded-lg hover:bg-primary/90 transition-colors"
                            >
                                Create First Module
                            </button>
                        </div>
                    ) : (
                        <div className="space-y-3">
                            {modules
                                .sort((a, b) => a.orderIndex - b.orderIndex)
                                .map((module) => (
                                    <ModuleCard
                                        key={module.id}
                                        module={module}
                                        courseId={course.id}
                                        isExpanded={expandedModules.has(module.id)}
                                        onToggle={() => toggleModule(module.id)}
                                        onAddLesson={() => {
                                            setSelectedModule(module);
                                            setShowLessonModal(true);
                                        }}
                                        onAddContent={(lesson) => {
                                            setSelectedModule(module);
                                            setSelectedLesson(lesson);
                                            setShowContentModal(true);
                                        }}
                                        theme={theme}
                                    />
                                ))}
                        </div>
                    )}
                </div>

                {/* Quizzes Section */}
                <div className="bg-white dark:bg-gray-800 rounded-2xl shadow-lg p-6">
                    <div className="flex items-center justify-between mb-6">
                        <h2 className="text-2xl font-bold text-gray-900 dark:text-white flex items-center gap-2">
                            <HelpCircle size={24} className="text-orange-500" />
                            Quizzes
                        </h2>
                        <button
                            onClick={() => setShowQuizModal(true)}
                            className="flex items-center gap-2 px-4 py-2 bg-orange-500 text-white rounded-lg hover:bg-orange-600 transition-colors"
                        >
                            <Plus size={18} />
                            Add Quiz
                        </button>
                    </div>

                    {quizzes.length === 0 ? (
                        <div className="text-center py-12">
                            <HelpCircle size={48} className="text-gray-400 mx-auto mb-4" />
                            <p className="text-gray-600 dark:text-gray-400 mb-4">No quizzes yet</p>
                            <button
                                onClick={() => setShowQuizModal(true)}
                                className="px-6 py-2 bg-orange-500 text-white rounded-lg hover:bg-orange-600 transition-colors"
                            >
                                Create First Quiz
                            </button>
                        </div>
                    ) : (
                        <div className="space-y-3">
                            {quizzes.map((quiz) => (
                                <QuizCard
                                    key={quiz.id}
                                    quiz={quiz}
                                    courseId={course.id}
                                    isExpanded={expandedQuizzes.has(quiz.id)}
                                    onToggle={() => toggleQuiz(quiz.id)}
                                    onAddQuestion={() => {
                                        setSelectedQuiz(quiz);
                                        setShowQuestionModal(true);
                                    }}
                                    theme={theme}
                                />
                            ))}
                        </div>
                    )}
                </div>
            </div>

            {/* Modals */}
            <ModuleFormModal
                isOpen={showModuleModal}
                onClose={() => setShowModuleModal(false)}
                onSubmit={(data) => {
                    window.parent.postMessage({
                        type: 'CREATE_MODULE',
                        courseId: course.id,
                        module: data
                    }, '*');
                }}
                existingModulesCount={modules.length}
            />

            <LessonFormModal
                isOpen={showLessonModal}
                onClose={() => {
                    setShowLessonModal(false);
                    setSelectedModule(null);
                }}
                onSubmit={(data) => {
                    if (selectedModule) {
                        window.parent.postMessage({
                            type: 'CREATE_LESSON',
                            moduleId: selectedModule.id,
                            lesson: data,
                            moduleIdForResponse: selectedModule.id // Include for response handling
                        }, '*');
                    }
                }}
                existingLessonsCount={selectedModule?.lessons?.length || 0}
            />

            <ContentFormModal
                isOpen={showContentModal}
                onClose={() => {
                    setShowContentModal(false);
                    setSelectedLesson(null);
                }}
                onSubmit={(data) => {
                    if (selectedLesson && selectedModule) {
                        window.parent.postMessage({
                            type: 'CREATE_CONTENT',
                            lessonId: selectedLesson.id,
                            content: data,
                            lessonIdForResponse: selectedLesson.id,
                            moduleIdForResponse: selectedModule.id
                        }, '*');
                    }
                }}
                existingContentCount={selectedLesson?.contents?.length || 0}
                availableQuizzes={quizzes.map(q => ({ id: q.id, title: q.title }))}
            />

            <QuizFormModal
                isOpen={showQuizModal}
                onClose={() => setShowQuizModal(false)}
                onSubmit={(data) => {
                    window.parent.postMessage({
                        type: 'CREATE_QUIZ',
                        courseId: course.id,
                        quiz: data
                    }, '*');
                }}
            />

            <QuestionFormModal
                isOpen={showQuestionModal}
                onClose={() => {
                    setShowQuestionModal(false);
                    setSelectedQuiz(null);
                }}
                onSubmit={(data) => {
                    if (selectedQuiz) {
                        window.parent.postMessage({
                            type: 'CREATE_QUESTION',
                            quizId: selectedQuiz.id,
                            question: data,
                            quizIdForResponse: selectedQuiz.id
                        }, '*');
                    }
                }}
            />
        </div>
    );
};

// Module Card Component
interface ModuleCardProps {
    module: Module;
    courseId: string;
    isExpanded: boolean;
    onToggle: () => void;
    onAddLesson: () => void;
    onAddContent?: (lesson: Lesson) => void;
    theme: 'light' | 'dark';
}

const ModuleCard: React.FC<ModuleCardProps> = ({ module, isExpanded, onToggle, onAddLesson, onAddContent }) => {
    return (
        <div className="border border-gray-200 dark:border-gray-700 rounded-lg overflow-hidden">
            <div
                className="p-4 bg-gray-50 dark:bg-gray-700/50 hover:bg-gray-100 dark:hover:bg-gray-700 cursor-pointer transition-colors flex items-center justify-between"
                onClick={onToggle}
            >
                <div className="flex items-center gap-3 flex-1">
                    {isExpanded ? <ChevronDown size={20} /> : <ChevronRight size={20} />}
                    <div className="flex-1">
                        <h3 className="font-semibold text-gray-900 dark:text-white">{module.title}</h3>
                        {module.description && (
                            <p className="text-sm text-gray-600 dark:text-gray-400 mt-1">{module.description}</p>
                        )}
                    </div>
                    <span className="text-sm text-gray-500 dark:text-gray-400">
                        {module.lessons?.length || 0} lessons
                    </span>
                </div>
            </div>

            <AnimatePresence>
                {isExpanded && (
                    <motion.div
                        initial={{ height: 0, opacity: 0 }}
                        animate={{ height: 'auto', opacity: 1 }}
                        exit={{ height: 0, opacity: 0 }}
                        className="border-t border-gray-200 dark:border-gray-700"
                    >
                        <div className="p-4 space-y-3">
                            {module.lessons && module.lessons.length > 0 ? (
                                <>
                                    {module.lessons
                                        .sort((a, b) => a.orderIndex - b.orderIndex)
                                        .map((lesson) => (
                                            <LessonCard 
                                                key={lesson.id} 
                                                lesson={lesson} 
                                                moduleId={module.id}
                                                onAddContent={onAddContent}
                                            />
                                        ))}
                                    <button
                                        onClick={(e) => {
                                            e.stopPropagation();
                                            onAddLesson();
                                        }}
                                        className="w-full py-2 border-2 border-dashed border-gray-300 dark:border-gray-600 rounded-lg text-gray-600 dark:text-gray-400 hover:border-primary hover:text-primary transition-colors flex items-center justify-center gap-2"
                                    >
                                        <Plus size={18} />
                                        Add Lesson
                                    </button>
                                </>
                            ) : (
                                <button
                                    onClick={(e) => {
                                        e.stopPropagation();
                                        onAddLesson();
                                    }}
                                    className="w-full py-4 border-2 border-dashed border-gray-300 dark:border-gray-600 rounded-lg text-gray-600 dark:text-gray-400 hover:border-primary hover:text-primary transition-colors flex items-center justify-center gap-2"
                                >
                                    <Plus size={18} />
                                    Add First Lesson
                                </button>
                            )}
                        </div>
                    </motion.div>
                )}
            </AnimatePresence>
        </div>
    );
};

// Lesson Card Component
interface LessonCardProps {
    lesson: Lesson;
    moduleId: string;
    onAddContent?: (lesson: Lesson) => void;
}

const LessonCard: React.FC<LessonCardProps> = ({ lesson, onAddContent }) => {
    const [isExpanded, setIsExpanded] = useState(false);

    return (
        <div className="border border-gray-200 dark:border-gray-700 rounded-lg overflow-hidden">
            <div
                className="p-3 bg-white dark:bg-gray-800 hover:bg-gray-50 dark:hover:bg-gray-700/50 cursor-pointer transition-colors flex items-center justify-between"
                onClick={() => setIsExpanded(!isExpanded)}
            >
                <div className="flex items-center gap-2 flex-1">
                    {isExpanded ? <ChevronDown size={18} /> : <ChevronRight size={18} />}
                    <BookOpen size={16} className="text-blue-500" />
                    <span className="font-medium text-gray-900 dark:text-white">{lesson.title}</span>
                    {lesson.summary && (
                        <span className="text-sm text-gray-500 dark:text-gray-400 truncate">- {lesson.summary}</span>
                    )}
                </div>
                <span className="text-xs text-gray-500 dark:text-gray-400">
                    {lesson.contents?.length || 0} items
                </span>
            </div>

            <AnimatePresence>
                {isExpanded && (
                    <motion.div
                        initial={{ height: 0, opacity: 0 }}
                        animate={{ height: 'auto', opacity: 1 }}
                        exit={{ height: 0, opacity: 0 }}
                        className="border-t border-gray-200 dark:border-gray-700 bg-gray-50 dark:bg-gray-800/50"
                    >
                        <div className="p-3 space-y-2">
                            {lesson.contents && lesson.contents.length > 0 ? (
                                <>
                                    {lesson.contents
                                        .sort((a, b) => a.orderIndex - b.orderIndex)
                                        .map((content) => (
                                            <div
                                                key={content.id}
                                                className="flex items-center justify-between p-2 bg-white dark:bg-gray-800 rounded border border-gray-200 dark:border-gray-700"
                                            >
                                                <div className="flex items-center gap-2 flex-1">
                                                    {getContentIcon(content.type)}
                                                    <span className="text-sm text-gray-900 dark:text-white">
                                                        {content.type}
                                                        {content.type === 'TEXT' && content.textContent && (
                                                            <span className="text-gray-500">: {content.textContent.substring(0, 30)}...</span>
                                                        )}
                                                    </span>
                                                </div>
                                            </div>
                                        ))}
                                    {onAddContent && (
                                        <button
                                            onClick={(e) => {
                                                e.stopPropagation();
                                                onAddContent(lesson);
                                            }}
                                            className="w-full py-2 border-2 border-dashed border-gray-300 dark:border-gray-600 rounded-lg text-gray-600 dark:text-gray-400 hover:border-blue-500 hover:text-blue-500 transition-colors flex items-center justify-center gap-2 text-sm"
                                        >
                                            <Plus size={16} />
                                            Add Content
                                        </button>
                                    )}
                                </>
                            ) : (
                                onAddContent && (
                                    <button
                                        onClick={(e) => {
                                            e.stopPropagation();
                                            onAddContent(lesson);
                                        }}
                                        className="w-full py-3 border-2 border-dashed border-gray-300 dark:border-gray-600 rounded-lg text-gray-600 dark:text-gray-400 hover:border-blue-500 hover:text-blue-500 transition-colors flex items-center justify-center gap-2"
                                    >
                                        <Plus size={18} />
                                        Add First Content
                                    </button>
                                )
                            )}
                        </div>
                    </motion.div>
                )}
            </AnimatePresence>
        </div>
    );
};

// Quiz Card Component
interface QuizCardProps {
    quiz: Quiz;
    courseId: string;
    isExpanded: boolean;
    onToggle: () => void;
    onAddQuestion: () => void;
    theme: 'light' | 'dark';
}

const QuizCard: React.FC<QuizCardProps> = ({ quiz, isExpanded, onToggle, onAddQuestion }) => {
    return (
        <div className="border border-gray-200 dark:border-gray-700 rounded-lg overflow-hidden">
            <div
                className="p-4 bg-orange-50 dark:bg-orange-900/20 hover:bg-orange-100 dark:hover:bg-orange-900/30 cursor-pointer transition-colors flex items-center justify-between"
                onClick={onToggle}
            >
                <div className="flex items-center gap-3 flex-1">
                    {isExpanded ? <ChevronDown size={20} /> : <ChevronRight size={20} />}
                    <HelpCircle size={20} className="text-orange-600 dark:text-orange-400" />
                    <div className="flex-1">
                        <h3 className="font-semibold text-gray-900 dark:text-white">{quiz.title}</h3>
                        {quiz.description && (
                            <p className="text-sm text-gray-600 dark:text-gray-400 mt-1">{quiz.description}</p>
                        )}
                    </div>
                    <div className="flex items-center gap-3">
                        {quiz.difficulty && (
                            <span className={`px-2 py-1 text-xs font-semibold rounded ${
                                quiz.difficulty === 'EASY' ? 'bg-green-100 text-green-800 dark:bg-green-900/30 dark:text-green-400' :
                                quiz.difficulty === 'MEDIUM' ? 'bg-yellow-100 text-yellow-800 dark:bg-yellow-900/30 dark:text-yellow-400' :
                                'bg-red-100 text-red-800 dark:bg-red-900/30 dark:text-red-400'
                            }`}>
                                {quiz.difficulty}
                            </span>
                        )}
                        <span className="text-sm text-gray-500 dark:text-gray-400">
                            {quiz.questions?.length || 0} questions
                        </span>
                    </div>
                </div>
            </div>

            <AnimatePresence>
                {isExpanded && (
                    <motion.div
                        initial={{ height: 0, opacity: 0 }}
                        animate={{ height: 'auto', opacity: 1 }}
                        exit={{ height: 0, opacity: 0 }}
                        className="border-t border-gray-200 dark:border-gray-700"
                    >
                        <div className="p-4 space-y-3">
                            {quiz.questions && quiz.questions.length > 0 ? (
                                <>
                                    {quiz.questions.map((question) => (
                                        <div
                                            key={question.id}
                                            className="p-3 bg-white dark:bg-gray-800 rounded border border-gray-200 dark:border-gray-700"
                                        >
                                            <p className="font-medium text-gray-900 dark:text-white mb-2">
                                                {question.questionText}
                                            </p>
                                            {question.options && question.options.length > 0 && (
                                                <div className="space-y-1 ml-4">
                                                    {question.options
                                                        .sort((a, b) => (a.optionOrder || 0) - (b.optionOrder || 0))
                                                        .map((option) => (
                                                            <div
                                                                key={option.id}
                                                                className={`text-sm p-2 rounded ${
                                                                    option.isCorrect
                                                                        ? 'bg-green-50 dark:bg-green-900/20 text-green-900 dark:text-green-400'
                                                                        : 'bg-gray-50 dark:bg-gray-700 text-gray-700 dark:text-gray-300'
                                                                }`}
                                                            >
                                                                {option.optionText}
                                                                {option.isCorrect && (
                                                                    <span className="ml-2 text-xs">✓ Correct</span>
                                                                )}
                                                            </div>
                                                        ))}
                                                </div>
                                            )}
                                        </div>
                                    ))}
                                    <button
                                        onClick={(e) => {
                                            e.stopPropagation();
                                            onAddQuestion();
                                        }}
                                        className="w-full py-2 border-2 border-dashed border-gray-300 dark:border-gray-600 rounded-lg text-gray-600 dark:text-gray-400 hover:border-orange-500 hover:text-orange-500 transition-colors flex items-center justify-center gap-2"
                                    >
                                        <Plus size={18} />
                                        Add Question
                                    </button>
                                </>
                            ) : (
                                <button
                                    onClick={(e) => {
                                        e.stopPropagation();
                                        onAddQuestion();
                                    }}
                                    className="w-full py-4 border-2 border-dashed border-gray-300 dark:border-gray-600 rounded-lg text-gray-600 dark:text-gray-400 hover:border-orange-500 hover:text-orange-500 transition-colors flex items-center justify-center gap-2"
                                >
                                    <Plus size={18} />
                                    Add First Question
                                </button>
                            )}
                        </div>
                    </motion.div>
                )}
            </AnimatePresence>
        </div>
    );
};

const getContentIcon = (type: string) => {
    switch (type) {
        case 'PDF':
            return <FileText size={16} className="text-red-500" />;
        case 'VIDEO':
            return <Video size={16} className="text-blue-500" />;
        case 'IMAGE':
            return <ImageIcon size={16} className="text-green-500" />;
        case 'QUIZ':
            return <FileQuestion size={16} className="text-purple-500" />;
        default:
            return <FileText size={16} className="text-gray-500" />;
    }
};

export default CourseDetailView;

