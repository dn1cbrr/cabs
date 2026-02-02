<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: POST, DELETE");
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

// Handle POST and DELETE methods
$method = $_SERVER['REQUEST_METHOD'];

if ($method == 'POST' || $method == 'DELETE') {
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
        // CRITICAL SAFETY CHECK: Prevent admin from deleting their own account
        if ($user_id === $admin_id) {
            http_response_code(403);
            echo json_encode([
                'success' => false,
                'message' => 'You cannot delete your own admin account. This is a safety measure to prevent system lockout.',
                'error_code' => 'SELF_DELETE_FORBIDDEN'
            ]);
            exit;
        }
        
        // Verify that the requesting user is an admin
        $admin_check_query = "SELECT role FROM users WHERE id = :admin_id";
        $admin_stmt = $db->prepare($admin_check_query);
        $admin_stmt->bindParam(':admin_id', $admin_id, PDO::PARAM_INT);
        $admin_stmt->execute();
        
        $admin = $admin_stmt->fetch(PDO::FETCH_ASSOC);
        
        if (!$admin || $admin['role'] !== 'admin') {
            http_response_code(403);
            echo json_encode([
                'success' => false,
                'message' => 'Unauthorized. Only admins can delete users.'
            ]);
            exit;
        }
        
        // Check if the user to be deleted exists
        $user_check_query = "SELECT id, username, role FROM users WHERE id = :user_id";
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
        
        // Additional safety check: Prevent deletion of other admin accounts (optional, can be removed if needed)
        // Uncomment the following block if you want to prevent deletion of ANY admin account
        /*
        if ($user['role'] === 'admin') {
            http_response_code(403);
            echo json_encode([
                'success' => false,
                'message' => 'Cannot delete admin accounts for security reasons.'
            ]);
            exit;
        }
        */
        
        // Delete the user
        $delete_query = "DELETE FROM users WHERE id = :user_id";
        $delete_stmt = $db->prepare($delete_query);
        $delete_stmt->bindParam(':user_id', $user_id, PDO::PARAM_INT);
        
        if ($delete_stmt->execute()) {
            if ($delete_stmt->rowCount() > 0) {
                http_response_code(200);
                echo json_encode([
                    'success' => true,
                    'message' => 'User deleted successfully',
                    'data' => [
                        'deleted_user_id' => $user_id,
                        'deleted_username' => $user['username']
                    ]
                ]);
            } else {
                http_response_code(404);
                echo json_encode([
                    'success' => false,
                    'message' => 'User not found or already deleted'
                ]);
            }
        } else {
            http_response_code(500);
            echo json_encode([
                'success' => false,
                'message' => 'Failed to delete user'
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
        'message' => 'Method not allowed. Use POST or DELETE.'
    ]);
}
?>
