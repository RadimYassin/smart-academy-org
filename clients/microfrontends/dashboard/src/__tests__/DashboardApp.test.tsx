import { describe, it, expect } from 'vitest';
import { render } from '../test/utils';
import DashboardApp from '../DashboardApp';

describe('DashboardApp', () => {
    it('should render without crashing', () => {
        const { container } = render(<DashboardApp />);
        expect(container).toBeTruthy();
    });

    it('should display dashboard content', () => {
        const { container } = render(<DashboardApp />);
        expect(container.textContent).toBeTruthy();
    });
});
