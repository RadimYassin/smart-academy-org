import React from 'react';
import { Plus, Pencil, Users } from 'lucide-react';
import { mockCourses } from '../../data/mockCourses';

const MyCourses: React.FC = () => {
    // Filter professor's courses (for demo, take first 6)
    const professorCourses = mockCourses.slice(0, 6);

    return (
        <div className="bg-gray-50 dark:bg-gray-900 overflow-y-auto h-full">
            <div className="max-w-7xl mx-auto p-8">
                {/* Header */}
                <div className="flex items-center justify-between mb-8">
                    <div>
                        <h1 className="text-3xl font-bold text-gray-900 dark:text-white mb-2">
                            My Courses
                        </h1>
                        <p className="text-gray-600 dark:text-gray-400">
                            Manage and monitor your courses
                        </p>
                    </div>
                    <button className="px-6 py-3 bg-[#4F46E5] hover:bg-[#4338CA] text-white font-semibold rounded-lg flex items-center gap-2 transition-colors">
                        <Plus size={20} />
                        Create New Course
                    </button>
                </div>

                {/* Courses Grid */}
                <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                    {professorCourses.map((course) => (
                        <div key={course.id} className="bg-white dark:bg-gray-800 rounded-xl overflow-hidden shadow-sm hover:shadow-md transition-shadow">
                            {/* Course Thumbnail */}
                            <div className="relative">
                                <img
                                    src={course.thumbnail}
                                    alt={course.title}
                                    className="w-full h-48 object-cover"
                                />
                                {course.bestseller && (
                                    <span className="absolute top-3 right-3 px-3 py-1 bg-yellow-400 text-gray-900 text-xs font-bold rounded">
                                        Bestseller
                                    </span>
                                )}
                            </div>

                            {/* Course Info */}
                            <div className="p-5">
                                <h3 className="font-bold text-gray-900 dark:text-white mb-3 line-clamp-2">
                                    {course.title}
                                </h3>

                                {/* Stats */}
                                <div className="flex items-center gap-4 mb-4 text-sm text-gray-600 dark:text-gray-400">
                                    <div className="flex items-center gap-1">
                                        <Users size={16} />
                                        <span>{course.students}</span>
                                    </div>
                                    <div className="flex items-center gap-1">
                                        <span className="text-yellow-500">★</span>
                                        <span>{course.rating}</span>
                                    </div>
                                </div>

                                {/* Manage Button */}
                                <button className="w-full px-4 py-2.5 border-2 border-gray-300 dark:border-gray-600 text-gray-700 dark:text-gray-300 font-medium rounded-lg hover:bg-gray-50 dark:hover:bg-gray-700 transition-colors flex items-center justify-center gap-2">
                                    <Pencil size={16} />
                                    Manage Course
                                </button>
                            </div>
                        </div>
                    ))}
                </div>
            </div>
        </div>
    );
};

export default MyCourses;
