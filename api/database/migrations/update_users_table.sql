-- Enhanced User Registration System - Database Schema Updates
-- This migration adds new fields to the users table for enhanced registration

ALTER TABLE users 
ADD COLUMN IF NOT EXISTS phone VARCHAR(20) NULL AFTER email,
ADD COLUMN IF NOT EXISTS profile_photo VARCHAR(255) NULL AFTER phone,
ADD COLUMN IF NOT EXISTS email_verified BOOLEAN DEFAULT FALSE AFTER profile_photo,
ADD COLUMN IF NOT EXISTS email_verification_token VARCHAR(255) NULL AFTER email_verified,
ADD COLUMN IF NOT EXISTS email_verification_expires TIMESTAMP NULL AFTER email_verification_token,
ADD COLUMN IF NOT EXISTS password_reset_token VARCHAR(255) NULL AFTER email_verification_expires,
ADD COLUMN IF NOT EXISTS password_reset_expires TIMESTAMP NULL AFTER password_reset_token,
ADD COLUMN IF NOT EXISTS created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP AFTER password_reset_expires,
ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP AFTER created_at;

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_email_verification_token ON users(email_verification_token);
CREATE INDEX IF NOT EXISTS idx_password_reset_token ON users(password_reset_token);
CREATE INDEX IF NOT EXISTS idx_email_verified ON users(email_verified);

-- Create a table for storing email verification logs
CREATE TABLE IF NOT EXISTS email_verification_logs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    email VARCHAR(255) NOT NULL,
    verification_token VARCHAR(255) NOT NULL,
    sent_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    verified_at TIMESTAMP NULL,
    ip_address VARCHAR(45),
    user_agent TEXT,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Create a table for password reset logs
CREATE TABLE IF NOT EXISTS password_reset_logs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    email VARCHAR(255) NOT NULL,
    reset_token VARCHAR(255) NOT NULL,
    requested_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    used_at TIMESTAMP NULL,
    ip_address VARCHAR(45),
    user_agent TEXT,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);
