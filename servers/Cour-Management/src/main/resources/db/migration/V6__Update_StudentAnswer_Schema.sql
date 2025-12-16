-- Migration to update StudentAnswer schema for UUID-based option selection

-- Update student_answers table to use UUID for selected option
ALTER TABLE student_answers DROP COLUMN IF EXISTS selected_option_index;
ALTER TABLE student_answers ADD COLUMN IF NOT EXISTS selected_option_id UUID;

-- Make selected_option_id NOT NULL after data migration
ALTER TABLE student_answers ALTER COLUMN selected_option_id SET NOT NULL;
