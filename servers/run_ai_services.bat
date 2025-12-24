@echo off
REM ============================================================================
REM Smart Academy - Start AI Services Locally (Windows)
REM Runs AI services without Docker to avoid long build times
REM ============================================================================

echo ========================================================================
echo  Starting AI Services Locally
echo ========================================================================

REM Check if Python is installed
python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: Python is not installed. Please install Python 3.8+
    pause
    exit /b 1
)

cd AI-services

REM Create virtual environment if it doesn't exist
if not exist "venv" (
    echo Creating Python virtual environment...
    python -m venv venv
)

REM Activate virtual environment
call venv\Scripts\activate

REM Install dependencies (only core ML libs, skip MLflow/Airflow for faster install)
echo.
echo Installing Python dependencies (this may take a few minutes)...
pip install pandas numpy scikit-learn xgboost matplotlib seaborn faiss-cpu openai python-dotenv
pip install fastapi uvicorn pydantic requests
pip install sqlalchemy psycopg2-binary

REM Start each AI service in a new window
echo.
echo Starting AI Services...

set EUREKA_SERVER_URL=http://localhost:8761/eureka

echo [1/4] Starting PrepaData Service (Port 8001)...
start "PrepaData Service" cmd /k "cd prepadata && set SERVICE_PORT=8001 && set EUREKA_SERVER_URL=%EUREKA_SERVER_URL% && python main_prepadata.py"
timeout /t 2 /nobreak >nul

echo [2/4] Starting StudentProfiler Service (Port 8002)...
start "StudentProfiler Service" cmd /k "cd profiler && set SERVICE_PORT=8002 && set EUREKA_SERVER_URL=%EUREKA_SERVER_URL% && python main_profiler.py"
timeout /t 2 /nobreak >nul

echo [3/4] Starting PathPredictor Service (Port 8003)...
start "PathPredictor Service" cmd /k "cd predictor && set SERVICE_PORT=8003 && set EUREKA_SERVER_URL=%EUREKA_SERVER_URL% && python main_predictor.py"
timeout /t 2 /nobreak >nul

echo [4/4] Starting RecoBuilder Service (Port 8004)...
start "RecoBuilder Service" cmd /k "cd recobuilder && set SERVICE_PORT=8004 && set EUREKA_SERVER_URL=%EUREKA_SERVER_URL% && set OPENAI_API_KEY=%OPENAI_API_KEY% && python main_recobuilder.py"

echo.
echo ========================================================================
echo  AI Services Starting in Separate Windows
echo ========================================================================
echo  PrepaData:         http://localhost:8001/docs
echo  StudentProfiler:   http://localhost:8002/docs
echo  PathPredictor:     http://localhost:8003/docs
echo  RecoBuilder:       http://localhost:8004/docs
echo ========================================================================
echo.
echo Wait 30 seconds then check Eureka: http://localhost:8761
echo.
pause
