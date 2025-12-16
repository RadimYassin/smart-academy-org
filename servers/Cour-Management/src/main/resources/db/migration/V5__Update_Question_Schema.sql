-- Migration to update Question schema for option objects
-- Previous schema stored options as TEXT field, now using separate table

-- Create question_options table
CREATE TABLE IF NOT EXISTS question_options (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    question_id UUID NOT NULL,
    option_text VARCHAR(500) NOT NULL,
    is_correct BOOLEAN NOT NULL DEFAULT FALSE,
    option_order INTEGER,
    CONSTRAINT fk_question_options_question FOREIGN KEY (question_id) REFERENCES questions(id) ON DELETE CASCADE
);

-- Create index for faster lookups
CREATE INDEX idx_question_options_question_id ON question_options(question_id);
CREATE INDEX idx_question_options_order ON question_options(question_id, option_order);

-- Migrate existing data if any (skip if table is empty)
-- Since the old structure used JSON strings, we'll handle migration manually if needed

-- Update questions table structure
ALTER TABLE questions DROP COLUMN IF EXISTS options;
ALTER TABLE questions DROP COLUMN IF EXISTS correct_option_index;

-- Add new columns  
ALTER TABLE questions ADD COLUMN IF NOT EXISTS question_text VARCHAR(1000);
ALTER TABLE questions ADD COLUMN IF NOT EXISTS question_type VARCHAR(50);
ALTER TABLE questions ADD COLUMN IF NOT EXISTS points INTEGER;

-- Update old content column to questionText if exists
UPDATE questions SET question_text = content WHERE question_text IS NULL AND content IS NOT NULL;

-- Drop old content column
ALTER TABLE questions DROP COLUMN IF EXISTS content;

-- Make question_text NOT NULL
ALTER TABLE questions ALTER COLUMN question_text SET NOT NULL;
ALTER TABLE questions ALTER COLUMN question_type SET NOT NULL;
