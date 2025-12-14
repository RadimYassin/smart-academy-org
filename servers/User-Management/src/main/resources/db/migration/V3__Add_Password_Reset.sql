-- Add password reset columns to users table
ALTER TABLE users ADD COLUMN password_reset_code VARCHAR(6);
ALTER TABLE users ADD COLUMN password_reset_expiry TIMESTAMP;
