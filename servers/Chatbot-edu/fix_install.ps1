# ========================================
# Quick Fix Script for EduBot
# Run this in PowerShell to fix dependencies
# ========================================

Write-Host "=" * 60 -ForegroundColor Cyan
Write-Host "EduBot Dependency Fix Script" -ForegroundColor Yellow
Write-Host "=" * 60 -ForegroundColor Cyan
Write-Host ""

# Step 1: Deactivate virtual environment if active
Write-Host "[1/6] Deactivating virtual environment..." -ForegroundColor Green
try {
    deactivate
} catch {
    Write-Host "  (No active venv to deactivate)" -ForegroundColor Gray
}

# Step 2: Remove old virtual environment
Write-Host "[2/6] Removing old virtual environment..." -ForegroundColor Green
if (Test-Path "venv") {
    Remove-Item -Recurse -Force "venv" -ErrorAction Stop
    Write-Host "  ✓ Old venv removed" -ForegroundColor Green
} else {
    Write-Host "  (No venv folder found)" -ForegroundColor Gray
}

# Step 3: Create fresh virtual environment
Write-Host "[3/6] Creating fresh virtual environment..." -ForegroundColor Green
python -m venv venv
if ($LASTEXITCODE -eq 0) {
    Write-Host "  ✓ Virtual environment created" -ForegroundColor Green
} else {
    Write-Host "  ✗ Failed to create venv" -ForegroundColor Red
    exit 1
}

# Step 4: Activate virtual environment
Write-Host "[4/6] Activating virtual environment..." -ForegroundColor Green
& ".\venv\Scripts\Activate.ps1"
if ($LASTEXITCODE -eq 0) {
    Write-Host "  ✓ Virtual environment activated" -ForegroundColor Green
} else {
    Write-Host "  ✗ Failed to activate venv" -ForegroundColor Red
    exit 1
}

# Step 5: Upgrade pip
Write-Host "[5/6] Upgrading pip..." -ForegroundColor Green
python -m pip install --upgrade pip
Write-Host "  ✓ Pip upgraded" -ForegroundColor Green

# Step 6: Install dependencies
Write-Host "[6/6] Installing dependencies (this may take a few minutes)..." -ForegroundColor Green
pip install -r requirements.txt
if ($LASTEXITCODE -eq 0) {
    Write-Host "  ✓ Dependencies installed successfully!" -ForegroundColor Green
} else {
    Write-Host "  ✗ Failed to install dependencies" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "=" * 60 -ForegroundColor Cyan
Write-Host "Installation Complete!" -ForegroundColor Green
Write-Host "=" * 60 -ForegroundColor Cyan
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "1. Create your .env file: copy .env.example .env" -ForegroundColor White
Write-Host "2. Edit .env and add your OpenAI API key" -ForegroundColor White
Write-Host "3. Run the application: python main.py" -ForegroundColor White
Write-Host ""
