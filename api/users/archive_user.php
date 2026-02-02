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

// Handle POST and PUT methods
$method = $_SERVER['REQUEST_METHOD'];

if ($method == 'POST' || $method == 'PUT') {
    // Get data from request body
    $input = json_decode(file_get_contents("php://input"), true);
    
    // Validate required fields
    if (empty($input['user_id'])) {
        http_response_code(400);
        echo json_encode([
            'success' => false,
            'message' => 'User ID is required'
        ]);
        exit;
    }
    
    if (empty($input['admin_id'])) {
        http_response_code(400);
        echo json_encode([
            'success' => false,
            'message' => 'Admin ID is required for authorization'
        ]);
        exit;
    }
    
    $user_id = intval($input['user_id']);
    $admin_id = intval($input['admin_id']);
    
    try {
        // CRITICAL SAFETY CHECK: Prevent admin from archiving their own account
        if ($user_id === $admin_id) {
            http_response_code(403);
            echo json_encode([
                'success' => false,
                'message' => 'You cannot archive your own admin account. This is a safety measure to prevent system lockout.',
                'error_code' => 'SELF_ARCHIVE_FORBIDDEN'
            ]);
            exit;
        }
        
        // Verify that the requesting user is an admin
        $admin_check_query = "SELECT role FROM users WHERE id = :admin_id AND is_archived = 0";
        $admin_stmt = $db->prepare($admin_check_query);
        $admin_stmt->bindParam(':admin_id', $admin_id, PDO::PARAM_INT);
        $admin_stmt->execute();
        
        $admin = $admin_stmt->fetch(PDO::FETCH_ASSOC);
        
        if (!$admin || $admin['role'] !== 'admin') {
            http_response_code(403);
            echo json_encode([
                'success' => false,
                'message' => 'Unauthorized. Only admins can archive users.'
            ]);
            exit;
        }
        
        // Check if the user to be archived exists and is not already archived
        $user_check_query = "SELECT id, username, role, is_archived FROM users WHERE id = :user_id";
        $user_stmt = $db->prepare($user_check_query);
        $user_stmt->bindParam(':user_id', $user_id, PDO::PARAM_INT);
        $user_stmt->execute();
        
        $user = $user_stmt->fetch(PDO::FETCH_ASSOC);
        
        if (!$user) {
            http_response_code(404);
            echo json_encode([
                'success' => false,
                'message' => 'User not found'
            ]);
            exit;
        }
        
        if ($user['is_archived'] == 1) {
            http_response_code(400);
            echo json_encode([
                'success' => false,
                'message' => 'User is already archived'
            ]);
            exit;
        }
        
        // Archive the user (soft delete)
        $archive_query = "UPDATE users 
                         SET is_archived = 1, 
                             archived_at = NOW(), 
                             archived_by = :admin_id,
                             updated_at = NOW()
                         WHERE id = :user_id";
        $archive_stmt = $db->prepare($archive_query);
        $archive_stmt->bindParam(':user_id', $user_id, PDO::PARAM_INT);
        $archive_stmt->bindParam(':admin_id', $admin_id, PDO::PARAM_INT);
        
        if ($archive_stmt->execute()) {
            if ($archive_stmt->rowCount() > 0) {
                http_response_code(200);
                echo json_encode([
                    'success' => true,
                    'message' => 'User archived successfully',
                    'data' => [
                        'archived_user_id' => $user_id,
                        'archived_username' => $user['username'],
                        'archived_at' => date('Y-m-d H:i:s')
                    ]
                ]);
            } else {
                http_response_code(404);
                echo json_encode([
                    'success' => false,
                    'message' => 'User not found or already archived'
                ]);
            }
        } else {
            http_response_code(500);
            echo json_encode([
                'success' => false,
                'message' => 'Failed to archive user'
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
        'message' => 'Method not allowed. Use POST or PUT.'
    ]);
}
?>
