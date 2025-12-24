# 🚀 How to Run Smart Academy Platform

## TL;DR - Fastest Way to Run

### Windows (PowerShell)
```powershell
cd d:\smart-academy-org\servers
.\quick-start.ps1
```

### Linux/Mac (Bash)
```bash
cd /path/to/smart-academy-org/servers
chmod +x *.sh
./quick-start.sh
```

That's it! The script will guide you through the setup.

---

## What Gets Started

### Infrastructure (Always Required)
- ✅ **3 PostgreSQL Databases** (ports 5432, 5433, 5434)
- ✅ **MinIO Object Storage** (ports 9000, 9001)
- ✅ **RabbitMQ Message Broker** (ports 5672, 15672)

### Microservices (Depends on Mode)
- ✅ **Eureka Server** - Service Discovery (8761)
- ✅ **Gateway** - API Gateway (8888)
- ✅ **User Management** - Auth & Users (8082)
- ✅ **Course Management** - Courses (8081)
- ✅ **LMS Connector** - Moodle Integration (3000)
- ✅ **Chatbot-edu** - RAG Chatbot (8005)

### AI Services (Run Separately)
- ⚠️ **PrepaData** (8001)
- ⚠️ **StudentProfiler** (8002)
- ⚠️ **PathPredictor** (8003)
- ⚠️ **RecoBuilder** (8004)

> [!NOTE]
> AI Services are NOT in Docker Compose and must be run manually using Python scripts.

---

## Step-by-Step Manual Deployment

### 1️⃣ Start Infrastructure + Services (Docker)

```bash
cd d:\smart-academy-org\servers
docker-compose up -d
```

**What this does:**
- Starts all PostgreSQL databases
- Starts MinIO and RabbitMQ
- Builds and starts Java services (Eureka, Gateway, User Mgmt, Course Mgmt)
- Builds and starts LMS Connector (NestJS)
- Builds and starts Chatbot-edu (Python)

**Wait time:** 2-3 minutes for all containers to be healthy.

### 2️⃣ Verify Services Are Running

#### Check Docker Status
```bash
docker-compose ps
```

All services should show "Up" status.

#### Run Health Check
```bash
# Windows
.\health-check.ps1

# Linux/Mac
./health-check.sh
```

#### Check Eureka Dashboard
Open browser: http://localhost:8761

You should see services registered:
- GATEWAY-SERVICE
- USER-MANAGEMENT-SERVICE
- COURSE-SERVICE
- LMS-CONNECTOR
- CHATBOT-EDU-SERVICE

### 3️⃣ Access Service Dashboards

| Service | URL | Credentials |
|---------|-----|-------------|
| Eureka Dashboard | http://localhost:8761 | None |
| API Gateway | http://localhost:8888 | None |
| User Management API | http://localhost:8082/swagger-ui.html | None |
| Course Management API | http://localhost:8081/swagger-ui.html | None |
| MinIO Console | http://localhost:9001 | minioadmin/minioadmin |
| RabbitMQ Management | http://localhost:15672 | admin/admin123 |
| Chatbot API | http://localhost:8005/docs | None |

### 4️⃣ Run AI Services (Optional)

AI services run separately:

```bash
cd d:\smart-academy-org\servers\AI-services

# Create virtual environment (first time only)
python -m venv venv

# Activate virtual environment
venv\Scripts\activate    # Windows
# source venv/bin/activate  # Linux/Mac

# Install dependencies
pip install -r requirements.txt

# Run the pipeline
python run_pipeline.py
```

**What this does:**
- Runs PrepaData, StudentProfiler, PathPredictor, RecoBuilder
- Processes student data
- Generates predictions and recommendations
- Creates outputs in `outputs/` folder

---

## Development Mode (Infrastructure Only)

If you want to run services locally for debugging:

### 1️⃣ Start Infrastructure
```bash
docker-compose -f docker-compose.infrastructure.yml up -d
```

This starts ONLY databases, MinIO, and RabbitMQ.

### 2️⃣ Run Each Service Manually

**Eureka Server:**
```bash
cd Eureka-Server
mvn spring-boot:run
```
Wait for: "Started EurekaServerApplication"

**Gateway:**
```bash
cd GateWay
mvn spring-boot:run
```
Wait for: "Started GatewayApplication"

**User Management:**
```bash
cd User-Management
mvn spring-boot:run
```

**Course Management:**
```bash
cd Cour-Management
mvn spring-boot:run
```

**LMS Connector:**
```bash
cd lmsconnector
npm install
npm run start:dev
```

**Chatbot:**
```bash
cd Chatbot-edu
pip install -r requirements.txt
python main.py
```

---

## Testing Your Deployment

### Test 1: Register a User

```bash
curl -X POST http://localhost:8888/user-management-service/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "student@test.com",
    "password": "Password123!",
    "firstName": "John",
    "lastName": "Doe",
    "role": "STUDENT"
  }'
```

**Expected Response:** `201 Created` with user details

### Test 2: Login

```bash
curl -X POST http://localhost:8888/user-management-service/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "student@test.com",
    "password": "Password123!"
  }'
```

**Expected Response:** JWT token and refresh token

**Save the token** for authenticated requests.

