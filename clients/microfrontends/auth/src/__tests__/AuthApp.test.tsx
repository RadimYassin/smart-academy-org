import { describe, it, expect } from 'vitest';
import { render, screen } from '../test/utils';
import AuthApp from '../AuthApp';

describe('AuthApp', () => {
    it('should render login page by default', () => {
        render(<AuthApp />);

        // Check for login-related elements
        const heading = screen.queryByRole('heading', { name: /sign in/i });
        expect(heading || screen.queryByText(/sign in/i)).toBeTruthy();
    });

    it('should render without errors', () => {
        const { container } = render(<AuthApp />);
        expect(container).toBeTruthy();
    });
});
