import React, { useState, useEffect } from 'react';
import { Search, Grid3x3, List, SlidersHorizontal } from 'lucide-react';
import { mockCourses, categories } from './data/mockCourses';
import CourseCard from './components/CourseCard';
import { motion, AnimatePresence } from 'framer-motion';

interface CoursesAppProps {
    theme?: 'light' | 'dark';
}

const CoursesApp: React.FC<CoursesAppProps> = ({ theme: initialTheme }) => {
    const [theme, setTheme] = useState<'light' | 'dark'>(initialTheme || 'light');
    const [searchQuery, setSearchQuery] = useState('');
    const [selectedCategory, setSelectedCategory] = useState('All');
    const [viewMode, setViewMode] = useState<'grid' | 'list'>('grid');
    const [selectedCourse, setSelectedCourse] = useState<number | null>(null);
    const [sortBy, setSortBy] = useState<'popular' | 'rating' | 'price'>('popular');

    // Listen for theme changes from parent Shell
    useEffect(() => {
        const handleMessage = (event: MessageEvent) => {
            if (event.data.type === 'THEME_CHANGE') {
                setTheme(event.data.theme);
            }
        };

        window.addEventListener('message', handleMessage);
        return () => window.removeEventListener('message', handleMessage);
    }, []);

    // Apply theme
    useEffect(() => {
        if (theme === 'dark') {
            document.documentElement.classList.add('dark');
        } else {
            document.documentElement.classList.remove('dark');
        }
    }, [theme]);

    // Filter and sort courses
    const filteredCourses = mockCourses
        .filter((course) => {
            const matchesSearch =
                course.title.toLowerCase().includes(searchQuery.toLowerCase()) ||
                course.instructor.toLowerCase().includes(searchQuery.toLowerCase()) ||
                course.description.toLowerCase().includes(searchQuery.toLowerCase());
            const matchesCategory =
                selectedCategory === 'All' || course.category === selectedCategory;
            return matchesSearch && matchesCategory;
        })
        .sort((a, b) => {
            if (sortBy === 'rating') return b.rating - a.rating;
            if (sortBy === 'price') return a.price - b.price;
            return b.students - a.students; // popular
        });

    if (selectedCourse) {
        const course = mockCourses.find((c) => c.id === selectedCourse);
        if (!course) return null;

        return (
            <div className="min-h-screen bg-light-bg dark:bg-dark-bg">
                <div className="max-w-6xl mx-auto p-8">
                    <button
                        onClick={() => setSelectedCourse(null)}
                        className="mb-6 px-4 py-2 bg-gray-200 dark:bg-gray-700 text-gray-900 dark:text-white rounded-lg hover:bg-gray-300 dark:hover:bg-gray-600 transition-colors"
                    >
                        ← Back to Courses
                    </button>

                    <div className="card p-8">
                        <img
                            src={course.thumbnail}
                            alt={course.title}
                            className="w-full h-96 object-cover rounded-xl mb-6"
                        />

                        <div className="flex items-start gap-2 mb-4">
                            <span className="px-3 py-1 bg-primary/10 text-primary text-sm font-semibold rounded-full">
                                {course.category}
                            </span>
                            {course.bestseller && (
                                <span className="px-3 py-1 bg-accent/10 text-accent text-sm font-semibold rounded-full">
                                    Bestseller
                                </span>
                            )}
                        </div>

                        <h1 className="text-4xl font-bold text-gray-900 dark:text-white mb-4">
                            {course.title}
                        </h1>

                        <p className="text-xl text-gray-600 dark:text-gray-400 mb-6">
                            {course.description}
                        </p>

                        <div className="flex items-center gap-6 mb-8">
                            <div>
                                <span className="text-sm text-gray-500 dark:text-gray-400">Instructor</span>
                                <p className="text-lg font-semibold text-gray-900 dark:text-white">
                                    {course.instructor}
                                </p>
                            </div>
                            <div>
                                <span className="text-sm text-gray-500 dark:text-gray-400">Rating</span>
                                <p className="text-lg font-semibold text-gray-900 dark:text-white">
                                    {course.rating} ⭐ ({course.reviewCount.toLocaleString()} reviews)
                                </p>
                            </div>
                            <div>
                                <span className="text-sm text-gray-500 dark:text-gray-400">Students</span>
                                <p className="text-lg font-semibold text-gray-900 dark:text-white">
                                    {course.students.toLocaleString()}
                                </p>
                            </div>
                        </div>

                        <div className="flex items-center gap-4">
                            <div>
                                <span className="text-4xl font-bold text-gray-900 dark:text-white">
                                    ${course.price}
                                </span>
                                {course.originalPrice && (
                                    <span className="ml-3 text-xl text-gray-500 dark:text-gray-400 line-through">
                                        ${course.originalPrice}
                                    </span>
                                )}
                            </div>
                            <button className="px-8 py-4 bg-gradient-to-r from-primary to-secondary text-white text-lg font-semibold rounded-xl hover:shadow-lg hover:shadow-primary/30 transition-all">
                                Enroll Now
                            </button>
                        </div>
                    </div>
                </div>
            </div>
        );
    }

    return (
        <div className="min-h-screen bg-light-bg dark:bg-dark-bg p-8">
            <div className="max-w-7xl mx-auto space-y-6">
                {/* Header */}
                <div>
                    <h1 className="text-3xl font-bold text-gray-900 dark:text-white mb-2">
                        Explore Courses
                    </h1>
                    <p className="text-gray-600 dark:text-gray-400">
                        Discover {mockCourses.length} courses to advance your career
                    </p>
                </div>

                {/* Search and Filters */}
                <div className="card p-6">
                    <div className="flex flex-col lg:flex-row gap-4">
                        {/* Search */}
                        <div className="relative flex-1">
                            <Search className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400" size={20} />
                            <input
                                type="text"
                                value={searchQuery}
                                onChange={(e) => setSearchQuery(e.target.value)}
                                placeholder="Search courses..."
                                className="w-full pl-11 pr-4 py-3 rounded-xl border border-gray-300 dark:border-gray-600 bg-white dark:bg-gray-800 focus:ring-2 focus:ring-primary outline-none"
                            />
                        </div>

                        {/* Sort */}
                        <select
                            value={sortBy}
                            onChange={(e) => setSortBy(e.target.value as any)}
                            className="px-4 py-3 rounded-xl border border-gray-300 dark:border-gray-600 bg-white dark:bg-gray-800 focus:ring-2 focus:ring-primary outline-none"
                        >
                            <option value="popular">Most Popular</option>
                            <option value="rating">Highest Rated</option>
                            <option value="price">Lowest Price</option>
                        </select>

                        {/* View Mode */}
                        <div className="flex gap-2">
                            <button
                                onClick={() => setViewMode('grid')}
                                className={`p-3 rounded-xl transition-colors ${viewMode === 'grid'
                                    ? 'bg-primary text-white'
                                    : 'bg-gray-200 dark:bg-gray-700 text-gray-700 dark:text-gray-300'
                                    }`}
                            >
                                <Grid3x3 size={20} />
                            </button>
                            <button
                                onClick={() => setViewMode('list')}
                                className={`p-3 rounded-xl transition-colors ${viewMode === 'list'
                                    ? 'bg-primary text-white'
                                    : 'bg-gray-200 dark:bg-gray-700 text-gray-700 dark:text-gray-300'
                                    }`}
                            >
                                <List size={20} />
                            </button>
                        </div>
                    </div>

                    {/* Category Pills */}
                    <div className="mt-4 flex flex-wrap gap-2">
                        {categories.map((category) => (
                            <button
                                key={category}
                                onClick={() => setSelectedCategory(category)}
                                className={`px-4 py-2 rounded-full text-sm font-medium transition-all ${selectedCategory === category
                                    ? 'bg-primary text-white'
                                    : 'bg-gray-100 dark:bg-gray-800 text-gray-700 dark:text-gray-300 hover:bg-gray-200 dark:hover:bg-gray-700'
                                    }`}
                            >
                                {category}
                            </button>
                        ))}
                    </div>
                </div>

                {/* Results Count */}
                <div className="flex items-center justify-between">
                    <p className="text-gray-600 dark:text-gray-400">
                        Showing {filteredCourses.length} {filteredCourses.length === 1 ? 'course' : 'courses'}
                    </p>
                </div>

                {/* Courses Grid */}
                <AnimatePresence mode="wait">
                    <motion.div
                        key={viewMode}
                        initial={{ opacity: 0, y: 20 }}
                        animate={{ opacity: 1, y: 0 }}
                        exit={{ opacity: 0, y: -20 }}
                        className={
                            viewMode === 'grid'
                                ? 'grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6'
                                : 'space-y-4'
                        }
                    >
                        {filteredCourses.map((course) => (
                            <CourseCard
                                key={course.id}
                                course={course}
                                onClick={() => setSelectedCourse(course.id)}
                            />
                        ))}
                    </motion.div>
                </AnimatePresence>

                {filteredCourses.length === 0 && (
                    <div className="text-center py-16">
                        <p className="text-xl text-gray-500 dark:text-gray-400">
                            No courses found matching your criteria
                        </p>
                    </div>
                )}
            </div>
        </div>
    );
};

export default CoursesApp;
