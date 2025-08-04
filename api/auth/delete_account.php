<?php
// Turn off error reporting to prevent any output that could interfere with JSON
error_reporting(0);
ini_set('display_errors', 0);

include_once '../config/database.php';

// Set headers for JSON response
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

// Handle preflight OPTIONS request
if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    exit(0);
}

try {
    $database = new Database();
    $db = $database->getConnection();
    
    if (!$db) {
        http_response_code(500);
        echo json_encode(array(
            "success" => false,
            "message" => "Database connection failed."
        ));
        exit;
    }

    if ($_SERVER['REQUEST_METHOD'] == 'POST') {
        // Get raw POST data
        $rawData = file_get_contents("php://input");
        
        // Check if data is empty
        if (empty($rawData)) {
            http_response_code(400);
            echo json_encode(array(
                "success" => false,
                "message" => "No data received."
            ));
            exit;
        }
        
        // Decode JSON data
        $data = json_decode($rawData);
        
        // Check for JSON decode errors
        if (json_last_error() !== JSON_ERROR_NONE) {
            http_response_code(400);
            echo json_encode(array(
                "success" => false,
                "message" => "Invalid JSON format: " . json_last_error_msg()
            ));
            exit;
        }

        if (!empty($data->user_id)) {
            $user_id = $data->user_id;

            // Delete user from users table
            $delete_user_query = "DELETE FROM users WHERE id = ?";
            $delete_user_stmt = $db->prepare($delete_user_query);
            $delete_user_stmt->bindParam(1, $user_id);

            if ($delete_user_stmt->execute()) {
                http_response_code(200);
                echo json_encode(array(
                    "success" => true,
                    "message" => "User account deleted successfully."
                ));
            } else {
                http_response_code(500);
                echo json_encode(array(
                    "success" => false,
                    "message" => "Failed to delete user account."
                ));
            }
        } else {
            http_response_code(400);
            echo json_encode(array(
                "success" => false,
                "message" => "User ID is required."
            ));
        }
    } else {
        http_response_code(405);
        echo json_encode(array(
            "success" => false,
            "message" => "Method not allowed."
        ));
    }
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode(array(
        "success" => false,
        "message" => "Server error: " . $e->getMessage()
    ));
}
?>
