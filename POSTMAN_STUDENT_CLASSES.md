# 📚 Postman Collection - Student Classes API

This document provides Postman examples for managing student classes and adding students to classes.

## 🔐 Prerequisites

### Base URL
```
http://localhost:8888/course-service
```

### Authentication
All endpoints require **JWT Bearer Token** authentication with **TEACHER** role.

**Header Required:**
```
Authorization: Bearer <your_jwt_token>
Content-Type: application/json
```

### Getting a JWT Token

First, you need to login as a teacher to get the JWT token:

**POST** `http://localhost:8888/user-management-service/api/v1/auth/login`

**Body:**
```json
{
  "email": "teacher@example.com",
  "password": "password123"
}
```

**Response:**
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "refreshToken": "...",
  "decodedUser": {
    "id": 1,
    "email": "teacher@example.com",
    "role": "TEACHER"
  }
}
```

Copy the `token` value and use it in the `Authorization` header for all subsequent requests.

---

## 📋 API Endpoints

### 1. Create a Student Class

**Endpoint:** `POST /api/classes`

**Description:** Create a new student class/group

**Headers:**
```
Authorization: Bearer <your_jwt_token>
Content-Type: application/json
```

**Request Body:**
```json
{
  "name": "Mathematics 101 - Section A",
  "description": "Introduction to Mathematics for beginners"
}
```

**Field Validation:**
- `name`: Required, 3-255 characters
- `description`: Optional, can be null or empty

**Example Request (cURL):**
```bash
curl -X POST http://localhost:8888/course-service/api/classes \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..." \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Mathematics 101 - Section A",
    "description": "Introduction to Mathematics for beginners"
  }'
```

**Example Response (201 Created):**
```json
{
  "id": "35941a65-b931-4ed6-a22e-2c217f369079",
  "name": "Mathematics 101 - Section A",
  "description": "Introduction to Mathematics for beginners",
  "teacherId": 1,
  "studentCount": 0,
  "createdAt": "2024-01-15T10:30:00",
  "updatedAt": "2024-01-15T10:30:00"
}
```

---

### 2. Add Students to a Class

**Endpoint:** `POST /api/classes/{classId}/students`

**Description:** Add one or more students to a class

**Headers:**
```
Authorization: Bearer <your_jwt_token>
Content-Type: application/json
```

**Path Parameters:**
- `classId`: UUID of the class (from the create response)

**Request Body:**
```json
{
  "studentIds": [2, 3, 5, 8]
}
```

**Field Validation:**
- `studentIds`: Required, array of Long (student user IDs)
- Students that already exist in the class will be skipped

**Example Request (cURL):**
```bash
curl -X POST http://localhost:8888/course-service/api/classes/35941a65-b931-4ed6-a22e-2c217f369079/students \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..." \
  -H "Content-Type: application/json" \
  -d '{
    "studentIds": [2, 3, 5, 8]
  }'
```

**Example Response (204 No Content):**
```
(Empty response body)
```

---

### 3. Get All My Classes

**Endpoint:** `GET /api/classes`

**Description:** Get all classes created by the authenticated teacher

**Headers:**
```
Authorization: Bearer <your_jwt_token>
```

**Example Request (cURL):**
```bash
curl -X GET http://localhost:8888/course-service/api/classes \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
```

**Example Response (200 OK):**
```json
[
  {
    "id": "35941a65-b931-4ed6-a22e-2c217f369079",
    "name": "Mathematics 101 - Section A",
    "description": "Introduction to Mathematics for beginners",
    "teacherId": 1,
    "studentCount": 4,
    "createdAt": "2024-01-15T10:30:00",
    "updatedAt": "2024-01-15T10:30:00"
  },
  {
    "id": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
    "name": "Physics 201 - Advanced",
    "description": "Advanced Physics course",
    "teacherId": 1,
    "studentCount": 12,
    "createdAt": "2024-01-14T09:15:00",
    "updatedAt": "2024-01-14T09:15:00"
  }
]
```

---

### 4. Get Class Details

**Endpoint:** `GET /api/classes/{classId}`

**Description:** Get detailed information about a specific class

**Headers:**
```
Authorization: Bearer <your_jwt_token>
```

**Path Parameters:**
- `classId`: UUID of the class

**Example Request (cURL):**
```bash
curl -X GET http://localhost:8888/course-service/api/classes/35941a65-b931-4ed6-a22e-2c217f369079 \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
```

**Example Response (200 OK):**
```json
{
  "id": "35941a65-b931-4ed6-a22e-2c217f369079",
  "name": "Mathematics 101 - Section A",
  "description": "Introduction to Mathematics for beginners",
  "teacherId": 1,
  "studentCount": 4,
  "createdAt": "2024-01-15T10:30:00",
  "updatedAt": "2024-01-15T10:30:00"
}
```

---

### 5. Get Students in a Class

**Endpoint:** `GET /api/classes/{classId}/students`

**Description:** Get list of all students enrolled in a class

**Headers:**
```
Authorization: Bearer <your_jwt_token>
```

**Path Parameters:**
- `classId`: UUID of the class

**Example Request (cURL):**
```bash
curl -X GET http://localhost:8888/course-service/api/classes/35941a65-b931-4ed6-a22e-2c217f369079/students \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
```

**Example Response (200 OK):**
```json
[
  {
    "studentId": 2,
    "addedBy": 1,
    "addedAt": "2024-01-15T10:35:00"
  },
  {
    "studentId": 3,
    "addedBy": 1,
    "addedAt": "2024-01-15T10:35:00"
  },
  {
    "studentId": 5,
    "addedBy": 1,
    "addedAt": "2024-01-15T10:35:00"
  },
  {
    "studentId": 8,
    "addedBy": 1,
    "addedAt": "2024-01-15T10:35:00"
  }
]
```

---

### 6. Update Class

**Endpoint:** `PUT /api/classes/{classId}`

**Description:** Update class name and/or description

**Headers:**
```
Authorization: Bearer <your_jwt_token>
Content-Type: application/json
```

**Path Parameters:**
- `classId`: UUID of the class

**Request Body:**
```json
{
  "name": "Mathematics 101 - Section A (Updated)",
  "description": "Updated description for Mathematics course"
}
```

**Example Request (cURL):**
```bash
curl -X PUT http://localhost:8888/course-service/api/classes/35941a65-b931-4ed6-a22e-2c217f369079 \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..." \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Mathematics 101 - Section A (Updated)",
    "description": "Updated description for Mathematics course"
  }'
