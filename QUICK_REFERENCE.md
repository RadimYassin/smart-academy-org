# 📚 Smart Academy Platform - Quick Reference Guide

## 🚀 Quick Start

### Start All Services
```bash
cd servers
./start_all_services.sh    # Linux/Mac
# OR
start_all_services.bat     # Windows
```

### Access Points
- **Eureka Dashboard**: http://localhost:8761
- **API Gateway**: http://localhost:8888
- **Frontend Shell**: http://localhost:5001
- **Swagger (User Service)**: http://localhost:8082/swagger-ui.html
- **Swagger (Course Service)**: http://localhost:8081/swagger-ui.html

---

## 📊 Services Port Reference

| Service | Port | Technology | Database |
|---------|------|------------|----------|
| **Eureka Server** | 8761 | Spring Boot | - |
| **API Gateway** | 8888 | Spring Cloud Gateway | - |
| **User Management** | 8082 | Spring Boot | PostgreSQL:5435 |
| **Course Management** | 8081 | Spring Boot | PostgreSQL |
| **LMS Connector** | 3000 | NestJS | PostgreSQL:5432 |
| **PrepaData** | 8001 | FastAPI | - |
| **StudentProfiler** | 8002 | FastAPI | - |
| **PathPredictor** | 8003 | FastAPI | - |
| **RecoBuilder** | 8004 | FastAPI | - |
| **Shell (Frontend)** | 5001 | React/Vite | - |
| **Auth (Frontend)** | 5002 | React/Vite | - |
| **Dashboard (Frontend)** | 5003 | React/Vite | - |
| **Courses (Frontend)** | 5004 | React/Vite | - |

---

## 🔑 API Endpoints Quick Reference

### Authentication (via Gateway: `http://localhost:8888`)

```bash
# Register
POST /user-management-service/api/v1/auth/register
Body: { "email", "password", "firstName", "lastName", "role" }

# Login
POST /user-management-service/api/v1/auth/login
Body: { "email", "password" }
Response: { "accessToken", "refreshToken", "user" }

# Refresh Token
POST /user-management-service/api/v1/auth/refresh-token
Body: { "refreshToken" }

# Logout
POST /user-management-service/api/v1/auth/logout
Headers: { "Authorization": "Bearer <token>" }
```

### User Management

```bash
# Get User by ID
GET /user-management-service/api/v1/users/{id}
Headers: { "Authorization": "Bearer <token>" }

# Restore User
POST /user-management-service/api/v1/users/{id}/restore
Headers: { "Authorization": "Bearer <token>" }
```

### Course Management

```bash
# Get All Courses
GET /course-service/courses
Headers: { "Authorization": "Bearer <token>" }

# Get Course by ID
GET /course-service/courses/{id}
Headers: { "Authorization": "Bearer <token>" }

# Create Course
POST /course-service/courses
Headers: { "Authorization": "Bearer <token>" }
Body: { "title", "description", "level", ... }

# Get Modules
GET /course-service/modules?courseId={id}
Headers: { "Authorization": "Bearer <token>" }

# Get Lessons
GET /course-service/lessons?moduleId={id}
Headers: { "Authorization": "Bearer <token>" }
```

### LMS Connector

```bash
# Sync Course Students from Moodle
POST /lmsconnector/ingestion/sync-course-students/{courseId}
Headers: { "Authorization": "Bearer <token>" }
```

### AI Services

```bash
# Process Data
POST /prepadata-service/process-data
Headers: { "Authorization": "Bearer <token>" }

# Get Engagement Stats
GET /prepadata-service/engagement-stats/{studentId}
Headers: { "Authorization": "Bearer <token>" }

# Get Student Profile
GET /studentprofiler-service/profile-student/{studentId}
Headers: { "Authorization": "Bearer <token>" }

# Predict Risk
GET /pathpredictor-service/predict-risk/{studentId}
Headers: { "Authorization": "Bearer <token>" }

# Get Recommendations
GET /recobuilder-service/recommend/{studentId}
Headers: { "Authorization": "Bearer <token>" }
```

---

## 🔐 JWT Configuration

**Shared Secret** (All Services):
```
404E635266556A586E3272357538782F413F4428472B4B6250645367566B5970
```

**Token Expiration**:
- Access Token: 24 hours
- Refresh Token: 7 days

**Claims**:
- `sub`: User ID
- `roles`: Array of roles
- `exp`: Expiration timestamp

**Usage**:
```bash
Headers: {
  "Authorization": "Bearer <your-jwt-token>"
}
```

---

## 🗄️ Database Schemas

### User Management DB (Port 5435)
- `user` - User accounts
- `role` - User roles (STUDENT, TEACHER, ADMIN)
- `refresh_token` - Refresh tokens

### Course Management DB
- `course` - Courses
- `module` - Course modules
- `lesson` - Lessons
- `lesson_content` - Lesson content (videos, docs, quizzes)
- `quiz` - Quizzes
- `question` - Quiz questions
- `quiz_attempt` - Quiz attempts
- `student_answer` - Student answers

