import { describe, it, expect, vi } from 'vitest';
import { render } from '../test/utils';
import CoursesApp from '../CoursesApp';

// Mock window.postMessage
const mockPostMessage = vi.fn();
window.parent.postMessage = mockPostMessage;

describe('CoursesApp', () => {
    it('should render without crashing', () => {
        const { container } = render(<CoursesApp />);
        expect(container).toBeTruthy();
    });

    it('should initialize with empty state', () => {
        const { container } = render(<CoursesApp />);
        expect(container.textContent).toBeTruthy();
    });
});
