import { http, HttpResponse } from 'msw';

const API_BASE = 'http://localhost:8888';

export const handlers = [
    // Auth endpoints
    http.post(`${API_BASE}/api/auth/login`, async ({ request }) => {
        const body = await request.json() as any;

        if (body.email === 'test@example.com' && body.password === 'password123') {
            return HttpResponse.json({
                access_token: 'mock-access-token',
                refresh_token: 'mock-refresh-token',
                token_type: 'Bearer',
            });
        }

        return HttpResponse.json(
            { message: 'Invalid credentials' },
            { status: 401 }
        );
    }),

    http.post(`${API_BASE}/api/auth/register`, async ({ request }) => {
        const body = await request.json() as any;

        return HttpResponse.json({
            access_token: 'mock-access-token',
            refresh_token: 'mock-refresh-token',
            token_type: 'Bearer',
        });
    }),

    // Course endpoints
    http.get(`${API_BASE}/api/courses`, () => {
        return HttpResponse.json([
            {
                id: 1,
                title: 'Introduction to React',
                description: 'Learn React basics',
                teacherId: 1,
            },
            {
                id: 2,
                title: 'Advanced TypeScript',
                description: 'Master TypeScript',
                teacherId: 1,
            },
        ]);
    }),

    http.get(`${API_BASE}/api/courses/:id`, ({ params }) => {
        const { id } = params;
        return HttpResponse.json({
            id: Number(id),
            title: 'Introduction to React',
            description: 'Learn React basics',
            teacherId: 1,
        });
    }),

    // Enrollment endpoints
    http.get(`${API_BASE}/api/enrollments/my-courses`, () => {
        return HttpResponse.json([
            {
                id: 1,
                courseId: 1,
                studentId: 1,
                enrolledAt: '2024-01-01',
            },
        ]);
    }),
];
