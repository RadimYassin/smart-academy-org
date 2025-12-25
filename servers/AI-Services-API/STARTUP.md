# 🚀 Startup Script - Windows PowerShell

## Quick Start Commands

Run these commands in **separate PowerShell terminals** in the specified order:

### Terminal 1: Start Eureka Server (MUST BE FIRST!)
```powershell
cd "C:\Users\ROG\Desktop\project chegar\anti\anti\Eureka-Server"
mvn spring-boot:run
```
**Wait for**: "Started EurekaServerApplication" or "Application started on port 8761"

---

### Terminal 2: Start Gateway
```powershell
cd "C:\Users\ROG\Desktop\project chegar\anti\anti\GateWay"
mvn spring-boot:run
```
**Wait for**: "Started GatewayApplication" or "Application started on port 8888"

---

### Terminal 3: Start User-Management
```powershell
cd "C:\Users\ROG\Desktop\project chegar\anti\anti\User-Management"
mvn spring-boot:run
```
**Wait for**: "Started application" or "Application started on port 8082"

---

### Terminal 4: Start LMSConnector
```powershell
cd "C:\Users\ROG\Desktop\project chegar\anti\anti\lmsconnector"
npm run start:dev
```
**Wait for**: "Application is running on: http://localhost:3000"

---

### Terminal 5: Start AI-Services-API
```powershell
cd "C:\Users\ROG\Desktop\project chegar\anti\anti\AI-Services-API"
python -m app.main
```
**Wait for**: "✅ ai-services-api registered with Eureka successfully!"

---

## Verification

### 1. Check Eureka Dashboard
Open in browser: **http://localhost:8761**

You should see all services registered:
- GATEWAY-SERVICE
- USER-MANAGEMENT-SERVICE  
- AI-SERVICES-API

### 2. Test AI Services Health
```powershell
# Via Gateway
curl http://localhost:8888/ai/health

# Direct access
curl http://localhost:8083/health
```

### 3. Access Swagger UI
Open in browser: **http://localhost:8083/docs**

---

## Current Status

✅ **Dependencies installed** - All Python packages ready
✅ **AI-Services-API code** - Complete and ready
⚠️ **Eureka Server** - Needs to be started first!

## Next Steps

1. **Start Eureka Server first** (Terminal 1)
2. Wait for it to fully start
3. Then start Gateway (Terminal 2)
4. Then start other services
5. Finally start AI-Services-API (Terminal 5)

## Troubleshooting

**Error: "All eureka servers are down"**
- Solution: Make sure Eureka Server is running on port 8761
- Check: http://localhost:8761

**Error: "Address already in use: bind"**
- Solution: A service is already running on that port
- Fix: Close the existing process or use a different port

**Error: "ModuleNotFoundError: No module named 'pipeline'"**
- Solution: Make sure you're running from AI-Services-API directory
- Fix: `cd C:\Users\ROG\Desktop\project chegar\anti\anti\AI-Services-API`
