# 🚀 Running All Services Locally - Quick Guide

## Prerequisites

✅ **Installed:**
- Java 17+
- Maven 3.8+
- Node.js 18+
- Python 3.8+
- Docker Desktop

## Option 1: Run ALL Services Locally (Recommended for Development)

```cmd
cd d:\smart-academy-org\servers
run-all-local.bat
```

**What it does:**
1. ✅ Starts infrastructure in Docker (PostgreSQL × 3, MinIO, RabbitMQ)
2. ✅ Starts Eureka Server (Maven)
3. ✅ Starts Gateway (Maven)
4. ✅ Starts User Management (Maven)
5. ✅ Starts Course Management (Maven)
6. ✅ Starts LMS Connector (npm)
7. ✅ Starts Chatbot-edu (Python)
8. ✅ Starts AI Services (Python × 4)

**Total: 12+ services in separate windows**

### Services Will Open In:
- Separate CMD windows for each service
- Easy to debug with direct console output
- Hot reload enabled for development

### Wait Time:
- Infrastructure: 20 seconds
- Services startup: ~2 minutes total
- Full system ready: ~3 minutes

---

## Option 2: Hybrid (Docker + Some Local Services)

```cmd
# Start infrastructure + core services in Docker
docker-compose up -d

# Run AI services locally for development
run_ai_services.bat
```

---

## Option 3: Full Docker (Production-like)

```cmd
docker-compose up -d --build
```

**Note:** AI services take 90+ minutes to build in Docker (heavy ML dependencies).

---

## Stopping Services

```cmd
stop-all-services.bat
```

Or manually:
1. Close all service windows (press Ctrl+C in each)
2. Stop Docker: `docker-compose down`

---

## Verify Everything is Running

### 1. Check Eureka Dashboard
```
http://localhost:8761
```

All services should appear within 2 minutes.

### 2. Test Gateway
```bash
curl http://localhost:8888/actuator/health
```

### 3. Check Individual Services
- User Management: http://localhost:8082/swagger-ui.html
- Course Management: http://localhost:8081/swagger-ui.html
- AI Services: http://localhost:8001-8004/docs

---

## Troubleshooting

### Port Already in Use
```bash
# Windows
netstat -ano | findstr :8080
taskkill /PID <PID> /F
```

### Service Won't Start
1. Check Java version: `java -version` (need 17+)
2. Check Maven: `mvn -version`
3. Check Node: `node -version`
4. Check Python: `python --version`

### Database Connection Failed
```bash
docker ps  # Check all DBs are running and healthy
```

---

## Development Workflow

### Making Changes:

**Java Services (Spring Boot):**
- Code changes → Maven automatically recompiles
- Restart service window if needed

**AI Services (FastAPI):**
- Code changes → Uvicorn auto-reloads (hot reload enabled)
- No restart needed!

**LMS Connector (NestJS):**
- Use `npm run start:dev` for hot reload
- Code changes apply automatically

---

## Service URLs Reference

| Service | URL | Port |
|---------|-----|------|
| Eureka | http://localhost:8761 | 8761 |
| Gateway | http://localhost:8888 | 8888 |
| User Mgmt | http://localhost:8082 | 8082 |
| Course Mgmt | http://localhost:8081 | 8081 |
| LMS Connector | http://localhost:3000 | 3000 |
| Chatbot | http://localhost:8005 | 8005 |
| PrepaData | http://localhost:8001 | 8001 |
| StudentProfiler | http://localhost:8002 | 8002 |
| PathPredictor | http://localhost:8003 | 8003 |
| RecoBuilder | http://localhost:8004 | 8004 |
| MinIO | http://localhost:9001 | 9001 |
| RabbitMQ | http://localhost:15672 | 15672 |

---

## Next Steps

1. ✅ Run `run-all-local.bat`
2. ⏱️ Wait 3 minutes
3. 🌐 Open http://localhost:8761
4. ✅ Verify all services registered
5. 🧪 Start testing APIs!

---

**Happy Coding! 🚀**
