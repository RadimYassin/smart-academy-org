# Smart Academy Platform - System Architecture

> **Senior Software Architect Deliverable**  
> Complete architectural design for production-ready educational platform  
> Focus: Backend services, APIs, frontend apps, integration — **NO** ML/data engineering logic

---

## 1. Global Architecture

### 1.1 High-Level System Overview

```mermaid
graph TB
    subgraph "Client Layer"
        TC[Teacher Console<br/>React + Chart.js]
        SC[Student Coach<br/>Flutter Mobile]
    end
    
    subgraph "API Gateway Layer"
        GW[API Gateway :8888<br/>Spring Cloud Gateway]
    end
    
    subgraph "Service Discovery"
        EU[Eureka Server :8761<br/>Netflix Eureka]
    end
    
    subgraph "Core Business Services"
        UM[User Management<br/>Spring Boot :8082]
        CM[Course Management<br/>Spring Boot :8081]
        LMS[LMS Connector<br/>NestJS :3000]
        CB[Chatbot-edu<br/>FastAPI :8005]
    end
    
    subgraph "AI Services - External APIs"
        PD[PrepaData :8001<br/>Data Normalization API]
        SP[StudentProfiler :8002<br/>Profiling API]
        PP[PathPredictor :8003<br/>Risk Prediction API]
        RB[RecoBuilder :8004<br/>Recommendation API]
    end
    
    subgraph "Data Layer"
        DB1[(User DB<br/>PostgreSQL :5435)]
        DB2[(Course DB<br/>PostgreSQL :5432)]
        DB3[(LMS DB<br/>PostgreSQL :5433)]
        MINIO[MinIO Object Storage<br/>:9000]
        RMQ[RabbitMQ<br/>:5672/:15672]
    end
    
    subgraph "External Systems"
        MOODLE[Moodle LMS<br/>OAuth2]
        CANVAS[Canvas LMS]
    end
    
    TC & SC --> GW
    GW --> UM & CM & LMS & CB & PD & SP & PP & RB
    UM & CM & LMS & CB & PD & SP & PP & RB --> EU
    
    UM --> DB1
    CM --> DB2
    LMS --> DB3
    CB --> MINIO
    RB --> MINIO
    UM --> RMQ
    
    LMS <--> MOODLE & CANVAS
    
    style TC fill:#4A90E2
    style SC fill:#4A90E2
    style GW fill:#F5A623
    style EU fill:#F5A623
    style PD fill:#7ED321
    style SP fill:#7ED321
    style PP fill:#7ED321
    style RB fill:#7ED321
```

### 1.2 System Communication Patterns

| Pattern | Implementation | Services |
|---------|---------------|----------|
| **Service Discovery** | Eureka Client (Spring Cloud) | All microservices register with Eureka |
| **API Gateway** | Spring Cloud Gateway | Single entry point at :8888 |
| **Authentication** | JWT Bearer Tokens | User-Management issues tokens |
| **Inter-Service** | REST APIs + Load Balancing | Via Eureka service names |
| **Async Messaging** | RabbitMQ AMQP | User events, email notifications |
| **External Integration** | OAuth2 + REST | Moodle/Canvas via LMSConnector |
| **File Storage** | MinIO S3-compatible API | PDFs,videos for Chatbot & Reco |

### 1.3 Technology Stack Summary

| Component | Technology | Justification |
|-----------|-----------|---------------|
| **API Gateway** | Spring Cloud Gateway | Native Spring Cloud integration, reactive routing |
| **Service Discovery** | Netflix Eureka | Industry standard, Spring Cloud native |
| **User Management** | Spring Boot 3, Spring Security, JWT | Enterprise authentication, role-based access |
| **Course Management** | Spring Boot 3, JPA, PostgreSQL | Complex domain modeling, transactional integrity |
| **LMS Connector** | NestJS, TypeORM, PostgreSQL | TypeScript for OAuth2 flows, modern Node.js |
| **AI Services** | FastAPI (Python) | Lightweight REST wrappers for AI model outputs |
| **Teacher Console** | React, Chart.js | Rich data visualization, responsive web |
| **Student Coach** | Flutter | Cross-platform mobile (iOS + Android) |
| **Databases** | PostgreSQL 15 | ACID compliance, relational integrity |
| **Object Storage** | MinIO | S3-compatible, self-hosted for PDFs/videos |
| **Message Broker** | RabbitMQ | Reliable async messaging for emails, events |

---

## 2. Module Design

### 2.1 LMSConnector (Node.js + NestJS)

#### Responsibilities
- **Primary**: Fetch and normalize raw data from LMS platforms (Moodle, Canvas)
- **Secondary**: Transform learning events into standard format for AI services
- **Tertiary**: Store raw and normalized data in PostgreSQL for auditing

#### Technology Stack
| Component | Choice | Version |
|-----------|--------|---------|
| Runtime | Node.js | 20.x |
| Framework | NestJS | 11.x |
| ORM | TypeORM | 0.3.x |
| Authentication | Passport-JWT, OAuth2 | Latest |
| Database | PostgreSQL | 15.x |
| Service Discovery | eureka-js-client | 4.5.x |

#### Database Schema

```sql
-- Students from LMS
CREATE TABLE student (
    id INTEGER PRIMARY KEY,              -- Moodle student ID
    fullname VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    last_access TIMESTAMP
);

-- Course enrollments
CREATE TABLE enrollment (
    id SERIAL PRIMARY KEY,
    student_id INTEGER REFERENCES student(id),
    course_id INTEGER NOT NULL,          -- Moodle course ID
    course_name VARCHAR(255),
    enrolled_at TIMESTAMP,
    status VARCHAR(50)                   -- 'active', 'completed', 'dropped'
);

-- Raw learning events from Moodle
CREATE TABLE raw_data (
    id SERIAL PRIMARY KEY,
    student_id INTEGER REFERENCES student(id),
    course_id INTEGER,
    event_type VARCHAR(100),             -- 'quiz_submit', 'forum_post', 'module_view'
    event_data JSONB,                    -- Raw event payload
    event_timestamp TIMESTAMP,
    ingested_at TIMESTAMP DEFAULT NOW()
);

-- AI-ready transformed data
CREATE TABLE ai_student_data (
    id SERIAL PRIMARY KEY,
    student_id INTEGER REFERENCES student(id),
    student_name VARCHAR(255),
    course_id INTEGER,
    course_name VARCHAR(255),
    avg_grade NUMERIC(5,2),              -- 0.00 - 100.00
    engagement_score NUMERIC(5,2),       -- Calculated metric
    total_activities INTEGER,
    completed_activities INTEGER,
    forum_posts INTEGER,
    last_activity_date TIMESTAMP,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);
```

