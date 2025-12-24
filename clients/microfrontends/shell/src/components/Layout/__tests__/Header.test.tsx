import { describe, it, expect } from 'vitest';
import { render, screen } from '../../../test/utils';
import Header from '../Header';

describe('Header Component', () => {
    it('should render welcome message', () => {
        render(<Header />);

        // Header shows "Welcome, Jason 👋" by default
        expect(screen.getByText(/welcome/i)).toBeInTheDocument();
        expect(screen.getByRole('heading', { name: /welcome.*jason/i })).toBeInTheDocument();
    });

    it('should render action buttons', () => {
        render(<Header />);

        // Check for buttons by their title attributes
        expect(screen.getByTitle(/ai assistant/i)).toBeInTheDocument();
        expect(screen.getByTitle(/logout/i)).toBeInTheDocument();
    });

    it('should display user avatar', () => {
        render(<Header />);

        const avatar = screen.getByAltText(/user/i);
        expect(avatar).toBeInTheDocument();
        expect(avatar).toHaveAttribute('src');
    });
});
