<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: POST, PUT");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

require_once '../config/database.php';

// Handle preflight OPTIONS request
if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    http_response_code(200);
    exit;
}

$database = new Database();
$db = $database->getConnection();

if (!$db) {
    http_response_code(500);
    echo json_encode(['success' => false, 'message' => 'Database connection failed']);
    exit;
}

// Handle both POST and PUT methods
$method = $_SERVER['REQUEST_METHOD'];

// Get user data from request body
if ($method == 'POST' || $method == 'PUT') {
    // Handle both JSON and multipart form data
    $data = [];
    
    // Check if it's multipart form data
    if (isset($_FILES['profile_photo']) || !empty($_POST)) {
        $data['user_id'] = $_POST['user_id'] ?? null;
        $data['username'] = $_POST['username'] ?? null;
        $data['email'] = $_POST['email'] ?? null;
        $data['full_name'] = $_POST['full_name'] ?? null;
        $data['phone_number'] = $_POST['phone_number'] ?? null;
        $data['birthday'] = $_POST['birthday'] ?? null;
        $data['license_name'] = $_POST['license_name'] ?? null;
        $data['license_number'] = $_POST['license_number'] ?? null;
        $data['license_address'] = $_POST['license_address'] ?? null;
        $data['license_codes'] = $_POST['license_codes'] ?? null;
        $data['license_expiration'] = $_POST['license_expiration'] ?? null;
        $data['role'] = $_POST['role'] ?? null;
    } else {
        // JSON data
        $input = json_decode(file_get_contents("php://input"), true);
        $data = $input;
    }

    // Validate required fields
    if (empty($data['user_id'])) {
        http_response_code(400);
        echo json_encode([
            'success' => false,
            'message' => 'User ID is required'
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

    // Build dynamic query based on provided fields
    $fields = [];
    $params = [':user_id' => $data['user_id']];
    
    $allowed_fields = ['username', 'email', 'full_name', 'phone_number', 'birthday', 
                      'license_name', 'license_number', 'license_address', 
                      'license_codes', 'license_expiration', 'role'];
    
    foreach ($allowed_fields as $field) {
        if (isset($data[$field]) && $data[$field] !== null) {
            $fields[] = "$field = :$field";
            $params[":$field"] = htmlspecialchars(strip_tags(trim($data[$field])));
        }
    }
    
    if (empty($fields)) {
        http_response_code(400);
        echo json_encode(['success' => false, 'message' => 'No fields to update']);
        exit;
    }
    
    try {
        $query = "UPDATE users SET " . implode(', ', $fields) . ", updated_at = NOW() WHERE id = :user_id";
        $stmt = $db->prepare($query);
        
        foreach ($params as $key => $value) {
            if ($key === ':user_id' || is_numeric($value)) {
                $stmt->bindValue($key, $value, PDO::PARAM_INT);
            } else {
                $stmt->bindValue($key, $value);
            }
        }
        
        if ($stmt->execute()) {
            if ($stmt->rowCount() > 0) {
                echo json_encode([
                    'success' => true,
                    'message' => 'User updated successfully'
                ]);
            } else {
                echo json_encode([
                    'success' => false,
                    'message' => 'No user found with the given ID or no changes made'
                ]);
            }
        } else {
            echo json_encode([
                'success' => false,
                'message' => 'Failed to update user'
            ]);
        }
    } catch (PDOException $e) {
        http_response_code(500);
        echo json_encode([
            'success' => false,
            'message' => 'Database error: ' . $e->getMessage()
        ]);
    }
} else {
    http_response_code(405);
    echo json_encode([
        'success' => false,
        'message' => 'Method not allowed'
    ]);
}
?>