#### API Endpoints

**Base URL**: `http://localhost:3000` or via Gateway: `http://localhost:8888/lmsconnector`

| Method | Path | Description | Request | Response |
|--------|------|-------------|---------|----------|
| `POST` | `/ingestion/pull` | Pull all data from Moodle for AI | None | `{ studentsPulled: 150, coursesProcessed: 12, timestamp: '...' }` |
| `POST` | `/ingestion/sync-course-students/:id` | Sync students for specific course | Param: `courseId` (int) | `{ studentsSynced: 25, courseId: 5 }` |
| `GET` | `/ingestion/ai-data` | Get all AI-ready student data | None | `[ { studentId, studentName, courseId, avgGrade, ... }, ... ]` |
| `GET` | `/ingestion/ai-data/student/:id` | Get AI data for one student | Param: `studentId` (int) | `{ studentId: 42, courses: [...], overallEngagement: 75.5 }` |
| `GET` | `/ingestion/export-csv` | Export AI data as CSV | None | CSV file download |
| `GET` | `/ingestion/stats` | Data collection statistics | None | `{ totalStudents: 150, totalCourses: 12, lastSync: '...' }` |
| `GET` | `/health` | Health check | None | `{ status: 'UP', service: 'lmsconnector' }` |

**Example Request/Response:**

```bash
# Pull data from Moodle
POST http://localhost:3000/ingestion/pull
```

```json
{
  "success": true,
  "studentsPulled": 150,
  "coursesProcessed": 12,
  "enrollmentsCreated": 380,
  "aiDataRecordsGenerated": 380,
  "timestamp": "2025-12-24T00:30:00Z",
  "duration": "45s"
}
```

```bash
# Get AI-ready data for PrepaData service
GET http://localhost:3000/ingestion/ai-data
```

```json
[
  {
    "studentId": 42,
    "studentName": "John Doe",
    "courseId": 5,
    "courseName": "Advanced Mathematics",
    "avgGrade": 75.5,
    "engagementScore": 68.2,
    "totalActivities": 20,
    "completedActivities": 14,
    "forumPosts": 3,
    "lastActivityDate": "2025-12-20T14:30:00Z"
  }
]
```

#### Integration Points

| Service | Direction | Purpose | Authentication |
|---------|-----------|---------|----------------|
| **Moodle** | ← Pull | Fetch courses, users, grades, forum activity via Moodle REST API | OAuth2 / API Token |
| **Canvas** | ← Pull | Fetch learning events via Canvas API | OAuth2 |
| **PrepaData** | → Push (via request) | PrepaData calls `/ingestion/ai-data` to get normalized data | None (internal) |
| **API Gateway** | ↔ | Routes `/lmsconnector/**` to this service | JWT validation |
| **Eureka** | → Register | Registers as `LMSCONNECTOR` | None |

#### Configuration

**Environment Variables** (`.env`):
```env
# Moodle Integration
MOODLE_URL=https://your-moodle.com
MOODLE_TOKEN=your_moodle_web_service_token

# Database
DB_HOST=localhost
DB_PORT=5433
DB_USERNAME=lms_user
DB_PASSWORD=lms_pass
DB_DATABASE=lms_connector_db

# Eureka
EUREKA_HOST=localhost
EUREKA_PORT=8761
SERVICE_PORT=3000
```

---

### 2.2 PrepaData (Python FastAPI - External Service)

#### Responsibilities
- **Treat as Black Box**: AI models already trained, this is just a REST API
- **Input**: Fetch raw data from LMSConnector (`GET /ingestion/ai-data`)
- **Output**: Expose cleaned, aggregated metrics via REST API
- **No Design Needed**: Data processing logic is out of scope

#### Technology Stack
| Component | Choice |
|-----------|--------|
| Framework | FastAPI |
| Database | PostgreSQL (read from LMSConnector) |
| Deployment | Standalone Python service |

#### API Endpoints (Consumed by TeacherConsole / StudentCoach)

**Base URL**: `http://localhost:8001` or via Gateway: `http://localhost:8888/prepadata-service`

| Method | Path | Description | Response Example |
|--------|------|-------------|------------------|
| `GET` | `/health` | Service health | `{ "status": "UP" }` |
| `GET` | `/metrics/student/:id` | Engagement metrics for student | `{ studentId: 42, engagementRate: 60, avgScore: 75 }` |
| `GET` | `/metrics/course/:id` | Aggregated course metrics | `{ courseId: 5, avgEngagement: 65, completionRate: 78 }` |

**Integration**: TeacherConsole calls this to display student engagement charts.

---

### 2.3 StudentProfiler (Python FastAPI - External Service)

#### Responsibilities
- **Treat as Black Box**: Clustering model (KMeans, PCA) already trained
- **Input**: Consumes metrics from PrepaData
- **Output**: Student profile labels via REST API

#### API Endpoints

**Base URL**: `http://localhost:8002` or via Gateway: `http://localhost:8888/studentprofiler-service`

| Method | Path | Description | Response Example |
|--------|------|-------------|------------------|
| `GET` | `/health` | Service health | `{ "status": "UP" }` |
| `GET` | `/profile/student/:id` | Get student profile type | `{ studentId: 42, profileType: "procrastinator", confidence: 0.85 }` |
| `POST` | `/profile/batch` | Batch profile students | Request: `{studentIds: [1,2,3]}` → Response: `[{studentId:1, profileType:...}, ...]` |

**Profile Types**: `"assidu"`, `"procrastinator"`, `"struggling"`, `"high_achiever"`

**Integration**: TeacherConsole displays profile badges, StudentCoach shows personalized messages.

---

### 2.4 PathPredictor (Python FastAPI - External Service)

#### Responsibilities
- **Treat as Black Box**: XGBoost model already trained
- **Input**: Student metrics from PrepaData
- **Output**: Success probability, risk scores

#### API Endpoints

**Base URL**: `http://localhost:8003` or via Gateway: `http://localhost:8888/pathpredictor-service`

