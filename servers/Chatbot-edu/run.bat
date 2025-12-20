@echo off
REM ============================================
REM Script de démarrage pour Chatbot-edu (Windows)
REM ============================================

setlocal enabledelayedexpansion

REM Configuration
set SCRIPT_DIR=%~dp0
set VENV_DIR=%SCRIPT_DIR%venv
set PORT=%SERVICE_PORT%
if "%PORT%"=="" set PORT=8005
set HOST=%SERVICE_HOST%
if "%HOST%"=="" set HOST=0.0.0.0
set EUREKA_SERVER=%EUREKA_SERVER_URL%
if "%EUREKA_SERVER%"=="" set EUREKA_SERVER=http://localhost:8761/eureka

echo ========================================
echo   Chatbot-edu - Script de demarrage
echo ========================================
echo.

REM Vérifier si Python est installé
python --version >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Python n'est pas installe. Veuillez l'installer d'abord.
    exit /b 1
)

echo [INFO] Python version:
python --version

REM Vérifier si l'environnement virtuel existe
if not exist "%VENV_DIR%" (
    echo [WARNING] Environnement virtuel non trouve. Creation en cours...
    python -m venv "%VENV_DIR%"
    echo [SUCCESS] Environnement virtuel cree
)

REM Activer l'environnement virtuel
echo [INFO] Activation de l'environnement virtuel...
call "%VENV_DIR%\Scripts\activate.bat"

REM Vérifier si les dépendances sont installées
if not exist "%VENV_DIR%\Scripts\uvicorn.exe" (
    echo [WARNING] Dependances non installees. Installation en cours...
    echo [INFO] Installation des dependances depuis requirements.txt...
    python -m pip install --upgrade pip
    pip install -r "%SCRIPT_DIR%requirements.txt"
    echo [SUCCESS] Dependances installees
) else (
    echo [INFO] Verification des dependances...
    python -m pip install --upgrade pip --quiet
    pip install -r "%SCRIPT_DIR%requirements.txt" --quiet
)

REM Vérifier si le fichier .env existe
if not exist "%SCRIPT_DIR%.env" (
    echo [WARNING] Fichier .env non trouve. Creation d'un fichier .env par defaut...
    (
        echo # OpenAI Configuration
        echo OPENAI_API_KEY=your_openai_api_key_here
        echo.
        echo # Service Configuration
        echo SERVICE_PORT=%PORT%
        echo SERVICE_HOST=%HOST%
        echo EUREKA_SERVER_URL=%EUREKA_SERVER%
        echo.
        echo # MinIO Configuration ^(optionnel^)
        echo MINIO_ENDPOINT=localhost:9000
        echo MINIO_ACCESS_KEY=minioadmin
        echo MINIO_SECRET_KEY=minioadmin
        echo MINIO_BUCKET_NAME=course-materials
        echo MINIO_SECURE=false
        echo.
        echo # LLM Provider ^(openai, ollama, gemini^)
        echo LLM_PROVIDER=openai
        echo.
        echo # Ollama Configuration ^(si LLM_PROVIDER=ollama^)
        echo OLLAMA_BASE_URL=http://localhost:11434
        echo OLLAMA_MODEL=llama2
        echo.
        echo # Gemini Configuration ^(si LLM_PROVIDER=gemini^)
        echo GEMINI_API_KEY=your_gemini_api_key_here
        echo GEMINI_MODEL=gemini-1.5-flash
    ) > "%SCRIPT_DIR%.env"
    echo [WARNING] Fichier .env cree. Veuillez configurer OPENAI_API_KEY avant de continuer.
    echo.
    set /p CONTINUE="Voulez-vous continuer quand meme? (y/n) "
    if /i not "%CONTINUE%"=="y" (
        echo [INFO] Arret du script.
        exit /b 0
    )
)

REM Vérifier si l'index FAISS existe
if not exist "%SCRIPT_DIR%faiss_index\index.faiss" (
    echo [WARNING] Index FAISS non trouve. Le service demarrera mais ne pourra pas repondre aux questions.
    echo [WARNING] Pour creer l'index, utilisez: POST /admin/ingest apres le demarrage
)

REM Exporter les variables d'environnement
set SERVICE_PORT=%PORT%
set SERVICE_HOST=%HOST%
set EUREKA_SERVER_URL=%EUREKA_SERVER%

REM Afficher la configuration
echo.
echo [INFO] Configuration:
echo   - Port: %PORT%
echo   - Host: %HOST%
echo   - Eureka Server: %EUREKA_SERVER%
echo   - Working Directory: %SCRIPT_DIR%
echo.

REM Démarrer le serveur
echo [SUCCESS] Demarrage du serveur Chatbot-edu...
echo.
echo ========================================
echo   Serveur demarre sur http://%HOST%:%PORT%
echo   Documentation: http://%HOST%:%PORT%/docs
echo   Health Check: http://%HOST%:%PORT%/health
echo ========================================
echo.
echo Appuyez sur Ctrl+C pour arreter le serveur
echo.

REM Lancer uvicorn
cd /d "%SCRIPT_DIR%"
uvicorn main:app --host %HOST% --port %PORT% --reload --log-level info

