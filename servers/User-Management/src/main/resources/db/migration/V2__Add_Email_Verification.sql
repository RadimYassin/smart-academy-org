-- Add email verification columns to users table
ALTER TABLE users ADD COLUMN is_verified BOOLEAN DEFAULT FALSE NOT NULL;
ALTER TABLE users ADD COLUMN verification_code VARCHAR(6);
ALTER TABLE users ADD COLUMN verification_code_expiry TIMESTAMP;

-- Update existing users to be verified (backward compatibility)
UPDATE users SET is_verified = TRUE WHERE verification_code IS NULL;
