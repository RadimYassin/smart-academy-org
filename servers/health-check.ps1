# ==================================================
# Smart Academy - Health Check Script
# ==================================================

$ErrorActionPreference = "SilentlyContinue"

Write-Host "`n╔════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║     Smart Academy Platform Health Check        ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════╝`n" -ForegroundColor Cyan

$services = @(
    @{Name="Eureka Server"; Url="http://localhost:8761"; Type="Dashboard"},
    @{Name="API Gateway"; Url="http://localhost:8888"; Type="Actuator"},
    @{Name="User Management"; Url="http://localhost:8082/actuator/health"; Type="Actuator"},
    @{Name="Course Management"; Url="http://localhost:8081/actuator/health"; Type="Actuator"},
    @{Name="LMS Connector"; Url="http://localhost:3000"; Type="NestJS"},
    @{Name="Chatbot-edu"; Url="http://localhost:8005/health"; Type="FastAPI"},
    @{Name="MinIO Console"; Url="http://localhost:9001"; Type="Web"},
    @{Name="RabbitMQ Management"; Url="http://localhost:15672"; Type="Web"}
)

$upCount = 0
$downCount = 0
$totalCount = $services.Count

foreach ($service in $services) {
    Write-Host "Checking $($service.Name)... " -NoNewline
    
    try {
        $response = Invoke-WebRequest -Uri $service.Url -TimeoutSec 3 -UseBasicParsing
        if ($response.StatusCode -eq 200) {
            Write-Host "✓ UP" -ForegroundColor Green
            $upCount++
        } else {
            Write-Host "? Status: $($response.StatusCode)" -ForegroundColor Yellow
            $downCount++
        }
    } catch {
        Write-Host "✗ DOWN" -ForegroundColor Red
        $downCount++
    }
}

Write-Host "`n" -NoNewline
Write-Host "═══════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "Summary: " -NoNewline -ForegroundColor White
Write-Host "$upCount UP " -NoNewline -ForegroundColor Green
Write-Host "| " -NoNewline
Write-Host "$downCount DOWN" -ForegroundColor Red
Write-Host "═══════════════════════════════════════════════════`n" -ForegroundColor Cyan

# Check Docker containers
Write-Host "Checking Docker Containers..." -ForegroundColor Cyan
try {
    docker ps --format "table {{.Names}}\t{{.Status}}" | Select-Object -First 20
} catch {
    Write-Host "Docker not running or not installed" -ForegroundColor Yellow
}

Write-Host "`n✓ Health check complete!`n" -ForegroundColor Green
