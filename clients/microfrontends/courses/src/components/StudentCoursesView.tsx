import React, { useState, useEffect } from 'react';
import { Search, BookOpen, Calendar, User, Play, ChevronRight, TrendingUp, Award, Download } from 'lucide-react';
import { motion } from 'framer-motion';
import type { Course, Enrollment } from '../../shell/src/api/types';
import { generateCertificatePDF } from '../utils/certificateGenerator';

// Import CourseProgressResponse from progressApi
interface CourseProgressResponse {
    courseId: string;
    courseTitle: string;
    totalLessons: number;
    completedLessons: number;
    completionRate: number;
}

interface StudentCoursesViewProps {
    theme: 'light' | 'dark';
}

const StudentCoursesView: React.FC<StudentCoursesViewProps> = ({ theme }) => {
    const [enrollments, setEnrollments] = useState<Enrollment[]>([]);
    const [courses, setCourses] = useState<Course[]>([]);
    const [courseProgress, setCourseProgress] = useState<Record<string, CourseProgressResponse>>({});
    const [isLoading, setIsLoading] = useState(true);
    const [error, setError] = useState<string | null>(null);
    const [searchQuery, setSearchQuery] = useState('');
    const [selectedCategory, setSelectedCategory] = useState('All');
    const [studentName, setStudentName] = useState<string>('Student');

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
                const loadedProgress = event.data.courseProgress || {};
                setEnrollments(loadedEnrollments);
                setCourses(loadedCourses);
                setCourseProgress(loadedProgress);
                setIsLoading(false);
            }

            if (event.data.type === 'MY_COURSES_ERROR') {
                setError(event.data.error);
                setIsLoading(false);
            }

            if (event.data.type === 'STUDENT_INFO_LOADED') {
                const name = event.data.firstName && event.data.lastName
                    ? `${event.data.firstName} ${event.data.lastName}`
                    : event.data.email?.split('@')[0] || 'Student';
                setStudentName(name);
            }
        };

        window.addEventListener('message', handleMessage);
        
        // Request student info from shell
        window.parent.postMessage({ type: 'FETCH_STUDENT_INFO' }, '*');
        
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
                            const progress = courseProgress[course.id];
                            const completionRate = progress?.completionRate || 0;
                            const completedLessons = progress?.completedLessons || 0;
                            const totalLessons = progress?.totalLessons || 0;
                            
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
                                        {/* Progress Overlay */}
                                        {progress && totalLessons > 0 && (
                                            <div className="absolute bottom-0 left-0 right-0 bg-black/50 backdrop-blur-sm p-3">
                                                <div className="flex items-center justify-between mb-1">
                                                    <span className="text-white text-xs font-medium">Progress</span>
                                                    <span className="text-white text-xs font-bold">{Math.round(completionRate)}%</span>
                                                </div>
                                                <div className="w-full bg-white/20 rounded-full h-2">
                                                    <div 
                                                        className="bg-gradient-to-r from-green-400 to-green-500 h-2 rounded-full transition-all duration-300"
                                                        style={{ width: `${completionRate}%` }}
                                                    />
                                                </div>
                                                <div className="text-white text-xs mt-1">
                                                    {completedLessons} of {totalLessons} lessons completed
                                                </div>
                                            </div>
                                        )}
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

                                        {/* Progress Info */}
                                        {progress && totalLessons > 0 && (
                                            <div className="mb-4 p-3 bg-gray-50 dark:bg-gray-700/50 rounded-lg">
                                                <div className="flex items-center justify-between mb-2">
                                                    <div className="flex items-center gap-2">
                                                        <TrendingUp size={16} className="text-primary" />
                                                        <span className="text-sm font-medium text-gray-700 dark:text-gray-300">Progress</span>
                                                    </div>
                                                    <span className="text-sm font-bold text-primary">{Math.round(completionRate)}%</span>
                                                </div>
                                                <div className="w-full bg-gray-200 dark:bg-gray-600 rounded-full h-2 mb-1">
                                                    <div 
                                                        className="bg-gradient-to-r from-primary to-secondary h-2 rounded-full transition-all duration-300"
                                                        style={{ width: `${completionRate}%` }}
                                                    />
                                                </div>
                                                <p className="text-xs text-gray-500 dark:text-gray-400">
                                                    {completedLessons} of {totalLessons} lessons completed
                                                </p>
                                            </div>
                                        )}

                                        {/* Enrollment Info */}
                                        {enrollment && (
                                            <div className="flex items-center gap-2 text-sm text-gray-500 dark:text-gray-400 mb-4">
                                                <Calendar size={16} />
                                                <span>Enrolled on {new Date(enrollment.enrolledAt).toLocaleDateString()}</span>
                                            </div>
                                        )}

                                        {/* Action Buttons */}
                                        <div className="flex flex-col gap-2">
                                            <button 
                                                onClick={(e) => {
                                                    e.stopPropagation();
                                                    window.parent.postMessage({
                                                        type: 'OPEN_STUDENT_COURSE',
                                                        courseId: course.id,
                                                        course: course
                                                    }, '*');
                                                }}
                                                className="w-full flex items-center justify-center gap-2 px-4 py-3 bg-primary text-white rounded-lg hover:bg-primary/90 transition-colors font-medium"
                                            >
                                                <Play size={18} />
                                                {completionRate === 100 ? 'Review Course' : 'Continue Learning'}
                                                <ChevronRight size={18} />
                                            </button>
                                            
                                            {/* Certificate Button - Only show when 100% complete */}
                                            {completionRate === 100 && (
                                                <motion.button
                                                    initial={{ opacity: 0, y: 10 }}
                                                    animate={{ opacity: 1, y: 0 }}
                                                    onClick={async (e) => {
                                                        e.stopPropagation();
                                                        try {
                                                            await generateCertificatePDF({
                                                                studentName: studentName,
                                                                courseTitle: course.title,
                                                                completionDate: new Date().toLocaleDateString('en-US', { 
                                                                    year: 'numeric', 
                                                                    month: 'long', 
                                                                    day: 'numeric' 
                                                                }),
                                                                completionRate: Math.round(completionRate)
                                                            });
                                                        } catch (error) {
                                                            console.error('Error generating certificate:', error);
                                                            alert('Failed to generate certificate. Please try again.');
                                                        }
                                                    }}
                                                    className="w-full flex items-center justify-center gap-2 px-4 py-3 bg-gradient-to-r from-yellow-500 to-orange-500 text-white rounded-lg hover:from-yellow-600 hover:to-orange-600 transition-all font-medium shadow-lg hover:shadow-xl"
                                                >
                                                    <Award size={18} />
                                                    Download Certificate
                                                    <Download size={18} />
                                                </motion.button>
                                            )}
                                        </div>
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

