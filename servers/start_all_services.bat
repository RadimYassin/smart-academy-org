@echo off
echo ========================================================
echo Starting Smart Academy Microservices Architecture
echo ========================================================

echo 1. Starting Eureka Server (Port 8761)...
start "Eureka Server" cmd /k "cd Eureka-Server && mvn spring-boot:run"
timeout /t 15

echo 2. Starting Core Services...
start "User Management (8082)" cmd /k "cd User-Management && mvn spring-boot:run"
start "Course Management (8081)" cmd /k "cd Cour-Management && mvn spring-boot:run"
timeout /t 10

echo 3. Starting Gateway Service (Port 8888)...
start "Gateway Service" cmd /k "cd GateWay && mvn spring-boot:run"

echo 4. Starting Python AI Services...
call run_python_services.bat

echo ========================================================
echo All services are starting up!
echo Monitor the separate windows for logs.
echo ========================================================
echo Access Points:
echo - Eureka Dashboard: http://localhost:8761
echo - Gateway: http://localhost:8888
echo ========================================================
pause
