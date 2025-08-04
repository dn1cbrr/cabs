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
    // Get posted data
    $data = json_decode(file_get_contents("php://input"));
    
    // Check if data is valid
    if (
        !empty($data->username) && 
        !empty($data->email) && 
        !empty($data->password) && 
        !empty($data->full_name) &&
        !empty($data->license_name) &&
        !empty($data->license_number) &&
        !empty($data->license_address) &&
        !empty($data->license_codes) &&
        !empty($data->license_expiration) &&
        !empty($data->phone_number)
    ) {
        
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
        } else {
            // Hash password
            $hashed_password = password_hash($data->password, PASSWORD_DEFAULT);
            
            // Insert new user as driver with phone number and driver fields
            $query = "INSERT INTO users (username, email, password, full_name, phone_number, role, birthday, license_name, license_number, license_address, license_codes, license_expiration) VALUES (?, ?, ?, ?, ?, 'driver', ?, ?, ?, ?, ?, ?)";
            $stmt = $db->prepare($query);
            $stmt->bindParam(1, $data->username);
            $stmt->bindParam(2, $data->email);
            $stmt->bindParam(3, $hashed_password);
            $stmt->bindParam(4, $data->full_name);
            $stmt->bindParam(5, $data->phone_number);
            $stmt->bindParam(6, $data->birthday);
            $stmt->bindParam(7, $data->license_name);
            $stmt->bindParam(8, $data->license_number);
            $stmt->bindParam(9, $data->license_address);
            $stmt->bindParam(10, $data->license_codes);
            $stmt->bindParam(11, $data->license_expiration);
            
            if ($stmt->execute()) {
                $user_id = $db->lastInsertId();
                
                // Create driver record
                $driver_query = "INSERT INTO drivers (user_id, license_name, license_number, license_address, license_codes, license_expiration, status, created_at) 
                                VALUES (?, ?, ?, ?, ?, ?, 'pending', NOW())";
                $driver_stmt = $db->prepare($driver_query);
                $driver_stmt->bindParam(1, $user_id);
                $driver_stmt->bindParam(2, $data->license_name);
                $driver_stmt->bindParam(3, $data->license_number);
                $driver_stmt->bindParam(4, $data->license_address);
                $driver_stmt->bindParam(5, $data->license_codes);
                $driver_stmt->bindParam(6, $data->license_expiration);
                
                if ($driver_stmt->execute()) {
                    $driver_id = $db->lastInsertId();
                    
                    // Generate OTP
                    $otp_code = rand(100000, 999999);
                    $expires_at = date('Y-m-d H:i:s', strtotime('+10 minutes')); // OTP expires in 10 minutes
                    
                    // Store OTP in database
                    $otp_query = "INSERT INTO otp_verifications (user_id, otp_code, expires_at) VALUES (?, ?, ?)";
                    $otp_stmt = $db->prepare($otp_query);
                    $otp_stmt->bindParam(1, $user_id);
                    $otp_stmt->bindParam(2, $otp_code);
                    $otp_stmt->bindParam(3, $expires_at);
                    
                    if ($otp_stmt->execute()) {
                        // Send OTP via email
                        $to = $data->email;
                        $subject = "OTP Verification for Transit App";
                        $message = "Your OTP code is: $otp_code\n\nThis code will expire in 10 minutes.";
                        $headers = "From: no-reply@transitapp.com\r\n";
                        $headers .= "Reply-To: no-reply@transitapp.com\r\n";
                        $headers .= "X-Mailer: PHP/" . phpversion();
                        
                        // For production, use PHPMailer or Gmail SMTP for better email delivery
                        $mail_sent = mail($to, $subject, $message, $headers);
                        
                        // TODO: Implement SMS sending for phone number verification
                        // For now, we send OTP via email only
                        
                        http_response_code(201);
                        echo json_encode(array(
                            "success" => true,
                            "message" => "Driver account created successfully. Please check your email for OTP verification.",
                            "user" => array(
                                "id" => $user_id,
                                "username" => $data->username,
                                "email" => $data->email,
                                "full_name" => $data->full_name,
                                "phone_number" => $data->phone_number,
                                "role" => "driver",
                                "birthday" => $data->birthday,
                                "license_name" => $data->license_name,
                                "license_number" => $data->license_number,
                                "license_address" => $data->license_address,
                                "license_codes" => $data->license_codes,
                                "license_expiration" => $data->license_expiration,
                                "profile_photo" => null
                            ),
                            "driver" => array(
                                "id" => $driver_id,
                                "user_id" => $user_id
                            ),
                            "otp_required" => true
                        ));
                    } else {
                        // Rollback user and driver creation if OTP storage fails
                        $delete_driver_query = "DELETE FROM drivers WHERE id = ?";
                        $delete_driver_stmt = $db->prepare($delete_driver_query);
                        $delete_driver_stmt->bindParam(1, $driver_id);
                        $delete_driver_stmt->execute();
                        
                        $delete_user_query = "DELETE FROM users WHERE id = ?";
                        $delete_user_stmt = $db->prepare($delete_user_query);
                        $delete_user_stmt->bindParam(1, $user_id);
                        $delete_user_stmt->execute();
                        
                        http_response_code(500);
                        echo json_encode(array(
                            "success" => false,
                            "message" => "Unable to store OTP"
                        ));
                    }
                } else {
                    // Rollback user creation if driver creation fails
                    $delete_query = "DELETE FROM users WHERE id = ?";
                    $delete_stmt = $db->prepare($delete_query);
                    $delete_stmt->bindParam(1, $user_id);
                    $delete_stmt->execute();
                    
                    http_response_code(500);
                    echo json_encode(array(
                        "success" => false,
                        "message" => "Unable to create driver account"
                    ));
                }
            } else {
                http_response_code(500);
                echo json_encode(array(
                    "success" => false,
                    "message" => "Unable to register user"
                ));
            }
        }
        
    } else {
        // Missing data
        http_response_code(400);
        echo json_encode(array(
            "success" => false,
            "message" => "All fields are required including phone number"
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
