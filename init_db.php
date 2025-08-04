<?php
// Script to initialize the database with required tables

// Database configuration
$host = "localhost";
$db_name = "transit_db";
$username = "root";
$password = "";

try {
    // Create connection
    $conn = new PDO("mysql:host=$host", $username, $password);
    $conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    
    // Create database
    $conn->exec("CREATE DATABASE IF NOT EXISTS `$db_name`");
    $conn->exec("USE `$db_name`");
    
    echo "Database created successfully\n";
    
    // Create users table
    $users_table_sql = "
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
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;";
    
    $conn->exec($users_table_sql);
    echo "Users table created successfully\n";
    
    // Create otp_verifications table
    $otp_table_sql = "
    CREATE TABLE IF NOT EXISTS `otp_verifications` (
      `id` int(11) NOT NULL AUTO_INCREMENT,
      `user_id` int(11) NOT NULL,
      `otp_code` varchar(10) NOT NULL,
      `expires_at` timestamp NOT NULL,
      `is_verified` tinyint(1) DEFAULT 0,
      `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
      PRIMARY KEY (`id`),
      FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;";
    
    $conn->exec($otp_table_sql);
    echo "OTP verifications table created successfully\n";
    
    // Create drivers table
    $drivers_table_sql = "
    CREATE TABLE IF NOT EXISTS drivers (
        id INT AUTO_INCREMENT PRIMARY KEY,
        name VARCHAR(100) NOT NULL,
        birthday DATE NOT NULL,
        age INT NOT NULL,
        address TEXT NOT NULL,
        contact VARCHAR(20) NOT NULL,
        license_name VARCHAR(100) NOT NULL,
        license_number VARCHAR(50) NOT NULL UNIQUE,
        license_address TEXT NOT NULL,
        license_codes VARCHAR(100) NOT NULL,
        expiration_date DATE NOT NULL,
        vehicle_type VARCHAR(50) NOT NULL,
        plate_number VARCHAR(20) NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        is_active BOOLEAN DEFAULT TRUE
    );";
    
    $conn->exec($drivers_table_sql);
    echo "Drivers table created successfully\n";
    
    // Create driver_trips table
    $trips_table_sql = "
    CREATE TABLE IF NOT EXISTS driver_trips (
        id INT AUTO_INCREMENT PRIMARY KEY,
        driver_id INT NOT NULL,
        trip_date DATE NOT NULL,
        start_time DATETIME NOT NULL,
        end_time DATETIME,
        route_details TEXT NOT NULL,
        total_passengers INT DEFAULT 0,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        FOREIGN KEY (driver_id) REFERENCES drivers(id) ON DELETE CASCADE,
        INDEX idx_driver_date (driver_id, trip_date),
        INDEX idx_trip_date (trip_date)
    );";
    
    $conn->exec($trips_table_sql);
    echo "Driver trips table created successfully\n";
    
    // Insert sample data for users
    $user_sql = "INSERT IGNORE INTO users (username, email, password, full_name, role) VALUES 
    ('admin', 'admin@example.com', '\$2y\$10\$examplehashedpassword', 'Administrator', 'admin'),
    ('driver1', 'driver1@example.com', '\$2y\$10\$examplehashedpassword', 'Driver One', 'user');";
    
    $conn->exec($user_sql);
    echo "Sample users inserted successfully\n";
    
    // Insert sample data for drivers
    $driver_sql = "INSERT IGNORE INTO drivers (name, birthday, age, address, contact, license_name, license_number, license_address, license_codes, expiration_date, vehicle_type, plate_number) VALUES
    ('John Doe', '1990-05-15', 34, '123 Main St, City', '09123456789', 'John Doe', 'D12345678', '123 Main St, City', 'DL Codes 1,2,3', '2025-12-31', 'SUV', 'ABC1234'),
    ('Jane Smith', '1985-08-22', 39, '456 Oak Ave, Town', '09876543210', 'Jane Smith', 'D87654321', '456 Oak Ave, Town', 'DL Codes 1,2', '2026-06-30', 'Sedan', 'XYZ5678');";
    
    $conn->exec($driver_sql);
    echo "Sample drivers inserted successfully\n";
    
    echo "Database initialization completed successfully!\n";
    
} catch(PDOException $e) {
    echo "Error: " . $e->getMessage();
}
?>
