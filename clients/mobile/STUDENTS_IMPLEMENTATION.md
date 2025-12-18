# Students Management Implementation

## Overview

This document describes the implementation of the Students Management feature in the mobile app, reimplemented from the microfrontends version.

## Features Implemented

### 1. **Class Management**
- ✅ Create new student classes
- ✅ View all classes for the authenticated teacher
- ✅ Delete classes
- ✅ Expand/collapse classes to view students
- ✅ View class details (creation date, update date, student count)

### 2. **Student Management**
- ✅ Create individual student accounts
- ✅ View all available students
- ✅ Add students to classes
- ✅ Remove students from classes
- ✅ Search and filter students

### 3. **UI Features**
- ✅ Beautiful Material Design 3 UI
- ✅ Dark mode support
- ✅ Loading indicators
- ✅ Error handling with user-friendly messages
- ✅ Pull-to-refresh
- ✅ Animations using flutter_animate
- ✅ Modal dialogs for creating classes and students
- ✅ Search functionality in add students modal

## Architecture

### Data Layer

#### Models
- `StudentClass` - Represents a student class
- `CreateClassRequest` - Request model for creating a class
- `ClassStudent` - Represents a student in a class
- `AddStudentsRequest` - Request model for adding students to a class
- `StudentDto` - Data transfer object for student information

#### Data Sources
- `ClassRemoteDataSource` - Handles all class-related API calls
- `StudentRemoteDataSource` - Handles all student-related API calls

#### Repositories
- `ClassRepository` / `ClassRepositoryImpl` - Repository pattern for class operations
- `StudentRepository` / `StudentRepositoryImpl` - Repository pattern for student operations

### Domain Layer

#### Repositories (Interfaces)
- `ClassRepository` - Interface for class operations
- `StudentRepository` - Interface for student operations

### Presentation Layer

#### Controller
- `StudentsController` - Manages state and business logic for the students screen
  - Classes list management
  - Students list management
  - Modal state management
  - Form state management
  - Search and filter functionality

#### Screens
- `StudentsScreen` - Main screen displaying classes and students
- `CreateClassModal` - Modal for creating a new class
- `CreateStudentModal` - Modal for creating a new student account
- `AddStudentsModal` - Modal for adding students to a class

## API Endpoints Used

### Class Endpoints
- `POST /course-service/api/classes` - Create a new class
- `GET /course-service/api/classes` - Get all classes for teacher
- `GET /course-service/api/classes/{classId}` - Get class by ID
- `DELETE /course-service/api/classes/{classId}` - Delete a class
- `POST /course-service/api/classes/{classId}/students` - Add students to class
- `GET /course-service/api/classes/{classId}/students` - Get students in class
- `DELETE /course-service/api/classes/{classId}/students/{studentId}` - Remove student from class

### Student Endpoints
- `GET /user-management-service/api/v1/users/students` - Get all students
- `GET /user-management-service/api/v1/users/{userId}` - Get student by ID
- `POST /user-management-service/api/v1/auth/register` - Create student account (with role: STUDENT)

## Navigation

The students screen is accessible via:
```dart
Get.toNamed(AppRoutes.students);
```

Route: `/students`

## Dependency Injection

All dependencies are registered in `dependency_injection.dart`:
- `ClassRemoteDataSource`
- `StudentRemoteDataSource`
- `ClassRepository`
- `StudentRepository`
- `StudentsController` (via `StudentsBinding`)

## Usage Example

```dart
// Navigate to students screen
Get.toNamed(AppRoutes.students);

// In the screen, the controller is automatically injected
final controller = Get.find<StudentsController>();

// Create a class
controller.newClass.value = CreateClassRequest(
  name: 'Mathematics 101',
  description: 'Introduction to Mathematics',
);
await controller.createClass();

// Add students to a class
await controller.addStudentsToClass(
  classId,
  [studentId1, studentId2, studentId3],
);
```

## UI Components

### Students Screen
- Header with title and action buttons
- Classes list with expand/collapse functionality
- Empty state when no classes exist
- Error message display
- Pull-to-refresh support

### Class Card
- Class name and description
- Student count
- Expandable to show students list
- Delete button
- Add students button

### Modals
- **Create Class Modal**: Form with name and description fields
- **Create Student Modal**: Form with firstName, lastName, email, and password fields
- **Add Students Modal**: Searchable list of students with multi-select functionality

## Future Enhancements

Potential improvements:
- [ ] CSV import/export functionality (as in web version)
- [ ] Bulk student creation
- [ ] Edit class functionality
- [ ] Student profile view
- [ ] Class statistics and analytics
- [ ] Offline support with local caching

## Notes

- The implementation follows the same architecture pattern as the rest of the mobile app
- All API calls go through the API Gateway at `http://localhost:8888`
- Authentication tokens are automatically injected via `ApiClient`
- Error handling is centralized and user-friendly
- The UI is fully responsive and supports both light and dark themes

