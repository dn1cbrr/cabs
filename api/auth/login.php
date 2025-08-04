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
    if (!empty($data->username) && !empty($data->password)) {
        
        // Prepare select statement
        $query = "SELECT id, username, email, full_name, role, password, birthday, license_name, license_number, license_address, license_codes, license_expiration, profile_photo FROM users WHERE username = ? LIMIT 0,1";
        $stmt = $db->prepare($query);
        $stmt->bindParam(1, $data->username);
        $stmt->execute();
        
        $num = $stmt->rowCount();
        
        if ($num > 0) {
            $row = $stmt->fetch(PDO::FETCH_ASSOC);
            
            // Verify password (assuming passwords are hashed with password_hash())
            // For the sample data with bcrypt hashes, we'll use password_verify
            if (password_verify($data->password, $row['password'])) {
                
                // Create response array
                $response = array(
                    "success" => true,
                    "message" => "Login successful",
                    "user" => array(
                        "id" => $row['id'],
                        "username" => $row['username'],
                        "email" => $row['email'],
                        "full_name" => $row['full_name'],
                        "role" => $row['role'],
                        "birthday" => $row['birthday'],
                        "license_name" => $row['license_name'],
                        "license_number" => $row['license_number'],
                        "license_address" => $row['license_address'],
                        "license_codes" => $row['license_codes'],
                        "license_expiration" => $row['license_expiration'],
                        "profile_photo" => $row['profile_photo']
                    )
                );
                
                http_response_code(200);
                echo json_encode($response);
                
            } else {
                // Invalid password
                http_response_code(401);
                echo json_encode(array(
                    "success" => false,
                    "message" => "Invalid username or password"
                ));
            }
            
        } else {
            // User not found
            http_response_code(401);
            echo json_encode(array(
                "success" => false,
                "message" => "Invalid username or password"
            ));
        }
        
    } else {
        // Missing data
        http_response_code(400);
        echo json_encode(array(
            "success" => false,
            "message" => "Username and password are required"
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
