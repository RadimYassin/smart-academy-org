import React, { useState, useEffect } from 'react';
import LoginPage from './components/LoginPage';
import RegisterPage from './components/RegisterPage';
import ForgotPassword from './components/ForgotPassword';
import { AnimatePresence } from 'framer-motion';

interface AuthAppProps {
    theme?: 'light' | 'dark';
    onAuth?: (email: string, password: string) => void;
}

const AuthApp: React.FC<AuthAppProps> = ({ theme: initialTheme, onAuth }) => {
    const [theme, setTheme] = useState<'light' | 'dark'>(initialTheme || 'light');
    const [currentView, setCurrentView] = useState<'login' | 'register' | 'forgot'>('login');

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

    const handleLogin = (email: string, password: string) => {
        if (onAuth) {
            onAuth(email, password);
        }
    };

    const handleRegister = (_name: string, email: string, password: string) => {
        // Auto-login after registration
        if (onAuth) {
            onAuth(email, password);
        }
    };

    return (
        <div>
            <AnimatePresence mode="wait">
                {currentView === 'login' && (
                    <LoginPage
                        key="login"
                        onLogin={handleLogin}
                        onSwitchToRegister={() => setCurrentView('register')}
                        onForgotPassword={() => setCurrentView('forgot')}
                    />
                )}
                {currentView === 'register' && (
                    <RegisterPage
                        key="register"
                        onRegister={handleRegister}
                        onSwitchToLogin={() => setCurrentView('login')}
                    />
                )}
                {currentView === 'forgot' && (
                    <ForgotPassword
                        key="forgot"
                        onBack={() => setCurrentView('login')}
                    />
                )}
            </AnimatePresence>
        </div>
    );
};

export default AuthApp;
