<?php
// Script to check if profile_photo column exists

echo "Checking database structure...\n";

// Include the database configuration
include_once 'api/config/database.php';

$database = new Database();
$db = $database->getConnection();

if (!$db) {
    echo "Database connection failed\n";
    exit(1);
}

echo "Database connection successful\n";

// Check if profile_photo column exists
try {
    $query = "SHOW COLUMNS FROM users LIKE 'profile_photo'";
    $stmt = $db->prepare($query);
    $stmt->execute();
    
    if ($stmt->rowCount() > 0) {
        echo "profile_photo column exists\n";
        print_r($stmt->fetch(PDO::FETCH_ASSOC));
    } else {
        echo "profile_photo column does not exist\n";
        
        // Try to add it manually
        echo "Adding profile_photo column manually...\n";
        $alterQuery = "ALTER TABLE users ADD COLUMN profile_photo VARCHAR(255) NULL DEFAULT NULL";
        $alterStmt = $db->prepare($alterQuery);
        if ($alterStmt->execute()) {
            echo "profile_photo column added successfully\n";
        } else {
            echo "Failed to add profile_photo column\n";
        }
    }
} catch (Exception $e) {
    echo "Error checking database: " . $e->getMessage() . "\n";
}

echo "Database check completed.\n";
?>
