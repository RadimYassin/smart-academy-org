# 🏗️ Smart Academy Platform - Complete Architecture Analysis

## 📋 Executive Summary

The **Smart Academy Platform** is a comprehensive microservices-based educational platform designed for intelligent student tracking, risk prediction, and personalized learning recommendations. The system follows a **microservices architecture** for both backend services and frontend applications, providing scalability, maintainability, and independent deployment capabilities.

---

## 🎯 System Overview

### Core Objectives
- **Centralize** pedagogical data from Learning Management Systems (LMS)
- Provide **AI-powered predictions** for student failure risk
- Generate **personalized learning recommendations**
- Offer **intuitive interfaces** for teachers and students
- Build a **scalable, maintainable architecture**

---

## 🏛️ Architecture Layers

### 1. **Frontend Layer (Microfrontends)**
- **Technology**: React 18, TypeScript, Vite, Module Federation
- **Pattern**: Microfrontend Architecture with Shell-Host pattern
- **Styling**: TailwindCSS

### 2. **API Gateway Layer**
- **Technology**: Spring Cloud Gateway (Reactive)
- **Port**: 8888
- **Role**: Single entry point, routing, CORS, load balancing

### 3. **Service Discovery Layer**
- **Technology**: Netflix Eureka Server
- **Port**: 8761
- **Role**: Service registration and discovery

### 4. **Backend Microservices Layer**
- **Java Services**: Spring Boot 3.2.5
- **Node.js Service**: NestJS
- **Python Services**: FastAPI
- **Databases**: PostgreSQL (multiple instances)

### 5. **AI/ML Services Layer**
- **Technology**: FastAPI, XGBoost, Scikit-learn, Transformers
- **Purpose**: Data processing, profiling, predictions, recommendations

---

## 🔧 Backend Microservices (Server-Side)

### Infrastructure Services

#### 1. **Eureka Server** (Port 8761)
- **Technology**: Spring Boot
- **Purpose**: Service Registry and Discovery
- **Configuration**:
  - Self-preservation disabled for development
  - Eviction interval: 10 seconds
  - Dashboard: `http://localhost:8761`

#### 2. **API Gateway** (Port 8888)
- **Technology**: Spring Cloud Gateway (Reactive)
- **Features**:
  - Dynamic service discovery routing
  - CORS configuration (allows all origins)
  - JWT secret sharing with microservices
- **Routes**:
  - `/user-management-service/**` → User Management Service
  - `/course-service/**` → Course Management Service
  - `/lmsconnector/**` → LMS Connector Service
  - `/prepadata-service/**` → PrepaData Service
  - `/studentprofiler-service/**` → StudentProfiler Service
  - `/pathpredictor-service/**` → PathPredictor Service
  - `/recobuilder-service/**` → RecoBuilder Service

---

### Core Business Services

#### 3. **User Management Service** (Port 8082)
- **Technology**: Spring Boot 3.2.5, PostgreSQL
- **Database**: `user_management` (Port 5435)
- **Key Features**:
  - User registration with email verification (OTP)
  - JWT authentication and refresh tokens
  - Password reset via email
  - Role-based access control (RBAC)
  - Email service integration (SMTP)
- **APIs**:
  - `POST /api/v1/auth/register` - User registration
  - `POST /api/v1/auth/login` - User authentication
  - `POST /api/v1/auth/refresh-token` - Token refresh
  - `POST /api/v1/auth/logout` - Logout
  - `GET /api/v1/users/{id}` - Get user details
  - `POST /api/v1/password/forgot` - Request password reset
  - `POST /api/v1/password/reset` - Reset password
- **Security**:
  - JWT tokens with 24-hour expiration
  - Refresh tokens with 7-day expiration
  - Shared JWT secret across all services
- **Database Migrations**: Flyway

