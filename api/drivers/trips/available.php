<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

require_once '../../config/database.php';

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    http_response_code(405);
    echo json_encode(['error' => 'Method not allowed']);
    exit();
}

try {
    $pdo = new PDO('mysql:host=' . DB_HOST . ';dbname=' . DB_NAME, DB_USER, DB_PASS);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    $stmt = $pdo->query("
        SELECT 
            dt.*,
            d.name as driver_name,
            d.license_number,
            d.vehicle_type,
            d.plate_number,
            (dt.seat_capacity - dt.current_occupancy) as available_seats
        FROM driver_trips dt
        JOIN drivers d ON dt.driver_id = d.id
        WHERE dt.trip_date >= CURDATE()
        AND dt.occupancy_status != 'full'
        ORDER BY dt.trip_date ASC, dt.start_time ASC
    ");

    $trips = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo json_encode([
        'success' => true,
        'trips' => $trips,
        'total_available' => count($trips)
    ]);

} catch (Exception $e) {
    http_response_code(400);
    echo json_encode(['error' => $e->getMessage()]);
}
?>
