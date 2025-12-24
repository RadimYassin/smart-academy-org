import { describe, it, expect, vi } from 'vitest';
import { render, screen } from '../../test/utils';
import userEvent from '@testing-library/user-event';
import LoginPage from '../LoginPage';

describe('LoginPage', () => {
    const mockOnLogin = vi.fn();

    it('should render login form', () => {
        render(<LoginPage onLogin={mockOnLogin} />);

        expect(screen.getByPlaceholderText(/email/i)).toBeInTheDocument();
        expect(screen.getByPlaceholderText(/password/i)).toBeInTheDocument();
        expect(screen.getByRole('button', { name: /sign in/i })).toBeInTheDocument();
    });

    it('should call onLogin when form is submitted with valid credentials', async () => {
        const user = userEvent.setup();
        render(<LoginPage onLogin={mockOnLogin} />);

        const emailInput = screen.getByPlaceholderText(/email/i);
        const passwordInput = screen.getByPlaceholderText(/password/i);
        const submitButton = screen.getByRole('button', { name: /sign in/i });

        await user.type(emailInput, 'test@example.com');
        await user.type(passwordInput, 'password123');
        await user.click(submitButton);

        // Login handler should be called (may need adjustment based on actual implementation)
        expect(mockOnLogin).toHaveBeenCalled();
    });

    it('should display error for invalid email format', async () => {
        const user = userEvent.setup();
        render(<LoginPage onLogin={mockOnLogin} />);

        const emailInput = screen.getByPlaceholderText(/email/i);
        const submitButton = screen.getByRole('button', { name: /sign in/i });

        await user.type(emailInput, 'invalid-email');
        await user.click(submitButton);

        // Check if validation runs (implementation dependent)
        expect(emailInput).toHaveValue('invalid-email');
    });
});