```

**Example Response (200 OK):**
```json
{
  "id": "35941a65-b931-4ed6-a22e-2c217f369079",
  "name": "Mathematics 101 - Section A (Updated)",
  "description": "Updated description for Mathematics course",
  "teacherId": 1,
  "studentCount": 4,
  "createdAt": "2024-01-15T10:30:00",
  "updatedAt": "2024-01-15T11:00:00"
}
```

---

### 7. Remove Student from Class

**Endpoint:** `DELETE /api/classes/{classId}/students/{studentId}`

**Description:** Remove a specific student from a class

**Headers:**
```
Authorization: Bearer <your_jwt_token>
```

**Path Parameters:**
- `classId`: UUID of the class
- `studentId`: Long - ID of the student user

**Example Request (cURL):**
```bash
curl -X DELETE http://localhost:8888/course-service/api/classes/35941a65-b931-4ed6-a22e-2c217f369079/students/5 \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
```

**Example Response (204 No Content):**
```
(Empty response body)
```

---

### 8. Delete Class

**Endpoint:** `DELETE /api/classes/{classId}`

**Description:** Delete a class (also removes all student associations)

**Headers:**
```
Authorization: Bearer <your_jwt_token>
```

**Path Parameters:**
- `classId`: UUID of the class

**Example Request (cURL):**
```bash
curl -X DELETE http://localhost:8888/course-service/api/classes/35941a65-b931-4ed6-a22e-2c217f369079 \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
```

**Example Response (204 No Content):**
```
(Empty response body)
```

---

## 🔄 Complete Workflow Example

### Step 1: Login as Teacher
```bash
POST http://localhost:8888/user-management-service/api/v1/auth/login
Body: {
  "email": "teacher@example.com",
  "password": "password123"
}
```

### Step 2: Create a Class
```bash
POST http://localhost:8888/course-service/api/classes
Headers: Authorization: Bearer <token_from_step1>
Body: {
  "name": "Mathematics 101",
  "description": "Basic math course"
}
```
**Save the `id` from response** (e.g., `35941a65-b931-4ed6-a22e-2c217f369079`)

### Step 3: Add Students to Class
```bash
POST http://localhost:8888/course-service/api/classes/35941a65-b931-4ed6-a22e-2c217f369079/students
Headers: Authorization: Bearer <token_from_step1>
Body: {
  "studentIds": [2, 3, 5, 8, 10]
}
```

### Step 4: Verify Students Were Added
```bash
GET http://localhost:8888/course-service/api/classes/35941a65-b931-4ed6-a22e-2c217f369079/students
Headers: Authorization: Bearer <token_from_step1>
```

---

## ⚠️ Error Responses

### 401 Unauthorized
```json
{
  "timestamp": "2024-01-15T10:30:00",
  "status": 401,
  "error": "Unauthorized",
  "message": "JWT token is missing or invalid",
  "path": "/api/classes"
}
```

### 403 Forbidden
```json
{
  "timestamp": "2024-01-15T10:30:00",
  "status": 403,
  "error": "Forbidden",
  "message": "Access denied: You do not have the required role",
  "path": "/api/classes"
}
```

### 400 Bad Request (Validation Error)
```json
{
  "timestamp": "2024-01-15T10:30:00",
  "status": 400,
  "error": "Bad Request",
  "message": "Validation failed",
  "errors": [
    {
      "field": "name",
      "message": "Name must be between 3 and 255 characters"
    }
  ],
  "path": "/api/classes"
}
```

### 404 Not Found
```json
{
  "timestamp": "2024-01-15T10:30:00",
  "status": 404,
  "error": "Not Found",
  "message": "Class not found",
  "path": "/api/classes/35941a65-b931-4ed6-a22e-2c217f369079"
}
```

### 403 Forbidden (Access Denied)
```json
{
  "timestamp": "2024-01-15T10:30:00",
  "status": 403,
  "error": "Forbidden",
  "message": "Access denied: You do not own this class",
  "path": "/api/classes/35941a65-b931-4ed6-a22e-2c217f369079"
}
```

---

## 📝 Postman Collection Variables

To use these in Postman, set up the following variables:

| Variable | Example Value | Description |
|----------|---------------|-------------|
| `base_url` | `http://localhost:8888` | Base URL of API Gateway |
| `course_service` | `/course-service` | Course service prefix |
| `user_service` | `/user-management-service` | User service prefix |
| `jwt_token` | `eyJhbGciOiJIUzI1NiIs...` | JWT token from login |

