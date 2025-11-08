<?php
include_once '../config/database.php';
include_once '../utils/token_generator.php';

header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

$database = new Database();
$db = $database->getConnection();

if ($_SERVER['REQUEST_METHOD'] == 'GET') {
    // Handle GET request (for email link clicks)
    $token = isset($_GET['token']) ? $_GET['token'] : '';
    
    if (empty($token)) {
        echo "<h2>Invalid verification link</h2><p>The verification token is missing.</p>";
        exit();
    }
    
    // Verify token
    $query = "SELECT id, email, email_verification_expires FROM users 
              WHERE email_verification_token = ? AND email_verified = 0";
    $stmt = $db->prepare($query);
    $stmt->bindParam(1, $token);
    $stmt->execute();
    
    if ($stmt->rowCount() == 0) {
        echo "<h2>Invalid or expired verification link</h2><p>This verification link is invalid or has already been used.</p>";
        exit();
    }
    
    $user = $stmt->fetch(PDO::FETCH_ASSOC);
    
    // Check if token has expired
    if (strtotime($user['email_verification_expires']) < time()) {
        echo "<h2>Verification link expired</h2><p>This verification link has expired. Please request a new one.</p>";
        exit();
    }
    
    // Update user as verified
    $update_query = "UPDATE users SET email_verified = 1, email_verification_token = NULL, 
                     email_verification_expires = NULL, updated_at = NOW() WHERE id = ?";
    $update_stmt = $db->prepare($update_query);
    $update_stmt->bindParam(1, $user['id']);
    
    if ($update_stmt->execute()) {
        echo "<h2>Email Verified Successfully!</h2>
              <p>Your email address has been verified. You can now log in to your account.</p>
              <p><a href='https://yourdomain.com/login'>Go to Login</a></p>";
    } else {
        echo "<h2>Verification Failed</h2><p>There was an error verifying your email. Please try again.</p>";
    }
    
} elseif ($_SERVER['REQUEST_METHOD'] == 'POST') {
    // Handle POST request (for API calls)
    $data = json_decode(file_get_contents("php://input"));
    $token = isset($data->token) ? $data->token : '';
    
    if (empty($token)) {
        http_response_code(400);
        echo json_encode(array(
            "success" => false,
            "message" => "Verification token is required"
        ));
        exit();
    }
    
    // Verify token
    $query = "SELECT id, email, email_verification_expires FROM users 
              WHERE email_verification_token = ? AND email_verified = 0";
    $stmt = $db->prepare($query);
    $stmt->bindParam(1, $token);
    $stmt->execute();
    
    if ($stmt->rowCount() == 0) {
        http_response_code(400);
        echo json_encode(array(
            "success" => false,
            "message" => "Invalid or expired verification token"
        ));
        exit();
    }
    
    $user = $stmt->fetch(PDO::FETCH_ASSOC);
    
    // Check if token has expired
    if (strtotime($user['email_verification_expires']) < time()) {
        http_response_code(400);
        echo json_encode(array(
            "success" => false,
            "message" => "Verification token has expired"
        ));
        exit();
    }
    
    // Update user as verified
    $update_query = "UPDATE users SET email_verified = 1, email_verification_token = NULL, 
                     email_verification_expires = NULL, updated_at = NOW() WHERE id = ?";
    $update_stmt = $db->prepare($update_query);
    $update_stmt->bindParam(1, $user['id']);
    
    if ($update_stmt->execute()) {
        http_response_code(200);
        echo json_encode(array(
            "success" => true,
            "message" => "Email verified successfully"
        ));
    } else {
        http_response_code(500);
        echo json_encode(array(
            "success" => false,
            "message" => "Failed to verify email"
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
