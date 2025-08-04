<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, GET, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

require_once '../../config/database.php';

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(['error' => 'Method not allowed']);
    exit();
}

try {
    $data = json_decode(file_get_contents('php://input'), true);
    
    if (!$data) {
        throw new Exception('Invalid JSON data');
    }

    $required_fields = ['driver_id', 'route_details', 'seat_capacity', 'trip_date', 'start_time'];
    foreach ($required_fields as $field) {
        if (!isset($data[$field])) {
            throw new Exception("Missing required field: $field");
        }
    }

    $driver_id = intval($data['driver_id']);
    $route_details = trim($data['route_details']);
    $seat_capacity = intval($data['seat_capacity']);
    $trip_date = $data['trip_date'];
    $start_time = $data['start_time'];

    // Validate seat capacity
    if ($seat_capacity <= 0 || $seat_capacity > 50) {
        throw new Exception('Seat capacity must be between 1 and 50');
    }

    $pdo = Database::getInstance()->getConnection();
    
    // Get driver details
    $stmt = $pdo->prepare("SELECT * FROM drivers WHERE id = ?");
    $stmt->execute([$driver_id]);
    $driver = $stmt->fetch(PDO::FETCH_ASSOC);
    
    if (!$driver) {
        throw new Exception('Driver not found');
    }

    $stmt = $pdo->prepare("
        INSERT INTO driver_trips 
        (driver_id, route_details, seat_capacity, current_occupancy, occupancy_status, trip_date, start_time, created_at, updated_at) 
        VALUES (?, ?, ?, 0, 'available', ?, ?, NOW(), NOW())
    ");
    
    $stmt->execute([
        $driver_id,
        $route_details,
        $seat_capacity,
        $trip_date,
        $start_time
    ]);
    
    $trip_id = $pdo->lastInsertId();
    
    echo json_encode([
        'success' => true,
        'message' => 'Trip created successfully',
        'trip_id' => $trip_id,
        'available_seats' => $seat_capacity
    ]);

} catch (Exception $e) {
    http_response_code(400);
    echo json_encode(['error' => $e->getMessage()]);
}
?>
