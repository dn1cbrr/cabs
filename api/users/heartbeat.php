<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

require_once '../config/database.php';

// Handle preflight OPTIONS request
if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    http_response_code(200);
    exit;
}

// Check if request method is POST
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(['success' => false, 'message' => 'Method not allowed']);
    exit;
}

$database = new Database();
$db = $database->getConnection();

if (!$db) {
    http_response_code(500);
    echo json_encode(['success' => false, 'message' => 'Database connection failed']);
    exit;
}

// Get heartbeat data from request body
$input = json_decode(file_get_contents("php://input"), true);

if (!$input || !isset($input['user_id'])) {
    http_response_code(400);
    echo json_encode(['success' => false, 'message' => 'User ID is required']);
    exit;
}

$user_id = intval($input['user_id']);

try {
    // Update user's online status and last seen timestamp
    $query = "UPDATE users SET is_online = TRUE, last_seen = NOW() WHERE id = :user_id";
    $stmt = $db->prepare($query);
    $stmt->bindParam(':user_id', $user_id, PDO::PARAM_INT);

    if ($stmt->execute()) {
        if ($stmt->rowCount() > 0) {
            http_response_code(200);
            echo json_encode([
                'success' => true,
                'message' => 'Heartbeat updated successfully',
                'timestamp' => date('Y-m-d H:i:s')
            ]);
        } else {
            http_response_code(404);
            echo json_encode([
                'success' => false,
                'message' => 'User not found'
            ]);
        }
    } else {
        http_response_code(500);
        echo json_encode([
            'success' => false,
            'message' => 'Failed to update heartbeat'
        ]);
    }
} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => 'Database error: ' . $e->getMessage()
    ]);
}
?>
