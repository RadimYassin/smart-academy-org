import { describe, it, expect, vi, beforeEach } from 'vitest';
import { render, screen, fireEvent, waitFor } from '../../test/utils';
import AuthPages from '../AuthPages';
import { authApi } from '../../api';

// Mock the auth API
vi.mock('../../api', () => ({
    authApi: {
        login: vi.fn(),
        register: vi.fn(),
        logout: vi.fn(),
    },
    tokenManager: {
        getAccessToken: vi.fn(() => null),
        getRefreshToken: vi.fn(() => null),
        setTokens: vi.fn(),
        clearTokens: vi.fn(),
    },
    handleApiError: vi.fn((err) => err.message || 'An error occurred'),
}));

describe('AuthPages Component', () => {
    const mockOnAuth = vi.fn();

    beforeEach(() => {
        vi.clearAllMocks();
    });

    describe('Login Form', () => {
        it('renders login form by default', () => {
            render(<AuthPages onAuth={mockOnAuth} />);

            expect(screen.getByText('Smart Academy')).toBeInTheDocument();
            expect(screen.getByLabelText(/email address/i)).toBeInTheDocument();
            expect(screen.getByLabelText(/^password$/i)).toBeInTheDocument();
            expect(screen.getByRole('button', { name: /login/i })).toBeInTheDocument();
        });

        it('handles successful login', async () => {
            const mockResponse = {
                access_token: 'test-token',
                refresh_token: 'test-refresh',
                token_type: 'Bearer',
            };

            vi.mocked(authApi.login).mockResolvedValueOnce(mockResponse);

            render(<AuthPages onAuth={mockOnAuth} />);

            const emailInput = screen.getByLabelText(/email address/i);
            const passwordInput = screen.getByLabelText(/^password$/i);
            const loginButton = screen.getByRole('button', { name: /login/i });

            fireEvent.change(emailInput, { target: { value: 'test@example.com' } });
            fireEvent.change(passwordInput, { target: { value: 'password123' } });
            fireEvent.click(loginButton);

            await waitFor(() => {
                expect(authApi.login).toHaveBeenCalledWith({
                    email: 'test@example.com',
                    password: 'password123',
                });
                expect(mockOnAuth).toHaveBeenCalledWith('test@example.com', 'password123');
            });

            expect(screen.getByText(/login successful/i)).toBeInTheDocument();
        });

        it('displays error on failed login', async () => {
            vi.mocked(authApi.login).mockRejectedValueOnce(new Error('Invalid credentials'));

            render(<AuthPages onAuth={mockOnAuth} />);

            const emailInput = screen.getByLabelText(/email address/i);
            const passwordInput = screen.getByLabelText(/^password$/i);
            const loginButton = screen.getByRole('button', { name: /login/i });

            fireEvent.change(emailInput, { target: { value: 'wrong@example.com' } });
            fireEvent.change(passwordInput, { target: { value: 'wrongpass' } });
            fireEvent.click(loginButton);

            await waitFor(() => {
                expect(screen.getByText(/invalid credentials/i)).toBeInTheDocument();
            });
        });

        it('toggles password visibility', () => {
            render(<AuthPages onAuth={mockOnAuth} />);

            const passwordInput = screen.getByLabelText(/^password$/i) as HTMLInputElement;
            const toggleButton = screen.getAllByRole('button')[2]; // Eye icon button

            expect(passwordInput.type).toBe('password');

            fireEvent.click(toggleButton);
            expect(passwordInput.type).toBe('text');

            fireEvent.click(toggleButton);
            expect(passwordInput.type).toBe('password');
        });
    });

    describe('Registration Form', () => {
        beforeEach(() => {
            render(<AuthPages onAuth={mockOnAuth} />);
            const registerTab = screen.getByRole('button', { name: /register/i });
            fireEvent.click(registerTab);
        });

        it('switches to registration form', () => {
            expect(screen.getByLabelText(/first name/i)).toBeInTheDocument();
            expect(screen.getByLabelText(/last name/i)).toBeInTheDocument();
            expect(screen.getByLabelText(/email address/i)).toBeInTheDocument();
            expect(screen.getByLabelText(/^password$/i)).toBeInTheDocument();
            expect(screen.getByLabelText(/confirm password/i)).toBeInTheDocument();
        });

        it('validates password match', async () => {
            const firstNameInput = screen.getByLabelText(/first name/i);
            const lastNameInput = screen.getByLabelText(/last name/i);
            const emailInput = screen.getByLabelText(/email address/i);
            const passwordInput = screen.getByLabelText(/^password$/i);
            const confirmPasswordInput = screen.getByLabelText(/confirm password/i);
            const submitButton = screen.getByRole('button', { name: /create account/i });

            fireEvent.change(firstNameInput, { target: { value: 'John' } });
            fireEvent.change(lastNameInput, { target: { value: 'Doe' } });
            fireEvent.change(emailInput, { target: { value: 'john@example.com' } });
            fireEvent.change(passwordInput, { target: { value: 'password123' } });
            fireEvent.change(confirmPasswordInput, { target: { value: 'different' } });
            fireEvent.click(submitButton);

            await waitFor(() => {
                expect(screen.getByText(/passwords do not match/i)).toBeInTheDocument();
            });
        });

        it('validates password length', async () => {
            const passwordInput = screen.getByLabelText(/^password$/i);
            const confirmPasswordInput = screen.getByLabelText(/confirm password/i);
            const submitButton = screen.getByRole('button', { name: /create account/i });

            fireEvent.change(passwordInput, { target: { value: 'short' } });
            fireEvent.change(confirmPasswordInput, { target: { value: 'short' } });
            fireEvent.click(submitButton);

            await waitFor(() => {
                expect(screen.getByText(/at least 8 characters/i)).toBeInTheDocument();
            });
        });

        it('handles successful registration', async () => {
            const mockResponse = {
                access_token: 'test-token',
                refresh_token: 'test-refresh',
                token_type: 'Bearer',
            };

            vi.mocked(authApi.register).mockResolvedValueOnce(mockResponse);

            const firstNameInput = screen.getByLabelText(/first name/i);
            const lastNameInput = screen.getByLabelText(/last name/i);
            const emailInput = screen.getByLabelText(/email address/i);
            const passwordInput = screen.getByLabelText(/^password$/i);
            const confirmPasswordInput = screen.getByLabelText(/confirm password/i);
            const submitButton = screen.getByRole('button', { name: /create account/i });

            fireEvent.change(firstNameInput, { target: { value: 'John' } });
            fireEvent.change(lastNameInput, { target: { value: 'Doe' } });
            fireEvent.change(emailInput, { target: { value: 'john@example.com' } });
            fireEvent.change(passwordInput, { target: { value: 'password123' } });
            fireEvent.change(confirmPasswordInput, { target: { value: 'password123' } });
            fireEvent.click(submitButton);

            await waitFor(() => {
                expect(authApi.register).toHaveBeenCalledWith({
                    firstName: 'John',
                    lastName: 'Doe',
                    email: 'john@example.com',
                    password: 'password123',
                    role: 'TEACHER',
                });
                expect(screen.getByText(/registration successful/i)).toBeInTheDocument();
            });
        });
    });

    describe('Tab Switching', () => {
        it('clears errors when switching tabs', async () => {
            vi.mocked(authApi.login).mockRejectedValueOnce(new Error('Login error'));

            render(<AuthPages onAuth={mockOnAuth} />);

            // Trigger login error
            const loginButton = screen.getByRole('button', { name: /login/i });
            fireEvent.click(loginButton);

            await waitFor(() => {
                expect(screen.getByText(/login error/i)).toBeInTheDocument();
            });

            // Switch to register tab
            const registerTab = screen.getByRole('button', { name: /register/i });
            fireEvent.click(registerTab);

            // Error should be cleared
            expect(screen.queryByText(/login error/i)).not.toBeInTheDocument();
        });
    });
});
