import React, { useState } from 'react';
import {
    Home,
    Compass,
    BookOpen,
    Heart,
    User,
    ArrowLeftRight,
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

interface SidebarProps {
    currentPage: string;
    onNavigate: (page: string) => void;
}

const Sidebar: React.FC<SidebarProps> = ({ currentPage, onNavigate }) => {
    const { theme, toggleTheme } = useTheme();
    const [isOpen, setIsOpen] = useState(false);
    const [role, setRole] = useState<'student' | 'professor'>('student');

    const studentNavItems = [
        { id: 'home', label: 'Home', icon: Home },
        { id: 'explore', label: 'Explore', icon: Compass },
        { id: 'learning', label: 'My Learning', icon: BookOpen },
        { id: 'wishlist', label: 'Wishlist', icon: Heart },
        { id: 'profile', label: 'Profile', icon: User },
    ];

    const professorNavItems = [
        { id: 'professor-dashboard', label: 'Dashboard', icon: LayoutDashboard },
        { id: 'my-courses', label: 'My Courses', icon: BookOpen },
        { id: 'students', label: 'Students', icon: Users },
        { id: 'analytics', label: 'Analytics', icon: BarChart3 },
        { id: 'settings', label: 'Settings', icon: SettingsIcon },
    ];

    const navItems = role === 'student' ? studentNavItems : professorNavItems;

    const handleRoleSwitch = () => {
        const newRole = role === 'student' ? 'professor' : 'student';
        setRole(newRole);
        // Navigate to default page for new role
        if (newRole === 'professor') {
            onNavigate('professor-dashboard');
        } else {
            onNavigate('home');
        }
    };

    const NavContent = () => (
        <>
            {/* Logo Section */}
            <div className="p-6 border-b border-gray-200 dark:border-gray-700">
                <div className="flex items-center gap-3">
                    <div className={`w-10 h-10 bg-gradient-to-br ${role === 'student'
                            ? 'from-[#5B4FE9] to-[#7C3AED]'
                            : 'from-[#4F46E5] to-[#6366F1]'
                        } rounded-lg flex items-center justify-center`}>
                        <BookOpen className="text-white" size={24} strokeWidth={2.5} />
                    </div>
                    <div>
                        <h1 className="text-xl font-bold text-gray-900 dark:text-white">Overskill</h1>
                        <p className="text-xs text-gray-500 dark:text-gray-400">
                            {role === 'student' ? 'Student' : 'Professor'}
                        </p>
                    </div>
                </div>
            </div>

            {/* Navigation Items */}
            <nav className="flex-1 p-4">
                <ul className="space-y-1">
                    {navItems.map((item) => {
                        const Icon = item.icon;
                        const isActive = currentPage === item.id;
                        const accentColor = role === 'student' ? '#5B4FE9' : '#4F46E5';

                        return (
                            <li key={item.id}>
                                <button
                                    onClick={() => {
                                        onNavigate(item.id);
                                        setIsOpen(false);
                                    }}
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
                                </button>
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

                {/* Role Switch */}
                <button
                    onClick={handleRoleSwitch}
                    className="w-full flex items-center gap-3 px-4 py-3 text-gray-600 dark:text-gray-400 hover:bg-gray-50 dark:hover:bg-gray-800 rounded-lg transition-colors"
                >
                    <ArrowLeftRight size={20} />
                    <span className="text-sm font-medium">
                        Switch to {role === 'student' ? 'Professor' : 'Student'}
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
