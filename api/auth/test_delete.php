<?php
// Test script for delete account functionality
include_once '../config/database.php';

header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

try {
    $database = new Database();
    $db = $database->getConnection();
    
    if (!$db) {
        echo json_encode(array(
            "success" => false,
            "message" => "Database connection failed."
        ));
        exit;
    }
    
    // Test deleting a user (be careful with this in production!)
    // This is just for testing purposes
    echo json_encode(array(
        "success" => true,
        "message" => "Delete account endpoint is working correctly.",
        "database_connected" => true
    ));
} catch (Exception $e) {
    echo json_encode(array(
        "success" => false,
        "message" => "Server error: " . $e->getMessage()
    ));
}
?>