#### 4. **Course Management Service** (Port 8081)
- **Technology**: Spring Boot 3.2.5, PostgreSQL
- **Purpose**: Educational content management
- **Key Features**:
  - Course CRUD operations
  - Module management
  - Lesson management with content (videos, documents, quizzes)
  - Quiz creation and attempts tracking
  - Content types: VIDEO, DOCUMENT, QUIZ, EXTERNAL_LINK
- **Entities**:
  - Course (with levels: BEGINNER, INTERMEDIATE, ADVANCED)
  - Module
  - Lesson
  - LessonContent
  - Quiz (with difficulty levels)
  - Question
  - QuizAttempt
  - StudentAnswer
- **Security**: JWT-protected endpoints
- **Database Migrations**: Flyway

#### 5. **LMS Connector Service** (Port 3000)
- **Technology**: NestJS, TypeORM, PostgreSQL
- **Purpose**: Integrate with external LMS (Moodle)
- **Features**:
  - OAuth2-based Moodle integration
  - Student data synchronization
  - Raw data storage for audit trail
  - Data normalization pipeline
- **Entities**:
  - `RowData`: Raw data from LMS
  - `Student`: Normalized student data
  - `Enrollment`: Course enrollments with grades
- **Key Endpoints**:
  - `POST /ingestion/sync-course-students/{courseId}` - Sync students from Moodle
- **Authentication**: JWT via Passport strategy
- **Eureka Integration**: Custom Eureka module for service registration

---

### AI/ML Services (Python FastAPI)

All Python services share:
- **JWT Authentication**: Shared secret with Java services
- **Eureka Registration**: Using `py-eureka-client`
- **Common Auth Module**: `auth/jwt_utils.py`

#### 6. **PrepaData Service** (Port 8001)
- **Purpose**: Data preprocessing and aggregation
- **Features**:
  - Trigger Airflow DAGs (planned)
  - Data cleaning and validation
  - Engagement statistics calculation
- **Endpoints**:
  - `POST /process-data` - Trigger data processing
  - `GET /engagement-stats/{student_id}` - Get student engagement metrics

#### 7. **StudentProfiler Service** (Port 8002)
- **Purpose**: AI-powered student profiling using clustering
- **Technology**: Scikit-learn (KMeans clustering)
- **Features**:
  - Student behavior categorization
  - Cluster analysis (e.g., "Procrastinator", "Diligent")
  - Profile confidence scoring
- **Endpoints**:
  - `GET /profile-student/{student_id}` - Get student profile
  - `POST /cluster-students` - Cluster all students (admin/teacher)

#### 8. **PathPredictor Service** (Port 8003)
- **Purpose**: Risk prediction using XGBoost
- **Technology**: XGBoost, MLflow (for model versioning)
- **Features**:
  - Failure risk prediction
  - Success probability calculation
  - Alert generation for at-risk students
- **Endpoints**:
  - `GET /predict-risk/{student_id}` - Predict student risk level

#### 9. **RecoBuilder Service** (Port 8004)
- **Purpose**: Personalized learning recommendations
- **Technology**: Transformers (BERT), Faiss (vector similarity)
- **Features**:
  - Content-based recommendations
  - Similarity matching using embeddings
  - Resource type filtering (video, exercise, quiz)
- **Endpoints**:
  - `GET /recommend/{student_id}` - Get personalized recommendations

---

## 💻 Frontend Microfrontends (Client-Side)

### Architecture Pattern: **Module Federation** (Vite Plugin)

The frontend follows a **Shell-Host** microfrontend architecture where:
- **Shell** (Host Application) - Loads and orchestrates microfrontends
- **Microfrontends** - Independent React applications exposing components

### Microfrontend Services

#### 1. **Shell Application** (Port 5001)
- **Technology**: React 18, Vite, React Router
- **Role**: Host application, routing, authentication context
- **Features**:
  - Loads remote microfrontends via iframes
  - Manages authentication state (JWT storage)
  - Handles all API calls to backend
  - Theme management (dark/light mode)
  - Protected routes based on user roles
