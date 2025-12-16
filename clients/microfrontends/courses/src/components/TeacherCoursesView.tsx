import React, { useState, useEffect } from 'react';
import { Plus, Edit, Trash2, Users, BookOpen, Star, Calendar, TrendingUp, Search, Filter, MoreVertical, Eye } from 'lucide-react';
import { motion, AnimatePresence } from 'framer-motion';
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
    const [filteredCourses, setFilteredCourses] = useState<Course[]>([]);
    const [isCreateModalOpen, setIsCreateModalOpen] = useState(false);
    const [editingCourse, setEditingCourse] = useState<Course | null>(null);
    const [deletingCourse, setDeletingCourse] = useState<Course | null>(null);
    const [isLoading, setIsLoading] = useState(true);
    const [error, setError] = useState<string | null>(null);
    const [searchQuery, setSearchQuery] = useState('');
    const [selectedCategory, setSelectedCategory] = useState<string>('All');
    const [selectedLevel, setSelectedLevel] = useState<string>('All');

    // Load courses on mount
    useEffect(() => {
        loadCourses();
    }, []);

    // Filter courses based on search, category, and level
    useEffect(() => {
        let filtered = courses;

        // Search filter
        if (searchQuery.trim()) {
            filtered = filtered.filter(course =>
                course.title.toLowerCase().includes(searchQuery.toLowerCase()) ||
                course.description.toLowerCase().includes(searchQuery.toLowerCase()) ||
                course.category.toLowerCase().includes(searchQuery.toLowerCase())
            );
        }

        // Category filter
        if (selectedCategory !== 'All') {
            filtered = filtered.filter(course => course.category === selectedCategory);
        }

        // Level filter
        if (selectedLevel !== 'All') {
            filtered = filtered.filter(course => course.level === selectedLevel);
        }

        setFilteredCourses(filtered);
    }, [courses, searchQuery, selectedCategory, selectedLevel]);

    const loadCourses = () => {
        setIsLoading(true);
        setError(null);

        // Send message to parent Shell to fetch courses
        // The Shell will filter courses by teacherId automatically
        window.parent.postMessage({ type: 'FETCH_TEACHER_COURSES' }, '*');
    };

    // Listen for responses from Shell
    useEffect(() => {
        const handleMessage = (event: MessageEvent) => {
            console.log('[TeacherCoursesView] Received message:', event.data);

            if (event.data.type === 'TEACHER_COURSES_LOADED') {
                console.log('[TeacherCoursesView] Courses loaded:', event.data.courses);
                const loadedCourses = event.data.courses || [];
                // Ensure we only show courses that belong to the teacher (additional safety check)
                // Backend already filters, but this is a frontend safety measure
                setCourses(loadedCourses);
                setFilteredCourses(loadedCourses);
                setIsLoading(false);
            }

            if (event.data.type === 'TEACHER_COURSES_ERROR') {
                console.error('[TeacherCoursesView] Error loading courses:', event.data.error);
                setError(event.data.error);
                setIsLoading(false);
            }

            if (event.data.type === 'COURSE_CREATED') {
                console.log('[TeacherCoursesView] Course created:', event.data.course);
                const newCourses = [...courses, event.data.course];
                setCourses(newCourses);
                // Filter will be applied automatically via useEffect
                setIsCreateModalOpen(false);
            }

            if (event.data.type === 'COURSE_UPDATED') {
                console.log('[TeacherCoursesView] Course updated:', event.data.course);
                const updatedCourses = courses.map(c =>
                    c.id === event.data.course.id ? event.data.course : c
                );
                setCourses(updatedCourses);
                // Filter will be applied automatically via useEffect
                setEditingCourse(null);
            }

            if (event.data.type === 'COURSE_DELETED') {
                console.log('[TeacherCoursesView] Course deleted:', event.data.courseId);
                const remainingCourses = courses.filter(c => c.id !== event.data.courseId);
                setCourses(remainingCourses);
                // Filter will be applied automatically via useEffect
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

    const categories = ['All', ...Array.from(new Set(courses.map(c => c.category)))];
    const levels: ('BEGINNER' | 'INTERMEDIATE' | 'ADVANCED' | 'All')[] = ['All', 'BEGINNER', 'INTERMEDIATE', 'ADVANCED'];

    return (
        <div className="min-h-screen bg-gradient-to-br from-gray-50 to-gray-100 dark:from-gray-900 dark:to-gray-800 p-4 sm:p-6 lg:p-8">
            <div className="max-w-7xl mx-auto space-y-6">
                {/* Header Section */}
                <motion.div
                    initial={{ opacity: 0, y: -20 }}
                    animate={{ opacity: 1, y: 0 }}
                    className="bg-white dark:bg-gray-800 rounded-2xl shadow-lg p-6 sm:p-8"
                >
                    <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
                    <div>
                            <h1 className="text-3xl sm:text-4xl font-bold bg-gradient-to-r from-primary to-secondary bg-clip-text text-transparent mb-2">
                            My Courses
                        </h1>
                            <p className="text-gray-600 dark:text-gray-400 text-sm sm:text-base">
                            Manage and track your {courses.length} {courses.length === 1 ? 'course' : 'courses'}
                        </p>
                            {courses.length > 0 && (
                                <div className="flex items-center gap-4 mt-3 text-sm text-gray-500 dark:text-gray-400">
                                    <div className="flex items-center gap-1">
                                        <TrendingUp size={16} />
                                        <span>{filteredCourses.length} showing</span>
                                    </div>
                                    <div className="flex items-center gap-1">
                                        <BookOpen size={16} />
                                        <span>{courses.reduce((sum, c) => sum + (c.modules?.length || 0), 0)} modules</span>
                                    </div>
                                </div>
                            )}
                    </div>
                    <button
                        onClick={() => setIsCreateModalOpen(true)}
                            className="flex items-center justify-center gap-2 px-6 py-3 bg-gradient-to-r from-primary to-secondary text-white font-semibold rounded-xl hover:shadow-xl hover:shadow-primary/30 transition-all transform hover:scale-105 active:scale-95"
                    >
                        <Plus size={20} />
                            <span>Create Course</span>
                        </button>
                    </div>
                </motion.div>

                {/* Search and Filters */}
                {courses.length > 0 && (
                    <motion.div
                        initial={{ opacity: 0, y: 20 }}
                        animate={{ opacity: 1, y: 0 }}
                        transition={{ delay: 0.1 }}
                        className="bg-white dark:bg-gray-800 rounded-2xl shadow-lg p-4 sm:p-6"
                    >
                        <div className="space-y-4">
                            {/* Search Bar */}
                            <div className="relative">
                                <Search className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400" size={20} />
                                <input
                                    type="text"
                                    value={searchQuery}
                                    onChange={(e) => setSearchQuery(e.target.value)}
                                    placeholder="Search courses by title, description, or category..."
                                    className="w-full pl-11 pr-4 py-3 rounded-xl border border-gray-300 dark:border-gray-600 bg-gray-50 dark:bg-gray-700 text-gray-900 dark:text-white focus:ring-2 focus:ring-primary focus:border-transparent outline-none transition-all"
                                />
                            </div>

                            {/* Filters */}
                            <div className="flex flex-wrap gap-3">
                                {/* Category Filter */}
                                <div className="flex items-center gap-2">
                                    <Filter size={18} className="text-gray-500" />
                                    <select
                                        value={selectedCategory}
                                        onChange={(e) => setSelectedCategory(e.target.value)}
                                        className="px-4 py-2 rounded-lg border border-gray-300 dark:border-gray-600 bg-white dark:bg-gray-700 text-gray-900 dark:text-white focus:ring-2 focus:ring-primary outline-none"
                                    >
                                        {categories.map((cat) => (
                                            <option key={cat} value={cat}>{cat}</option>
                                        ))}
                                    </select>
                                </div>

                                {/* Level Filter */}
                                <select
                                    value={selectedLevel}
                                    onChange={(e) => setSelectedLevel(e.target.value)}
                                    className="px-4 py-2 rounded-lg border border-gray-300 dark:border-gray-600 bg-white dark:bg-gray-700 text-gray-900 dark:text-white focus:ring-2 focus:ring-primary outline-none"
                                >
                                    {levels.map((level) => (
                                        <option key={level} value={level}>
                                            {level === 'All' ? 'All Levels' : level}
                                        </option>
                                    ))}
                                </select>

                                {/* Clear Filters */}
                                {(searchQuery || selectedCategory !== 'All' || selectedLevel !== 'All') && (
                                    <button
                                        onClick={() => {
                                            setSearchQuery('');
                                            setSelectedCategory('All');
                                            setSelectedLevel('All');
                                        }}
                                        className="px-4 py-2 text-sm text-gray-600 dark:text-gray-400 hover:text-gray-900 dark:hover:text-white transition-colors"
                                    >
                                        Clear filters
                    </button>
                                )}
                            </div>
                </div>
                    </motion.div>
                )}

                {/* Courses Grid */}
                {isLoading ? null : courses.length === 0 ? (
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
                ) : filteredCourses.length === 0 ? (
                    <motion.div
                        initial={{ opacity: 0 }}
                        animate={{ opacity: 1 }}
                        className="bg-white dark:bg-gray-800 rounded-2xl shadow-lg p-12 text-center"
                    >
                        <div className="w-24 h-24 bg-gray-100 dark:bg-gray-700 rounded-full flex items-center justify-center mx-auto mb-4">
                            <Search size={48} className="text-gray-400" />
                        </div>
                        <h3 className="text-xl font-bold text-gray-900 dark:text-white mb-2">
                            No courses found
                        </h3>
                        <p className="text-gray-600 dark:text-gray-400 mb-6">
                            Try adjusting your search or filters
                        </p>
                        <button
                            onClick={() => {
                                setSearchQuery('');
                                setSelectedCategory('All');
                                setSelectedLevel('All');
                            }}
                            className="px-6 py-3 bg-primary text-white font-semibold rounded-xl hover:bg-primary/90 transition-colors"
                        >
                            Clear Filters
                        </button>
                    </motion.div>
                ) : (
                    <AnimatePresence mode="wait">
                        <motion.div
                            key={`${selectedCategory}-${selectedLevel}-${searchQuery}`}
                            initial={{ opacity: 0 }}
                            animate={{ opacity: 1 }}
                            exit={{ opacity: 0 }}
                            className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6"
                        >
                            {filteredCourses.map((course, index) => (
                            <motion.div
                                key={course.id}
                                initial={{ opacity: 0, y: 20 }}
                                animate={{ opacity: 1, y: 0 }}
                                transition={{ delay: index * 0.05 }}
                                whileHover={{ y: -4 }}
                                className="bg-white dark:bg-gray-800 rounded-2xl shadow-lg overflow-hidden hover:shadow-2xl transition-all duration-300 group"
                            >
                                {/* Thumbnail */}
                                <div className="relative h-48 overflow-hidden bg-gradient-to-br from-primary/20 via-secondary/20 to-primary/10">
                                    {course.thumbnailUrl ? (
                                        <img
                                            src={course.thumbnailUrl}
                                            alt={course.title}
                                            className="w-full h-full object-cover group-hover:scale-110 transition-transform duration-500"
                                            onError={(e) => {
                                                (e.target as HTMLImageElement).style.display = 'none';
                                            }}
                                        />
                                    ) : (
                                        <div className="w-full h-full flex items-center justify-center">
                                            <BookOpen size={48} className="text-gray-400 group-hover:text-primary transition-colors" />
                                        </div>
                                    )}
                                    <div className="absolute inset-0 bg-gradient-to-t from-black/60 via-transparent to-transparent opacity-0 group-hover:opacity-100 transition-opacity" />
                                    <div className="absolute top-3 right-3 flex gap-2">
                                        <span className={`px-3 py-1 text-xs font-bold rounded-full shadow-lg backdrop-blur-sm ${course.level === 'BEGINNER'
                                            ? 'bg-green-500/90 text-white'
                                            : course.level === 'INTERMEDIATE'
                                                ? 'bg-yellow-500/90 text-white'
                                                : 'bg-red-500/90 text-white'
                                            }`}>
                                            {course.level}
                                        </span>
                                    </div>
                                    {/* Hover overlay with quick actions */}
                                    <div className="absolute inset-0 bg-black/60 opacity-0 group-hover:opacity-100 transition-opacity flex items-center justify-center gap-2">
                                        <button
                                            onClick={(e) => {
                                                e.stopPropagation();
                                                window.parent.postMessage({
                                                    type: 'OPEN_COURSE_DETAIL',
                                                    courseId: course.id,
                                                    course: course
                                                }, '*');
                                            }}
                                            className="px-4 py-2 bg-white text-gray-900 rounded-lg hover:bg-gray-100 transition-colors flex items-center gap-2"
                                        >
                                            <Eye size={16} />
                                            Manage Content
                                        </button>
                                    </div>
                                </div>

                                {/* Content */}
                                <div className="p-5">
                                    <div className="flex items-center justify-between mb-3">
                                        <span className="px-3 py-1 bg-primary/10 text-primary text-xs font-semibold rounded-full">
                                            {course.category}
                                        </span>
                                        {course.createdAt && (
                                            <div className="flex items-center gap-1 text-xs text-gray-500 dark:text-gray-400">
                                                <Calendar size={12} />
                                                <span>{new Date(course.createdAt).toLocaleDateString()}</span>
                                            </div>
                                        )}
                                    </div>

                                    <h3 className="text-lg font-bold text-gray-900 dark:text-white mb-2 line-clamp-2 group-hover:text-primary transition-colors">
                                        {course.title}
                                    </h3>

                                    <p className="text-sm text-gray-600 dark:text-gray-400 mb-4 line-clamp-2">
                                        {course.description || 'No description available'}
                                    </p>

                                    {/* Stats */}
                                    <div className="grid grid-cols-2 gap-3 mb-4 p-3 bg-gray-50 dark:bg-gray-700/50 rounded-lg">
                                        <div className="text-center">
                                            <div className="flex items-center justify-center gap-1 text-gray-900 dark:text-white font-bold mb-1">
                                                <BookOpen size={16} className="text-primary" />
                                                <span>{course.modules?.length || 0}</span>
                                            </div>
                                            <p className="text-xs text-gray-500 dark:text-gray-400">Modules</p>
                                        </div>
                                        <div className="text-center">
                                            <div className="flex items-center justify-center gap-1 text-gray-900 dark:text-white font-bold mb-1">
                                                <Users size={16} className="text-secondary" />
                                                <span>0</span>
                                            </div>
                                            <p className="text-xs text-gray-500 dark:text-gray-400">Students</p>
                                        </div>
                                    </div>

                                    {/* Actions */}
                                    <div className="flex gap-2 pt-4 border-t border-gray-200 dark:border-gray-700">
                                        <button
                                            onClick={(e) => {
                                                e.stopPropagation();
                                                setEditingCourse(course);
                                            }}
                                            className="flex-1 flex items-center justify-center gap-2 px-4 py-2.5 bg-primary/10 hover:bg-primary/20 text-primary rounded-lg font-medium transition-all hover:scale-105 active:scale-95"
                                        >
                                            <Edit size={16} />
                                            Edit
                                        </button>
                                        <button
                                            onClick={(e) => {
                                                e.stopPropagation();
                                                setDeletingCourse(course);
                                            }}
                                            className="flex-1 flex items-center justify-center gap-2 px-4 py-2.5 bg-red-50 dark:bg-red-900/20 hover:bg-red-100 dark:hover:bg-red-900/30 text-red-600 dark:text-red-400 rounded-lg font-medium transition-all hover:scale-105 active:scale-95"
                                        >
                                            <Trash2 size={16} />
                                            Delete
                                        </button>
                                    </div>
                                </div>
                            </motion.div>
                        ))}
                        </motion.div>
                    </AnimatePresence>
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
