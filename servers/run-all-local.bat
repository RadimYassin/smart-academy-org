@echo off
REM ============================================================================
REM Smart Academy - Run ALL Services Locally (Windows)
REM Infrastructure: Docker (databases only)
REM Services: Local execution for development
REM ============================================================================

echo ========================================================================
echo  Smart Academy - Starting ALL Services Locally
echo ========================================================================

REM Check Docker
docker info >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: Docker is not running. Install Docker Desktop and start it.
    pause
    exit /b 1
)

echo.
echo [1/6] Starting Infrastructure (Docker: PostgreSQL, MinIO, RabbitMQ)...
echo ========================================================================
docker-compose up -d user-db course-db lms-db minio rabbitmq

echo Waiting for infrastructure to be ready (20 seconds)...
timeout /t 20 /nobreak >nul

echo.
echo [2/6] Starting Eureka Server (Java/Spring Boot)...
echo ========================================================================
cd Eureka-Server
start "Eureka Server" cmd /k "mvn spring-boot:run"
cd ..
timeout /t 5 /nobreak >nul

echo.
echo [3/6] Starting Gateway (Java/Spring Boot)...
echo ========================================================================
cd GateWay
start "API Gateway" cmd /k "mvn spring-boot:run"
cd ..
timeout /t 5 /nobreak >nul

echo.
echo [4/6] Starting User Management (Java/Spring Boot)...
echo ========================================================================
cd User-Management
start "User Management" cmd /k "mvn spring-boot:run"
cd ..
timeout /t 3 /nobreak >nul

echo.
echo [5/6] Starting Course Management (Java/Spring Boot)...
echo ========================================================================
cd Cour-Management
start "Course Management" cmd /k "mvn spring-boot:run"
cd ..
timeout /t 3 /nobreak >nul

echo.
echo [6/6] Starting LMS Connector (Node.js/NestJS)...
echo ========================================================================
cd lmsconnector
start "LMS Connector" cmd /k "npm run start"
cd ..
timeout /t 3 /nobreak >nul

echo.
echo [7/8] Starting Chatbot-edu (Python/FastAPI)...
echo ========================================================================
cd Chatbot-edu
start "Chatbot Service" cmd /k "python main.py"
cd ..
timeout /t 3 /nobreak >nul

echo.
echo [8/8] Starting AI Services (Python/FastAPI)...
echo ========================================================================
call run_ai_services.bat

echo.
echo ========================================================================
echo  ALL SERVICES STARTED!
echo ========================================================================
echo.
echo Infrastructure (Docker):
echo   PostgreSQL User DB:    localhost:5432
echo   PostgreSQL Course DB:  localhost:5433
echo   PostgreSQL LMS DB:     localhost:5434
echo   MinIO:                 http://localhost:9001 (minioadmin/minioadmin)
echo   RabbitMQ:              http://localhost:15672 (admin/admin123)
echo.
echo Core Services (Local):
echo   Eureka Server:         http://localhost:8761
echo   API Gateway:           http://localhost:8888
echo   User Management:       http://localhost:8082/swagger-ui.html
echo   Course Management:     http://localhost:8081/swagger-ui.html
echo   LMS Connector:         http://localhost:3000
echo   Chatbot:               http://localhost:8005/docs
echo.
echo AI Services (Local):
echo   PrepaData:             http://localhost:8001/docs
echo   StudentProfiler:       http://localhost:8002/docs
echo   PathPredictor:         http://localhost:8003/docs
echo   RecoBuilder:           http://localhost:8004/docs
echo.
echo ========================================================================
echo Wait 2 minutes, then check: http://localhost:8761
echo ========================================================================
pause
