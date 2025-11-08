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

// Set JSON response headers
header('Content-Type: application/json');

// Initialize response
$response = ['success' => false, 'message' => ''];

try {
    if ($_SERVER['REQUEST_METHOD'] != 'POST') {
        http_response_code(405);
        $response['message'] = 'Method not allowed';
        echo json_encode($response);
        exit;
    }

    // Get input data
    $input = file_get_contents("php://input");
    if (empty($input)) {
        http_response_code(400);
        $response['message'] = 'Empty request body';
        echo json_encode($response);
        exit;
    }

    $data = json_decode($input);
    if (json_last_error() !== JSON_ERROR_NONE) {
        http_response_code(400);
        $response['message'] = 'Invalid JSON format';
        echo json_encode($response);
        exit;
    }

    // Validate input
    if (empty($data) || !isset($data->email)) {
        http_response_code(400);
        $response['message'] = 'Email address is required';
        echo json_encode($response);
        exit;
    }

    // Validate email format
    if (!filter_var($data->email, FILTER_VALIDATE_EMAIL)) {
        http_response_code(400);
        $response['message'] = 'Please provide a valid email address';
        echo json_encode($response);
        exit;
    }

    $email = trim($data->email);

    // Check if email exists
    $query = "SELECT id, username, email FROM users WHERE email = ? LIMIT 1";
    $stmt = $db->prepare($query);
    
    if (!$stmt) {
        throw new Exception("Database prepare failed: " . implode(" ", $db->errorInfo()));
    }
    
    $stmt->execute([$email]);
    
    if ($stmt->rowCount() > 0) {
        $user = $stmt->fetch(PDO::FETCH_ASSOC);
        
        // Generate secure reset token
        $resetToken = bin2hex(random_bytes(32));
        $expiresAt = date('Y-m-d H:i:s', strtotime('+1 hour'));
        
        // Start transaction
        $db->beginTransaction();
        
        try {
            // Delete any existing unused tokens for this user
            $deleteQuery = "DELETE FROM password_resets WHERE user_id = ? AND is_used = 0";
            $deleteStmt = $db->prepare($deleteQuery);
            $deleteStmt->execute([$user['id']]);
            
            // Store new reset token in database
            $insertQuery = "INSERT INTO password_resets (user_id, reset_token, expires_at) VALUES (?, ?, ?)";
            $insertStmt = $db->prepare($insertQuery);
            $insertSuccess = $insertStmt->execute([$user['id'], $resetToken, $expiresAt]);
            
            if (!$insertSuccess) {
                throw new Exception("Failed to store reset token");
            }
            
            // Commit transaction
            $db->commit();
            
            // Create reset link - ensure correct path structure
            $protocol = (isset($_SERVER['HTTPS']) && $_SERVER['HTTPS'] === 'on') ? "https" : "http";
            $host = $_SERVER['HTTP_HOST'];
            $scriptPath = dirname($_SERVER['SCRIPT_NAME']);
            $basePath = rtrim($scriptPath, '/');
            $resetLink = "{$protocol}://{$host}{$basePath}/../../reset-password.php?token={$resetToken}";
            
            // Clean up the path
            $resetLink = str_replace('/api/auth/../../', '/', $resetLink);
            
            // Try to send email
            $emailSent = false;
            try {
                $emailHelper = new EmailHelper();
                $emailSent = $emailHelper->sendPasswordResetEmail($email, $resetLink, $user['username']);
            } catch (Exception $e) {
                // Log email error but don't expose to user
                error_log("Email sending failed: " . $e->getMessage());
            }
            
            // Always log the reset link for testing
            EmailHelper::logPasswordReset($email, $resetLink, $user['username']);
            
            http_response_code(200);
            $response = [
                "success" => true,
                "message" => "If the email address exists in our system, you will receive password reset instructions",
                "debug_info" => [
                    "email_sent" => $emailSent,
                    "reset_link" => $resetLink // Remove this in production
                ]
            ];
            
        } catch (Exception $e) {
            $db->rollBack();
            throw $e;
        }
        
    } else {
        // Don't reveal if email exists or not for security
        http_response_code(200);
        $response = [
            "success" => true,
            "message" => "If the email address exists in our system, you will receive password reset instructions"
        ];
    }
    
} catch (PDOException $e) {
    http_response_code(500);
    $response = [
        "success" => false,
        "message" => "Database error occurred",
        "error" => $e->getMessage() // Remove in production
    ];
} catch (Exception $e) {
    http_response_code(500);
    $response = [
        "success" => false,
        "message" => "An error occurred while processing your request",
        "error" => $e->getMessage() // Remove in production
    ];
}

// Ensure we always return valid JSON
echo json_encode($response, JSON_PRETTY_PRINT);
?>
