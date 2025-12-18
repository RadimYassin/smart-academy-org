import React, { useState } from 'react';
import { Link, useLocation } from 'react-router-dom';
import {
    Home,
    Compass,
    BookOpen,
    Heart,
    User,
    LayoutDashboard,
    Users,
    BarChart3,
    Settings as SettingsIcon,
    Moon,
    Sun,
    Menu,
    X
} from 'lucide-react';
import { useTheme } from '../../contexts/ThemeContext';
import { useAuth } from '../../contexts/AuthContext';

const Sidebar: React.FC = () => {
    const { theme, toggleTheme } = useTheme();
    const { user } = useAuth();
    const location = useLocation();
    const [isOpen, setIsOpen] = useState(false);

    // Get role from authenticated user
    const role = user?.role || 'STUDENT';

    const studentNavItems = [
        { path: '/student/dashboard', label: 'Home', icon: Home },
        { path: '/student/explore', label: 'Explore', icon: Compass },
        { path: '/student/learning', label: 'My Learning', icon: BookOpen },
        { path: '/student/wishlist', label: 'Wishlist', icon: Heart },
        { path: '/student/profile', label: 'Profile', icon: User },
    ];

    const teacherNavItems = [
        { path: '/teacher/dashboard', label: 'Dashboard', icon: LayoutDashboard },
        { path: '/teacher/courses', label: 'My Courses', icon: BookOpen },
        { path: '/teacher/students', label: 'Students', icon: Users },
        { path: '/teacher/analytics', label: 'Analytics', icon: BarChart3 },
        { path: '/teacher/settings', label: 'Settings', icon: SettingsIcon },
    ];

    const navItems = role === 'TEACHER' ? teacherNavItems : studentNavItems;

    const NavContent = () => (
        <>
            {/* Logo Section */}
            <div className="p-6 border-gray-200 dark:border-gray-700">
                <div className="flex items-center gap-3">
                    <div className={`w-10 h-10 bg-gradient-to-br ${role === 'STUDENT'
                        ? 'from-[#5B4FE9] to-[#7C3AED]'
                        : 'from-[#4F46E5] to-[#6366F1]'
                        } rounded-lg flex items-center justify-center`}>
                        <BookOpen className="text-white" size={24} strokeWidth={2.5} />
                    </div>
                    <div>
                        <h1 className="text-xl font-bold text-gray-900 dark:text-white">Smart Academy</h1>
                        <p className="text-xs text-gray-500 dark:text-gray-400">
                            {role === 'TEACHER' ? 'Teacher' : 'Student'}
                        </p>
                    </div>
                </div>
            </div>

            {/* Navigation Items */}
            <nav className="flex-1 p-4">
                <ul className="space-y-1">
                    {navItems.map((item) => {
                        const Icon = item.icon;
                        const isActive = location.pathname === item.path ||
                            (item.path === '/' && location.pathname === '/dashboard');
                        const accentColor = role === 'STUDENT' ? '#5B4FE9' : '#4F46E5';

                        return (
                            <li key={item.path}>
                                <Link
                                    to={item.path}
                                    onClick={() => setIsOpen(false)}
                                    className={`w-full flex items-center gap-3 px-4 py-3 rounded-lg transition-colors ${isActive
                                        ? `bg-[${accentColor}]/10 text-[${accentColor}]`
                                        : 'text-gray-600 dark:text-gray-400 hover:bg-gray-50 dark:hover:bg-gray-800'
                                        }`}
                                    style={isActive ? {
                                        backgroundColor: `${accentColor}1A`,
                                        color: accentColor
                                    } : undefined}
                                >
                                    <Icon size={20} strokeWidth={isActive ? 2.5 : 2} />
                                    <span className={`text-sm ${isActive ? 'font-semibold' : 'font-medium'}`}>
                                        {item.label}
                                    </span>
                                </Link>
                            </li>
                        );
                    })}
                </ul>
            </nav>

            {/* Bottom Section */}
            <div className="p-4 border-t border-gray-200 dark:border-gray-700 space-y-2">
                {/* Theme Toggle */}
                <button
                    onClick={toggleTheme}
                    className="w-full flex items-center gap-3 px-4 py-3 rounded-lg text-gray-600 dark:text-gray-400 hover:bg-gray-50 dark:hover:bg-gray-800 transition-colors"
                >
                    {theme === 'light' ? <Moon size={20} /> : <Sun size={20} />}
                    <span className="text-sm font-medium">
                        {theme === 'light' ? 'Dark Mode' : 'Light Mode'}
                    </span>
                </button>
            </div>
        </>
    );

    return (
        <>
            {/* Mobile Menu Button */}
            <button
                onClick={() => setIsOpen(!isOpen)}
                className="lg:hidden fixed top-4 left-4 z-50 p-2 rounded-lg bg-white dark:bg-gray-800 shadow-lg"
            >
                {isOpen ? <X size={24} /> : <Menu size={24} />}
            </button>

            {/* Mobile Overlay */}
            {isOpen && (
                <div
                    className="lg:hidden fixed inset-0 bg-black/50 z-40"
                    onClick={() => setIsOpen(false)}
                />
            )}

            {/* Sidebar */}
            <aside
                className={`fixed lg:static inset-y-0 left-0 z-40 w-64 bg-white dark:bg-gray-900 border-r border-gray-200 dark:border-gray-700 flex flex-col transition-transform duration-300 lg:translate-x-0 ${isOpen ? 'translate-x-0' : '-translate-x-full'
                    }`}
            >
                <NavContent />
            </aside>
        </>
    );
};

export default Sidebar;
