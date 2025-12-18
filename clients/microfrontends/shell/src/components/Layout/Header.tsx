import React, { useState } from 'react';
import { Bell, MessageSquare, LogOut, Sparkles } from 'lucide-react';
import { useNavigate } from 'react-router-dom';
import { useAuth } from '../../contexts/AuthContext';

const Header: React.FC = () => {
    const { user, logout } = useAuth();
    const navigate = useNavigate();

    return (
        <header className="sticky top-0 z-30 bg-white dark:bg-gray-900 border-b border-gray-200 dark:border-gray-700 px-8 py-4">
            <div className="flex items-center justify-between">
                <div>
                    <h1 className="text-3xl font-bold text-gray-900 dark:text-white">
                        Welcome, {user?.name || 'Jason'} 👋
                    </h1>
                </div>

                <div className="flex items-center gap-4">
                    {/* AI Assistant */}
                    <button 
                        onClick={() => {
                            console.log('[Header] Navigating to /chat');
                            navigate('/chat');
                        }}
                        className="p-2 hover:bg-gradient-to-br hover:from-purple-50 hover:to-indigo-50 dark:hover:from-purple-900/20 dark:hover:to-indigo-900/20 rounded-lg transition-all group relative"
                        title="AI Assistant"
                    >
                        <Sparkles 
                            size={24} 
                            className="text-gray-600 dark:text-gray-400 group-hover:text-purple-600 dark:group-hover:text-purple-400 transition-colors" 
                        />
                        <span className="absolute -top-1 -right-1 w-2 h-2 bg-gradient-to-r from-purple-500 to-indigo-500 rounded-full animate-pulse"></span>
                    </button>

                    {/* Messages */}
                    <button className="p-2 hover:bg-gray-100 dark:hover:bg-gray-800 rounded-lg transition-colors">
                        <MessageSquare size={24} className="text-gray-600 dark:text-gray-400" />
                    </button>

                    {/* Notifications */}
                    <button className="relative p-2 hover:bg-gray-100 dark:hover:bg-gray-800 rounded-lg transition-colors">
                        <Bell size={24} className="text-gray-600 dark:text-gray-400" />
                        <span className="absolute top-1 right-1 w-2 h-2 bg-red-500 rounded-full"></span>
                    </button>

                    {/* User Avatar with Logout */}
                    <div className="flex items-center gap-2">
                        <img
                            src={user?.avatar || 'https://i.pravatar.cc/150?img=12'}
                            alt={user?.name || 'User'}
                            className="w-10 h-10 rounded-full border-2 border-gray-200 dark:border-gray-700"
                        />
                        <button
                            onClick={logout}
                            className="hidden md:block p-2 rounded-lg hover:bg-red-50 dark:hover:bg-red-900/20 text-red-600 dark:text-red-400 transition-colors"
                            title="Logout"
                        >
                            <LogOut size={18} />
                        </button>
                    </div>
                </div>
            </div>
        </header>
    );
};

export default Header;