- **Key Components**:
  - `RemoteApp`: Loads microfrontends via iframes
  - `AuthContext`: Global authentication state
  - `ThemeContext`: Theme management
  - `ProtectedRoute`: Route guards
- **API Integration**: Centralized API service layer

#### 2. **Auth Microfrontend** (Port 5002)
- **Technology**: React 18, Vite, Module Federation
- **Exposed Module**: `./AuthApp`
- **Purpose**: Pure UI component for authentication
- **Features**:
  - Beautiful login/registration UI
  - Smart Academy branding
  - No direct API calls (uses postMessage)
  - Form validation
- **Communication**: PostMessage events to Shell
  - `AUTH_LOGIN`: Login request
  - `AUTH_REGISTER`: Registration request

#### 3. **Dashboard Microfrontend** (Port 5003)
- **Technology**: React 18, Vite, Module Federation
- **Exposed Module**: `./DashboardApp`
- **Purpose**: Teacher and student dashboards
- **Features**:
  - Role-based dashboard views
  - Statistics and analytics
  - Navigation components
- **Communication**: PostMessage with Shell for data fetching

#### 4. **Courses Microfrontend** (Port 5004)
- **Technology**: React 18, Vite, Module Federation
- **Exposed Module**: `./CoursesApp`
- **Purpose**: Course management interface
- **Features**:
  - Course listing and creation
  - Module and lesson management
  - Quiz creation and management
  - Teacher/student views
- **Communication**: PostMessage events
  - `FETCH_TEACHER_COURSES`: Request courses
  - `CREATE_COURSE`: Create new course
  - `UPDATE_COURSE`: Update course

### Communication Pattern

```
┌─────────────────┐
│  Shell (5001)   │ ← Host Application
│  - Routing      │
│  - Auth State   │
│  - API Calls    │
└────────┬────────┘
         │
         ├─── iframe ───→ Auth (5002) [PostMessage]
         ├─── iframe ───→ Dashboard (5003) [PostMessage]
         └─── iframe ───→ Courses (5004) [PostMessage]
```

**PostMessage Flow**:
1. Microfrontend sends event via `window.parent.postMessage()`
2. Shell listens via `window.addEventListener('message')`
3. Shell makes API call to Gateway
4. Shell responds back to microfrontend via iframe postMessage

---

## 🔐 Security Architecture

### Authentication Flow

1. **User Registration/Login**:
   ```
   Client → Shell → Gateway (8888) → User-Management (8082)
   Response: JWT Access Token + Refresh Token
   ```

2. **Token Storage**:
   - JWT stored in cookies or localStorage
   - Refresh token stored securely

3. **JWT Validation** (Shared Across All Services):
   - **Secret**: `404E635266556A586E3272357538782F413F4428472B4B6250645367566B5970`
   - **Algorithm**: HS256
   - **Claims**: `sub` (user ID), `roles` (array), `exp` (expiration)
   - **Expiration**: 24 hours (access), 7 days (refresh)

### Authorization

- **Role-Based Access Control (RBAC)**:
  - Roles: `STUDENT`, `TEACHER`, `ADMIN`
  - Role extraction from JWT claims
  - Spring Security `@PreAuthorize` annotations (Java services)
  - FastAPI dependency injection for Python services

### Service-to-Service Authentication

- **JWT Pass-through**: Gateway forwards JWT to microservices
- **Shared Secret**: All services validate using same secret
- **No Service Mesh**: Direct communication with JWT validation

---

## 📊 Data Flow and Workflows

### Workflow 1: User Authentication
```
1. User fills login form in Auth microfrontend
2. Auth sends AUTH_LOGIN postMessage to Shell
3. Shell calls: POST /user-management-service/api/v1/auth/login
4. User-Management validates credentials
5. User-Management generates JWT tokens
6. Shell stores tokens and updates AuthContext
7. Shell redirects to dashboard
```

