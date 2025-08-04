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
    // Handle both JSON and multipart form data
    $data = [];
    
    // Check if it's multipart form data (file upload)
    if (isset($_FILES['profile_photo']) || !empty($_POST)) {
        // Multipart form data
        $data['user_id'] = $_POST['user_id'] ?? null;
        $data['full_name'] = $_POST['full_name'] ?? null;
        $data['email'] = $_POST['email'] ?? null;
        $data['phone_number'] = $_POST['phone_number'] ?? null;
        $data['license_name'] = $_POST['license_name'] ?? null;
        $data['license_number'] = $_POST['license_number'] ?? null;
        $data['license_address'] = $_POST['license_address'] ?? null;
        $data['license_codes'] = $_POST['license_codes'] ?? null;
        $data['license_expiration'] = $_POST['license_expiration'] ?? null;
        $data['birthday'] = $_POST['birthday'] ?? null;
    } else {
        // JSON data
        $input = json_decode(file_get_contents("php://input"), true);
        $data = $input;
    }

    if (empty($data['user_id'])) {
        http_response_code(400);
        echo json_encode([
            "success" => false,
            "message" => "User ID is required"
        ]);
        exit;
    }

    // Handle profile photo upload if provided
    $profile_photo_path = null;
    if (isset($_FILES['profile_photo']) && $_FILES['profile_photo']['error'] == 0) {
        $upload_dir = '../uploads/profile_photos/';
        if (!is_dir($upload_dir)) {
            mkdir($upload_dir, 0777, true);
        }
        
        $file_extension = pathinfo($_FILES['profile_photo']['name'], PATHINFO_EXTENSION);
        $file_name = 'user_' . $data['user_id'] . '_' . time() . '.' . $file_extension;
        $file_path = $upload_dir . $file_name;
        
        if (move_uploaded_file($_FILES['profile_photo']['tmp_name'], $file_path)) {
            $profile_photo_path = $file_path;
        }
    }

    // Prepare update statement
    if ($profile_photo_path) {
        $query = "UPDATE users SET 
            full_name = :full_name,
            email = :email,
            phone_number = :phone_number,
            license_name = :license_name,
            license_number = :license_number,
            license_address = :license_address,
            license_codes = :license_codes,
            license_expiration = :license_expiration,
            birthday = :birthday,
            profile_photo = :profile_photo
            WHERE id = :user_id";
    } else {
        $query = "UPDATE users SET 
            full_name = :full_name,
            email = :email,
            phone_number = :phone_number,
            license_name = :license_name,
            license_number = :license_number,
            license_address = :license_address,
            license_codes = :license_codes,
            license_expiration = :license_expiration,
            birthday = :birthday
            WHERE id = :user_id";
    }

    $stmt = $db->prepare($query);

    $stmt->bindValue(':full_name', $data['full_name'] ?? null);
    $stmt->bindValue(':email', $data['email'] ?? null);
    $stmt->bindValue(':phone_number', $data['phone_number'] ?? null);
    $stmt->bindValue(':license_name', $data['license_name'] ?? null);
    $stmt->bindValue(':license_number', $data['license_number'] ?? null);
    $stmt->bindValue(':license_address', $data['license_address'] ?? null);
    $stmt->bindValue(':license_codes', $data['license_codes'] ?? null);
    $stmt->bindValue(':license_expiration', !empty($data['license_expiration']) ? date('Y-m-d', strtotime($data['license_expiration'])) : null);
    $stmt->bindValue(':birthday', !empty($data['birthday']) ? date('Y-m-d', strtotime($data['birthday'])) : null);
    $stmt->bindValue(':user_id', $data['user_id']);
    
    if ($profile_photo_path) {
        $stmt->bindValue(':profile_photo', $profile_photo_path);
    }

    if ($stmt->execute()) {
        http_response_code(200);
        echo json_encode([
            "success" => true,
            "message" => "Profile updated successfully"
        ]);
    } else {
        http_response_code(500);
        echo json_encode([
            "success" => false,
            "message" => "Failed to update profile"
        ]);
    }
} else {
    http_response_code(405);
    echo json_encode([
        "success" => false,
        "message" => "Method not allowed"
    ]);
}
?>
