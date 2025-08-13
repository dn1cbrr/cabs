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
    
    if (!empty($data->token) && !empty($data->new_password)) {
        $token = $data->token;
        $newPassword = $data->new_password;
        
        // Validate token
        $query = "SELECT pr.user_id, pr.expires_at, pr.is_used, u.username 
                  FROM password_resets pr 
                  JOIN users u ON pr.user_id = u.id 
                  WHERE pr.reset_token = ? AND pr.is_used = 0 
                  LIMIT 0,1";
        
        $stmt = $db->prepare($query);
        $stmt->bindParam(1, $token);
        $stmt->execute();
        
        if ($stmt->rowCount() > 0) {
            $resetData = $stmt->fetch(PDO::FETCH_ASSOC);
            
            // Check if token is expired
            $currentTime = date('Y-m-d H:i:s');
            if ($currentTime > $resetData['expires_at']) {
                http_response_code(400);
                echo json_encode(array(
                    "success" => false,
                    "message" => "Reset token has expired"
                ));
                exit();
            }
            
            // Hash new password
            $hashedPassword = password_hash($newPassword, PASSWORD_DEFAULT);
            
            // Update user password
            $updateQuery = "UPDATE users SET password = ? WHERE id = ?";
            $updateStmt = $db->prepare($updateQuery);
            $updateStmt->bindParam(1, $hashedPassword);
            $updateStmt->bindParam(2, $resetData['user_id']);
            
            if ($updateStmt->execute()) {
                // Mark token as used
                $markUsedQuery = "UPDATE password_resets SET is_used = 1 WHERE reset_token = ?";
                $markUsedStmt = $db->prepare($markUsedQuery);
                $markUsedStmt->bindParam(1, $token);
                $markUsedStmt->execute();
                
                http_response_code(200);
                echo json_encode(array(
                    "success" => true,
                    "message" => "Password reset successfully"
                ));
            } else {
                http_response_code(500);
                echo json_encode(array(
                    "success" => false,
                    "message" => "Failed to reset password"
                ));
            }
        } else {
            http_response_code(400);
            echo json_encode(array(
                "success" => false,
                "message" => "Invalid or expired reset token"
            ));
        }
    } else {
        http_response_code(400);
        echo json_encode(array(
            "success" => false,
            "message" => "Reset token and new password are required"
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