Then use in requests:
- `{{base_url}}{{course_service}}/api/classes`
- `{{base_url}}{{user_service}}/api/v1/auth/login`

---

## 🧪 Postman Collection JSON

Here's a ready-to-import Postman collection:

```json
{
  "info": {
    "name": "Student Classes API",
    "description": "API collection for managing student classes",
    "schema": "https://schema.getpostman.com/json/collection/v2.1.0/collection.json"
  },
  "variable": [
    {
      "key": "base_url",
      "value": "http://localhost:8888",
      "type": "string"
    },
    {
      "key": "course_service",
      "value": "/course-service",
      "type": "string"
    },
    {
      "key": "user_service",
      "value": "/user-management-service",
      "type": "string"
    },
    {
      "key": "jwt_token",
      "value": "",
      "type": "string"
    },
    {
      "key": "class_id",
      "value": "",
      "type": "string"
    }
  ],
  "item": [
    {
      "name": "Auth",
      "item": [
        {
          "name": "Login (Teacher)",
          "event": [
            {
              "listen": "test",
              "script": {
                "exec": [
                  "if (pm.response.code === 200) {",
                  "    var jsonData = pm.response.json();",
                  "    pm.collectionVariables.set('jwt_token', jsonData.token);",
                  "}"
                ]
              }
            }
          ],
          "request": {
            "method": "POST",
            "header": [
              {
                "key": "Content-Type",
                "value": "application/json"
              }
            ],
            "body": {
              "mode": "raw",
              "raw": "{\n  \"email\": \"teacher@example.com\",\n  \"password\": \"password123\"\n}"
            },
            "url": {
              "raw": "{{base_url}}{{user_service}}/api/v1/auth/login",
              "host": ["{{base_url}}"],
              "path": ["{{user_service}}", "api", "v1", "auth", "login"]
            }
          }
        }
      ]
    },
    {
      "name": "Classes",
      "item": [
        {
          "name": "Create Class",
          "event": [
            {
              "listen": "test",
              "script": {
                "exec": [
                  "if (pm.response.code === 201) {",
                  "    var jsonData = pm.response.json();",
                  "    pm.collectionVariables.set('class_id', jsonData.id);",
                  "}"
                ]
              }
            }
          ],
          "request": {
            "auth": {
              "type": "bearer",
              "bearer": [
                {
                  "key": "token",
                  "value": "{{jwt_token}}",
                  "type": "string"
                }
              ]
            },
            "method": "POST",
            "header": [
              {
                "key": "Content-Type",
                "value": "application/json"
              }
            ],
            "body": {
              "mode": "raw",
              "raw": "{\n  \"name\": \"Mathematics 101 - Section A\",\n  \"description\": \"Introduction to Mathematics for beginners\"\n}"
            },
            "url": {
              "raw": "{{base_url}}{{course_service}}/api/classes",
              "host": ["{{base_url}}"],
              "path": ["{{course_service}}", "api", "classes"]
            }
          }
        },
        {
          "name": "Get All Classes",
          "request": {
            "auth": {
              "type": "bearer",
              "bearer": [
                {
                  "key": "token",
                  "value": "{{jwt_token}}",
                  "type": "string"
                }
              ]
            },
            "method": "GET",
            "url": {
              "raw": "{{base_url}}{{course_service}}/api/classes",
              "host": ["{{base_url}}"],
              "path": ["{{course_service}}", "api", "classes"]
            }
          }
        },
        {
          "name": "Get Class Details",
          "request": {
            "auth": {
              "type": "bearer",
              "bearer": [
                {
                  "key": "token",
                  "value": "{{jwt_token}}",
                  "type": "string"
                }
              ]
            },
            "method": "GET",
            "url": {
              "raw": "{{base_url}}{{course_service}}/api/classes/{{class_id}}",
              "host": ["{{base_url}}"],
              "path": ["{{course_service}}", "api", "classes", "{{class_id}}"]
            }
          }
        },
        {
          "name": "Update Class",
          "request": {
            "auth": {
              "type": "bearer",
              "bearer": [
                {
                  "key": "token",
                  "value": "{{jwt_token}}",
                  "type": "string"
                }
              ]
            },
            "method": "PUT",
            "header": [
              {
                "key": "Content-Type",
                "value": "application/json"
              }
            ],
            "body": {
              "mode": "raw",
              "raw": "{\n  \"name\": \"Mathematics 101 - Section A (Updated)\",\n  \"description\": \"Updated description\"\n}"
            },
            "url": {
              "raw": "{{base_url}}{{course_service}}/api/classes/{{class_id}}",
              "host": ["{{base_url}}"],
              "path": ["{{course_service}}", "api", "classes", "{{class_id}}"]
            }
          }
        },
        {
          "name": "Delete Class",
          "request": {
            "auth": {
              "type": "bearer",
              "bearer": [
                {
                  "key": "token",
                  "value": "{{jwt_token}}",
                  "type": "string"
                }
              ]
            },
            "method": "DELETE",
            "url": {
              "raw": "{{base_url}}{{course_service}}/api/classes/{{class_id}}",
              "host": ["{{base_url}}"],
              "path": ["{{course_service}}", "api", "classes", "{{class_id}}"]
            }
          }
        }
      ]
    },
    {
      "name": "Class Students",
      "item": [
        {
          "name": "Add Students to Class",
          "request": {
            "auth": {
              "type": "bearer",
              "bearer": [
                {
                  "key": "token",
                  "value": "{{jwt_token}}",
                  "type": "string"
                }
              ]
            },
            "method": "POST",
            "header": [
              {
                "key": "Content-Type",
                "value": "application/json"
              }
            ],
            "body": {
              "mode": "raw",
              "raw": "{\n  \"studentIds\": [2, 3, 5, 8]\n}"
            },
            "url": {
              "raw": "{{base_url}}{{course_service}}/api/classes/{{class_id}}/students",
              "host": ["{{base_url}}"],
              "path": ["{{course_service}}", "api", "classes", "{{class_id}}", "students"]
            }
          }
        },
        {
          "name": "Get Class Students",
          "request": {
            "auth": {
              "type": "bearer",
              "bearer": [
                {
                  "key": "token",
                  "value": "{{jwt_token}}",
                  "type": "string"
                }
              ]
            },
            "method": "GET",
            "url": {
              "raw": "{{base_url}}{{course_service}}/api/classes/{{class_id}}/students",
              "host": ["{{base_url}}"],
              "path": ["{{course_service}}", "api", "classes", "{{class_id}}", "students"]
            }
          }
        },
        {
          "name": "Remove Student from Class",
          "request": {
            "auth": {
              "type": "bearer",
              "bearer": [
                {
                  "key": "token",
                  "value": "{{jwt_token}}",
                  "type": "string"
                }
              ]
            },
            "method": "DELETE",
            "url": {
              "raw": "{{base_url}}{{course_service}}/api/classes/{{class_id}}/students/2",
              "host": ["{{base_url}}"],
              "path": ["{{course_service}}", "api", "classes", "{{class_id}}", "students", "2"]
            }
          }
        }
      ]
    }
  ]
}
```

---

## 🎯 Quick Reference

| Action | Method | Endpoint | Body Required |
|--------|--------|----------|---------------|
| Create Class | POST | `/api/classes` | ✅ Yes |
| Get All Classes | GET | `/api/classes` | ❌ No |
| Get Class Details | GET | `/api/classes/{classId}` | ❌ No |
| Update Class | PUT | `/api/classes/{classId}` | ✅ Yes |
| Delete Class | DELETE | `/api/classes/{classId}` | ❌ No |
| Add Students | POST | `/api/classes/{classId}/students` | ✅ Yes |
| Get Class Students | GET | `/api/classes/{classId}/students` | ❌ No |
| Remove Student | DELETE | `/api/classes/{classId}/students/{studentId}` | ❌ No |

---

**Note:** All endpoints require authentication with a valid JWT token from a user with `TEACHER` role.

