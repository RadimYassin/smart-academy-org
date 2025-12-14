# API Module Documentation

## 📁 Directory Structure

```
src/api/
├── index.ts              # Central export
├── apiClient.ts          # Core Axios instance with interceptors
├── services.ts           # Service route constants
├── types.ts              # TypeScript types
├── authApi.ts            # Authentication API
├── userApi.ts            # User management API
├── courseApi.ts          # Course management API
└── analyticsApi.ts       # Analytics & AI APIs
```

## 🚀 Quick Start

```typescript
import { authApi, courseApi, userApi } from '@/api';

// Login
await authApi.login({ email: 'user@example.com', password: 'pass123' });

// Get courses
const courses = await courseApi.getAllCourses();

// Get user
const user = await userApi.getUserById(1);
```

## 🔐 Features

- **Auto JWT Token Attachment**: Automatically adds `Authorization` header
- **Auto Token Refresh**: Refreshes expired tokens and retries failed requests
- **Request Queuing**: Prevents multiple refresh calls during token renewal
- **Type Safety**: Full TypeScript support
- **Error Handling**: Centralized error handling with `handleApiError`

## 📡 Available Services

- `authApi` - Login, register, logout
- `userApi` - User CRUD operations
- `courseApi` - Course management
- `moduleApi` - Module management
- `lessonApi` - Lesson management
- `quizApi` - Quiz and attempts
- `analyticsApi` - Student engagement stats
- `profilerApi` - AI student profiling
- `predictorApi` - Risk prediction
- `recommendationApi` - Learning recommendations

## 🛠️ Usage Examples

See the examples file for detailed usage patterns.