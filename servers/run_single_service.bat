@echo off
setlocal
:: Clear SSL variables that might cause issues
set SSL_CERT_FILE=
set REQUESTS_CA_BUNDLE=
set CURL_CA_BUNDLE=

echo Starting %1...
echo Cleared SSL_CERT_FILE and REQUESTS_CA_BUNDLE
cd %1

:: Install dependencies with trusted host to avoid SSL verification issues
echo Installing dependencies...
pip install --trusted-host pypi.org --trusted-host pypi.python.org --trusted-host files.pythonhosted.org -r requirements.txt

:: Run the application
echo Starting application...
python main.py
endlocal
pause
