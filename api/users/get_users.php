<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: GET");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

require_once '../config/database.php';

// Check if request method is GET
if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
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

try {
    // First, check which columns exist
    $columnsQuery = "SHOW COLUMNS FROM users";
    $columnsStmt = $db->query($columnsQuery);
    $existingColumns = [];
    while ($col = $columnsStmt->fetch(PDO::FETCH_ASSOC)) {
        $existingColumns[] = $col['Field'];
    }
    
    // Build query with only existing columns
    $baseColumns = ['id', 'username', 'email', 'full_name', 'role', 'created_at'];
    $optionalColumns = [
        'phone_number', 'birthday', 'license_name', 'license_number', 
        'license_address', 'license_codes', 'license_expiration', 
        'profile_photo', 'is_online', 'last_seen'
    ];
    
    $selectColumns = $baseColumns;
    foreach ($optionalColumns as $col) {
        if (in_array($col, $existingColumns)) {
            $selectColumns[] = $col;
        }
    }
    
    $columnsList = implode(', ', $selectColumns);
    
    // Build WHERE clause based on available columns
    $whereClause = '';
    if (in_array('is_archived', $existingColumns)) {
        $whereClause = 'WHERE is_archived = 0 OR is_archived IS NULL';
    }
    
    $query = "SELECT $columnsList FROM users $whereClause ORDER BY created_at DESC";
    $stmt = $db->prepare($query);
    $stmt->execute();
    
    $users = [];
    while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
        // Ensure all expected fields exist with default values
        $user = [
            'id' => $row['id'] ?? '',
            'username' => $row['username'] ?? '',
            'email' => $row['email'] ?? '',
            'full_name' => $row['full_name'] ?? '',
            'role' => $row['role'] ?? 'user',
            'phone_number' => $row['phone_number'] ?? null,
            'birthday' => $row['birthday'] ?? null,
            'license_name' => $row['license_name'] ?? null,
            'license_number' => $row['license_number'] ?? null,
            'license_address' => $row['license_address'] ?? null,
            'license_codes' => $row['license_codes'] ?? null,
            'license_expiration' => $row['license_expiration'] ?? null,
            'profile_photo' => $row['profile_photo'] ?? null,
            'is_online' => isset($row['is_online']) ? (bool)$row['is_online'] : false,
            'last_seen' => $row['last_seen'] ?? null,
            'created_at' => $row['created_at'] ?? null,
        ];
        $users[] = $user;
    }
    
    http_response_code(200);
    echo json_encode([
        'success' => true,
        'data' => [
            'users' => $users
        ]
    ], JSON_UNESCAPED_UNICODE);
    
} catch (PDOException $e) {
    error_log("Get Users Error: " . $e->getMessage());
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => 'Database error: ' . $e->getMessage()
    ]);
}
