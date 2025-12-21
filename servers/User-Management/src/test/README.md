# User Management Service - Test Suite

[![Tests](https://img.shields.io/badge/tests-35%20passing-brightgreen)](.) 
[![Coverage](https://img.shields.io/badge/coverage-unit%20%7C%20integration-blue)](.)

Complete test suite for the User-Management microservice using JUnit 5, Mockito, and Spring Boot Test.

---

## 📊 Test Statistics

| Metric | Value |
|--------|-------|
| **Total Tests** | 35 |
| **Unit Tests** | 10 |
| **Integration Tests** | 24 |
| **Context Load Test** | 1 |
| **Execution Time** | ~14s |
| **Status** | ✅ All Passing |

---

## 🏗️ Test Structure

```
src/test/java/radim/ma/
├── controllers/
│   └── UserControllerTest.java          (12 tests - @WebMvcTest)
├── repositories/
│   └── UserRepositoryTest.java          (12 tests - @DataJpaTest)
├── services/
│   └── UserServiceTest.java             (4 tests - existing)
├── services/impl/
│   └── PasswordResetServiceImplTest.java (6 tests - Mockito)
└── UserManagementApplicationTests.java   (1 test - @SpringBootTest)
```

---

## 🚀 Running Tests

### Run All Tests
```bash
mvn test
```

### Run Specific Test Class
```bash
mvn test -Dtest=PasswordResetServiceImplTest
mvn test -Dtest=UserRepositoryTest
mvn test -Dtest=UserControllerTest
```

### Run Specific Test Method
```bash
mvn test -Dtest=UserRepositoryTest#findByEmail_Success
mvn test -Dtest=UserControllerTest#getAllUsers_AsAdmin_Success
```

### Run Tests with Coverage
```bash
mvn clean test jacoco:report
```
*Coverage report will be generated in `target/site/jacoco/index.html`*

### Skip Tests
```bash
mvn clean install -DskipTests
```

---

## 📝 Test Classes Overview

### 1️⃣ PasswordResetServiceImplTest
**Type:** Unit Test (Mockito)  
**Tests:** 6  
**Purpose:** Test password reset business logic in isolation

**Coverage:**
- ✅ Request password reset successfully
- ✅ Handle user not found exception
- ✅ Reset password with valid code
- ✅ Reject invalid reset code
- ✅ Reject expired reset code
- ✅ Handle null reset code

**Key Features:**
- Uses `@ExtendWith(MockitoExtension.class)`
- Mocks all dependencies (UserRepository, OTPService, EmailService, PasswordEncoder)
- Fast execution (~250ms)
- No Spring context loaded

**Example:**
```java
@Test
@DisplayName("Should successfully request password reset")
void requestPasswordReset_Success() {
    // Given
    when(userRepository.findByEmail(email)).thenReturn(Optional.of(testUser));
    when(otpService.generateOTP()).thenReturn("123456");
    
    // When
    passwordResetService.requestPasswordReset(email);
    
    // Then
    verify(emailService).sendPasswordResetEmail(email, "John", "123456");
}
```

---

### 2️⃣ UserRepositoryTest
**Type:** Integration Test (@DataJpaTest)  
**Tests:** 12  
**Purpose:** Test database operations with H2 in-memory database

**Coverage:**
- ✅ CRUD operations (save, find, delete)
- ✅ Custom query methods (`findByEmail`, `findByRole`)
- ✅ Soft delete functionality
- ✅ Restore deleted users
- ✅ JPA lifecycle callbacks (`@PrePersist`, `@PreUpdate`)
- ✅ Timestamp auditing

**Key Features:**
- Uses H2 in-memory database
- `TestEntityManager` for entity operations
- Auto-rollback after each test
- Tests real JPA/Hibernate behavior

**Example:**
```java
@Test
@DisplayName("Should save and find user by email")
void findByEmail_Success() {
    // Given
    entityManager.persistAndFlush(student);
    
    // When
    Optional<User> found = userRepository.findByEmail("student@example.com");
    
    // Then
    assertThat(found).isPresent();
    assertThat(found.get().getEmail()).isEqualTo("student@example.com");
}
```

---

### 3️⃣ UserControllerTest
**Type:** Web Layer Test (@WebMvcTest)  
**Tests:** 12  
**Purpose:** Test REST endpoints and authorization

**Coverage:**
- ✅ GET /api/v1/users (Admin only)
- ✅ GET /api/v1/users/students (Admin/Teacher)
- ✅ GET /api/v1/users/{id} (All roles)
- ✅ PUT /api/v1/users/{id} (Update user)
- ✅ DELETE /api/v1/users/{id} (Admin only)
- ✅ POST /api/v1/users/{id}/restore (Admin only)
- ✅ Authorization rules with `@PreAuthorize`

**Key Features:**
- Uses `MockMvc` for HTTP simulation
- Custom `TestSecurityConfig` for isolated security
- Tests JSON serialization/deserialization
- Verifies HTTP status codes and response bodies

**Example:**
```java
@Test
@WithMockUser(roles = "ADMIN")
@DisplayName("Should get all users when admin")
void getAllUsers_AsAdmin_Success() throws Exception {
    // Given
    when(userService.getAllUsers()).thenReturn(users);
    
    // When & Then
    mockMvc.perform(get("/api/v1/users"))
        .andExpect(status().isOk())
        .andExpect(jsonPath("$", hasSize(2)))
        .andExpect(jsonPath("$[0].email", is("student@example.com")));
}
```

---

### 4️⃣ UserManagementApplicationTests
**Type:** Context Load Test (@SpringBootTest)  
**Tests:** 1  
**Purpose:** Verify Spring application context loads correctly

**Key Features:**
- Loads full Spring Boot context
- Verifies all beans are created
- Mocks external dependencies (RabbitMQ, Email)

---

## 🎯 Testing Best Practices Used

### ✅ Test Pyramid
```
       /\      E2E Tests (1)
      /  \     
     /----\    Integration Tests (24)
    /      \   
   /--------\  Unit Tests (10)
```

### ✅ Naming Conventions
```java
// Class names
[ClassName]Test

// Method names
[methodName]_[scenario]_[expectedResult]

void requestPasswordReset_UserNotFound()
void findByEmail_Success()
void getAllUsers_AsAdmin_Success()
```

### ✅ AAA Pattern (Arrange-Act-Assert)
```java
@Test
void testExample() {
    // Given (Arrange) - Setup test data
    User user = createTestUser();
    when(repository.save(user)).thenReturn(user);
    
    // When (Act) - Execute the action
    User result = service.saveUser(user);
    
    // Then (Assert) - Verify expectations
    assertThat(result.getId()).isNotNull();
    verify(repository).save(user);
}
```

### ✅ Modern Assertions (AssertJ)
```java
// ✅ Fluent and readable
assertThat(user.getEmail()).isEqualTo("test@example.com");
assertThat(users).hasSize(2)
    .extracting(User::getRole)
    .contains(Role.STUDENT);

// ❌ Avoid old JUnit style
assertEquals("test@example.com", user.getEmail());
```

### ✅ Test Isolation
- Each test is independent
- `@BeforeEach` sets up clean state
- Database recreated for each test class
- No shared mutable state

---

## ⚙️ Test Configuration

### application-test.yml
```yaml
spring:
  datasource:
    url: jdbc:h2:mem:testdb  # In-memory database
    driver-class-name: org.h2.Driver
  
  jpa:
    hibernate:
      ddl-auto: create-drop  # Recreate schema for each test
    show-sql: true

eureka:
  client:
    enabled: false  # Disable service discovery

spring.rabbitmq.listener.simple.auto-startup: false  # Disable RabbitMQ
```

---

## 🔍 Test Types Comparison

| Aspect | Unit Test | @DataJpaTest | @WebMvcTest | @SpringBootTest |
|--------|-----------|--------------|-------------|-----------------|
| **Spring Context** | ❌ None | ⚠️ JPA only | ⚠️ Web only | ✅ Full |
| **Database** | ❌ Mocked | ✅ H2 | ❌ Mocked | ✅ H2 |
| **Speed** | ⚡⚡⚡ Fast | ⚡⚡ Medium | ⚡⚡ Medium | ⚡ Slow |
| **Use Case** | Business logic | Repositories | Controllers | Integration |
| **Example** | PasswordResetServiceImplTest | UserRepositoryTest | UserControllerTest | UserManagementApplicationTests |

---

## 📦 Dependencies

All testing dependencies are already configured in `pom.xml`:

```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-test</artifactId>
    <scope>test</scope>
</dependency>
<dependency>
    <groupId>org.springframework.security</groupId>
    <artifactId>spring-security-test</artifactId>
    <scope>test</scope>
</dependency>
<dependency>
    <groupId>com.h2database</groupId>
    <artifactId>h2</artifactId>
    <scope>test</scope>
</dependency>
```

**Includes:**
- JUnit 5 (Jupiter)
- Mockito
- AssertJ
- Hamcrest
- Spring Boot Test
- Spring Security Test

---

## 🐛 Troubleshooting

### Tests Not Running?
```bash
# Clean and rebuild
mvn clean test

# Update project
mvn clean install
```

### H2 Database Issues?
Check `application-test.yml` has correct H2 configuration:
```yaml
spring:
  datasource:
    url: jdbc:h2:mem:testdb
```

### Context Load Failures?
Ensure all required properties are set in `application-test.yml`:
```yaml
application:
  mail:
    from: test@example.com
    from-name: Test
  security:
    jwt:
      secret-key: your-secret-key
```

### Port Already in Use?
Tests use random ports. If issues persist:
```java
@SpringBootTest(webEnvironment = WebEnvironment.RANDOM_PORT)
```

---

## 📈 Next Steps

1. **Add Test Coverage Plugin**
   ```xml
   <plugin>
       <groupId>org.jacoco</groupId>
       <artifactId>jacoco-maven-plugin</artifactId>
   </plugin>
   ```

2. **Add More Controller Tests**
   - AuthController (login, register)
   - VerificationController
   - CreditController

3. **Add Integration Tests**
   - Full authentication flow
   - RabbitMQ message handling
   - Email sending verification

4. **Performance Testing**
   - JMeter scripts
   - Load testing scenarios

---

## 📚 Resources

- [Spring Boot Testing Documentation](https://docs.spring.io/spring-boot/docs/current/reference/html/features.html#features.testing)
- [JUnit 5 User Guide](https://junit.org/junit5/docs/current/user-guide/)
- [Mockito Documentation](https://javadoc.io/doc/org.mockito/mockito-core/latest/org/mockito/Mockito.html)
- [AssertJ Documentation](https://assertj.github.io/doc/)

---

## ✅ Summary

You now have a **production-ready test suite** with:
- **35 tests** covering services, repositories, and controllers
- **Multiple testing strategies** (unit, integration, web layer)
- **Best practices** from real-world Spring Boot projects
- **Fast feedback loop** (~14 seconds for full suite)

Run `mvn test` to verify your code anytime! 🚀
