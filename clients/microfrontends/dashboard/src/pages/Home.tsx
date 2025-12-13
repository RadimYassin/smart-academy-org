import React from 'react';
import { Search } from 'lucide-react';
import { mockCourses } from '../data/mockCourses';

const Home: React.FC = () => {
    // Progress data for Continue Learning
    const progress = 70; // 70% progress (23 of 33 lessons)
    const currentLesson = 23;
    const totalLessons = 33;

    // Recently added (last 3 courses)
    const recentlyAdded = mockCourses.slice(0, 3);

    // Popular courses (bestseller courses)
    const popularCourses = mockCourses.filter(c => c.bestseller).slice(0, 3);

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
                <section className="mb-12">
                    <h2 className="text-2xl font-bold text-gray-900 mb-6">Continue Learning</h2>
                    <div className="bg-gradient-to-br from-[#5B4FE9] via-[#6B5FFF] to-[#4B3FD9] rounded-3xl p-8 relative overflow-hidden">
                        {/* Decorative elements */}
                        <div className="absolute top-0 right-0 w-96 h-96 bg-white/10 rounded-full blur-3xl"></div>
                        <div className="absolute bottom-0 left-20 w-64 h-64 bg-purple-300/20 rounded-full blur-2xl"></div>

                        <div className="relative z-10 flex items-center justify-between">
                            <div className="flex-1">
                                <span className="inline-block px-3 py-1 bg-white/20 text-white text-xs font-semibold rounded-full mb-3">
                                    Website
                                </span>
                                <h3 className="text-2xl font-bold text-white mb-2">
                                    Fundamentals of HTML & CSS From Scratch
                                </h3>
                                <p className="text-white/90 text-sm mb-4">
                                    Continue where you left off
                                </p>
                                <p className="text-white/90 text-sm mb-3">
                                    {currentLesson} of {totalLessons} lessons
                                </p>

                                {/* Progress Bar */}
                                <div className="w-full max-w-md bg-white/20 rounded-full h-2 mb-6">
                                    <div
                                        className="bg-white rounded-full h-2 transition-all"
                                        style={{ width: `${progress}%` }}
                                    ></div>
                                </div>

                                <button className="px-6 py-3 bg-white text-[#5B4FE9] font-semibold rounded-lg hover:bg-gray-50 transition-colors">
                                    Continue Learning
                                </button>
                            </div>

                            {/* Code Snippet Decoration */}
                            <div className="hidden lg:block ml-8">
                                <div className="bg-gray-900/40 backdrop-blur-sm rounded-lg p-6 text-sm font-mono text-white/80 max-w-md">
                                    <div className="text-purple-300">&lt;div&gt;</div>
                                    <div className="ml-4 text-blue-300">&lt;css&gt;</div>
                                    <div className="ml-8"><span className="text-pink-300">.icon-family</span></div>
                                    <div className="ml-8"><span className="text-green-300">&lt;css&gt;</span></div>
                                    <div className="ml-8"><span className="text-purple-300">:background-color</span></div>
                                    <div className="ml-8"><span className="text-orange-300">&lt;background-color&gt;</span></div>
                                </div>
                                <span className="absolute bottom-8 right-8 text-6xl text-white/30 font-bold">
                                    {progress}%
                                </span>
                            </div>
                        </div>
                    </div>
                </section>

                {/* Recently Added */}
                <section className="mb-12">
                    <h2 className="text-2xl font-bold text-gray-900 mb-6">Recently Added</h2>
                    <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
                        {recentlyAdded.map((course) => (
                            <div key={course.id} className="bg-white rounded-xl overflow-hidden shadow-sm hover:shadow-md transition-shadow">
                                <img
                                    src={course.thumbnail}
                                    alt={course.title}
                                    className="w-full h-40 object-cover"
                                />
                                <div className="p-4">
                                    <h3 className="font-semibold text-gray-900 mb-2 line-clamp-2 text-sm">
                                        {course.title}
                                    </h3>
                                    <div className="flex items-center gap-2 mb-2">
                                        <span className="text-yellow-500">★</span>
                                        <span className="text-sm font-semibold text-gray-900">{course.rating}</span>
                                        <span className="text-xs text-gray-500">({course.reviewCount.toLocaleString()})</span>
                                    </div>
                                    <div className="flex items-center justify-between">
                                        <p className="text-lg font-bold text-[#5B4FE9]">
                                            ${course.price.toFixed(2)}
                                        </p>
                                        <span className="text-xs text-gray-500">{currentLesson}/{totalLessons} lessons</span>
                                    </div>
                                </div>
                            </div>
                        ))}
                    </div>
                </section>

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

                {/* Popular Courses */}
                <section>
                    <h2 className="text-2xl font-bold text-gray-900 mb-6">Popular Courses</h2>
                    <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
                        {popularCourses.map((course) => (
                            <div key={course.id} className="bg-white rounded-xl overflow-hidden shadow-sm hover:shadow-md transition-shadow group cursor-pointer">
                                <div className="relative">
                                    <img
                                        src={course.thumbnail}
                                        alt={course.title}
                                        className="w-full h-48 object-cover"
                                    />
                                    {course.bestseller && (
                                        <span className="absolute top-3 left-3 px-3 py-1 bg-yellow-400 text-gray-900 text-xs font-bold rounded">
                                            Bestseller
                                        </span>
                                    )}
                                </div>
                                <div className="p-5">
                                    <h3 className="font-bold text-gray-900 mb-2 line-clamp-2">
                                        {course.title}
                                    </h3>
                                    <p className="text-sm text-gray-600 mb-3">{course.instructor}</p>
                                    <div className="flex items-center gap-2 mb-3">
                                        <span className="text-yellow-500">★</span>
                                        <span className="text-sm font-semibold text-gray-900">{course.rating}</span>
                                        <span className="text-xs text-gray-500">({course.students.toLocaleString()})</span>
                                    </div>
                                    <div className="flex items-center justify-between">
                                        <p className="text-xl font-bold text-gray-900">
                                            ${course.price.toFixed(2)}
                                        </p>
                                        {course.originalPrice && (
                                            <span className="text-sm text-gray-400 line-through">
                                                ${course.originalPrice.toFixed(2)}
                                            </span>
                                        )}
                                    </div>
                                </div>
                            </div>
                        ))}
                    </div>
                </section>
            </div>
        </div >
    );
};

export default Home;
