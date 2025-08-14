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
    if (!empty($data->username) && !empty($data->email) && !empty($data->password) && !empty($data->full_name)) {
        
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
            
            // Insert new user
            $query = "INSERT INTO users (username, email, password, full_name, role, birthday, license_name, license_number, license_address, license_codes, license_expiration) VALUES (?, ?, ?, ?, 'user', ?, ?, ?, ?, ?, ?)";
            $stmt = $db->prepare($query);
            $stmt->bindParam(1, $data->username);
            $stmt->bindParam(2, $data->email);
            $stmt->bindParam(3, $hashed_password);
            $stmt->bindParam(4, $data->full_name);
            $stmt->bindParam(5, $data->birthday);
            $stmt->bindParam(6, $data->license_name);
            $stmt->bindParam(7, $data->license_number);
            $stmt->bindParam(8, $data->license_address);
            $stmt->bindParam(9, $data->license_codes);
            $stmt->bindParam(10, $data->license_expiration);
            
            if ($stmt->execute()) {
                $user_id = $db->lastInsertId();
                
                http_response_code(201);
                echo json_encode(array(
                    "success" => true,
                    "message" => "User registered successfully",
                    "user" => array(
                        "id" => $user_id,
                        "username" => $data->username,
                        "email" => $data->email,
                        "full_name" => $data->full_name,
                        "role" => "user",
                        "birthday" => $data->birthday,
                        "license_name" => $data->license_name,
                        "license_number" => $data->license_number,
                        "license_address" => $data->license_address,
                        "license_codes" => $data->license_codes,
                        "license_expiration" => $data->license_expiration,
                        "profile_photo" => null
                    )
                ));
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
            "message" => "All fields are required (username, email, password, full_name)"
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
