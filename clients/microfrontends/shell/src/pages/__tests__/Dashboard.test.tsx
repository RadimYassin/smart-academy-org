import { describe, it, expect, vi, beforeEach } from 'vitest';
import { render, screen, waitFor } from '../../test/utils';
import Dashboard from '../Dashboard';
import { courseApi } from '../../api/courseApi';
import { enrollmentApi } from '../../api/enrollmentApi';

// Mock the APIs
vi.mock('../../api/courseApi', () => ({
    courseApi: {
        getCourseById: vi.fn(),
    },
}));

vi.mock('../../api/enrollmentApi', () => ({
    enrollmentApi: {
        getMyCourses: vi.fn(),
    },
}));

// Mock RemoteApp component
vi.mock('../../components/RemoteApp', () => ({
    default: ({ moduleName }: { moduleName: string }) => (
        <div data-testid="remote-app">{moduleName}</div>
    ),
}));

// Mock useAuth hook
const mockNavigate = vi.fn();
vi.mock('react-router-dom', async () => {
    const actual = await vi.importActual('react-router-dom');
    return {
        ...actual,
        useNavigate: () => mockNavigate,
    };
});

vi.mock('../../contexts/AuthContext', () => ({
    useAuth: () => ({
        user: {
            id: 1,
            email: 'student@example.com',
            role: 'STUDENT',
        },
    }),
}));

describe('Dashboard Page', () => {
    beforeEach(() => {
        vi.clearAllMocks();
        // Clear any existing iframes
        document.body.innerHTML = '';
    });

    it('renders RemoteApp with dashboard module', () => {
        render(<Dashboard />);

        const remoteApp = screen.getByTestId('remote-app');
        expect(remoteApp).toBeInTheDocument();
        expect(remoteApp).toHaveTextContent('dashboard');
    });

    it('fetches student courses on FETCH_MY_COURSES message', async () => {
        const mockEnrollments = [
            { id: 1, courseId: 1, studentId: 1, enrolledAt: '2024-01-01' },
        ];

        const mockCourses = [
            {
                id: 1,
                title: 'React Basics',
                description: 'Learn React',
                teacherId: 1,
            },
        ];

        vi.mocked(enrollmentApi.getMyCourses).mockResolvedValueOnce(mockEnrollments);
        vi.mocked(courseApi.getCourseById).mockResolvedValueOnce(mockCourses[0]);

        render(<Dashboard />);

        // Create a mock iframe
        const iframe = document.createElement('iframe');
        iframe.src = 'http://localhost:5002';
        document.body.appendChild(iframe);

        // Wait for component to mount and setup listeners
        await waitFor(() => {
            expect(iframe).toBeInTheDocument();
        });

        // Simulate message from iframe
        const messageEvent = new MessageEvent('message', {
            data: { type: 'FETCH_MY_COURSES' },
            origin: '*',
        });

        window.dispatchEvent(messageEvent);

        await waitFor(() => {
            expect(enrollmentApi.getMyCourses).toHaveBeenCalled();
            expect(courseApi.getCourseById).toHaveBeenCalledWith(1);
        });
    });

    it('handles OPEN_STUDENT_COURSE message', async () => {
        render(<Dashboard />);

        const iframe = document.createElement('iframe');
        iframe.src = 'http://localhost:5002';
        document.body.appendChild(iframe);

        await waitFor(() => {
            expect(iframe).toBeInTheDocument();
        });

        const messageEvent = new MessageEvent('message', {
            data: { type: 'OPEN_STUDENT_COURSE', courseId: 123 },
            origin: '*',
        });

        window.dispatchEvent(messageEvent);

        await waitFor(() => {
            expect(mockNavigate).toHaveBeenCalledWith('/student/courses/123');
        });
    });

    it('handles course fetch error gracefully', async () => {
        const consoleErrorSpy = vi.spyOn(console, 'error').mockImplementation(() => { });

        vi.mocked(enrollmentApi.getMyCourses).mockRejectedValueOnce(
            new Error('Failed to fetch courses')
        );

        render(<Dashboard />);

        const iframe = document.createElement('iframe');
        iframe.src = 'http://localhost:5002';
        document.body.appendChild(iframe);

        await waitFor(() => {
            expect(iframe).toBeInTheDocument();
        });

        const messageEvent = new MessageEvent('message', {
            data: { type: 'FETCH_MY_COURSES' },
            origin: '*',
        });

        window.dispatchEvent(messageEvent);

        await waitFor(() => {
            expect(enrollmentApi.getMyCourses).toHaveBeenCalled();
            expect(consoleErrorSpy).toHaveBeenCalled();
        });

        consoleErrorSpy.mockRestore();
    });
});