| Method | Path | Description | Response Example |
|--------|------|-------------|------------------|
| `GET` | `/health` | Service health | `{ "status": "UP" }` |
| `POST` | `/predict` | Predict student success | Request: `{studentId: 42, courseId: 5}` → `{studentId: 42, successProbability: 0.35, riskLevel: "high"}` |
| `GET` | `/alerts/course/:id` | Get at-risk students for course | `[{studentId: 42, riskLevel: "high", successProb: 0.35}, ...]` |

**Risk Levels**: `"low"`, `"medium"`, `"high"`

**Integration**: TeacherConsole shows alerts, StudentCoach sends motivational messages.

---

### 2.5 RecoBuilder (Python FastAPI - External Service)

#### Responsibilities
- **Treat as Black Box**: BERT + Faiss model already trained
- **Input**: Student performance data, profile type
- **Output**: Personalized learning resource recommendations

#### API Endpoints

**Base URL**: `http://localhost:8004` or via Gateway: `http://localhost:8888/recobuilder-service`

| Method | Path | Description | Response Example |
|--------|------|-------------|------------------|
| `GET` | `/health` | Service health | `{ "status": "UP" }` |
| `POST` | `/recommend` | Get recommendations for student | Request: `{studentId: 42, courseId: 5, difficulty: "statistics"}` → `{recommendations: [{type: "video", title: "Stats Basics", url: "..."}, {type: "quiz", title: "..."}]}` |

**Integration**: StudentCoach displays recommended resources.

---

### 2.6 TeacherConsole (React + Chart.js)

#### Responsibilities
- **Dashboard** for teachers to monitor class performance
- **Visualize** student profiles, at-risk alerts, engagement trends
- **Action** on recommendations: schedule tutoring, send messages

#### Technology Stack
| Component | Choice |
|-----------|--------|
| Framework | React 18 |
| State Management | React Context API or Redux |
| Charts | Chart.js 4 |
| HTTP Client | Axios |
| UI Library | Material-UI or TailwindCSS |
| Build Tool | Vite |

#### Application Structure

```
teacher-console/
├── src/
│   ├── components/
│   │   ├── Dashboard.jsx           # Main dashboard
│   │   ├── StudentList.jsx         # Paginated student table
│   │   ├── StudentDetail.jsx       # Individual student view
│   │   ├── AlertPanel.jsx          # At-risk students alerts
│   │   ├── EngagementChart.jsx     # Chart.js line/bar charts
│   │   └── ProfileBadge.jsx        # Profile type badge
│   ├── services/
│   │   ├── authService.js          # Login via User-Management
│   │   ├── studentService.js       # Fetch from PrepaData, Profiler
│   │   ├── courseService.js        # Fetch from Course-Management
│   │   └── predictionService.js    # Fetch from PathPredictor
│   ├── contexts/
│   │   └── AuthContext.jsx         # JWT token management
│   ├── hooks/
│   │   └── useAuth.js              # Custom auth hook
│   ├── App.jsx
│   └── main.jsx
├── package.json
└── vite.config.js
```

#### API Integration

| Feature | API Call | Example |
|---------|----------|---------|
| **Login** | `POST /user-management-service/api/v1/auth/login` | → JWT token |
| **Fetch Courses** | `GET /course-service/api/courses` | → List of teacher's courses |
| **Student Metrics** | `GET /prepadata-service/metrics/student/:id` | → Engagement, scores |
| **Student Profile** | `GET /studentprofiler-service/profile/student/:id` | → Profile type |
| **At-Risk Alerts** | `GET /pathpredictor-service/alerts/course/:id` | → List of at-risk students |

#### Sample UI Workflow

1. **Teacher logs in** → JWT stored in localStorage
2. **Dashboard loads** → Fetch teacher's courses from Course-Management
3. **Select course** → Display:
   - Engagement chart (Chart.js) from PrepaData
   - Student list with profile badges (StudentProfiler)
   - Alert panel showing at-risk students (PathPredictor)
4. **Click student** → Student detail page:
   - Performance timeline
   - Recommended actions from RecoBuilder

#### Security
- **JWT Token** in `Authorization: Bearer <token>` header on every API call
- **Role Check**: Only users with `role: TEACHER` can access
- **CORS**: Configuredin API Gateway to allow `http://localhost:3001`

---

### 2.7 StudentCoach (Flutter Mobile)

#### Responsibilities
- **Mobile app** for students to track progress and receive coaching
- **Motivational messages** based on profile type and performance
- **Resource suggestions** from RecoBuilder

#### Technology Stack
| Component | Choice |
|-----------|--------|
| Framework | Flutter 3.x |
| State Management | Riverpod or Provider |
| HTTP Client | Dio |
| Charts | fl_chart |
| Platform | iOS, Android |

#### Application Structure

```
student_coach/
├── lib/
│   ├── main.dart
│   ├── screens/
│   │   ├── login_screen.dart
│   │   ├── home_screen.dart
│   │   ├── progress_screen.dart       # Charts of student's progress
│   │   ├── recommendations_screen.dart # Resources from RecoBuilder
│   │   └── profile_screen.dart
│   ├── widgets/
│   │   ├── progress_card.dart
│   │   ├── recommendation_card.dart
│   │   └── motivational_banner.dart
│   ├── services/
│   │   ├── auth_service.dart          # JWT login
│   │   ├── student_service.dart       # Fetch metrics, profile
│   │   └── recommendation_service.dart
│   ├── models/
│   │   ├── user.dart
│   │   ├── course.dart
│   │   └── recommendation.dart
│   └── providers/
│       └── auth_provider.dart
├── pubspec.yaml
└── android/ios/
```

#### API Integration

| Feature | API Call | Example |
|---------|----------|---------|
| **Login** | `POST /user-management-service/api/v1/auth/login` | → JWT token |
| **My Courses** | `GET /course-service/api/courses` | → Enrolled courses |
| **My Metrics** | `GET /prepadata-service/metrics/student/:id` | → Engagement, scores |
| **My Profile** | `GET /studentprofiler-service/profile/student/:id` | → Profile type |
| **Recommendations** | `POST /recobuilder-service/recommend` | → Resources |

#### Sample UI Workflow

1. **Student logs in** → JWT token stored in Secure Storage
2. **Home screen** → Display:
   - "Welcome back, John! You're doing great!" (motivational message based on profile)
   - Progress summary (avg score, engagement %)
3. **Progress tab** → fl_chart showing:
   - Weekly engagement trend (PrepaData)
   - Quiz scores over time
4. **Recommendations tab** → List of cards:
   - Video: "Statistics Basics" (from RecoBuilder)
   - Quiz: "Practice Problems"
   - Tutor: "Book a session"