### Test 3: Access Protected Endpoint

```bash
curl -X GET http://localhost:8888/course-service/api/courses \
  -H "Authorization: Bearer YOUR_JWT_TOKEN_HERE"
```

**Expected Response:** List of courses (empty array if no courses created yet)

### Test 4: Test Chatbot

```bash
curl -X POST http://localhost:8005/ask \
  -H "Content-Type: application/json" \
  -d '{
    "question": "What is machine learning?",
    "course_id": "CS101"
  }'
```

**Expected Response:** AI-generated answer

---

## Stopping Services

### Stop Docker Services
```bash
docker-compose down
```

### Stop and Remove All Data (Reset)
```bash
docker-compose down -v
```
⚠️ This deletes all data including databases!

### Stop Individual Local Services
Press `Ctrl+C` in each terminal running a service.

---

## Environment Configuration

### Required: Copy and Configure .env

```bash
cd d:\smart-academy-org\servers
copy .env.example .env
```

Edit `.env` and set:

```env
# REQUIRED: OpenAI API Key (for Chatbot and AI Services)
OPENAI_API_KEY=sk-your-actual-openai-key

# OPTIONAL: Email configuration (for User Management password reset)
SPRING_MAIL_USERNAME=your-email@gmail.com
SPRING_MAIL_PASSWORD=your-gmail-app-password
```

### Using .env with Docker Compose

Docker Compose automatically reads `.env` file. No extra steps needed.

---

## Common Issues & Solutions

### Issue 1: Port Already in Use

**Error:** "Port 8080 is already in use"

**Solution:**
```bash
# Windows
netstat -ano | findstr :8080
taskkill /PID <PID> /F

# Linux/Mac
lsof -ti:8080 | xargs kill -9
```

### Issue 2: Services Not Registering with Eureka

**Symptoms:** Service starts but doesn't appear on http://localhost:8761

**Solutions:**
1. Wait 1-2 minutes (registration takes time)
2. Check service logs: `docker logs <container-name>`
3. Verify Eureka URL in service config
4. Restart the service

### Issue 3: Database Connection Failed

**Error:** "Connection refused to localhost:5432"

**Solutions:**
1. Check Docker containers: `docker ps`
2. Check database logs: `docker logs user-management-db`
3. Wait 30 seconds after starting Docker (databases need time to initialize)

### Issue 4: Out of Memory (Java)

**Error:** `OutOfMemoryError: Java heap space`

**Solution:**
```bash
# Increase Maven heap size
export MAVEN_OPTS="-Xmx2g"
mvn spring-boot:run
```

### Issue 5: Docker Build Failed

**Error:** "failed to solve with frontend dockerfile.v0"

**Solutions:**
1. Update Docker Desktop to latest version
2. Enable BuildKit: `export DOCKER_BUILDKIT=1`
3. Clear Docker cache: `docker system prune -a`

---

## Service Startup Order (Important!)

Services must start in this order:

1. **Infrastructure** (PostgreSQL, MinIO, RabbitMQ) → Wait 30s
2. **Eureka Server** → Wait until "Started"
3. **Gateway** → Wait 10s
4. **Business Services** (User, Course, LMS) → Can start in parallel
5. **AI Services & Chatbot** → After business services registered

Docker Compose handles this automatically with `depends_on` and health checks.

---

## Next Steps After Deployment

1. ✅ **Create Test Data**
   - Use Swagger UI to create courses, modules, lessons
   - Register multiple test users

2. ✅ **Configure Moodle Integration**
   - Set up Moodle instance
   - Configure LMS Connector with Moodle URL and credentials

3. ✅ **Upload Course Materials**
   - Upload PDFs to MinIO (http://localhost:9001)
   - Bucket name: `course-materials`
   - Run chatbot ingestion

4. ✅ **Process Student Data**
   - Run AI pipeline to generate profiles and predictions
   - Check outputs in `AI-services/outputs/`

5. ✅ **Connect Frontend**
   - Deploy Teacher Console (React)
   - Deploy Mobile App (Flutter)
   - Configure API Gateway URL

---

## Quick Reference

### All Service URLs

```
Eureka:           http://localhost:8761
Gateway:          http://localhost:8888
User Mgmt:        http://localhost:8082/swagger-ui.html
Course Mgmt:      http://localhost:8081/swagger-ui.html
LMS Connector:    http://localhost:3000
Chatbot:          http://localhost:8005/docs
MinIO:            http://localhost:9001
RabbitMQ:         http://localhost:15672
AI Services:      http://localhost:8001-8004
```

### Essential Commands

```bash
# Start everything
docker-compose up -d

# Stop everything
docker-compose down

# Check status
docker-compose ps

# Health check
.\health-check.ps1  # or ./health-check.sh

# View logs
docker-compose logs -f <service-name>

# Rebuild service
docker-compose up -d --build <service-name>
```

---

## Documentation Files

- **QUICK-START.md** ← You are here
- **deployment-guide.md** - Detailed deployment options
- **servers-analysis.md** - Complete architecture analysis
- **.env.example** - Environment variables template

---

**🎉 Your Smart Academy platform is running! Enjoy coding! 🚀**
