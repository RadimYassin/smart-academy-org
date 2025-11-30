# Smart Academy Microservices Architecture

This repository contains the complete microservices ecosystem for the Smart Academy platform. It consists of Java Spring Boot services, a NestJS connector, and a suite of Python AI services, all orchestrated via Eureka Service Discovery and a Spring Cloud Gateway.

## 🏗️ Architecture Overview

| Service | Technology | Port | Description |
| :--- | :--- | :--- | :--- |
| **Eureka Server** | Java / Spring Boot | `8761` | Service Registry & Discovery Server. |
| **Gateway** | Java / Spring Boot | `8888` | API Gateway (Reactive) with dynamic routing. |
| **User Management** | Java / Spring Boot | `8082` | Manages users, roles, and authentication (JWT). |
| **Course Management** | Java / Spring Boot | `8081` | Manages courses, modules, lessons, and quizzes. |
| **LMS Connector** | Node.js / NestJS | `3000` | Connects to external LMS (e.g., Moodle) to ingest data. |
| **PrepaData** | Python / FastAPI | `8001` | Data preprocessing and aggregation service. |
| **StudentProfiler** | Python / FastAPI | `8002` | AI service for student profiling (Clustering). |
| **PathPredictor** | Python / FastAPI | `8003` | AI service for risk prediction (XGBoost). |
| **RecoBuilder** | Python / FastAPI | `8004` | AI service for personalized recommendations. |

---

## 🚀 Getting Started

### Prerequisites
- **Java 17+**
- **Maven 3.8+**
- **Python 3.8+**
- **Node.js 18+**
- **PostgreSQL** (running locally on default ports or configured in `application.yml`)

### ⚡ Quick Start (Run Everything)

We have provided a master script to launch the entire ecosystem in one go.

**Windows:**
```powershell
cd servers
.\start_all_services.bat
```
*This will open separate terminal windows for each service group.*

---

## 🛠️ Service Details

### 1. Core Infrastructure
- **Eureka Server**: The heart of the system. All other services register here.
  - Dashboard: [http://localhost:8761](http://localhost:8761)
- **Gateway Service**: The entry point for all client requests.
  - URL: [http://localhost:8888](http://localhost:8888)
  - Routes:
    - `/user-management-service/**` -> User Service
    - `/course-service/**` -> Course Service
    - `/lmsconnector/**` -> LMS Connector
    - `/prepadata-service/**` -> PrepaData
    - `/studentprofiler-service/**` -> StudentProfiler
    - `/pathpredictor-service/**` -> PathPredictor
    - `/recobuilder-service/**` -> RecoBuilder

### 2. Java Microservices
- **User Management**: Handles registration (`/api/v1/auth/register`) and login (`/api/v1/auth/login`).
- **Course Management**: CRUD operations for educational content. Protected by JWT.

### 3. Python AI Services
These services use **FastAPI** and **py-eureka-client**.
- **PrepaData**: Cleans and aggregates raw learning data.
- **StudentProfiler**: Uses Scikit-learn to categorize students (e.g., "Procrastinator", "Diligent").
- **PathPredictor**: Uses XGBoost to predict failure risks.
- **RecoBuilder**: Uses Transformers/Faiss to recommend learning resources.

### 4. LMS Connector (NestJS)
- Ingests data from external systems.
- Running on Port `3000`.

---

## 🧪 Testing

### Postman / Curl
You can access any service through the Gateway.

**Example: Login**
```bash
POST http://localhost:8888/user-management-service/api/v1/auth/login
Content-Type: application/json
{
  "email": "student@example.com",
  "password": "Password123!"
}
```

**Example: Get Student Profile (AI)**
```bash
GET http://localhost:8888/studentprofiler-service/profile-student/123
```

### Swagger API Docs
- **User Service**: `http://localhost:8082/swagger-ui.html`
- **Course Service**: `http://localhost:8081/swagger-ui.html`
- **Python Services**: `http://localhost:8888/[service-name]/docs` (e.g., `/prepadata-service/docs`)

---

## 🔧 Troubleshooting

- **SSL Errors in Python**: If you see SSL errors, use the provided `run_single_service.bat` or the patched `run_python_services.bat` which handles certificate issues automatically.
- **Service Not Found**: Check Eureka Dashboard to ensure the service is UP.
