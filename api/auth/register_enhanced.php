<?php
include_once '../config/database.php';
include_once '../utils/email_service.php';
include_once '../utils/token_generator.php';

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
    // Get posted data
    $data = json_decode(file_get_contents("php://input"));
    
    // Validate required fields
    $required_fields = ['username', 'email', 'password', 'full_name', 'phone'];
    $missing_fields = [];
    
    foreach ($required_fields as $field) {
        if (empty($data->$field)) {
            $missing_fields[] = $field;
        }
    }
    
    if (!empty($missing_fields)) {
        http_response_code(400);
        echo json_encode(array(
            "success" => false,
            "message" => "Missing required fields: " . implode(', ', $missing_fields)
        ));
        exit();
    }
    
    // Validate email format
    if (!filter_var($data->email, FILTER_VALIDATE_EMAIL)) {
        http_response_code(400);
        echo json_encode(array(
            "success" => false,
            "message" => "Invalid email format"
        ));
        exit();
    }
    
    // Validate phone format (basic validation)
    if (!preg_match('/^[0-9+\-\s()]+$/', $data->phone)) {
        http_response_code(400);
        echo json_encode(array(
            "success" => false,
            "message" => "Invalid phone format"
        ));
        exit();
    }
    
    // Validate password strength
    if (strlen($data->password) < 8) {
        http_response_code(400);
        echo json_encode(array(
            "success" => false,
            "message" => "Password must be at least 8 characters long"
        ));
        exit();
    }
    
    // Check if username or email already exists
    $check_query = "SELECT id FROM users WHERE username = ? OR email = ?";
    $check_stmt = $db->prepare($check_query);
    $check_stmt->bindParam(1, $data->username);
    $check_stmt->bindParam(2, $data->email);
    $check_stmt->execute();
    
    if ($check_stmt->rowCount() > 0) {
        http_response_code(409);
        echo json_encode(array(
            "success" => false,
            "message" => "Username or email already exists"
        ));
        exit();
    }
    
    // Hash password
    $hashed_password = password_hash($data->password, PASSWORD_DEFAULT);
    
    // Generate email verification token
    $verification_token = generateSecureToken();
    $verification_expires = date('Y-m-d H:i:s', strtotime('+24 hours'));
    
    // Handle profile photo upload (if provided)
    $profile_photo = null;
    if (!empty($data->profile_photo)) {
        // In production, handle actual file upload
        $profile_photo = $data->profile_photo;
    }
    
    // Insert new user
    $query = "INSERT INTO users (
        username, email, password, full_name, phone, profile_photo, role, 
        birthday, license_name, license_number, license_address, 
        license_codes, license_expiration, email_verification_token, 
        email_verification_expires
    ) VALUES (?, ?, ?, ?, ?, ?, 'user', ?, ?, ?, ?, ?, ?, ?, ?)";
    
    $stmt = $db->prepare($query);
    $stmt->bindParam(1, $data->username);
    $stmt->bindParam(2, $data->email);
    $stmt->bindParam(3, $hashed_password);
    $stmt->bindParam(4, $data->full_name);
    $stmt->bindParam(5, $data->phone);
    $stmt->bindParam(6, $profile_photo);
    $stmt->bindParam(7, $data->birthday);
    $stmt->bindParam(8, $data->license_name);
    $stmt->bindParam(9, $data->license_number);
    $stmt->bindParam(10, $data->license_address);
    $stmt->bindParam(11, $data->license_codes);
    $stmt->bindParam(12, $data->license_expiration);
    $stmt->bindParam(13, $verification_token);
    $stmt->bindParam(14, $verification_expires);
    
    if ($stmt->execute()) {
        $user_id = $db->lastInsertId();
        
        // Send verification email
        $email_sent = sendVerificationEmail($data->email, $verification_token, $data->full_name);
        
        // Log the verification attempt
        $log_query = "INSERT INTO email_verification_logs (user_id, email, verification_token, ip_address, user_agent) 
                      VALUES (?, ?, ?, ?, ?)";
        $log_stmt = $db->prepare($log_query);
        $log_stmt->bindParam(1, $user_id);
        $log_stmt->bindParam(2, $data->email);
        $log_stmt->bindParam(3, $verification_token);
        $log_stmt->bindParam(4, $_SERVER['REMOTE_ADDR']);
        $log_stmt->bindParam(5, $_SERVER['HTTP_USER_AGENT'] ?? '');
        $log_stmt->execute();
        
        http_response_code(201);
        echo json_encode(array(
            "success" => true,
            "message" => "User registered successfully. Please check your email to verify your account.",
            "user" => array(
                "id" => $user_id,
                "username" => $data->username,
                "email" => $data->email,
                "full_name" => $data->full_name,
                "phone" => $data->phone,
                "role" => "user",
                "email_verified" => false,
                "profile_photo" => $profile_photo
            ),
            "email_sent" => $email_sent
        ));
    } else {
        http_response_code(500);
        echo json_encode(array(
            "success" => false,
            "message" => "Unable to register user"
        ));
    }
    
} else {
    // Invalid request method
    http_response_code(405);
    echo json_encode(array(
        "success" => false,
        "message" => "Method not allowed"
    ));
}
?>
