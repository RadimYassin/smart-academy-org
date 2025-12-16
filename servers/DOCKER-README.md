# Docker Compose Quick Start Guide

## ✅ System Status
All services are running successfully with the following architecture:
- **8 Containers**: 3 PostgreSQL databases + 5 application services
- **Network**: `smart-academy-network` (bridge)
- **Volumes**: Persistent storage for all databases

---

## Prerequisites
- Docker Desktop installed and running
- Docker Compose v2.0+

---

## Quick Start

### 1. Build all services
```bash
cd servers
docker-compose build
```
**Build time**: ~3-5 minutes (first time)

### 2. Start all services
```bash
docker-compose up -d
```
**Startup time**: ~30-60 seconds

### 3. Verify all services are running
```bash
docker-compose ps
```
**Expected**: All services should show "Up" status

### 4. View logs
```bash
# All services (follow mode)
docker-compose logs -f

# Specific service
docker-compose logs -f eureka-server
docker-compose logs -f user-management
docker-compose logs -f course-management
docker-compose logs -f gateway
docker-compose logs -f lms-connector

# Last 50 lines
docker-compose logs --tail=50
```

### 5. Stop all services
```bash
docker-compose down
```

### 6. Stop and remove volumes (⚠️ Deletes all data)
```bash
docker-compose down -v
```

---

## Service Access

### Application URLs

| Service | URL | Description |
|---------|-----|-------------|
| **Eureka Dashboard** | http://localhost:8761 | View registered microservices |
| **Gateway** | http://localhost:8888 | API Gateway entry point |
| **User Management** | http://localhost:8082/swagger-ui.html | Auth & User API docs |
| **Course Management** | http://localhost:8081/swagger-ui.html | Course API docs |
| **LMS Connector** | http://localhost:3000 | Moodle integration service |

### Database Connections

| Database | Host | Port | Database Name | User | Password |
|----------|------|------|---------------|------|----------|
| **User DB** | localhost | 5432 | user_management_db | postgres | postgres |
| **Course DB** | localhost | 5433 | course_management_db | postgres | postgres |
| **LMS DB** | localhost | 5434 | lmsconnector_db | postgres | postgres |

---

## Configuration

### Environment Variables

Create a `.env` file in the `servers/` directory:

```bash
# JWT Configuration (REQUIRED - same across all services)
JWT_SECRET=404E635266556A586E3272357538782F413F4428472B4B6250645367566B5970
JWT_EXPIRATION=86400000
JWT_REFRESH_EXPIRATION=604800000

# Email Configuration (for User Management - OPTIONAL)
SPRING_MAIL_HOST=smtp.gmail.com
SPRING_MAIL_PORT=587
SPRING_MAIL_USERNAME=your-email@gmail.com
SPRING_MAIL_PASSWORD=your-app-password
```

> **Note**: Email configuration is only needed if you want to test email verification features. The system will work without it, but email-related features will fail.

---

## Testing the Services

### 1. Check Eureka Dashboard
Visit http://localhost:8761 and verify all services are registered:
- USER-MANAGEMENT-SERVICE
- COURSE-SERVICE
- GATEWAY-SERVICE
- LMSCONNECTOR

### 2. Test User Registration (via Gateway)
```bash
curl -X POST http://localhost:8888/user-management-service/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "Password123!",
    "firstName": "John",
    "lastName": "Doe",
    "role": "STUDENT"
  }'
```

### 3. Test Login
```bash
curl -X POST http://localhost:8888/user-management-service/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "Password123!"
  }'
```

### 4. Access Swagger UI
- User Management: http://localhost:8082/swagger-ui.html
- Course Management: http://localhost:8081/swagger-ui.html

---

## Management Commands

### View Container Status
```bash
docker-compose ps
```

### Restart a Specific Service
```bash
docker-compose restart user-management
docker-compose restart course-management
```

### Rebuild and Restart a Service
```bash
docker-compose build --no-cache user-management
docker-compose up -d user-management
```

### View Resource Usage
```bash
docker stats
```

### Access Container Shell
```bash
docker-compose exec user-management sh
docker-compose exec course-management sh
```

### Remove Stopped Containers
```bash
docker-compose rm
```

---

## Troubleshooting

### ⚠️ Email Configuration Warnings
```
WARNING: The "SPRING_MAIL_USERNAME" variable is not set. Defaulting to a blank string.
```
**Solution**: This is normal if you haven't configured email. Create a `.env` file with email credentials or ignore if not needed.

### ⚠️ Version Warning
```
WARNING: the attribute `version` is obsolete
```
**Solution**: This is a Docker Compose v2 warning and can be safely ignored. The configuration still works correctly.

### 🔴 Services Not Starting
**Check logs**:
```bash
docker-compose logs eureka-server
docker-compose logs user-management
```

**Common issues**:
- Port conflicts: Ensure ports 5432, 5433, 5434, 8761, 8888, 8081, 8082, 3000 are free
- Database not ready: Wait 10-15 seconds for databases to become healthy

### 🔴 Service Can't Connect to Database
**Check database health**:
```bash
docker-compose ps
```
Databases should show "healthy" status.

**Restart the service**:
```bash
docker-compose restart user-management
```

### 🔴 Eureka Registration Failed
**Wait for Eureka to fully start** (30-40 seconds), then:
```bash
docker-compose restart gateway
docker-compose restart user-management
docker-compose restart course-management
```

### 🔴 Out of Disk Space
```bash
# Remove unused images and containers
docker system prune -a

# Remove unused volumes
docker volume prune
```

---

## Production Considerations

> [!IMPORTANT]
> **Before deploying to production:**
> 
> 1. **Change JWT Secret**: Generate a new secret with `openssl rand -base64 32`
> 2. **Use Secrets Management**: Store credentials in AWS Secrets Manager, Azure Key Vault, or similar
> 3. **Enable HTTPS**: Configure SSL certificates
> 4. **Add Resource Limits**: Set CPU and memory limits in docker-compose.yml
> 5. **Implement Monitoring**: Add Prometheus, Grafana, or similar
> 6. **Add Health Checks**: Implement proper health endpoints
> 7. **Use Production Databases**: Replace with managed PostgreSQL (AWS RDS, Azure Database, etc.)

---

## Container Information

### Images Built
- `servers-eureka-server` - Service discovery (Java 17 Alpine)
- `servers-gateway` - API Gateway (Java 17 Alpine)
- `servers-user-management` - Auth service (Java 17 Alpine)
- `servers-course-management` - Course service (Java 17 Alpine)
- `servers-lms-connector` - LMS integration (Node 18 Alpine)

### Images Used
- `postgres:15-alpine` - PostgreSQL databases

### Network
- `servers_smart-academy-network` - Bridge network for inter-service communication

### Volumes
- `servers_user-db-data` - User database persistent storage
- `servers_course-db-data` - Course database persistent storage
- `servers_lms-db-data` - LMS database persistent storage

---

## Next Steps

1. ✅ Verify all services in Eureka: http://localhost:8761
2. ✅ Test APIs via Swagger UI
3. ⏭️ Configure email for verification features
4. ⏭️ Add Python AI services to Docker (optional)
5. ⏭️ Set up monitoring and logging

---

**Docker setup complete!** All services are containerized and running. 🎉
