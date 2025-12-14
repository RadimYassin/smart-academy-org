import React, { createContext, useContext, useState, useEffect, type ReactNode } from 'react';
import { authApi, tokenManager } from '../api';

interface User {
    id: number;
    name: string;
    email: string;
    avatar: string;
    role: 'TEACHER' | 'STUDENT' | 'ADMIN';
}

interface AuthContextType {
    isAuthenticated: boolean;
    isLoading: boolean;
    user: User | null;
    login: (user: Partial<User>) => void;
    logout: () => void;
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

export const useAuth = () => {
    const context = useContext(AuthContext);
    if (!context) {
        throw new Error('useAuth must be used within AuthProvider');
    }
    return context;
};

interface AuthProviderProps {
    children: ReactNode;
}

export const AuthProvider: React.FC<AuthProviderProps> = ({ children }) => {
    const [isAuthenticated, setIsAuthenticated] = useState(false);
    const [isLoading, setIsLoading] = useState(true);
    const [user, setUser] = useState<User | null>(null);

    // Check for existing token on mount
    useEffect(() => {
        console.log('[AuthContext] Checking for existing tokens...');
        const token = tokenManager.getAccessToken();
        console.log('[AuthContext] Access token found:', !!token);

        if (token) {
            // Token exists, user is logged in
            // Try to restore user data from localStorage
            const savedUser = localStorage.getItem('user');
            console.log('[AuthContext] Saved user found:', !!savedUser);

            if (savedUser) {
                try {
                    const userData = JSON.parse(savedUser);
                    setUser(userData);
                    console.log('[AuthContext] User data restored:', userData.email);
                } catch (error) {
                    console.error('[AuthContext] Failed to parse saved user:', error);
                }
            }
            setIsAuthenticated(true);
            console.log('[AuthContext] User is authenticated');
        } else {
            console.log('[AuthContext] No token found, user not authenticated');
        }
        setIsLoading(false);
    }, []);

    const login = (userInfo: Partial<User>) => {
        console.log('[AuthContext] Login called with user:', userInfo);

        // Create complete user object
        const userData: User = {
            id: userInfo.id || 1,
            name: userInfo.name || userInfo.email?.split('@')[0] || 'User',
            email: userInfo.email || '',
            avatar: userInfo.avatar || `https://api.dicebear.com/7.x/avataaars/svg?seed=${userInfo.email}`,
            role: userInfo.role || 'STUDENT',
        };

        // Save user to localStorage for persistence
        localStorage.setItem('user', JSON.stringify(userData));
        console.log('[AuthContext] User data saved with role:', userData.role);

        setUser(userData);
        setIsAuthenticated(true);
        console.log('[AuthContext] Authentication state updated');
    };

    const logout = async () => {
        try {
            await authApi.logout();
        } catch (error) {
            console.error('Logout error:', error);
        } finally {
            localStorage.removeItem('user');
            setUser(null);
            setIsAuthenticated(false);
        }
    };

    return (
        <AuthContext.Provider value={{ isAuthenticated, isLoading, user, login, logout }}>
            {children}
        </AuthContext.Provider>
    );
};
