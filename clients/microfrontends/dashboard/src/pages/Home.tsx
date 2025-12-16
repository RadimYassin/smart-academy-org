import React, { useState, useEffect } from 'react';
import { Search, Play, BookOpen, Clock } from 'lucide-react';
import type { Course, Enrollment } from '../../shell/src/api/types';

const Home: React.FC = () => {
    const [enrollments, setEnrollments] = useState<Enrollment[]>([]);
    const [courses, setCourses] = useState<Course[]>([]);
    const [isLoading, setIsLoading] = useState(true);
    const [continueLearningCourse, setContinueLearningCourse] = useState<Course | null>(null);
    const [progress, setProgress] = useState(0);

    // Load student's enrolled courses
    useEffect(() => {
        loadMyCourses();
    }, []);

    const loadMyCourses = () => {
        setIsLoading(true);
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
                
                // Set the first course as "Continue Learning" (in a real app, this would be based on progress)
                if (loadedCourses.length > 0) {
                    setContinueLearningCourse(loadedCourses[0]);
                    // Mock progress - in real app, fetch from progress API
                    setProgress(70);
                }
                
                setIsLoading(false);
            }

            if (event.data.type === 'MY_COURSES_ERROR') {
                console.error('Error loading courses:', event.data.error);
                setIsLoading(false);
            }
        };

        window.addEventListener('message', handleMessage);
        return () => window.removeEventListener('message', handleMessage);
    }, []);

    // Recently added (last 3 courses, sorted by enrollment date)
    const recentlyAdded = enrollments
        .sort((a, b) => new Date(b.enrolledAt).getTime() - new Date(a.enrolledAt).getTime())
        .slice(0, 3)
        .map(enrollment => courses.find(c => c.id === enrollment.courseId))
        .filter(Boolean) as Course[];

    // Popular courses (take first 3 courses if available)
    const popularCourses = courses.slice(0, 3);

    // Explore Topics
    const topics = [
        { id: 'design', name: 'Design', icon: '🎨', color: 'from-pink-500 to-pink-600' },
        { id: 'business', name: 'Business', icon: '💼', color: 'from-blue-500 to-blue-600' },
        { id: 'development', name: 'Development', icon: '💻', color: 'from-teal-500 to-teal-600' },
        { id: 'marketing', name: 'Marketing', icon: '📢', color: 'from-orange-500 to-orange-600' },
    ];

    return (
        <div className="bg-gray-50 overflow-y-auto">
            <div className="max-w-7xl mx-auto p-8">
                {/* Search Bar */}
                <div className="relative mb-12">
                    <Search className="absolute left-4 top-1/2 -translate-y-1/2 text-gray-400" size={20} />
                    <input
                        type="text"
                        placeholder="What do you want to learn?"
                        className="w-full pl-12 pr-4 py-4 bg-white border border-gray-200 rounded-2xl focus:outline-none focus:ring-2 focus:ring-[#5B4FE9] transition-all text-gray-900 placeholder-gray-400"
                    />
                </div>

                {/* Continue Learning */}
                {continueLearningCourse ? (
                <section className="mb-12">
                        <h2 className="text-2xl font-bold text-gray-900 dark:text-white mb-6">Continue Learning</h2>
                        <div 
                            className="bg-gradient-to-br from-[#5B4FE9] via-[#6B5FFF] to-[#4B3FD9] rounded-3xl p-8 relative overflow-hidden cursor-pointer hover:shadow-xl transition-shadow"
                            onClick={() => {
                                window.parent.postMessage({
                                    type: 'OPEN_STUDENT_COURSE',
                                    courseId: continueLearningCourse.id,
                                    course: continueLearningCourse
                                }, '*');
                            }}
                        >
                        {/* Decorative elements */}
                        <div className="absolute top-0 right-0 w-96 h-96 bg-white/10 rounded-full blur-3xl"></div>
                        <div className="absolute bottom-0 left-20 w-64 h-64 bg-purple-300/20 rounded-full blur-2xl"></div>

                        <div className="relative z-10 flex items-center justify-between">
                            <div className="flex-1">
                                <span className="inline-block px-3 py-1 bg-white/20 text-white text-xs font-semibold rounded-full mb-3">
                                        {continueLearningCourse.category || 'Course'}
                                </span>
                                <h3 className="text-2xl font-bold text-white mb-2">
                                        {continueLearningCourse.title}
                                </h3>
                                <p className="text-white/90 text-sm mb-4">
                                    Continue where you left off
                                </p>
                                <p className="text-white/90 text-sm mb-3">
                                        {Math.round((progress / 100) * 10)} of 10+ lessons
                                </p>

                                {/* Progress Bar */}
                                <div className="w-full max-w-md bg-white/20 rounded-full h-2 mb-6">
                                    <div
                                        className="bg-white rounded-full h-2 transition-all"
                                        style={{ width: `${progress}%` }}
                                    ></div>
                                </div>

                                    <button 
                                        className="px-6 py-3 bg-white text-[#5B4FE9] font-semibold rounded-lg hover:bg-gray-50 transition-colors flex items-center gap-2"
                                        onClick={(e) => {
                                            e.stopPropagation();
                                            window.parent.postMessage({
                                                type: 'OPEN_STUDENT_COURSE',
                                                courseId: continueLearningCourse.id,
                                                course: continueLearningCourse
                                            }, '*');
                                        }}
                                    >
                                        <Play size={18} />
                                    Continue Learning
                                </button>
                            </div>

                                {/* Course Image or Icon */}
                            <div className="hidden lg:block ml-8">
                                    {continueLearningCourse.thumbnailUrl ? (
                                        <img
                                            src={continueLearningCourse.thumbnailUrl}
                                            alt={continueLearningCourse.title}
                                            className="w-64 h-48 object-cover rounded-lg bg-white/10 backdrop-blur-sm"
                                        />
                                    ) : (
                                <div className="bg-gray-900/40 backdrop-blur-sm rounded-lg p-6 text-sm font-mono text-white/80 max-w-md">
                                    <div className="text-purple-300">&lt;div&gt;</div>
                                            <div className="ml-4 text-blue-300">&lt;course&gt;</div>
                                            <div className="ml-8"><span className="text-pink-300">.learning</span></div>
                                </div>
                                    )}
                                <span className="absolute bottom-8 right-8 text-6xl text-white/30 font-bold">
                                    {progress}%
                                </span>
                            </div>
                        </div>
                    </div>
                </section>
                ) : !isLoading && courses.length === 0 ? (
                    <section className="mb-12">
                        <h2 className="text-2xl font-bold text-gray-900 dark:text-white mb-6">Continue Learning</h2>
                        <div className="bg-gradient-to-br from-gray-100 to-gray-200 dark:from-gray-800 dark:to-gray-700 rounded-3xl p-12 text-center">
                            <BookOpen size={64} className="text-gray-400 mx-auto mb-4" />
                            <h3 className="text-xl font-bold text-gray-600 dark:text-gray-300 mb-2">
                                No courses yet
                            </h3>
                            <p className="text-gray-500 dark:text-gray-400">
                                Start learning by enrolling in courses
                            </p>
                        </div>
                    </section>
                ) : null}

                {/* Recently Added */}
                {recentlyAdded.length > 0 && (
                <section className="mb-12">
                        <h2 className="text-2xl font-bold text-gray-900 dark:text-white mb-6">Recently Added</h2>
                    <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
                            {recentlyAdded.map((course) => {
                                const enrollment = enrollments.find(e => e.courseId === course.id);
                                return (
                                    <div 
                                        key={course.id} 
                                        className="bg-white dark:bg-gray-800 rounded-xl overflow-hidden shadow-sm hover:shadow-md transition-shadow cursor-pointer"
                                        onClick={() => {
                                            window.parent.postMessage({
                                                type: 'OPEN_STUDENT_COURSE',
                                                courseId: course.id,
                                                course: course
                                            }, '*');
                                        }}
                                    >
                                        {course.thumbnailUrl ? (
                                <img
                                                src={course.thumbnailUrl}
                                    alt={course.title}
                                    className="w-full h-40 object-cover"
                                />
                                        ) : (
                                            <div className="w-full h-40 bg-gradient-to-br from-[#5B4FE9] to-[#7C3AED] flex items-center justify-center">
                                                <BookOpen size={48} className="text-white opacity-50" />
                                            </div>
                                        )}
                                <div className="p-4">
                                            <span className="inline-block px-2 py-1 bg-[#5B4FE9]/10 text-[#5B4FE9] text-xs font-semibold rounded-full mb-2">
                                                {course.category || 'Course'}
                                            </span>
                                            <h3 className="font-semibold text-gray-900 dark:text-white mb-2 line-clamp-2 text-sm">
                                        {course.title}
                                    </h3>
                                    <div className="flex items-center gap-2 mb-2">
                                                <span className="px-2 py-1 bg-gray-100 dark:bg-gray-700 text-gray-600 dark:text-gray-300 text-xs font-medium rounded">
                                                    {course.level}
                                                </span>
                                                {enrollment && (
                                                    <span className="text-xs text-gray-500 dark:text-gray-400">
                                                        Enrolled {new Date(enrollment.enrolledAt).toLocaleDateString()}
                                                    </span>
                                                )}
                                            </div>
                                            <button className="w-full mt-3 px-4 py-2 bg-[#5B4FE9] text-white font-semibold rounded-lg hover:bg-[#4B3FD9] transition-colors flex items-center justify-center gap-2">
                                                <Play size={16} />
                                                Start Learning
                                            </button>
                                    </div>
                                    </div>
                                );
                            })}
                    </div>
                </section>
                )}

                {/* Explore Topics */}
                <section className="mb-12">
                    <h2 className="text-2xl font-bold text-gray-900 mb-6">Explore Topics</h2>
                    <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
                        {topics.map((topic) => (
                            <button
                                key={topic.id}
                                className="bg-white rounded-xl p-6 hover:shadow-md transition-all group"
                            >
                                <div className={`w-14 h-14 bg-gradient-to-br ${topic.color} rounded-xl flex items-center justify-center mb-3 group-hover:scale-110 transition-transform`}>
                                    <span className="text-2xl">{topic.icon}</span>
                                </div>
                                <h3 className="text-gray-900 font-semibold text-sm">{topic.name}</h3>
                            </button>
                        ))}
                    </div>
                </section>

                {/* My Courses */}
                {courses.length > 3 && (
                <section>
                        <h2 className="text-2xl font-bold text-gray-900 dark:text-white mb-6">My Courses</h2>
                    <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
                            {courses.slice(3).map((course) => {
                                const enrollment = enrollments.find(e => e.courseId === course.id);
                                return (
                                    <div 
                                        key={course.id} 
                                        className="bg-white dark:bg-gray-800 rounded-xl overflow-hidden shadow-sm hover:shadow-md transition-shadow group cursor-pointer"
                                        onClick={() => {
                                            window.parent.postMessage({
                                                type: 'OPEN_STUDENT_COURSE',
                                                courseId: course.id,
                                                course: course
                                            }, '*');
                                        }}
                                    >
                                <div className="relative">
                                            {course.thumbnailUrl ? (
                                    <img
                                                    src={course.thumbnailUrl}
                                        alt={course.title}
                                        className="w-full h-48 object-cover"
                                    />
                                            ) : (
                                                <div className="w-full h-48 bg-gradient-to-br from-[#5B4FE9] to-[#7C3AED] flex items-center justify-center">
                                                    <BookOpen size={64} className="text-white opacity-50" />
                                                </div>
                                            )}
                                            <span className="absolute top-3 left-3 px-3 py-1 bg-white/90 dark:bg-gray-800/90 text-gray-900 dark:text-white text-xs font-bold rounded">
                                                {course.level}
                                        </span>
                                </div>
                                <div className="p-5">
                                            <span className="inline-block px-2 py-1 bg-[#5B4FE9]/10 text-[#5B4FE9] text-xs font-semibold rounded-full mb-2">
                                                {course.category || 'Course'}
                                            </span>
                                            <h3 className="font-bold text-gray-900 dark:text-white mb-2 line-clamp-2">
                                                {course.title}
                                            </h3>
                                            <p className="text-sm text-gray-600 dark:text-gray-400 mb-3 line-clamp-2">
                                                {course.description}
                                            </p>
                                            {enrollment && (
                                                <div className="flex items-center gap-2 mb-3 text-xs text-gray-500 dark:text-gray-400">
                                                    <Clock size={14} />
                                                    <span>Enrolled {new Date(enrollment.enrolledAt).toLocaleDateString()}</span>
                                                </div>
                                            )}
                                            <button className="w-full mt-3 px-4 py-2 bg-[#5B4FE9] text-white font-semibold rounded-lg hover:bg-[#4B3FD9] transition-colors flex items-center justify-center gap-2">
                                                <Play size={16} />
                                                Continue
                                            </button>
                                        </div>
                                    </div>
                                );
                            })}
                                </div>
                    </section>
                )}

                {/* Empty State */}
                {!isLoading && courses.length === 0 && (
                    <section>
                        <div className="bg-white dark:bg-gray-800 rounded-xl p-12 text-center">
                            <BookOpen size={64} className="text-gray-400 mx-auto mb-4" />
                            <h2 className="text-2xl font-bold text-gray-900 dark:text-white mb-2">
                                No Courses Yet
                            </h2>
                            <p className="text-gray-600 dark:text-gray-400 mb-6">
                                You haven't been assigned to any courses yet. Contact your teacher to get enrolled.
                            </p>
                    </div>
                </section>
                )}
            </div>
        </div >
    );
};

export default Home;
