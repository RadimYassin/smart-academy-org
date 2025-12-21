# User Management Microservice

This is a Spring Boot 3 microservice for User Management, featuring JWT authentication, Role-Based Access Control (RBAC), and PostgreSQL integration.

## 🚀 Quick Start (Docker)

The eas iest way to run the application is using Docker Compose, which sets up both the application and the PostgreSQL database.

### Prerequisites
- Docker and Docker Compose installed.

### Steps
1. **Build the application:**
   ```bash
   mvn clean package
   ```
   *(Note: You need Java 17 and Maven installed. If you don't have Maven, you can use the wrapper: `./mvnw clean package` on Linux/Mac or `.\mvnw.cmd clean package` on Windows)*

2. **Run with Docker Compose:**
   ```bash
   docker-compose up --build
   ```

3. **Access the API:**
   - The application will start on port `8081`.
   - **Swagger UI:** [http://localhost:8081/swagger-ui/index.html](http://localhost:8081/swagger-ui/index.html)

## 🛠️ Running Locally (Without Docker)

If you prefer to run the application locally (e.g., in IntelliJ or via command line), you need a running PostgreSQL database.

1. **Start PostgreSQL:**
   Ensure you have a PostgreSQL database running on `localhost:5432` with:
   - Database: `user_management`
   - Username: `postgres`
   - Password: `postgres`

   *(Or update `src/main/resources/application.yml` with your credentials)*

2. **Run the Application:**
   ```bash
   mvn spring-boot:run
   ```

## 🧪 Running Tests

Unit tests use an in-memory H2 database, so no external database is required.

```bash
mvn test
```

## 📚 API Documentation

Once running, explore the API via Swagger UI:
[http://localhost:8081/swagger-ui/index.html](http://localhost:8081/swagger-ui/index.html)

### Key Endpoints
- **POST** `/api/v1/auth/register` - Register a new user
- **POST** `/api/v1/auth/login` - Login to get Access & Refresh tokens
- **POST** `/api/v1/auth/refresh-token` - Refresh an expired access token
- **GET** `/api/v1/users` - List all users (Requires ADMIN role)
