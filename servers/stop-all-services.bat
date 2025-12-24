@echo off
REM ============================================================================
REM Smart Academy - Stop All Services
REM ============================================================================

echo ========================================================================
echo  Stopping All Services
echo ========================================================================

echo.
echo [1/2] Stopping Docker containers...
cd /d "%~dp0"
docker-compose down

echo.
echo [2/2] Stopping local services...
echo Please manually close all service windows (Eureka, Gateway, User Mgmt, Course Mgmt, LMS, Chatbot, AI Services)
echo Or press Ctrl+C in each terminal window.

echo.
echo ========================================================================
echo  Infrastructure stopped. Close service windows manually.
echo ========================================================================
pause