### LMS Connector DB (Port 5432)
- `row_data` - Raw Moodle data (JSONB)
- `student` - Normalized student data
- `enrollment` - Course enrollments

---

## 📁 Key File Locations

### Server-Side
```
servers/
├── Eureka-Server/              # Service discovery
├── GateWay/                    # API Gateway
├── User-Management/            # User & auth service
├── Cour-Management/            # Course management
├── lmsconnector/               # LMS integration
├── PrepaData/                  # Data preprocessing
├── StudentProfiler/            # Student profiling
├── PathPredictor/              # Risk prediction
└── RecoBuilder/                # Recommendations
```

### Client-Side
```
clients/microfrontends/
├── shell/                      # Host application
├── auth/                       # Auth microfrontend
├── dashboard/                  # Dashboard microfrontend
└── courses/                    # Courses microfrontend
```

---

## 🔄 Service Communication Patterns

### 1. Client → Gateway → Service
```
Client → Gateway (8888) → [Service Discovery] → Microservice
```

### 2. Microfrontend → Shell → Backend
```
Microfrontend → postMessage → Shell → HTTP → Gateway → Service
```

### 3. Service-to-Service
```
Service A → HTTP → Gateway → Service B
OR
Service A → HTTP (via Eureka) → Service B
```

---

## 🛠️ Development Commands

### Java Services (Maven)
```bash
cd servers/[service-name]
mvn spring-boot:run
```

### NestJS Service
```bash
cd servers/lmsconnector
npm install
npm run start:dev
```

### Python Services
```bash
cd servers/[service-name]
pip install -r requirements.txt
python main.py
```

### Frontend Services
```bash
cd clients/microfrontends/[app-name]
npm install
npm run dev
```

---

## 🔍 Troubleshooting

### Service Not Found in Eureka
1. Check Eureka dashboard: http://localhost:8761
2. Verify service is running
3. Check service logs for registration errors
4. Ensure Eureka server is started first

### JWT Authentication Fails
1. Verify JWT secret matches across all services
2. Check token expiration
3. Ensure Authorization header format: `Bearer <token>`
4. Validate token at: https://jwt.io

### CORS Issues
1. Check Gateway CORS configuration
2. Verify allowed origins
3. Check browser console for CORS errors

### Database Connection Issues
1. Verify PostgreSQL is running
2. Check connection strings in `application.yml`
3. Verify database credentials
4. Check Flyway migration status

---

## 📝 Environment Variables

### User Management Service
```bash
DB_USERNAME=postgres
DB_PASSWORD=postgres
JWT_SECRET=<shared-secret>
MAIL_HOST=smtp.gmail.com
MAIL_USERNAME=<email>
MAIL_PASSWORD=<password>
```

### LMS Connector
```bash
DATABASE_HOST=localhost
DATABASE_PORT=5432
DATABASE_USER=postgres
DATABASE_PASSWORD=postgres
DATABASE_NAME=lmsconnector
MOODLE_URL=<moodle-url>
MOODLE_TOKEN=<moodle-token>
JWT_SECRET=<shared-secret>
```

### Python Services
```bash
JWT_SECRET=<shared-secret>
EUREKA_SERVER=http://localhost:8761/eureka/
```

---

## 🎯 Common Workflows

### Register New User
1. Open: http://localhost:5001/auth
2. Fill registration form
3. Submit → Shell calls `/auth/register`
4. Receive email with OTP (if configured)
5. Verify email → Login

### Create Course (Teacher)
1. Login as teacher
2. Navigate to Courses
3. Click "Create Course"
4. Fill course details
5. Submit → Shell calls `/course-service/courses`
6. Course created in database

### Sync Students from Moodle
1. Login as teacher
2. Navigate to course
3. Click "Sync from Moodle"
4. Shell calls `/lmsconnector/ingestion/sync-course-students/{id}`
5. Students imported and normalized

### Predict Student Risk
1. Login as teacher
2. Navigate to student profile
3. Click "Predict Risk"
4. Shell calls `/pathpredictor-service/predict-risk/{id}`
5. Display risk level and recommendations

---

## 📚 Technology Versions

| Technology | Version |
|------------|---------|
| Java | 17+ |
| Spring Boot | 3.2.5 |
| Spring Cloud | 2023.0.0 |
| Node.js | 18+ |
| NestJS | 11 |
| Python | 3.8+ |
| FastAPI | 0.104+ |
| React | 18.2 |
| TypeScript | 5.2+ |
| Vite | 5.0+ |
| PostgreSQL | Latest |

---

## 🔗 Useful Links

- **Eureka Dashboard**: http://localhost:8761
- **Gateway**: http://localhost:8888
- **Frontend**: http://localhost:5001
- **API Docs (User)**: http://localhost:8082/swagger-ui.html
- **API Docs (Course)**: http://localhost:8081/swagger-ui.html

---

This quick reference guide provides essential information for working with the Smart Academy Platform. For detailed architecture analysis, see `ARCHITECTURE_ANALYSIS.md`.

