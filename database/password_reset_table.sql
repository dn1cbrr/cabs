-- =============================================
-- PASSWORD RESET TABLE
-- For forgot password functionality
-- =============================================

USE `transit_db`;

-- Create password_resets table
CREATE TABLE IF NOT EXISTS `password_resets` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `reset_token` varchar(255) NOT NULL,
  `expires_at` timestamp NOT NULL,
  `is_used` tinyint(1) DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `reset_token` (`reset_token`),
  FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE,
  INDEX `idx_user_id` (`user_id`),
  INDEX `idx_token` (`reset_token`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Add email_verified column to users table if not exists
ALTER TABLE `users` 
ADD COLUMN IF NOT EXISTS `email_verified` tinyint(1) DEFAULT 0,
ADD COLUMN IF NOT EXISTS `reset_token` varchar(255) DEFAULT NULL,
ADD COLUMN IF NOT EXISTS `reset_token_expires` timestamp NULL DEFAULT NULL;
