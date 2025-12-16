import React, { useState, useEffect } from 'react';
import { Plus, Edit, Trash2, Users, BookOpen, Star } from 'lucide-react';
import { motion } from 'framer-motion';
import CourseFormModal from './CourseFormModal';
import DeleteCourseModal from './DeleteCourseModal';

interface Course {
    id: string;
    title: string;
    description: string;
    category: string;
    level: 'BEGINNER' | 'INTERMEDIATE' | 'ADVANCED';
    thumbnailUrl: string;
    price?: number;
    teacherId: number;
    modules?: any[];
    createdAt?: string;
    updatedAt?: string;
}

interface CourseFormData {
    title: string;
    description: string;
    category: string;
    level: 'BEGINNER' | 'INTERMEDIATE' | 'ADVANCED';
    thumbnailUrl: string;
}

interface TeacherCoursesViewProps {
    theme: 'light' | 'dark';
}

const TeacherCoursesView: React.FC<TeacherCoursesViewProps> = () => {
    const [courses, setCourses] = useState<Course[]>([]);
    const [isCreateModalOpen, setIsCreateModalOpen] = useState(false);
    const [editingCourse, setEditingCourse] = useState<Course | null>(null);
    const [deletingCourse, setDeletingCourse] = useState<Course | null>(null);
    const [isLoading, setIsLoading] = useState(true);
    const [error, setError] = useState<string | null>(null);

    // Load courses on mount
    useEffect(() => {
        loadCourses();
    }, []);

    const loadCourses = () => {
        setIsLoading(true);
        setError(null);

        // Send message to parent Shell to fetch courses
        window.parent.postMessage({ type: 'FETCH_TEACHER_COURSES' }, '*');
    };

    // Listen for responses from Shell
    useEffect(() => {
        const handleMessage = (event: MessageEvent) => {
            console.log('[TeacherCoursesView] Received message:', event.data);

            if (event.data.type === 'TEACHER_COURSES_LOADED') {
                console.log('[TeacherCoursesView] Courses loaded:', event.data.courses);
                setCourses(event.data.courses || []);
                setIsLoading(false);
            }

            if (event.data.type === 'TEACHER_COURSES_ERROR') {
                console.error('[TeacherCoursesView] Error loading courses:', event.data.error);
                setError(event.data.error);
                setIsLoading(false);
            }

            if (event.data.type === 'COURSE_CREATED') {
                console.log('[TeacherCoursesView] Course created:', event.data.course);
                setCourses(prev => [...prev, event.data.course]);
                setIsCreateModalOpen(false);
            }

            if (event.data.type === 'COURSE_UPDATED') {
                console.log('[TeacherCoursesView] Course updated:', event.data.course);
                setCourses(prev => prev.map(c =>
                    c.id === event.data.course.id ? event.data.course : c
                ));
                setEditingCourse(null);
            }

            if (event.data.type === 'COURSE_DELETED') {
                console.log('[TeacherCoursesView] Course deleted:', event.data.courseId);
                setCourses(prev => prev.filter(c => c.id !== event.data.courseId));
                setDeletingCourse(null);
            }

            if (event.data.type === 'COURSE_ERROR') {
                console.error('[TeacherCoursesView] Course operation error:', event.data.error);
                alert(`Error: ${event.data.error}`);
            }
        };

        window.addEventListener('message', handleMessage);
        return () => window.removeEventListener('message', handleMessage);
    }, []);

    const handleCreateCourse = (courseData: Partial<CourseFormData>) => {
        console.log('[TeacherCoursesView] Creating course:', courseData);
        window.parent.postMessage({
            type: 'CREATE_COURSE',
            course: {
                title: courseData.title,
                description: courseData.description,
                category: courseData.category,
                level: courseData.level,
                thumbnailUrl: courseData.thumbnailUrl,
            }
        }, '*');
    };

    const handleUpdateCourse = (courseData: Partial<CourseFormData>) => {
        if (!editingCourse) return;

        console.log('[TeacherCoursesView] Updating course:', editingCourse.id, courseData);
        window.parent.postMessage({
            type: 'UPDATE_COURSE',
            courseId: editingCourse.id,
            course: {
                title: courseData.title,
                description: courseData.description,
                category: courseData.category,
                level: courseData.level,
                thumbnailUrl: courseData.thumbnailUrl,
            }
        }, '*');
    };

    const handleDeleteCourse = () => {
        if (!deletingCourse) return;

        console.log('[TeacherCoursesView] Deleting course:', deletingCourse.id);
        window.parent.postMessage({
            type: 'DELETE_COURSE',
            courseId: deletingCourse.id
        }, '*');
    };

    if (isLoading) {
        return (
            <div className="min-h-screen bg-light-bg dark:bg-dark-bg flex items-center justify-center">
                <div className="text-center">
                    <div className="w-16 h-16 border-4 border-primary border-t-transparent rounded-full animate-spin mx-auto mb-4"></div>
                    <p className="text-gray-600 dark:text-gray-400">Loading your courses...</p>
                </div>
            </div>
        );
    }

    if (error) {
        return (
            <div className="min-h-screen bg-light-bg dark:bg-dark-bg flex items-center justify-center p-4">
                <div className="card p-8 max-w-md text-center">
                    <div className="w-16 h-16 bg-red-100 dark:bg-red-900/30 rounded-full flex items-center justify-center mx-auto mb-4">
                        <span className="text-3xl">⚠️</span>
                    </div>
                    <h3 className="text-xl font-bold text-gray-900 dark:text-white mb-2">
                        Error Loading Courses
                    </h3>
                    <p className="text-gray-600 dark:text-gray-400 mb-4">{error}</p>
                    <button
                        onClick={loadCourses}
                        className="px-6 py-3 bg-primary text-white font-semibold rounded-xl hover:bg-primary/90 transition-colors"
                    >
                        Try Again
                    </button>
                </div>
            </div>
        );
    }

    return (
        <div className="min-h-screen bg-light-bg dark:bg-dark-bg p-8">
            <div className="max-w-7xl mx-auto space-y-6">
                {/* Header */}
                <div className="flex items-center justify-between">
                    <div>
                        <h1 className="text-3xl font-bold text-gray-900 dark:text-white mb-2">
                            My Courses
                        </h1>
                        <p className="text-gray-600 dark:text-gray-400">
                            Manage and track your {courses.length} {courses.length === 1 ? 'course' : 'courses'}
                        </p>
                    </div>
                    <button
                        onClick={() => setIsCreateModalOpen(true)}
                        className="flex items-center gap-2 px-6 py-3 bg-gradient-to-r from-primary to-secondary text-white font-semibold rounded-xl hover:shadow-lg hover:shadow-primary/30 transition-all"
                    >
                        <Plus size={20} />
                        Create Course
                    </button>
                </div>

                {/* Courses Grid */}
                {courses.length === 0 ? (
                    <div className="card p-12 text-center">
                        <div className="w-24 h-24 bg-gray-100 dark:bg-gray-800 rounded-full flex items-center justify-center mx-auto mb-4">
                            <BookOpen size={48} className="text-gray-400" />
                        </div>
                        <h3 className="text-xl font-bold text-gray-900 dark:text-white mb-2">
                            No courses yet
                        </h3>
                        <p className="text-gray-600 dark:text-gray-400 mb-6">
                            Get started by creating your first course
                        </p>
                        <button
                            onClick={() => setIsCreateModalOpen(true)}
                            className="px-6 py-3 bg-primary text-white font-semibold rounded-xl hover:bg-primary/90 transition-colors"
                        >
                            Create Your First Course
                        </button>
                    </div>
                ) : (
                    <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                        {courses.map((course) => (
                            <motion.div
                                key={course.id}
                                initial={{ opacity: 0, y: 20 }}
                                animate={{ opacity: 1, y: 0 }}
                                className="card overflow-hidden hover:shadow-xl transition-shadow"
                            >
                                {/* Thumbnail */}
                                <div className="relative h-48 overflow-hidden bg-gradient-to-br from-primary/20 to-secondary/20">
                                    {course.thumbnailUrl ? (
                                        <img
                                            src={course.thumbnailUrl}
                                            alt={course.title}
                                            className="w-full h-full object-cover"
                                        />
                                    ) : (
                                        <div className="w-full h-full flex items-center justify-center">
                                            <BookOpen size={48} className="text-gray-400" />
                                        </div>
                                    )}
                                    <div className="absolute top-3 right-3">
                                        <span className={`px-3 py-1 text-xs font-semibold rounded-full ${course.level === 'BEGINNER'
                                            ? 'bg-green-500 text-white'
                                            : course.level === 'INTERMEDIATE'
                                                ? 'bg-yellow-500 text-white'
                                                : 'bg-red-500 text-white'
                                            }`}>
                                            {course.level}
                                        </span>
                                    </div>
                                </div>

                                {/* Content */}
                                <div className="p-6">
                                    <div className="flex items-center gap-2 mb-2">
                                        <span className="px-2 py-1 bg-primary/10 text-primary text-xs font-semibold rounded">
                                            {course.category}
                                        </span>
                                    </div>

                                    <h3 className="text-lg font-bold text-gray-900 dark:text-white mb-2 line-clamp-2">
                                        {course.title}
                                    </h3>

                                    <p className="text-sm text-gray-600 dark:text-gray-400 mb-4 line-clamp-2">
                                        {course.description}
                                    </p>

                                    {/* Stats */}
                                    <div className="grid grid-cols-2 gap-4 mb-4">
                                        <div className="text-center">
                                            <div className="flex items-center justify-center gap-1 text-gray-900 dark:text-white font-semibold mb-1">
                                                <BookOpen size={16} />
                                                {course.modules?.length || 0}
                                            </div>
                                            <p className="text-xs text-gray-500 dark:text-gray-400">Modules</p>
                                        </div>
                                        <div className="text-center">
                                            <div className="flex items-center justify-center gap-1 text-gray-900 dark:text-white font-semibold mb-1">
                                                <Users size={16} />
                                                0
                                            </div>
                                            <p className="text-xs text-gray-500 dark:text-gray-400">Students</p>
                                        </div>
                                    </div>

                                    {/* Actions */}
                                    <div className="flex gap-2 pt-4 border-t border-gray-200 dark:border-gray-700">
                                        <button
                                            onClick={() => setEditingCourse(course)}
                                            className="flex-1 flex items-center justify-center gap-2 px-4 py-2 bg-gray-100 dark:bg-gray-800 text-gray-900 dark:text-white rounded-lg hover:bg-gray-200 dark:hover:bg-gray-700 transition-colors"
                                        >
                                            <Edit size={16} />
                                            Edit
                                        </button>
                                        <button
                                            onClick={() => setDeletingCourse(course)}
                                            className="flex-1 flex items-center justify-center gap-2 px-4 py-2 bg-red-50 dark:bg-red-900/20 text-red-600 dark:text-red-400 rounded-lg hover:bg-red-100 dark:hover:bg-red-900/30 transition-colors"
                                        >
                                            <Trash2 size={16} />
                                            Delete
                                        </button>
                                    </div>
                                </div>
                            </motion.div>
                        ))}
                    </div>
                )}
            </div>

            {/* Modals */}
            <CourseFormModal
                isOpen={isCreateModalOpen}
                onClose={() => setIsCreateModalOpen(false)}
                onSubmit={handleCreateCourse}
                title="Create New Course"
            />

            <CourseFormModal
                isOpen={!!editingCourse}
                onClose={() => setEditingCourse(null)}
                onSubmit={handleUpdateCourse}
                initialData={editingCourse ? {
                    title: editingCourse.title,
                    description: editingCourse.description,
                    category: editingCourse.category,
                    level: editingCourse.level,
                    thumbnailUrl: editingCourse.thumbnailUrl,
                } : undefined}
                title="Edit Course"
            />

            <DeleteCourseModal
                isOpen={!!deletingCourse}
                onClose={() => setDeletingCourse(null)}
                onConfirm={handleDeleteCourse}
                courseName={deletingCourse?.title || ''}
            />
        </div>
    );
};

export default TeacherCoursesView;
