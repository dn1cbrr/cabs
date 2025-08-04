<?php
// Simple test script to verify the add.php endpoint
include_once '../config/database.php';

header("Content-Type: application/json; charset=UTF-8");

$database = new Database();
$db = $database->getConnection();

// Test database connection
if ($db) {
    echo json_encode([
        "status" => "success",
        "message" => "Database connection successful",
        "database" => "transit_db"
    ]);
} else {
    echo json_encode([
        "status" => "error",
        "message" => "Database connection failed"
    ]);
}
?>
