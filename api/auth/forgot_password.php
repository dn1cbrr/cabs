<?php
include_once '../config/database.php';
include_once '../utils/email_helper.php';

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
    
    if (!empty($data->email) && filter_var($data->email, FILTER_VALIDATE_EMAIL)) {
        $email = trim($data->email);
        
        try {
            // Check if email exists
            $query = "SELECT id, username, email FROM users WHERE email = ? LIMIT 1";
            $stmt = $db->prepare($query);
            $stmt->execute([$email]);
            
            if ($stmt->rowCount() > 0) {
                $user = $stmt->fetch(PDO::FETCH_ASSOC);
                
                // Generate secure reset token
                $resetToken = bin2hex(random_bytes(32));
                $expiresAt = date('Y-m-d H:i:s', strtotime('+1 hour'));
                
                // Delete any existing unused tokens for this user
                $deleteQuery = "DELETE FROM password_resets WHERE user_id = ? AND is_used = 0";
                $deleteStmt = $db->prepare($deleteQuery);
                $deleteStmt->execute([$user['id']]);
                
                // Store new reset token in database
                $insertQuery = "INSERT INTO password_resets (user_id, reset_token, expires_at) VALUES (?, ?, ?)";
                $insertStmt = $db->prepare($insertQuery);
                $insertStmt->execute([$user['id'], $resetToken, $expiresAt]);
                
                if ($insertStmt) {
                    // Create reset link - ensure correct path structure
                    $protocol = (isset($_SERVER['HTTPS']) && $_SERVER['HTTPS'] === 'on') ? "https" : "http";
                    $host = $_SERVER['HTTP_HOST'];
                    $scriptPath = dirname($_SERVER['SCRIPT_NAME']);
                    $basePath = rtrim($scriptPath, '/');
                    $resetLink = "{$protocol}://{$host}{$basePath}/../../reset-password.php?token={$resetToken}";
                    
                    // Clean up the path
                    $resetLink = str_replace('/api/auth/../../', '/', $resetLink);
                    
                    // For development/testing - log the reset link
                    EmailHelper::logPasswordReset($email, $resetLink, $user['username']);
                    
                    // Send the email
                    $emailSent = EmailHelper::sendPasswordResetEmail($email, $resetLink, $user['username']);

                    // Always return a consistent success message to the user to prevent email enumeration attacks.
                    // The actual success/failure of the email sending will be in the server logs.
                    http_response_code(200);
                    echo json_encode(array(
                        "success" => true,
                        "message" => "If the email address exists in our system, you will receive password reset instructions"
                    ));

                } else {
                    throw new Exception("Failed to store reset token");
                }
            } else {
                // Don't reveal if email exists or not for security
                http_response_code(200);
                echo json_encode(array(
                    "success" => true,
                    "message" => "If the email address exists in our system, you will receive password reset instructions"
                ));
            }
        } catch (Exception $e) {
            http_response_code(500);
            echo json_encode(array(
                "success" => false,
                "message" => "An error occurred while processing your request",
                "error" => $e->getMessage()
            ));
        }
    } else {
        http_response_code(400);
        echo json_encode(array(
            "success" => false,
            "message" => "Please provide a valid email address"
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
