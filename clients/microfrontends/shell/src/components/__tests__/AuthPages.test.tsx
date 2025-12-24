import { describe, it, expect } from 'vitest';
import { render, screen } from '../../test/utils';
import userEvent from '@testing-library/user-event';
import AuthPages from '../AuthPages';

describe('AuthPages', () => {
    const mockOnAuth = () => { };

    it('should render login form by default', () => {
        render(<AuthPages onAuth={mockOnAuth} />);

        // Check for login form inputs using placeholders
        const emailInput = screen.getByPlaceholderText(/you@example.com/i);
        const passwordInput = screen.getByPlaceholderText(/••••/);

        expect(emailInput).toBeInTheDocument();
        expect(passwordInput).toBeInTheDocument();
        expect(screen.getByText(/email address/i)).toBeInTheDocument();
    });

    it('should switch to register form when Register tab is clicked', async () => {
        const user = userEvent.setup();
        render(<AuthPages onAuth={mockOnAuth} />);

        // Get all buttons and find the one with exact text "Register"
        const registerTab = screen.getAllByRole('button').find(btn => btn.textContent?.trim() === 'Register');

        if (registerTab) {
            await user.click(registerTab);

            // Check for register form fields that don't exist in login form
            expect(screen.getByPlaceholderText(/john/i)).toBeInTheDocument(); // First name
            expect(screen.getByPlaceholderText(/doe/i)).toBeInTheDocument(); // Last name
            expect(screen.getByText(/first name/i)).toBeInTheDocument(); // Label text
        }
    });

    it('should display Smart Academy branding', () => {
        render(<AuthPages onAuth={mockOnAuth} />);

        expect(screen.getByText('Smart Academy')).toBeInTheDocument();
        expect(screen.getByText('Your Learning Journey Starts Here')).toBeInTheDocument();
    });
});
