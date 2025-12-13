import React, { useEffect, useState } from 'react';
import Home from './pages/Home';
import ProfessorDashboard from './pages/professor/ProfessorDashboard';
import MyCourses from './pages/professor/MyCourses';
import Students from './pages/professor/Students';
import Analytics from './pages/professor/Analytics';
import ProfessorSettings from './pages/professor/ProfessorSettings';

interface DashboardAppProps {
    theme?: 'light' | 'dark';
}

const DashboardApp: React.FC<DashboardAppProps> = ({ theme: initialTheme }) => {
    const [theme, setTheme] = useState<'light' | 'dark'>(initialTheme || 'light');
    const [currentPage, setCurrentPage] = useState('home');

    // Listen for theme and page changes from parent Shell
    useEffect(() => {
        const handleMessage = (event: MessageEvent) => {
            if (event.data.type === 'THEME_CHANGE') {
                setTheme(event.data.theme);
            }
            if (event.data.type === 'PAGE_CHANGE') {
                setCurrentPage(event.data.page);
            }
        };

        window.addEventListener('message', handleMessage);
        return () => window.removeEventListener('message', handleMessage);
    }, []);

    // Listen to URL hash for page (fallback)
    useEffect(() => {
        const hash = window.location.hash.slice(1);
        if (hash) {
            setCurrentPage(hash);
        }
    }, []);

    // Apply theme
    useEffect(() => {
        if (theme === 'dark') {
            document.documentElement.classList.add('dark');
        } else {
            document.documentElement.classList.remove('dark');
        }
    }, [theme]);

    const renderPage = () => {
        switch (currentPage) {
            case 'home':
                return <Home />;
            case 'professor-dashboard':
                return <ProfessorDashboard />;
            case 'my-courses':
                return <MyCourses />;
            case 'students':
                return <Students />;
            case 'analytics':
                return <Analytics />;
            case 'settings':
                return <ProfessorSettings />;
            default:
                return <Home />;
        }
    };

    return (
        <div className="h-full overflow-y-auto bg-gray-50 dark:bg-gray-900">
            {renderPage()}
        </div>
    );
};

export default DashboardApp;
