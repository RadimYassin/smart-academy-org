import React, { useState, useEffect } from 'react';
import { Search, BookOpen, Calendar, User, Play, ChevronRight } from 'lucide-react';
import { motion } from 'framer-motion';
import type { Course, Enrollment } from '../../shell/src/api/types';

interface StudentCoursesViewProps {
    theme: 'light' | 'dark';
}

const StudentCoursesView: React.FC<StudentCoursesViewProps> = ({ theme }) => {
    const [enrollments, setEnrollments] = useState<Enrollment[]>([]);
    const [courses, setCourses] = useState<Course[]>([]);
    const [isLoading, setIsLoading] = useState(true);
    const [error, setError] = useState<string | null>(null);
    const [searchQuery, setSearchQuery] = useState('');
    const [selectedCategory, setSelectedCategory] = useState('All');

    // Load student's enrolled courses
    useEffect(() => {
        loadMyCourses();
    }, []);

    const loadMyCourses = () => {
        setIsLoading(true);
        setError(null);
        // Request enrollments from Shell
        window.parent.postMessage({ type: 'FETCH_MY_COURSES' }, '*');
    };

    // Listen for responses from Shell
    useEffect(() => {
        const handleMessage = (event: MessageEvent) => {
            if (event.data.type === 'MY_COURSES_LOADED') {
                const loadedEnrollments = event.data.enrollments || [];
                const loadedCourses = event.data.courses || [];
                setEnrollments(loadedEnrollments);
                setCourses(loadedCourses);
                setIsLoading(false);
            }

            if (event.data.type === 'MY_COURSES_ERROR') {
                setError(event.data.error);
                setIsLoading(false);
            }
        };

        window.addEventListener('message', handleMessage);
        return () => window.removeEventListener('message', handleMessage);
    }, []);

    // Filter courses
    const filteredCourses = courses.filter((course) => {
        const matchesSearch =
            course.title.toLowerCase().includes(searchQuery.toLowerCase()) ||
            course.description?.toLowerCase().includes(searchQuery.toLowerCase()) ||
            course.category?.toLowerCase().includes(searchQuery.toLowerCase());
        const matchesCategory =
            selectedCategory === 'All' || course.category === selectedCategory;
        return matchesSearch && matchesCategory;
    });

    // Get unique categories from courses
    const categories = ['All', ...Array.from(new Set(courses.map(c => c.category).filter(Boolean)))];

    if (isLoading) {
        return (
            <div className="min-h-screen bg-gradient-to-br from-gray-50 to-gray-100 dark:from-gray-900 dark:to-gray-800 flex items-center justify-center">
                <div className="text-center">
                    <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-primary mx-auto mb-4"></div>
                    <p className="text-gray-600 dark:text-gray-400">Loading your courses...</p>
                </div>
            </div>
        );
    }

    if (error) {
        return (
            <div className="min-h-screen bg-gradient-to-br from-gray-50 to-gray-100 dark:from-gray-900 dark:to-gray-800 flex items-center justify-center p-8">
                <div className="bg-white dark:bg-gray-800 rounded-2xl shadow-lg p-8 max-w-md w-full text-center">
                    <p className="text-red-500 mb-4">{error}</p>
                    <button
                        onClick={loadMyCourses}
                        className="px-6 py-2 bg-primary text-white rounded-lg hover:bg-primary/90 transition-colors"
                    >
                        Retry
                    </button>
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
                    <h1 className="text-4xl font-extrabold text-gray-900 dark:text-white mb-2">
                        My Courses
                    </h1>
                    <p className="text-lg text-gray-600 dark:text-gray-400">
                        {courses.length === 0
                            ? "You haven't enrolled in any courses yet"
                            : `You are enrolled in ${courses.length} ${courses.length === 1 ? 'course' : 'courses'}`}
                    </p>
                </motion.div>

                {/* Search and Filters */}
                {courses.length > 0 && (
                    <motion.div
                        initial={{ opacity: 0, y: 20 }}
                        animate={{ opacity: 1, y: 0 }}
                        className="bg-white dark:bg-gray-800 rounded-2xl shadow-lg p-6"
                    >
                        <div className="flex flex-col lg:flex-row gap-4 mb-4">
                            {/* Search */}
                            <div className="relative flex-1">
                                <Search className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400" size={20} />
                                <input
                                    type="text"
                                    value={searchQuery}
                                    onChange={(e) => setSearchQuery(e.target.value)}
                                    placeholder="Search courses..."
                                    className="w-full pl-11 pr-4 py-3 rounded-xl border border-gray-300 dark:border-gray-600 bg-white dark:bg-gray-700 text-gray-900 dark:text-white focus:ring-2 focus:ring-primary outline-none"
                                />
                            </div>
                        </div>

                        {/* Category Pills */}
                        <div className="flex flex-wrap gap-2">
                            {categories.map((category) => (
                                <button
                                    key={category}
                                    onClick={() => setSelectedCategory(category)}
                                    className={`px-4 py-2 rounded-full text-sm font-medium transition-all ${
                                        selectedCategory === category
                                            ? 'bg-primary text-white'
                                            : 'bg-gray-100 dark:bg-gray-700 text-gray-700 dark:text-gray-300 hover:bg-gray-200 dark:hover:bg-gray-600'
                                    }`}
                                >
                                    {category}
                                </button>
                            ))}
                        </div>
                    </motion.div>
                )}

                {/* Courses Grid */}
                {filteredCourses.length === 0 && courses.length > 0 ? (
                    <div className="bg-white dark:bg-gray-800 rounded-2xl shadow-lg p-12 text-center">
                        <p className="text-gray-600 dark:text-gray-400">
                            No courses found matching your criteria
                        </p>
                    </div>
                ) : filteredCourses.length === 0 ? (
                    <motion.div
                        initial={{ opacity: 0 }}
                        animate={{ opacity: 1 }}
                        className="bg-white dark:bg-gray-800 rounded-2xl shadow-lg p-12 text-center"
                    >
                        <BookOpen size={64} className="text-gray-400 mx-auto mb-4" />
                        <h2 className="text-2xl font-bold text-gray-900 dark:text-white mb-2">
                            No Courses Yet
                        </h2>
                        <p className="text-gray-600 dark:text-gray-400 mb-6">
                            You haven't been assigned to any courses yet. Contact your teacher to get enrolled.
                        </p>
                    </motion.div>
                ) : (
                    <motion.div
                        initial={{ opacity: 0 }}
                        animate={{ opacity: 1 }}
                        className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6"
                    >
                        {filteredCourses.map((course) => {
                            const enrollment = enrollments.find(e => e.courseId === course.id);
                            return (
                                <motion.div
                                    key={course.id}
                                    initial={{ opacity: 0, y: 20 }}
                                    animate={{ opacity: 1, y: 0 }}
                                    whileHover={{ y: -5 }}
                                    className="bg-white dark:bg-gray-800 rounded-2xl shadow-lg overflow-hidden hover:shadow-xl transition-shadow cursor-pointer"
                                    onClick={() => {
                                        window.parent.postMessage({
                                            type: 'OPEN_STUDENT_COURSE',
                                            courseId: course.id,
                                            course: course
                                        }, '*');
                                    }}
                                >
                                    {/* Course Image */}
                                    <div className="relative h-48 bg-gradient-to-br from-primary to-secondary">
                                        {course.thumbnailUrl ? (
                                            <img
                                                src={course.thumbnailUrl}
                                                alt={course.title}
                                                className="w-full h-full object-cover"
                                            />
                                        ) : (
                                            <div className="w-full h-full flex items-center justify-center">
                                                <BookOpen size={64} className="text-white opacity-50" />
                                            </div>
                                        )}
                                        <div className="absolute top-4 right-4">
                                            <span className="px-3 py-1 bg-white/90 dark:bg-gray-800/90 text-gray-900 dark:text-white rounded-full text-sm font-medium">
                                                {course.level}
                                            </span>
                                        </div>
                                    </div>

                                    {/* Course Content */}
                                    <div className="p-6">
                                        <div className="flex items-center gap-2 mb-3">
                                            <span className="px-3 py-1 bg-primary/10 text-primary text-xs font-medium rounded-full">
                                                {course.category}
                                            </span>
                                        </div>

                                        <h3 className="text-xl font-bold text-gray-900 dark:text-white mb-2 line-clamp-2">
                                            {course.title}
                                        </h3>

                                        <p className="text-gray-600 dark:text-gray-400 text-sm mb-4 line-clamp-2">
                                            {course.description}
                                        </p>

                                        {/* Enrollment Info */}
                                        {enrollment && (
                                            <div className="flex items-center gap-2 text-sm text-gray-500 dark:text-gray-400 mb-4">
                                                <Calendar size={16} />
                                                <span>Enrolled on {new Date(enrollment.enrolledAt).toLocaleDateString()}</span>
                                            </div>
                                        )}

                                        {/* Action Button */}
                                        <button 
                                            onClick={() => {
                                                window.parent.postMessage({
                                                    type: 'OPEN_STUDENT_COURSE',
                                                    courseId: course.id,
                                                    course: course
                                                }, '*');
                                            }}
                                            className="w-full flex items-center justify-center gap-2 px-4 py-3 bg-primary text-white rounded-lg hover:bg-primary/90 transition-colors font-medium"
                                        >
                                            <Play size={18} />
                                            Start Learning
                                            <ChevronRight size={18} />
                                        </button>
                                    </div>
                                </motion.div>
                            );
                        })}
                    </motion.div>
                )}

                {/* Results Count */}
                {courses.length > 0 && (
                    <div className="text-center text-gray-600 dark:text-gray-400">
                        Showing {filteredCourses.length} of {courses.length} courses
                    </div>
                )}
            </div>
        </div>
    );
};

export default StudentCoursesView;

