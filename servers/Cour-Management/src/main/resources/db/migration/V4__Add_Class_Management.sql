-- V4: Add Class Management, Enrollment, Progress Tracking, and Certificates

-- 1. Classes table (student groups managed by teachers)
CREATE TABLE classes (
    id UUID PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    teacher_id BIGINT NOT NULL,
    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP NOT NULL
);

CREATE INDEX idx_classes_teacher ON classes(teacher_id);

-- 2. Class Students table (many-to-many: classes and students)
CREATE TABLE class_students (
    id UUID PRIMARY KEY,
    class_id UUID NOT NULL REFERENCES classes(id) ON DELETE CASCADE,
    student_id BIGINT NOT NULL,
    added_by BIGINT NOT NULL,
    added_at TIMESTAMP NOT NULL,
    UNIQUE(class_id, student_id)
);

CREATE INDEX idx_class_students_class ON class_students(class_id);
CREATE INDEX idx_class_students_student ON class_students(student_id);

-- 3. Enrollments table (students/classes assigned to courses)
CREATE TABLE enrollments (
    id UUID PRIMARY KEY,
    course_id UUID NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
    student_id BIGINT,
    class_id UUID REFERENCES classes(id) ON DELETE CASCADE,
    assigned_by BIGINT NOT NULL,
    assignment_type VARCHAR(20) NOT NULL CHECK (assignment_type IN ('INDIVIDUAL', 'CLASS')),
    enrolled_at TIMESTAMP NOT NULL,
    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP NOT NULL,
    UNIQUE(course_id, student_id),
    CHECK (
        (student_id IS NOT NULL AND class_id IS NULL) OR
        (student_id IS NULL AND class_id IS NOT NULL)
    )
);

CREATE INDEX idx_enrollments_course ON enrollments(course_id);
CREATE INDEX idx_enrollments_student ON enrollments(student_id);
CREATE INDEX idx_enrollments_class ON enrollments(class_id);
CREATE INDEX idx_enrollments_assigned_by ON enrollments(assigned_by);

-- 4. Lesson Progress table (track student lesson completion)
CREATE TABLE lesson_progress (
    id UUID PRIMARY KEY,
    lesson_id UUID NOT NULL REFERENCES lessons(id) ON DELETE CASCADE,
    student_id BIGINT NOT NULL,
    completed BOOLEAN NOT NULL DEFAULT false,
    completed_at TIMESTAMP,
    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP NOT NULL,
    UNIQUE(lesson_id, student_id)
);

CREATE INDEX idx_lesson_progress_lesson ON lesson_progress(lesson_id);
CREATE INDEX idx_lesson_progress_student ON lesson_progress(student_id);
CREATE INDEX idx_lesson_progress_student_completed ON lesson_progress(student_id, completed);

-- 5. Certificates table (course completion certificates)
CREATE TABLE certificates (
    id UUID PRIMARY KEY,
    course_id UUID NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
    student_id BIGINT NOT NULL,
    verification_code VARCHAR(50) NOT NULL UNIQUE,
    completion_rate DOUBLE PRECISION NOT NULL,
    issued_at TIMESTAMP NOT NULL,
    pdf_url VARCHAR(500),
    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP NOT NULL,
    UNIQUE(course_id, student_id)
);

CREATE INDEX idx_certificates_student ON certificates(student_id);
CREATE INDEX idx_certificates_course ON certificates(course_id);
CREATE INDEX idx_certificates_verification ON certificates(verification_code);

-- 6. Update quizzes table to add passingScore and mandatory fields
ALTER TABLE quizzes 
ADD COLUMN passing_score INTEGER DEFAULT 60,
ADD COLUMN mandatory BOOLEAN DEFAULT false;

COMMENT ON TABLE classes IS 'Student groups/classes managed by teachers';
COMMENT ON TABLE class_students IS 'Students belonging to a class';
COMMENT ON TABLE enrollments IS 'Course enrollments for students or entire classes';
COMMENT ON TABLE lesson_progress IS 'Tracks student progress through lessons';
COMMENT ON TABLE certificates IS 'Course completion certificates';
COMMENT ON COLUMN quizzes.passing_score IS 'Percentage required to pass the quiz (e.g., 60)';
COMMENT ON COLUMN quizzes.mandatory IS 'Whether quiz must be passed to earn certificate';
