CREATE TABLE courses (
    id UUID PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    category VARCHAR(255),
    level VARCHAR(50),
    thumbnail_url VARCHAR(255),
    teacher_id UUID NOT NULL,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
);

CREATE TABLE modules (
    id UUID PRIMARY KEY,
    course_id UUID NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    order_index INT,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
);

CREATE TABLE lessons (
    id UUID PRIMARY KEY,
    module_id UUID NOT NULL REFERENCES modules(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    summary TEXT,
    order_index INT,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
);

CREATE TABLE quizzes (
    id UUID PRIMARY KEY,
    course_id UUID NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    difficulty VARCHAR(50),
    created_at TIMESTAMP,
    updated_at TIMESTAMP
);

CREATE TABLE questions (
    id UUID PRIMARY KEY,
    quiz_id UUID NOT NULL REFERENCES quizzes(id) ON DELETE CASCADE,
    content TEXT NOT NULL,
    options TEXT, -- Stored as JSON string
    correct_option_index INT,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
);

CREATE TABLE lesson_contents (
    id UUID PRIMARY KEY,
    lesson_id UUID NOT NULL REFERENCES lessons(id) ON DELETE CASCADE,
    type VARCHAR(50) NOT NULL,
    text_content TEXT,
    pdf_url VARCHAR(255),
    video_url VARCHAR(255),
    image_url VARCHAR(255),
    quiz_id UUID, -- Can reference a quiz, but not strictly a FK if we want loose coupling or if quiz is reusable. But let's make it loose for now or FK if strict.
    order_index INT,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
);
