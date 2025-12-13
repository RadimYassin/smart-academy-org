-- Add Quiz Attempts and Student Answers tables

CREATE TABLE quiz_attempts (
    id UUID PRIMARY KEY,
    quiz_id UUID NOT NULL REFERENCES quizzes(id) ON DELETE CASCADE,
    student_id BIGINT NOT NULL,
    score INT NOT NULL,
    max_score INT NOT NULL,
    percentage DOUBLE PRECISION NOT NULL,
    passed BOOLEAN NOT NULL,
    started_at TIMESTAMP NOT NULL,
    submitted_at TIMESTAMP,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
);

CREATE INDEX idx_quiz_attempts_quiz ON quiz_attempts(quiz_id);
CREATE INDEX idx_quiz_attempts_student ON quiz_attempts(student_id);
CREATE INDEX idx_quiz_attempts_student_quiz ON quiz_attempts(student_id, quiz_id);

CREATE TABLE student_answers (
    id UUID PRIMARY KEY,
    quiz_attempt_id UUID NOT NULL REFERENCES quiz_attempts(id) ON DELETE CASCADE,
    question_id UUID NOT NULL REFERENCES questions(id) ON DELETE CASCADE,
    selected_option_index INT NOT NULL,
    is_correct BOOLEAN NOT NULL,
    answered_at TIMESTAMP
);

CREATE INDEX idx_student_answers_attempt ON student_answers(quiz_attempt_id);
CREATE INDEX idx_student_answers_question ON student_answers(question_id);