### Workflow 2: Course Creation (Teacher)
```
1. Teacher creates course in Courses microfrontend
2. Courses sends CREATE_COURSE postMessage to Shell
3. Shell calls: POST /course-service/courses
   Headers: Authorization: Bearer <JWT>
4. Gateway routes to Course-Management service
5. Course-Management validates JWT and role (TEACHER)
6. Course-Management creates course in database
7. Shell sends course data back to Courses microfrontend
```

### Workflow 3: Student Risk Prediction
```
1. Teacher requests student risk analysis
2. Dashboard sends PREDICT_RISK postMessage to Shell
3. Shell calls: GET /pathpredictor-service/predict-risk/{student_id}
   Headers: Authorization: Bearer <JWT>
4. PathPredictor:
   a. Validates JWT
   b. Fetches student data from PrepaData
   c. Loads XGBoost model (via MLflow)
   d. Generates prediction
5. Response: Risk level, success probability, alerts
```

### Workflow 4: LMS Data Synchronization
```
1. Teacher triggers Moodle sync from Dashboard
2. Dashboard sends SYNC_COURSE postMessage to Shell
3. Shell calls: POST /lmsconnector/ingestion/sync-course-students/{courseId}
4. LMS Connector:
   a. Authenticates with Moodle (OAuth2)
   b. Fetches enrolled users from Moodle API
   c. Stores raw data in RowData table
   d. Normalizes and stores in Student table
   e. Creates Enrollment records
5. Response: Sync status and student count
```

### Workflow 5: Personalized Recommendations
```
1. Student views recommendations
2. Dashboard sends RECOMMEND postMessage to Shell
3. Shell calls: GET /recobuilder-service/recommend/{student_id}
4. RecoBuilder:
   a. Fetches student profile from StudentProfiler
   b. Fetches engagement gaps from PrepaData
   c. Uses BERT embeddings to match content
   d. Ranks recommendations using Faiss
5. Response: List of recommended resources
```

---

## 🗄️ Database Architecture

### Database Per Service Pattern

1. **User-Management DB** (PostgreSQL:5435)
   - `user` table
   - `role` table
   - `refresh_token` table
   - Flyway migrations

2. **Course-Management DB** (PostgreSQL)
   - `course`, `module`, `lesson` tables
   - `lesson_content` table
   - `quiz`, `question` tables
   - `quiz_attempt`, `student_answer` tables
   - Flyway migrations

3. **LMS Connector DB** (PostgreSQL:5432)
   - `row_data` table (JSONB for raw Moodle data)
   - `student` table (normalized)
   - `enrollment` table
   - TypeORM entities

### Data Consistency

- **No Distributed Transactions**: Each service manages its own database
- **Eventual Consistency**: Services communicate via HTTP/REST
- **Audit Trail**: Raw data stored in LMS Connector for traceability

---

## 🚀 Deployment and Infrastructure

### Development Setup

**Start Scripts**:
- `start_all_services.sh` (Linux/Mac) - Starts all services
- `start_all_services.bat` (Windows) - Starts all services

**Service Startup Order**:
1. Eureka Server (15s wait)
2. User-Management + Course-Management (10s wait)
3. Gateway
4. Python AI Services (parallel)
5. NestJS LMS Connector (manual)

### Containerization

**Frontend**:
- Docker Compose for microfrontends
- Each microfrontend has Dockerfile
- Network: `microfrontend-network`

**Backend**:
- Java services: Maven builds
- Python services: Requirements.txt
- NestJS service: npm/yarn

### Service Discovery

- **Eureka Client Libraries**:
  - Java: Spring Cloud Netflix Eureka
  - Python: `py-eureka-client`
  - Node.js: `eureka-js-client`

---

## 🔄 Inter-Service Communication

### Synchronous Communication (REST)

- **Protocol**: HTTP/HTTPS
- **Format**: JSON
- **Routing**: Via API Gateway
- **Service Discovery**: Eureka-based routing

### Communication Patterns

1. **Request-Response**: All client-to-service calls
2. **Service-to-Service**: Direct HTTP calls (via Gateway or service discovery)
3. **No Message Queue**: Currently synchronous only (RabbitMQ planned)

