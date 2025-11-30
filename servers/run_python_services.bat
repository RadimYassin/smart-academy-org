@echo off
echo Starting Python Microservices...

:: Fix for PostgreSQL SSL Certificate Error
set SSL_CERT_FILE=
set REQUESTS_CA_BUNDLE=
set CURL_CA_BUNDLE=

start "PrepaData (8001)" cmd /c "run_single_service.bat PrepaData"
start "StudentProfiler (8002)" cmd /c "run_single_service.bat StudentProfiler"
start "PathPredictor (8003)" cmd /c "run_single_service.bat PathPredictor"
start "RecoBuilder (8004)" cmd /c "run_single_service.bat RecoBuilder"

echo All services started in separate windows.
