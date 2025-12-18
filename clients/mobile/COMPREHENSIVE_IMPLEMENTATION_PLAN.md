# Comprehensive Teacher & Student Implementation Plan

## Overview
This document outlines the complete implementation of all teacher and student features from the microfrontends into the mobile app.

## Features to Implement

### Teacher Features
1. ✅ **Students Management** - Already implemented
2. ⏳ **Teacher Dashboard** - Statistics, overview, recent activity
3. ⏳ **Course Management** - Create, edit, delete, view courses
4. ⏳ **Course Detail** - Modules, lessons, quizzes, content management
5. ⏳ **Enrollment Management** - Assign students/classes to courses
6. ⏳ **Analytics** - Coming soon (placeholder)
7. ⏳ **Settings** - Coming soon (placeholder)

### Student Features
1. ⏳ **Student Dashboard** - Enrolled courses overview
2. ⏳ **Student Explore** - Browse all courses
3. ⏳ **Student Course View** - Learning interface with progress
4. ⏳ **Progress Tracking** - Mark lessons complete, view progress
5. ⏳ **Certificate Generation** - When course is 100% complete

## Implementation Order

### Phase 1: Core Models & Data Sources
1. Course models
2. Module models
3. Lesson models
4. Lesson Content models
5. Quiz models
6. Question models
7. Enrollment models
8. Progress models

### Phase 2: Data Sources & Repositories
1. Course data source & repository
2. Module data source & repository
3. Lesson data source & repository
4. Lesson Content data source & repository
5. Quiz data source & repository
6. Question data source & repository
7. Enrollment data source & repository
8. Progress data source & repository

### Phase 3: Controllers
1. Course controller
2. Module controller
3. Lesson controller
4. Enrollment controller
5. Progress controller
6. Teacher dashboard controller
7. Student dashboard controller

### Phase 4: Screens
1. Teacher dashboard screen
2. Teacher courses screen
3. Course detail screen
4. Student dashboard screen
5. Student explore screen
6. Student course view screen

## API Endpoints Reference

### Course Endpoints
- `GET /course-service/courses` - Get all courses
- `GET /course-service/courses/teacher/{teacherId}` - Get teacher courses
- `GET /course-service/courses/{courseId}` - Get course by ID
- `POST /course-service/courses` - Create course
- `PUT /course-service/courses/{courseId}` - Update course
- `DELETE /course-service/courses/{courseId}` - Delete course

### Module Endpoints
- `GET /course-service/courses/{courseId}/modules` - Get modules
- `POST /course-service/courses/{courseId}/modules` - Create module
- `PUT /course-service/courses/{courseId}/modules/{moduleId}` - Update module
- `DELETE /course-service/courses/{courseId}/modules/{moduleId}` - Delete module

### Lesson Endpoints
- `GET /course-service/modules/{moduleId}/lessons` - Get lessons
- `GET /course-service/lessons/{lessonId}` - Get lesson by ID
- `POST /course-service/modules/{moduleId}/lessons` - Create lesson
- `PUT /course-service/modules/{moduleId}/lessons/{lessonId}` - Update lesson
- `DELETE /course-service/modules/{moduleId}/lessons/{lessonId}` - Delete lesson

### Lesson Content Endpoints
- `GET /course-service/lessons/{lessonId}/content` - Get content
- `POST /course-service/lessons/{lessonId}/content` - Create content
- `PUT /course-service/lessons/{lessonId}/content/{contentId}` - Update content
- `DELETE /course-service/lessons/{lessonId}/content/{contentId}` - Delete content

### Quiz Endpoints
- `GET /course-service/courses/{courseId}/quizzes` - Get quizzes
- `POST /course-service/courses/{courseId}/quizzes` - Create quiz
- `PUT /course-service/courses/{courseId}/quizzes/{quizId}` - Update quiz
- `DELETE /course-service/courses/{courseId}/quizzes/{quizId}` - Delete quiz

### Question Endpoints
- `GET /course-service/quizzes/{quizId}/questions` - Get questions
- `POST /course-service/quizzes/{quizId}/questions` - Create question
- `PUT /course-service/quizzes/{quizId}/questions/{questionId}` - Update question
- `DELETE /course-service/quizzes/{quizId}/questions/{questionId}` - Delete question

### Enrollment Endpoints
- `POST /course-service/api/enrollments/student` - Assign student
- `POST /course-service/api/enrollments/class` - Assign class
- `GET /course-service/api/enrollments/courses/{courseId}` - Get enrollments
- `DELETE /course-service/api/enrollments/courses/{courseId}/students/{studentId}` - Unenroll
- `GET /course-service/api/enrollments/my-courses` - Get my courses

### Progress Endpoints
- `POST /course-service/api/progress/lessons/{lessonId}/complete` - Mark complete
- `GET /course-service/api/progress/lessons/{lessonId}` - Get lesson progress
- `GET /course-service/api/progress/courses/{courseId}` - Get course progress
- `GET /course-service/api/progress/courses/{courseId}/lessons` - Get all lesson progress