---

## 📦 Technology Stack Summary

### Backend
- **Java**: Spring Boot 3.2.5, Spring Security, Spring Cloud Gateway
- **Node.js**: NestJS 11, TypeORM, Passport JWT
- **Python**: FastAPI, Uvicorn, Pandas, XGBoost, Scikit-learn
- **Databases**: PostgreSQL
- **Service Discovery**: Netflix Eureka

### Frontend
- **Framework**: React 18.2
- **Language**: TypeScript
- **Build Tool**: Vite 5.0
- **Module Federation**: @originjs/vite-plugin-federation
- **Routing**: React Router 7
- **Styling**: TailwindCSS 3.4
- **HTTP Client**: Axios 1.13

### DevOps & Tools
- **Containerization**: Docker, Docker Compose
- **Database Migrations**: Flyway (Java)
- **API Documentation**: Swagger/OpenAPI (SpringDoc)
- **Authentication**: JWT (JJWT for Java, python-jose for Python)

---

## 📈 Scalability Considerations

### Current Architecture Strengths
- ✅ Independent service scaling
- ✅ Database per service isolation
- ✅ Stateless services (except databases)
- ✅ Service discovery enables load balancing
- ✅ Microfrontend independence

### Potential Improvements
- ⚠️ Add message queue (RabbitMQ/Kafka) for async processing
- ⚠️ Implement API rate limiting
- ⚠️ Add distributed tracing (Zipkin/Jaeger)
- ⚠️ Implement circuit breakers (Resilience4j)
- ⚠️ Add centralized logging (ELK stack)
- ⚠️ Implement caching layer (Redis)

---

## 🔍 Key Architectural Decisions

1. **Microservices over Monolith**: 
   - Enables independent scaling
   - Technology diversity (Java, Python, Node.js)
   - Team autonomy

2. **API Gateway Pattern**:
   - Single entry point
   - Centralized CORS
   - Service discovery integration

3. **Database Per Service**:
   - Data isolation
   - Independent schema evolution
   - No tight coupling

4. **JWT for Authentication**:
   - Stateless authentication
   - Cross-service validation
   - No session storage needed

5. **Module Federation for Frontend**:
   - Independent deployment
   - Team autonomy
   - Code sharing via shared dependencies

6. **Eureka for Service Discovery**:
   - Dynamic service registration
   - Load balancing support
   - Health checks

---

## 📝 File Structure Overview

```
smart-academy-org/
├── clients/
│   └── microfrontends/
│       ├── shell/          # Host application
│       ├── auth/           # Auth microfrontend
│       ├── dashboard/      # Dashboard microfrontend
│       ├── courses/        # Courses microfrontend
│       └── docker-compose.yml
├── servers/
│   ├── Eureka-Server/      # Service discovery
│   ├── GateWay/            # API Gateway
│   ├── User-Management/    # User & auth service
│   ├── Cour-Management/    # Course management service
│   ├── lmsconnector/       # LMS integration (NestJS)
│   ├── PrepaData/          # Data preprocessing (Python)
│   ├── StudentProfiler/    # Student profiling (Python)
│   ├── PathPredictor/      # Risk prediction (Python)
│   ├── RecoBuilder/        # Recommendations (Python)
│   └── start_all_services.sh
├── docs/                   # Documentation
└── README.md
```

---

## ✅ Conclusion

The Smart Academy Platform demonstrates a well-architected microservices system with:
- **Clear separation of concerns** between services
- **Technology diversity** enabling best-fit solutions
- **Modern frontend architecture** with microfrontends
- **Scalable backend** with service discovery
- **AI/ML integration** for intelligent features
- **Security-first approach** with JWT authentication

The architecture supports independent development, deployment, and scaling while maintaining a cohesive user experience through the Shell application and API Gateway.

---

**Generated**: $(date)
**Analysis Date**: 2024

