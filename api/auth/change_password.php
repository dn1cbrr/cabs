<?php
include_once '../config/database.php';

header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

// Handle preflight OPTIONS request
if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    exit(0);
}

$database = new Database();
$db = $database->getConnection();

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    $data = json_decode(file_get_contents("php://input"));
    
    if (!empty($data->user_id) && !empty($data->current_password) && !empty($data->new_password)) {
        $userId = $data->user_id;
        $currentPassword = $data->current_password;
        $newPassword = $data->new_password;
        
        // Validate new password strength
        if (strlen($newPassword) < 8) {
            http_response_code(400);
            echo json_encode(array(
                "success" => false,
                "message" => "Password must be at least 8 characters long"
            ));
            exit();
        }
        
        if (!preg_match('/[A-Z]/', $newPassword)) {
            http_response_code(400);
            echo json_encode(array(
                "success" => false,
                "message" => "Password must contain at least one uppercase letter"
            ));
            exit();
        }
        
        if (!preg_match('/[a-z]/', $newPassword)) {
            http_response_code(400);
            echo json_encode(array(
                "success" => false,
                "message" => "Password must contain at least one lowercase letter"
            ));
            exit();
        }
        
        if (!preg_match('/[0-9]/', $newPassword)) {
            http_response_code(400);
            echo json_encode(array(
                "success" => false,
                "message" => "Password must contain at least one number"
            ));
            exit();
        }
        
        if (!preg_match('/[!@#$%^&*(),.?":{}|<>]/', $newPassword)) {
            http_response_code(400);
            echo json_encode(array(
                "success" => false,
                "message" => "Password must contain at least one special character"
            ));
            exit();
        }
        
        // Get current user password
        $query = "SELECT id, password FROM users WHERE id = ? LIMIT 0,1";
        $stmt = $db->prepare($query);
        $stmt->bindParam(1, $userId);
        $stmt->execute();
        
        if ($stmt->rowCount() > 0) {
            $userData = $stmt->fetch(PDO::FETCH_ASSOC);
            
            // Verify current password
            if (password_verify($currentPassword, $userData['password'])) {
                // Hash new password
                $hashedPassword = password_hash($newPassword, PASSWORD_DEFAULT);
                
                // Update user password
                $updateQuery = "UPDATE users SET password = ? WHERE id = ?";
                $updateStmt = $db->prepare($updateQuery);
                $updateStmt->bindParam(1, $hashedPassword);
                $updateStmt->bindParam(2, $userId);
                
                if ($updateStmt->execute()) {
                    http_response_code(200);
                    echo json_encode(array(
                        "success" => true,
                        "message" => "Password changed successfully"
                    ));
                } else {
                    http_response_code(500);
                    echo json_encode(array(
                        "success" => false,
                        "message" => "Failed to update password"
                    ));
                }
            } else {
                http_response_code(401);
                echo json_encode(array(
                    "success" => false,
                    "message" => "Current password is incorrect"
                ));
            }
        } else {
            http_response_code(404);
            echo json_encode(array(
                "success" => false,
                "message" => "User not found"
            ));
        }
    } else {
        http_response_code(400);
        echo json_encode(array(
            "success" => false,
            "message" => "User ID, current password, and new password are required"
        ));
    }
} else {
    http_response_code(405);
    echo json_encode(array(
        "success" => false,
        "message" => "Method not allowed"
    ));
}
?>
