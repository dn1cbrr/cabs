<?php
include_once 'api/config/database.php';

$database = new Database();
$db = $database->getConnection();

if ($db) {
    echo "Database connection successful\n";
    
    try {
        // Check if birthday column exists
        $stmt = $db->prepare("SHOW COLUMNS FROM users LIKE 'birthday'");
        $stmt->execute();
        $result = $stmt->fetchAll();
        
        if (empty($result)) {
            echo "Adding missing birthday column...\n";
            $stmt = $db->prepare("ALTER TABLE users ADD COLUMN birthday DATE NULL DEFAULT NULL");
            $stmt->execute();
            echo "Birthday column added successfully\n";
        } else {
            echo "Birthday column already exists\n";
        }
        
        // Check if license_name column exists
        $stmt = $db->prepare("SHOW COLUMNS FROM users LIKE 'license_name'");
        $stmt->execute();
        $result = $stmt->fetchAll();
        
        if (empty($result)) {
            echo "Adding missing license_name column...\n";
            $stmt = $db->prepare("ALTER TABLE users ADD COLUMN license_name VARCHAR(100) NULL DEFAULT NULL");
            $stmt->execute();
            echo "License name column added successfully\n";
        } else {
            echo "License name column already exists\n";
        }
        
        // Check if license_number column exists
        $stmt = $db->prepare("SHOW COLUMNS FROM users LIKE 'license_number'");
        $stmt->execute();
        $result = $stmt->fetchAll();
        
        if (empty($result)) {
            echo "Adding missing license_number column...\n";
            $stmt = $db->prepare("ALTER TABLE users ADD COLUMN license_number VARCHAR(50) NULL DEFAULT NULL");
            $stmt->execute();
            echo "License number column added successfully\n";
        } else {
            echo "License number column already exists\n";
        }
        
        // Check if license_address column exists
        $stmt = $db->prepare("SHOW COLUMNS FROM users LIKE 'license_address'");
        $stmt->execute();
        $result = $stmt->fetchAll();
        
        if (empty($result)) {
            echo "Adding missing license_address column...\n";
            $stmt = $db->prepare("ALTER TABLE users ADD COLUMN license_address TEXT NULL DEFAULT NULL");
            $stmt->execute();
            echo "License address column added successfully\n";
        } else {
            echo "License address column already exists\n";
        }
        
        // Check if license_codes column exists
        $stmt = $db->prepare("SHOW COLUMNS FROM users LIKE 'license_codes'");
        $stmt->execute();
        $result = $stmt->fetchAll();
        
        if (empty($result)) {
            echo "Adding missing license_codes column...\n";
            $stmt = $db->prepare("ALTER TABLE users ADD COLUMN license_codes VARCHAR(100) NULL DEFAULT NULL");
            $stmt->execute();
            echo "License codes column added successfully\n";
        } else {
            echo "License codes column already exists\n";
        }
        
        // Check if license_expiration column exists
        $stmt = $db->prepare("SHOW COLUMNS FROM users LIKE 'license_expiration'");
        $stmt->execute();
        $result = $stmt->fetchAll();
        
        if (empty($result)) {
            echo "Adding missing license_expiration column...\n";
            $stmt = $db->prepare("ALTER TABLE users ADD COLUMN license_expiration DATE NULL DEFAULT NULL");
            $stmt->execute();
            echo "License expiration column added successfully\n";
        } else {
            echo "License expiration column already exists\n";
        }
    } catch (Exception $e) {
        echo "Error: " . $e->getMessage() . "\n";
    }
} else {
    echo "Database connection failed\n";
}
?>