#### Security
- **JWT Token** in HTTP headers
- **Role Check**: Only `role: STUDENT`
- **Secure Storage**: flutter_secure_storage for tokens

---

### 2.8 User-Management (Spring Boot)

#### Responsibilities
- **User Accounts**: CRUD for users (students, teachers, admins)
- **Authentication**: JWT token issuance and validation
- **Authorization**: Role-based access control (RBAC)
- **Email**: Password reset, email verification (via RabbitMQ)

#### Technology Stack
| Component | Choice | Version |
|-----------|--------|---------|
| Framework | Spring Boot | 3.2.5 |
| Security | Spring Security + JWT | 6.x |
| ORM | Spring Data JPA | 3.x |
| Database | PostgreSQL | 15.x |
| Messaging | Spring AMQP + RabbitMQ | Latest |
| Email | Spring Mail (SMTP) | Latest |
| API Docs | SpringDoc OpenAPI | 2.5.0 |
| Service Discovery | Eureka Client | Spring Cloud 2023.0.0 |

#### Database Schema

```sql
-- Users table
CREATE TABLE users (
    id BIGSERIAL PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,        -- BCrypt hashed
    first_name VARCHAR(255) NOT NULL,
    last_name VARCHAR(255) NOT NULL,
    role VARCHAR(50) NOT NULL,             -- 'ADMIN', 'TEACHER', 'STUDENT'
    deleted BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Refresh tokens for JWT rotation
CREATE TABLE refresh_token (
    id BIGSERIAL PRIMARY KEY,
    token VARCHAR(255) UNIQUE NOT NULL,
    expiry_date TIMESTAMP NOT NULL,
    user_id BIGINT REFERENCES users(id) ON DELETE CASCADE
);

-- Email verification tokens
CREATE TABLE email_verification_token (
    id BIGSERIAL PRIMARY KEY,
    token VARCHAR(255) UNIQUE NOT NULL,
    expiry_date TIMESTAMP NOT NULL,
    user_id BIGINT REFERENCES users(id) ON DELETE CASCADE
);

-- Password reset tokens
CREATE TABLE password_reset_token (
    id BIGSERIAL PRIMARY KEY,
    token VARCHAR(255) UNIQUE NOT NULL,
    expiry_date TIMESTAMP NOT NULL,
    user_id BIGINT REFERENCES users(id) ON DELETE CASCADE
);

-- Student-specific fields (credits, enrollment info)
CREATE TABLE student_profile (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT UNIQUE REFERENCES users(id) ON DELETE CASCADE,
    credits INTEGER DEFAULT 0,
    enrollment_year INTEGER,
    major VARCHAR(255)
);
```

#### API Endpoints

**Base URL**: `http://localhost:8082` or via Gateway: `http://localhost:8888/user-management-service`

| Method | Path | Description | Auth | Request | Response |
|--------|------|-------------|------|---------|----------|
| `POST` | `/api/v1/auth/register` | Register new user | Public | `{email, password, firstName, lastName, role}` | `{userId, email, ...}` (201) |
| `POST` | `/api/v1/auth/login` | Login | Public | `{email, password}` | `{accessToken, refreshToken, user:{...}}` (200) |
| `POST` | `/api/v1/auth/refresh` | Refresh JWT token | Public | `{refreshToken}` | `{accessToken, refreshToken}` (200) |
| `POST` | `/api/v1/auth/logout` | Logout (invalidate refresh token) | JWT | `{refreshToken}` | `{message: "Logged out"}` (200) |
| `POST` | `/api/v1/auth/forgot-password` | Request password reset | Public | `{email}` | `{message: "Email sent"}` (200) |
| `POST` | `/api/v1/auth/reset-password` | Reset password with token | Public | `{token, newPassword}` | `{message: "Password reset"}` (200) |
| `GET` | `/api/v1/users/me` | Get current user info | JWT | None | `{id, email, firstName, lastName, role}` (200) |
| `GET` | `/api/v1/users/:id` | Get user by ID | JWT (ADMIN) | None | `{id, email, ...}` (200) |
| `GET` | `/api/v1/users` | List all users | JWT (ADMIN) | Query: `?role=STUDENT&page=0&size=20` | `{content: [...], totalPages, totalElements}` (200) |
| `PUT` | `/api/v1/users/:id` | Update user | JWT (ADMIN or self) | `{firstName, lastName, ...}` | `{id, ...}` (200) |
| `DELETE` | `/api/v1/users/:id` | Soft delete user | JWT (ADMIN) | None | `204 No Content` |

**Example Request/Response:**

```bash
# Register
POST http://localhost:8888/user-management-service/api/v1/auth/register
Content-Type: application/json

{
  "email": "student@test.com",
  "password": "Password123!",
  "firstName": "John",
  "lastName": "Doe",
  "role": "STUDENT"
}
```

```json
{
  "id": 42,
  "email": "student@test.com",
  "firstName": "John",
  "lastName": "Doe",
  "role": "STUDENT",
  "createdAt": "2025-12-24T00:30:00Z"
}
```

```bash
# Login
POST http://localhost:8888/user-management-service/api/v1/auth/login
Content-Type: application/json

{
  "email": "student@test.com",
  "password": "Password123!"
}
```

```json
{
  "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "refreshToken": "550e8400-e29b-41d4-a716-446655440000",
  "tokenType": "Bearer",
  "expiresIn": 3600,
  "user": {
    "id": 42,
    "email": "student@test.com",
    "firstName": "John",
    "lastName": "Doe",
    "role": "STUDENT"
  }
}
```

#### Integration Points

| Service | Direction | Purpose | How |
|---------|-----------|---------|-----|
| **API Gateway** | ↔ | Routes `/user-management-service/**` | Spring Cloud Gateway |
| **Eureka** | → Register | Registers as `USER-MANAGEMENT-SERVICE` | Eureka Client auto-config |
| **RabbitMQ** | → Publish | Publish `UserCreatedEvent`, `PasswordResetEvent` | Spring AMQP |
| **Email Service** | ← Consume | Listen to RabbitMQ queue, send emails via SMTP | Spring Mail |
| **All Services** | → JWT Validation | Other services validate JWT using shared secret | JWT library |

#### Security Configuration

**JWT Secret**: Shared across all services via environment variable
```env
JWT_SECRET=404E635266556A586E3272357538782F413F4428472B4B6250645367566B5970
```

**Password Encoding**: BCrypt with strength 10

