import React, { useState, useEffect } from 'react';
import LoginPage from './components/LoginPage';
import RegisterPage from './components/RegisterPage';
import ForgotPassword from './components/ForgotPassword';
import VerificationPage from './components/VerificationPage';
import ResetPassword from './components/ResetPassword';
import { AnimatePresence } from 'framer-motion';

interface AuthAppProps {
    theme?: 'light' | 'dark';
    onAuth?: (email: string, password: string) => void;
}

const AuthApp: React.FC<AuthAppProps> = ({ theme: initialTheme, onAuth }) => {
    const [theme, setTheme] = useState<'light' | 'dark'>(initialTheme || 'light');
    const [currentView, setCurrentView] = useState<'login' | 'register' | 'forgot' | 'verification' | 'reset'>('login');
    const [verificationEmail, setVerificationEmail] = useState('');
    const [resetEmail, setResetEmail] = useState('');

    // Listen for messages from parent Shell
    useEffect(() => {
        const handleMessage = (event: MessageEvent) => {
            if (event.data.type === 'THEME_CHANGE') {
                setTheme(event.data.theme);
            }

            // Handle verification page request from Shell
            if (event.data.type === 'SHOW_VERIFICATION') {
                setVerificationEmail(event.data.email);
                setCurrentView('verification');
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

    const handleRegister = (_firstName: string, _lastName: string, _email: string, _password: string) => {
        // Registration will be handled by Shell via postMessage
    };

    const handleVerify = (code: string) => {
        // Send verification code to Shell
        if (window.parent !== window) {
            window.parent.postMessage(
                {
                    type: 'VERIFY_EMAIL',
                    email: verificationEmail,
                    code: code,
                },
                '*'
            );
        }
    };

    const handleForgotPasswordCodeSent = (email: string) => {
        setResetEmail(email);
        setCurrentView('reset');
    };

    const handleResetPassword = (code: string, newPassword: string) => {
        // Send reset password request to Shell
        if (window.parent !== window) {
            window.parent.postMessage(
                {
                    type: 'RESET_PASSWORD',
                    email: resetEmail,
                    code: code,
                    newPassword: newPassword,
                },
                '*'
            );
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
                        onCodeSent={handleForgotPasswordCodeSent}
                    />
                )}
                {currentView === 'reset' && (
                    <ResetPassword
                        key="reset"
                        email={resetEmail}
                        onReset={handleResetPassword}
                        onBack={() => setCurrentView('login')}
                    />
                )}
                {currentView === 'verification' && (
                    <VerificationPage
                        key="verification"
                        email={verificationEmail}
                        onVerify={handleVerify}
                        onBack={() => setCurrentView('login')}
                    />
                )}
            </AnimatePresence>
        </div>
    );
};

export default AuthApp;
