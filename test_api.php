<?php
// Test script to verify API functionality

echo "Testing API functionality...\n";

// Test 1: Check if we can connect to the database
include_once 'api/config/database.php';

$database = new Database();
$db = $database->getConnection();

if ($db) {
    echo "Database connection successful\n";
} else {
    echo "Database connection failed\n";
    exit(1);
}

// Test 2: Check if we can read the users table
try {
    $query = "SELECT id, username, email FROM users LIMIT 1";
    $stmt = $db->prepare($query);
    $stmt->execute();
    
    if ($stmt->rowCount() > 0) {
        echo "Database query successful\n";
        $user = $stmt->fetch(PDO::FETCH_ASSOC);
        echo "Sample user: " . $user['username'] . " (" . $user['email'] . ")\n";
    } else {
        echo "No users found in database\n";
    }
} catch (Exception $e) {
    echo "Database query failed: " . $e->getMessage() . "\n";
}

echo "API testing completed.\n";
?>