**CORS**: Configured in Gateway to allow frontend origins

---

### 2.9 Course-Management (Spring Boot)

#### Responsibilities
- **Courses**: CRUD operations for courses, modules, lessons, quizzes
- **Enrollments**: Students enroll in courses (managed by classes)
- **Quiz Attempts**: Store student quiz submissions and grades
- **Teacher Assignment**: Associate teachers with courses

#### Technology Stack
| Component | Choice | Version |
|-----------|--------|---------|
| Framework | Spring Boot | 3.2.5 |
| ORM | Spring Data JPA | 3.x |
| Database | PostgreSQL | 15.x |
| API Docs | SpringDoc OpenAPI | 2.5.0 |
| Service Discovery | Eureka Client | Spring Cloud 2023.0.0 |

#### Database Schema

```sql
-- Courses
CREATE TABLE courses (
    id UUID PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    category VARCHAR(255),
    level VARCHAR(50),                   -- 'beginner', 'intermediate', 'advanced'
    thumbnail_url VARCHAR(255),
    teacher_id BIGINT NOT NULL,          -- References User-Management
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Modules (chapters within a course)
CREATE TABLE modules (
    id UUID PRIMARY KEY,
    course_id UUID REFERENCES courses(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    order_index INT,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Lessons (individual lessons in a module)
CREATE TABLE lessons (
    id UUID PRIMARY KEY,
    module_id UUID REFERENCES modules(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    summary TEXT,
    order_index INT,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Lesson contents (text, video, PDF, quiz)
CREATE TABLE lesson_contents (
    id UUID PRIMARY KEY,
    lesson_id UUID REFERENCES lessons(id) ON DELETE CASCADE,
    type VARCHAR(50) NOT NULL,           -- 'text', 'video', 'pdf', 'quiz'
    text_content TEXT,
    pdf_url VARCHAR(255),
    video_url VARCHAR(255),
    image_url VARCHAR(255),
    quiz_id UUID,                        -- Loose FK to quizzes
    order_index INT,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Quizzes
CREATE TABLE quizzes (
    id UUID PRIMARY KEY,
    course_id UUID REFERENCES courses(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    difficulty VARCHAR(50),              -- 'easy', 'medium', 'hard'
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Quiz questions
CREATE TABLE questions (
    id UUID PRIMARY KEY,
    quiz_id UUID REFERENCES quizzes(id) ON DELETE CASCADE,
    content TEXT NOT NULL,
    options JSONB,                       -- ["Option A", "Option B", "Option C", "Option D"]
    correct_option_index INT,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Student quiz attempts
CREATE TABLE quiz_attempts (
    id UUID PRIMARY KEY,
    quiz_id UUID REFERENCES quizzes(id),
    student_id BIGINT NOT NULL,          -- References User-Management
    score NUMERIC(5,2),
    total_questions INT,
    correct_answers INT,
    submitted_at TIMESTAMP DEFAULT NOW()
);

-- Classes (group of students for enrollment management)
CREATE TABLE classes (
    id UUID PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    course_id UUID REFERENCES courses(id) ON DELETE CASCADE,
    teacher_id BIGINT NOT NULL,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Class enrollments (students in a class)
CREATE TABLE class_students (
    id UUID PRIMARY KEY,
    class_id UUID REFERENCES classes(id) ON DELETE CASCADE,
    student_id BIGINT NOT NULL,
    enrolled_at TIMESTAMP DEFAULT NOW()
);
```

#### API Endpoints

**Base URL**: `http://localhost:8081` or via Gateway: `http://localhost:8888/course-service`

| Method | Path | Description | Auth | Request | Response |
|--------|------|-------------|------|---------|----------|
| **Courses** |
| `GET` | `/api/courses` | List all courses | JWT | Query: `?category=math&page=0&size=20` | `{content: [...], totalPages}` |
| `GET` | `/api/courses/:id` | Get course by ID | JWT | None | `{id, title, description, modules: [...]}` |
| `POST` | `/api/courses` | Create course | JWT (TEACHER) | `{title, description, category, level}` | `{id, ...}` (201) |
| `PUT` | `/api/courses/:id` | Update course | JWT (TEACHER) | `{title, description, ...}` | `{id, ...}` (200) |
| `DELETE` | `/api/courses/:id` | Delete course | JWT (ADMIN) | None | `204 No Content` |
| **Modules** |
| `GET` | `/api/courses/:courseId/modules` | List modules for course | JWT | None | `[{id, title, orderIndex, lessons: [...]}, ...]` |
| `POST` | `/api/courses/:courseId/modules` | Create module | JWT (TEACHER) | `{title, description, orderIndex}` | `{id, ...}` (201) |
| `PUT` | `/api/modules/:id` | Update module | JWT (TEACHER) | `{title, description, ...}` | `{id, ...}` (200) |
| `DELETE` | `/api/modules/:id` | Delete module | JWT (TEACHER) | None | `204 No Content` |
| **Lessons** |
| `GET` | `/api/modules/:moduleId/lessons` | List lessons for module | JWT | None | `[{id, title, summary, contents: [...]}, ...]` |
| `POST` | `/api/modules/:moduleId/lessons` | Create lesson | JWT (TEACHER) | `{title, summary, orderIndex}` | `{id, ...}` (201) |
| `PUT` | `/api/lessons/:id` | Update lesson | JWT (TEACHER) | `{title, summary, ...}` | `{id, ...}` (200) |
| `DELETE` | `/api/lessons/:id` | Delete lesson | JWT (TEACHER) | None | `204 No Content` |
| **Quizzes** |
| `GET` | `/api/courses/:courseId/quizzes` | List quizzes for course | JWT | None | `[{id, title, difficulty, questions: [...]}, ...]` |
| `POST` | `/api/courses/:courseId/quizzes` | Create quiz | JWT (TEACHER) | `{title, description, difficulty, questions: [...]}` | `{id, ...}` (201) |
| `POST` | `/api/quizzes/:id/submit` | Submit quiz attempt | JWT (STUDENT) | `{studentId, answers: [{questionId, selectedOptionIndex}, ...]}` | `{score, correctAnswers, totalQuestions}` (200) |

**Example Request/Response:**

```bash
# Create a course
POST http://localhost:8888/course-service/api/courses
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
Content-Type: application/json

{
  "title": "Advanced Mathematics",
  "description": "Calculus, Linear Algebra, Statistics",
  "category": "Mathematics",
  "level": "advanced"
}
```

