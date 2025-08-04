-- =============================================
-- SIMPLE DECINA TRANSPORT DATABASE
-- For XAMPP/phpMyAdmin
-- =============================================

-- Create database
CREATE DATABASE IF NOT EXISTS `transit_db` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `transit_db`;

-- =============================================
-- USERS TABLE - Simple user authentication
-- =============================================
CREATE TABLE IF NOT EXISTS `users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `username` varchar(50) NOT NULL,
  `email` varchar(100) NOT NULL,
  `password` varchar(255) NOT NULL,
  `full_name` varchar(100) NOT NULL,
  `phone_number` varchar(20),
  `birthday` DATE NULL DEFAULT NULL,
  `license_name` VARCHAR(100) NULL DEFAULT NULL,
  `license_number` VARCHAR(50) NULL DEFAULT NULL,
  `license_address` TEXT NULL DEFAULT NULL,
  `license_codes` VARCHAR(100) NULL DEFAULT NULL,
  `license_expiration` DATE NULL DEFAULT NULL,
  `profile_photo` VARCHAR(255) NULL DEFAULT NULL,
  `role` enum('admin','user') NOT NULL DEFAULT 'user',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `username` (`username`),
  UNIQUE KEY `email` (`email`),
  INDEX `idx_license_number` (`license_number`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Create otp_verifications table for storing OTP codes
CREATE TABLE IF NOT EXISTS `otp_verifications` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `otp_code` varchar(10) NOT NULL,
  `expires_at` timestamp NOT NULL,
  `is_verified` tinyint(1) DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================
-- INSERT SAMPLE DATA
-- =============================================

-- Note: Add your actual users here
-- Example structure (replace with real data):
-- INSERT INTO `users` (`username`, `email`, `password`, `full_name`, `role`) VALUES
-- ('realuser', 'real@example.com', '$2y$10$...hashedpassword...', 'Real User', 'admin');
