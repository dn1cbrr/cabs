-- Add driver license fields and profile photo to users table
ALTER TABLE `users` 
ADD COLUMN `birthday` DATE NULL DEFAULT NULL,
ADD COLUMN `license_name` VARCHAR(100) NULL DEFAULT NULL,
ADD COLUMN `license_number` VARCHAR(50) NULL DEFAULT NULL,
ADD COLUMN `license_address` TEXT NULL DEFAULT NULL,
ADD COLUMN `license_codes` VARCHAR(100) NULL DEFAULT NULL,
ADD COLUMN `license_expiration` DATE NULL DEFAULT NULL,
ADD COLUMN `profile_photo` VARCHAR(255) NULL DEFAULT NULL;

-- Add index on license_number for faster lookups
ALTER TABLE `users` ADD INDEX `idx_license_number` (`license_number`);