```json
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "title": "Advanced Mathematics",
  "description": "Calculus, Linear Algebra, Statistics",
  "category": "Mathematics",
  "level": "advanced",
  "teacherId": 5,
  "createdAt": "2025-12-24T00:30:00Z"
}
```

```bash
# Submit a quiz
POST http://localhost:8888/course-service/api/quizzes/123e4567-e89b-12d3-a456-426614174000/submit
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
Content-Type: application/json

{
  "studentId": 42,
  "answers": [
    {"questionId": "abc-123", "selectedOptionIndex": 2},
    {"questionId": "def-456", "selectedOptionIndex": 1},
    {"questionId": "ghi-789", "selectedOptionIndex": 3}
  ]
}
```

```json
{
  "quizId": "123e4567-e89b-12d3-a456-426614174000",
  "studentId": 42,
  "score": 66.67,
  "correctAnswers": 2,
  "totalQuestions": 3,
  "submittedAt": "2025-12-24T00:35:00Z"
}
```

#### Integration Points

| Service | Direction | Purpose | How |
|---------|-----------|---------|-----|
| **API Gateway** | ↔ | Routes `/course-service/**` | Spring Cloud Gateway |
| **Eureka** | → Register | Registers as `COURSE-SERVICE` | Eureka Client |
| **User-Management** | → Validate | Validate JWT, get user roles | JWT shared secret |
| **LMSConnector** | ← Query | LMSConnector may query courses for enrichment | REST API |
| **PrepaData** | ← Query | PrepaData fetches course structure for metrics | REST API |

---

## 3. API & Integration Design

### 3.1 API Contract Standards

#### Versioning
- **URL Versioning**: `/api/v1/...`
- **Header Versioning** (future): `Accept: application/vnd.smart-academy.v2+json`

#### Response Format

**Success Response**:
```json
{
  "id": "...",
  "title": "...",
  ...
}
```

**Paginated Response**:
```json
{
  "content": [...],
  "page": 0,
  "size": 20,
  "totalElements": 150,
  "totalPages": 8
}
```

**Error Response**:
```json
{
  "timestamp": "2025-12-24T00:30:00Z",
  "status": 400,
  "error": "Bad Request",
  "message": "Validation failed: email is required",
  "path": "/api/v1/auth/register"
}
```

#### HTTP Status Codes

| Code | Usage |
|------|-------|
| `200 OK` | Successful GET, PUT |
| `201 Created` | Successful POST |
| `204 No Content` | Successful DELETE |
| `400 Bad Request` | Validation error, malformed request |
| `401 Unauthorized` | Missing or invalid JWT |
| `403 Forbidden` | User lacks permission (wrong role) |
| `404 Not Found` | Resource not found |
| `500 Internal Server Error` | Server error |

#### Error Handling

**Global Exception Handler** in each Spring Boot service:
```java
@ControllerAdvice
public class GlobalExceptionHandler {
    @ExceptionHandler(ResourceNotFoundException.class)
    public ResponseEntity<ErrorResponse> handleNotFound(ResourceNotFoundException ex) {
        return ResponseEntity.status(404).body(new ErrorResponse(...));
    }
    
    @ExceptionHandler(UnauthorizedException.class)
    public ResponseEntity<ErrorResponse> handleUnauthorized(UnauthorizedException ex) {
        return ResponseEntity.status(401).body(new ErrorResponse(...));
    }
}
```

**NestJS Error Filter**:
```typescript
@Catch()
export class GlobalExceptionFilter implements ExceptionFilter {
  catch(exception: unknown, host: ArgumentsHost) {
    const ctx = host.switchToHttp();
    const response = ctx.getResponse();
    const status = exception instanceof HttpException ? exception.getStatus() : 500;
    
    response.status(status).json({
      timestamp: new Date().toISOString(),
      status,
      error: exception.message,
      path: ctx.getRequest().url
    });
  }
}
```

### 3.2 Service-to-Service Communication

#### Pattern: REST over HTTP + Load Balancing

**Example**: Course-Management calls User-Management to validate teacher existence

```java
// In Course-Management service
@Service
public class CourseService {
    private final RestTemplate restTemplate;
    
    public Course createCourse(CreateCourseRequest request) {
        // Validate teacher via User-Management
        String userServiceUrl = "http://USER-MANAGEMENT-SERVICE/api/v1/users/" + request.getTeacherId();
        UserDTO teacher = restTemplate.getForObject(userServiceUrl, UserDTO.class);
        
        if (!teacher.getRole().equals("TEACHER")) {
            throw new ForbiddenException("Only teachers can create courses");
        }
        
        // Create course...
    }
}
```

**Load Balancing**: `@LoadBalanced` RestTemplate uses Eureka service names → Gateway routes to healthy instances

#### Pattern: Async Messaging via RabbitMQ

**Example**: User-Management publishes `UserCreatedEvent` → Email Service consumes

**Publisher** (User-Management):
```java
@Service
public class UserService {
    private final RabbitTemplate rabbitTemplate;
    
    public User registerUser(RegisterRequest request) {
        User user = userRepository.save(new User(...));
        
        // Publish event
        rabbitTemplate.convertAndSend("user.exchange", "user.created", new UserCreatedEvent(user));
        
        return user;
    }
}
```

**Consumer** (Email Service in User-Management or separate):
```java
@Component
public class EmailEventListener {
    @RabbitListener(queues = "email.queue")
    public void handleUserCreated(UserCreatedEvent event) {
        emailService.sendWelcomeEmail(event.getEmail(), event.getFirstName());
    }
}
```

### 3.3 Data Exchange Formats

| Scenario | Format | Example |
|----------|--------|---------|
| **REST APIs** | JSON | All API requests/responses |
| **RabbitMQ** | JSON (via Jackson) | Event payloads |
| **LMSConnector Export** | CSV | `/ingestion/export-csv` |
| **Database** | SQL | Relational data |
| **File Storage (MinIO)** | Binary (PDF, MP4) | Course materials |

---

## 4. Security & Roles

### 4.1 Authentication Flow

