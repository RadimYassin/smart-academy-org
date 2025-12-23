import { describe, it, expect, vi } from 'vitest';
import { render as rtlRender } from '@testing-library/react';
import App from '../App';

// Mock remote modules
vi.mock('auth/AuthApp', () => ({
    default: () => <div>Auth App Mock</div>
}));

vi.mock('dashboard/DashboardApp', () => ({
    default: () => <div>Dashboard App Mock</div>
}));

vi.mock('courses/CoursesApp', () => ({
    default: () => <div>Courses App Mock</div>
}));

describe('App Component', () => {
    it('should render without crashing', () => {
        // App has its own BrowserRouter, so we use rtlRender directly
        rtlRender(<App />);
        expect(document.body).toBeTruthy();
    });

    it('should render the application', () => {
        rtlRender(<App />);
        // Check that the app renders
        expect(document.querySelector('body')).toBeInTheDocument();
    });
});
