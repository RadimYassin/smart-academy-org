import React from 'react';
import { TrendingUp, Users as UsersIcon, UserPlus, DollarSign } from 'lucide-react';
import { mockCourses } from '../../data/mockCourses';

const ProfessorDashboard: React.FC = () => {
    // Calculate stats from mock data
    const totalRevenue = 12450;
    const revenueGrowth = '+12.5%';
    const totalStudents = mockCourses.reduce((sum, course) => sum + course.students, 0);
    const newEnrollments = 156;
    const enrollmentGrowth = '+8.2%';

    // Revenue data for chart (Jan-Dec)
    const revenueData = [
        { month: 'Jan', value: 8500 },
        { month: 'Feb', value: 10200 },
        { month: 'Mar', value: 9800 },
        { month: 'Apr', value: 12500 },
        { month: 'May', value: 11200 },
        { month: 'Jun', value: 13800 },
        { month: 'Jul', value: 12900 },
        { month: 'Aug', value: 14500 },
        { month: 'Sep', value: 13200 },
        { month: 'Oct', value: 15800 },
        { month: 'Nov', value: 16500 },
        { month: 'Dec', value: 14200 },
    ];

    const maxRevenue = Math.max(...revenueData.map(d => d.value));

    // Recent activity
    const activities = [
        { type: 'enrollment', text: 'Jason Mark enrolled in "Master UX Research"', time: '2 hours ago', icon: '👤' },
        { type: 'comment', text: 'New comment on "Intro to HTML & CSS"', time: '5 hours ago', icon: '💬' },
        { type: 'completion', text: 'Sophie Chen completed "Photoshop Basics"', time: '1 day ago', icon: '✓' },
        { type: 'review', text: 'Marci Senter left a 5-star review', time: '2 days ago', icon: '⭐' },
    ];

    return (
        <div className="bg-gray-50 dark:bg-gray-900 overflow-y-auto h-full">
            <div className="max-w-7xl mx-auto p-8">
                {/* Header */}
                <div className="mb-8">
                    <h1 className="text-3xl font-bold text-gray-900 dark:text-white mb-2">
                        Professor Dashboard
                    </h1>
                    <p className="text-gray-600 dark:text-gray-400">
                        Overview of your teaching performance
                    </p>
                </div>

                {/* Stats Cards */}
                <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
                    {/* Total Revenue */}
                    <div className="bg-white dark:bg-gray-800 rounded-xl p-6 shadow-sm">
                        <div className="flex items-start justify-between mb-4">
                            <div>
                                <p className="text-sm text-gray-600 dark:text-gray-400 mb-1">Total Revenue</p>
                                <h3 className="text-3xl font-bold text-gray-900 dark:text-white">
                                    ${totalRevenue.toLocaleString()}
                                </h3>
                            </div>
                            <div className="w-12 h-12 bg-green-100 dark:bg-green-900/30 rounded-lg flex items-center justify-center">
                                <DollarSign className="text-green-600 dark:text-green-400" size={24} />
                            </div>
                        </div>
                        <div className="flex items-center gap-1 text-sm">
                            <TrendingUp size={16} className="text-green-600 dark:text-green-400" />
                            <span className="text-green-600 dark:text-green-400 font-semibold">{revenueGrowth}</span>
                            <span className="text-gray-500 dark:text-gray-400">from last month</span>
                        </div>
                    </div>

                    {/* Enrolled Students */}
                    <div className="bg-white dark:bg-gray-800 rounded-xl p-6 shadow-sm">
                        <div className="flex items-start justify-between mb-4">
                            <div>
                                <p className="text-sm text-gray-600 dark:text-gray-400 mb-1">Enrolled Students</p>
                                <h3 className="text-3xl font-bold text-gray-900 dark:text-white">
                                    {totalStudents.toLocaleString()}
                                </h3>
                            </div>
                            <div className="w-12 h-12 bg-blue-100 dark:bg-blue-900/30 rounded-lg flex items-center justify-center">
                                <UsersIcon className="text-blue-600 dark:text-blue-400" size={24} />
                            </div>
                        </div>
                        <p className="text-sm text-gray-500 dark:text-gray-400">Across all courses</p>
                    </div>

                    {/* New Enrollments */}
                    <div className="bg-white dark:bg-gray-800 rounded-xl p-6 shadow-sm">
                        <div className="flex items-start justify-between mb-4">
                            <div>
                                <p className="text-sm text-gray-600 dark:text-gray-400 mb-1">New Enrollments (30d)</p>
                                <h3 className="text-3xl font-bold text-gray-900 dark:text-white">
                                    {newEnrollments}
                                </h3>
                            </div>
                            <div className="w-12 h-12 bg-purple-100 dark:bg-purple-900/30 rounded-lg flex items-center justify-center">
                                <UserPlus className="text-purple-600 dark:text-purple-400" size={24} />
                            </div>
                        </div>
                        <div className="flex items-center gap-1 text-sm">
                            <TrendingUp size={16} className="text-green-600 dark:text-green-400" />
                            <span className="text-green-600 dark:text-green-400 font-semibold">{enrollmentGrowth}</span>
                            <span className="text-gray-500 dark:text-gray-400">from last month</span>
                        </div>
                    </div>
                </div>

                {/* Charts and Activity */}
                <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
                    {/* Revenue Chart */}
                    <div className="lg:col-span-2 bg-white dark:bg-gray-800 rounded-xl p-6 shadow-sm">
                        <h2 className="text-xl font-bold text-gray-900 dark:text-white mb-6">Revenue This Month</h2>
                        <div className="flex items-end justify-between h-64 gap-2">
                            {revenueData.map((data, index) => {
                                const heightPercent = (data.value / maxRevenue) * 100;
                                return (
                                    <div key={index} className="flex-1 flex flex-col items-center gap-2">
                                        <div className="w-full relative group">
                                            <div
                                                className="w-full bg-gradient-to-t from-blue-600 to-blue-400 rounded-t-lg transition-all hover:from-blue-700 hover:to-blue-500 cursor-pointer"
                                                style={{ height: `${heightPercent * 0.8}%` }}
                                            >
                                                {/* Tooltip */}
                                                <div className="absolute bottom-full left-1/2 -translate-x-1/2 mb-2 hidden group-hover:block">
                                                    <div className="bg-gray-900 text-white text-xs px-2 py-1 rounded">
                                                        ${data.value.toLocaleString()}
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                        <span className="text-xs text-gray-500 dark:text-gray-400">{data.month}</span>
                                    </div>
                                );
                            })}
                        </div>
                    </div>

                    {/* Recent Activity */}
                    <div className="bg-white dark:bg-gray-800 rounded-xl p-6 shadow-sm">
                        <h2 className="text-xl font-bold text-gray-900 dark:text-white mb-6">Recent Activity</h2>
                        <div className="space-y-4">
                            {activities.map((activity, index) => (
                                <div key={index} className="flex items-start gap-3">
                                    <div className="w-10 h-10 bg-blue-100 dark:bg-blue-900/30 rounded-lg flex items-center justify-center flex-shrink-0">
                                        <span className="text-lg">{activity.icon}</span>
                                    </div>
                                    <div className="flex-1 min-w-0">
                                        <p className="text-sm text-gray-900 dark:text-white line-clamp-2">
                                            {activity.text}
                                        </p>
                                        <p className="text-xs text-gray-500 dark:text-gray-400 mt-1">
                                            {activity.time}
                                        </p>
                                    </div>
                                </div>
                            ))}
                        </div>
                    </div>
                </div>
            </div>
        </div>
    );
};

export default ProfessorDashboard;
