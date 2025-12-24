import { ReactElement } from 'react';
import { render, RenderOptions } from '@testing-library/react';

const customRender = (
    ui: ReactElement,
    options?: RenderOptions,
) => render(ui, options);

export * from '@testing-library/react';
export { customRender as render };
