# React Testing Infrastructure - Quick Start Guide

## 📦 Installation

```bash
cd clients/microfrontends/shell
npm install
```

## 🧪 Running Tests

```bash
# Run all tests
npm test

# Run tests with UI
npm run test:ui

# Generate coverage report
npm run test:coverage
```

## 📊 Coverage Reports

After running `npm run test:coverage`:
- HTML: `coverage/index.html`
- LCOV: `coverage/lcov.info` (for SonarQube)

## 🎯 Test Structure

```
src/
├── test/
│   ├── setup.ts              # Global test configuration
│   ├── utils.tsx             # Custom render with providers
│   └── mocks/
│       ├── handlers.ts       # MSW API handlers
│       └── server.ts         # MSW server setup
├── components/
│   └── __tests__/
│       └── AuthPages.test.tsx
├── pages/
│   └── __tests__/
│       └── Dashboard.test.tsx
└── api/
    └── __tests__/
        ├── authApi.test.ts
        └── courseApi.test.ts
```

## ✨ Key Features

- ✅ MSW for API mocking
- ✅ Custom render with all providers
- ✅ 60% coverage thresholds
- ✅ Framer Motion mocks
- ✅ React Testing Library best practices

## 📝 Example Test

```typescript
import { render, screen, fireEvent } from '../test/utils';
import MyComponent from '../MyComponent';

it('handles click', () => {
    render(<MyComponent />);
    fireEvent.click(screen.getByRole('button'));
    expect(screen.getByText(/success/i)).toBeInTheDocument();
});
```

## 🔧 Troubleshooting

**TypeScript errors?** Run `npm install` first.

**Tests failing?** Check that MSW handlers match your API endpoints.

**Coverage too low?** Add more test cases for edge cases and error paths.