```mermaid
sequenceDiagram
    participant User as User (Browser/Mobile)
    participant GW as API Gateway
    participant UM as User-Management
    participant CS as Course-Management
    
    User->>GW: POST /user-management-service/api/v1/auth/login<br/>{email, password}
    GW->>UM: Forward request
    UM->>UM: Validate credentials (BCrypt)
    UM->>UM: Generate JWT (access + refresh tokens)
    UM-->>GW: {accessToken, refreshToken, user}
    GW-->>User: {accessToken, refreshToken, user}
    
    Note over User: Store tokens in localStorage/SecureStorage
    
    User->>GW: GET /course-service/api/courses<br/>Authorization: Bearer <accessToken>
    GW->>GW: Validate JWT signature
    GW->>CS: Forward with validated JWT
    CS->>CS: Extract user ID and role from JWT
    CS->>CS: Fetch courses
    CS-->>GW: {courses: [...]}
    GW-->>User: {courses: [...]}
```

### 4.2 JWT Token Structure

**Access Token Payload**:
```json
{
  "sub": "student@test.com",
  "userId": 42,
  "role": "STUDENT",
  "firstName": "John",
  "lastName": "Doe",
  "iat": 1703375400,
  "exp": 1703379000
}
```

**Refresh Token**: UUID stored in database, expires in 7 days

### 4.3 Role-Based Access Control (RBAC)

| Role | Permissions |
|------|-------------|
| **ADMIN** | Full access: manage users, delete courses, view all data |
| **TEACHER** | Create/update/delete own courses, view enrolled students, access TeacherConsole |
| **STUDENT** | View enrolled courses, submit quizzes, access StudentCoach |

**Implementation in Spring Security**:
```java
@Configuration
@EnableMethodSecurity(prePostEnabled = true)
public class SecurityConfig {
    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) {
        http
            .authorizeHttpRequests(auth -> auth
                .requestMatchers("/api/v1/auth/**").permitAll()
                .requestMatchers("/api/v1/admin/**").hasRole("ADMIN")
                .requestMatchers("/api/courses/**").authenticated()
                .anyRequest().authenticated()
            )
            .addFilterBefore(jwtAuthFilter, UsernamePasswordAuthenticationFilter.class);
        return http.build();
    }
}
```

**Method-Level**:
```java
@PreAuthorize("hasRole('TEACHER')")
public Course createCourse(CreateCourseRequest request) { ... }
```

### 4.4 Inter-Service Security

**Shared JWT Secret**: All services validate JWT using same secret key
```yaml
# application.yml (all services)
application:
  security:
    jwt:
      secret-key: ${JWT_SECRET:404E635266556A586E3272357538782F413F4428472B4B6250645367566B5970}
```

**Gateway JWT Validation**: Gateway validates JWT before forwarding to backend services

---

## 5. Deployment & Operations

### 5.1 Deployment Architecture

```mermaid
graph TB
    subgraph "Load Balancer / Reverse Proxy"
        LB[Nginx / Traefik<br/>HTTPS Termination]
    end
    
    subgraph "Container Orchestration - Docker Compose / Kubernetes"
        subgraph "Discovery & Gateway"
            EU[Eureka Server<br/>:8761]
            GW[API Gateway<br/>:8888]
        end
        
        subgraph "Business Services (Scalable)"
            UM1[User-Management<br/>Instance 1]
            UM2[User-Management<br/>Instance 2]
            CM1[Course-Management<br/>Instance 1]
            LMS1[LMS Connector<br/>Instance 1]
            CB1[Chatbot-edu<br/>Instance 1]
        end
        
        subgraph "AI Services"
            PD1[PrepaData :8001]
            SP1[StudentProfiler :8002]
            PP1[PathPredictor :8003]
            RB1[RecoBuilder :8004]
        end
        
        subgraph "Data Layer"
            PG1[(User DB<br/>PostgreSQL)]
            PG2[(Course DB<br/>PostgreSQL)]
            PG3[(LMS DB<br/>PostgreSQL)]
            MINIO[MinIO]
            RMQ[RabbitMQ]
        end
    end
    
    LB --> GW
    GW --> UM1 & UM2 & CM1 & LMS1 & CB1 & PD1 & SP1 & PP1 & RB1
    UM1 & UM2 & CM1 & LMS1 & CB1 & PD1 & SP1 & PP1 & RB1 --> EU
    UM1 & UM2 --> PG1
    CM1 --> PG2
    LMS1 --> PG3
    CB1 & RB1 --> MINIO
    UM1 & UM2 --> RMQ
```

### 5.2 Service Separation & Scalability

| Service | Instances | Scaling Strategy | Stateless? |
|---------|-----------|------------------|------------|
| **Eureka Server** | 1 (dev), 3 (prod) | Peer-to-peer replication | Yes |
| **API Gateway** | 2+ | Horizontal (load balancer) | Yes |
| **User-Management** | 2+ | Horizontal (Eureka LB) | Yes |
| **Course-Management** | 2+ | Horizontal (Eureka LB) | Yes |
| **LMS Connector** | 2+ | Horizontal (Eureka LB) | Yes |
| **Chatbot-edu** | 1-2 | Vertical (GPU for embeddings) | No (model in memory) |
| **AI Services** | 1 each | Vertical (CPU/RAM for models) | No (models in memory) |
| **PostgreSQL** | 1 (dev), 3 (prod) | Master-Replica replication | No |
| **MinIO** | 1 (dev), 4+ (prod) | Distributed mode (erasure coding) | Yes |
| **RabbitMQ** | 1 (dev), 3 (prod) | Cluster mode | No (queue state) |

### 5.3 Environment Configuration

#### Development (Local)

**`.env` file**:
```env
# Infrastructure
POSTGRES_USER_DB_PORT=5435
POSTGRES_COURSE_DB_PORT=5432
POSTGRES_LMS_DB_PORT=5433
MINIO_PORT=9000
RABBITMQ_PORT=5672

# JWT
JWT_SECRET=404E635266556A586E3272357538782F413F4428472B4B6250645367566B5970

# Moodle
MOODLE_URL=http://localhost:8080
MOODLE_TOKEN=your_test_token

# OpenAI (for Chatbot)
OPENAI_API_KEY=sk-your-openai-key

# Email
SPRING_MAIL_USERNAME=noreply@smart-academy.local
SPRING_MAIL_PASSWORD=test
```

**Docker Compose**: `docker-compose up -d` starts all services locally

**Local Run**: `mvn spring-boot:run` for Java, `npm run start:dev` for NestJS, `python main.py` for AI

#### Production

**Kubernetes ConfigMaps**:
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
data:
  EUREKA_URL: "http://eureka-service:8761/eureka"
  JWT_SECRET: "<from-secret>"
  DATABASE_HOST: "postgres-master.db.svc.cluster.local"
