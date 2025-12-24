# ==================================================
# Smart Academy - Quick Start Script
# Starts all services in the correct order
# ==================================================

Write-Host "`n╔════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║      Smart Academy Quick Start Script          ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════╝`n" -ForegroundColor Cyan

# Check prerequisites
Write-Host "Checking prerequisites..." -ForegroundColor Yellow

$prerequisites = @(
    @{Name="Docker"; Command="docker --version"},
    @{Name="Java"; Command="java -version"},
    @{Name="Maven"; Command="mvn -version"},
    @{Name="Node.js"; Command="node -v"},
    @{Name="Python"; Command="python --version"}
)

$missingPrereqs = @()

foreach ($prereq in $prerequisites) {
    try {
        $null = Invoke-Expression $prereq.Command 2>&1
        Write-Host "  ✓ $($prereq.Name) installed" -ForegroundColor Green
    } catch {
        Write-Host "  ✗ $($prereq.Name) NOT found" -ForegroundColor Red
        $missingPrereqs += $prereq.Name
    }
}

if ($missingPrereqs.Count -gt 0) {
    Write-Host "`n⚠ Missing prerequisites: $($missingPrereqs -join ', ')" -ForegroundColor Red
    Write-Host "Please install missing tools before continuing.`n" -ForegroundColor Yellow
    exit 1
}

Write-Host "`n✓ All prerequisites met!`n" -ForegroundColor Green

# Ask user for deployment mode
Write-Host "Choose deployment mode:" -ForegroundColor Cyan
Write-Host "  1. Docker Only (Recommended - Fast)" -ForegroundColor White
Write-Host "  2. Infrastructure Only (Development)" -ForegroundColor White
Write-Host "  3. Full Docker Compose" -ForegroundColor White
$mode = Read-Host "`nEnter choice (1-3)"

switch ($mode) {
    "1" {
        Write-Host "`n🚀 Starting infrastructure with Docker..." -ForegroundColor Cyan
        docker-compose -f docker-compose.infrastructure.yml up -d
        
        Write-Host "`n⏳ Waiting 30 seconds for databases to start..." -ForegroundColor Yellow
        Start-Sleep -Seconds 30
        
        Write-Host "`n✓ Infrastructure started!`n" -ForegroundColor Green
        Write-Host "Run services manually:" -ForegroundColor Cyan
        Write-Host "  - Eureka: cd Eureka-Server && mvn spring-boot:run" -ForegroundColor White
        Write-Host "  - Gateway: cd GateWay && mvn spring-boot:run" -ForegroundColor White
        Write-Host "  - User Mgmt: cd User-Management && mvn spring-boot:run" -ForegroundColor White
        Write-Host "  - Course Mgmt: cd Cour-Management && mvn spring-boot:run" -ForegroundColor White
        Write-Host "  - LMS: cd lmsconnector && npm run start:dev" -ForegroundColor White
        Write-Host "  - Chatbot: cd Chatbot-edu && python main.py`n" -ForegroundColor White
    }
    "2" {
        Write-Host "`n🚀 Starting infrastructure only..." -ForegroundColor Cyan
        docker-compose -f docker-compose.infrastructure.yml up -d
        
        Write-Host "`n✓ Infrastructure started!" -ForegroundColor Green
        Write-Host "Services will run locally. Start them manually.`n" -ForegroundColor Yellow
    }
    "3" {
        Write-Host "`n🚀 Starting full Docker Compose..." -ForegroundColor Cyan
        docker-compose up -d
        
        Write-Host "`n⏳ Waiting for services to start..." -ForegroundColor Yellow
        Start-Sleep -Seconds 60
        
        Write-Host "`n✓ All services started!`n" -ForegroundColor Green
    }
    default {
        Write-Host "`n✗ Invalid choice. Exiting.`n" -ForegroundColor Red
        exit 1
    }
}

# Run health check
Write-Host "Running health check...`n" -ForegroundColor Cyan
powershell -File .\health-check.ps1

Write-Host "`n📊 Access services:" -ForegroundColor Cyan
Write-Host "  - Eureka: http://localhost:8761" -ForegroundColor White
Write-Host "  - Gateway: http://localhost:8888" -ForegroundColor White
Write-Host "  - MinIO Console: http://localhost:9001 (minioadmin/minioadmin)" -ForegroundColor White
Write-Host "  - RabbitMQ: http://localhost:15672 (admin/admin123)`n" -ForegroundColor White

Write-Host "✓ Smart Academy is ready!`n" -ForegroundColor Green
