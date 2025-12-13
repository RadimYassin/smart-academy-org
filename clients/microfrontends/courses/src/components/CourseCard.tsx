import React from 'react';
import { Star, Users, Clock, TrendingUp } from 'lucide-react';
import type { Course } from '../data/mockCourses';
import { motion } from 'framer-motion';

interface CourseCardProps {
    course: Course;
    onClick: () => void;
}

const CourseCard: React.FC<CourseCardProps> = ({ course, onClick }) => {
    const discount = course.originalPrice
        ? Math.round(((course.originalPrice - course.price) / course.originalPrice) * 100)
        : 0;

    return (
        <motion.div
            whileHover={{ y: -8 }}
            onClick={onClick}
            className="card card-hover cursor-pointer overflow-hidden group"
        >
            {/* Thumbnail */}
            <div className="relative overflow-hidden">
                <img
                    src={course.thumbnail}
                    alt={course.title}
                    className="w-full h-48 object-cover group-hover:scale-110 transition-transform duration-500"
                />
                {course.bestseller && (
                    <div className="absolute top-3 left-3 px-3 py-1 bg-accent text-white text-xs font-bold rounded-full flex items-center gap-1">
                        <TrendingUp size={12} />
                        Bestseller
                    </div>
                )}
                {discount > 0 && (
                    <div className="absolute top-3 right-3 px-2 py-1 bg-red-500 text-white text-xs font-bold rounded">
                        -{discount}%
                    </div>
                )}
            </div>

            {/* Content */}
            <div className="p-4">
                {/* Category */}
                <span className="text-xs font-semibold text-primary uppercase tracking-wide">
                    {course.category}
                </span>

                {/* Title */}
                <h3 className="mt-2 text-lg font-bold text-gray-900 dark:text-white line-clamp-2 group-hover:text-primary transition-colors">
                    {course.title}
                </h3>

                {/* Instructor */}
                <p className="mt-1 text-sm text-gray-600 dark:text-gray-400">
                    {course.instructor}
                </p>

                {/* Rating */}
                <div className="mt-3 flex items-center gap-2">
                    <div className="flex items-center gap-1">
                        <Star className="text-accent fill-accent" size={16} />
                        <span className="text-sm font-bold text-gray-900 dark:text-white">
                            {course.rating}
                        </span>
                    </div>
                    <span className="text-sm text-gray-500 dark:text-gray-400">
                        ({course.reviewCount.toLocaleString()})
                    </span>
                </div>

                {/* Meta Info */}
                <div className="mt-3 flex items-center gap-4 text-sm text-gray-600 dark:text-gray-400">
                    <div className="flex items-center gap-1">
                        <Users size={14} />
                        <span>{(course.students / 1000).toFixed(1)}k</span>
                    </div>
                    <div className="flex items-center gap-1">
                        <Clock size={14} />
                        <span>{course.duration}</span>
                    </div>
                </div>

                {/* Price */}
                <div className="mt-4 flex items-center gap-2">
                    <span className="text-2xl font-bold text-gray-900 dark:text-white">
                        ${course.price}
                    </span>
                    {course.originalPrice && (
                        <span className="text-sm text-gray-500 dark:text-gray-400 line-through">
                            ${course.originalPrice}
                        </span>
                    )}
                </div>

                {/* Level Badge */}
                <div className="mt-3">
                    <span
                        className={`inline-block px-3 py-1 text-xs font-semibold rounded-full ${course.level === 'Beginner'
                            ? 'bg-green-100 dark:bg-green-900/20 text-green-800 dark:text-green-400'
                            : course.level === 'Intermediate'
                                ? 'bg-blue-100 dark:bg-blue-900/20 text-blue-800 dark:text-blue-400'
                                : 'bg-purple-100 dark:bg-purple-900/20 text-purple-800 dark:text-purple-400'
                            }`}
                    >
                        {course.level}
                    </span>
                </div>
            </div>
        </motion.div>
    );
};

export default CourseCard;