```

**Kubernetes Secrets**:
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: app-secrets
type: Opaque
data:
  JWT_SECRET: <base64-encoded>
  DB_PASSWORD: <base64-encoded>
  OPENAI_API_KEY: <base64-encoded>
```

**Environment-Specific Profiles**:
- `application-dev.yml`: Development config (localhost URLs)
- `application-prod.yml`: Production config (service URLs, SSL enabled)

**Activation**:
```bash
# Spring Boot
java -jar app.jar --spring.profiles.active=prod

# Docker
docker run -e SPRING_PROFILES_ACTIVE=prod ...
```

### 5.4 Service Startup Order

**Critical Order**:
1. **Infrastructure** (PostgreSQL, MinIO, RabbitMQ) → Wait 30s
2. **Eureka Server** → Wait until "Started EurekaServerApplication" (60s)
3. **API Gateway** → Wait 10s
4. **Business Services** (User, Course, LMS) → Parallel start, register with Eureka
5. **AI Services** → After business services healthy

**Docker Compose Dependency Management**:
```yaml
services:
  eureka-server:
    depends_on:
      postgres-user-db:
        condition: service_healthy
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8761/actuator/health"]
      interval: 10s
  
  gateway-service:
    depends_on:
      eureka-server:
        condition: service_healthy
```

### 5.5 Monitoring & Health Checks

**Spring Boot Actuator**:
```yaml
# application.yml
management:
  endpoints:
    web:
      exposure:
        include: health,info,metrics,prometheus
  endpoint:
    health:
      show-details: always
```

**Health Check Endpoints**:
- Eureka: `http://localhost:8761/actuator/health`
- Gateway: `http://localhost:8888/actuator/health`
- User-Management: `http://localhost:8082/actuator/health`
- LMSConnector: `http://localhost:3000/health`
- AI Services: `http://localhost:8001-8004/health`

**Production Monitoring Stack**:
- **Prometheus**: Scrape `/actuator/prometheus` from all services
- **Grafana**: Visualize metrics (request rate, latency, error rate)
- **ELK Stack**: Centralized logging (Elasticsearch, Logstash, Kibana)
- **Distributed Tracing**: Zipkin or Jaeger for request tracing

---

## 6. Summary & Next Steps

### 6.1 Architecture Highlights

✅ **Modular Microservices**: 9 independent services with clear boundaries  
✅ **API-First Design**: RESTful contracts, versioned endpoints  
✅ **Security by Design**: JWT authentication, RBAC, shared secret validation  
✅ **Scalability**: Stateless services, horizontal scaling via Eureka LB  
✅ **Observability**: Health checks, actuator metrics, ready for Prometheus  
✅ **AI as a Service**: ML models treated as external APIs, no data engineering in scope  

### 6.2 Integration Flow Example

**Teacher creates a course and views at-risk students:**

1. **Teacher logs in** (TeacherConsole) → `POST /user-management-service/api/v1/auth/login` → Receives JWT
2. **Create course** → `POST /course-service/api/courses` (with JWT) → Course created in PostgreSQL
3. **LMSConnector pulls data** → `POST /lmsconnector/ingestion/pull` → Fetches Moodle data, stores in LMS DB
4. **PrepaData processes** → Calls `/lmsconnector/ingestion/ai-data` → Calculates engagement metrics
5. **PathPredictor predicts** → Consumes PrepaData metrics → Generates risk scores
6. **TeacherConsole displays** → Fetches `/pathpredictor-service/alerts/course/:id` → Shows at-risk students

### 6.3 What's Included in This Design

| Component | Status | Description |
|-----------|--------|-------------|
| **Global Architecture** | ✅ Complete | Service diagram, communication patterns, tech stack |
| **9 Module Designs** | ✅ Complete | Responsibilities, DB schemas, API endpoints, integrations |
| **API Contracts** | ✅ Complete | Request/response examples, error handling, versioning |
| **Security Design** | ✅ Complete | JWT flow, RBAC, inter-service security |
| **Deployment Architecture** | ✅ Complete | Docker Compose, Kubernetes concepts, environment config |

### 6.4 What's Out of Scope (As Requested)

❌ **ML Model Design**: No neural network architecture, no model training  
❌ **Data Engineering**: No ETL pipelines, no Spark/Airflow logic  
❌ **Model Optimization**: No hyperparameter tuning, no feature engineering  

AI services are **black box REST APIs** consuming data and returning predictions.

---

## 7. Appendix

### 7.1 Quick Reference - All Service URLs

| Service | Local URL | Gateway Route | Port |
|---------|-----------|---------------|------|
| Eureka Dashboard | http://localhost:8761 | - | 8761 |
| API Gateway | http://localhost:8888 | - | 8888 |
| User-Management | http://localhost:8082/swagger-ui.html | `/user-management-service/**` | 8082 |
| Course-Management | http://localhost:8081/swagger-ui.html | `/course-service/**` | 8081 |
| LMS Connector | http://localhost:3000 | `/lmsconnector/**` | 3000 |
| PrepaData | http://localhost:8001/docs | `/prepadata-service/**` | 8001 |
| StudentProfiler | http://localhost:8002/docs | `/studentprofiler-service/**` | 8002 |
| PathPredictor | http://localhost:8003/docs | `/pathpredictor-service/**` | 8003 |
| RecoBuilder | http://localhost:8004/docs | `/recobuilder-service/**` | 8004 |
| Chatbot-edu | http://localhost:8005/docs | `/chatbot-edu-service/**` | 8005 |
| MinIO Console | http://localhost:9001 | - | 9001 |
| RabbitMQ Management | http://localhost:15672 | - | 15672 |

### 7.2 Tech Stack Versions

| Technology | Version |
|------------|---------|
| Java | 17 |
| Spring Boot | 3.2.5 |
| Spring Cloud | 2023.0.0 |
| Node.js | 20.x |
| NestJS | 11.x |
| Python | 3.10+ |
| FastAPI | Latest |
| PostgreSQL | 15.x |
| React | 18.x |
| Flutter | 3.x |
| Docker | 24.x |

### 7.3 Database Ports Summary

| Database | Port | Service |
|----------|------|---------|
| User DB | 5435 | User-Management |
| Course DB | 5432 | Course-Management |
| LMS DB | 5433 | LMS Connector |

---

**Document Version**: 1.0  
**Last Updated**: December 24, 2025  
**Architect**: Senior Software Architect  
**Status**: **Ready for Implementation** 🚀
