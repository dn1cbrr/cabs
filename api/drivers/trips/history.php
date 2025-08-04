<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: GET");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

require_once '../../config/database.php';

if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    http_response_code(405);
    echo json_encode(['success' => false, 'message' => 'Method not allowed']);
    exit;
}

// Initialize database connection
$database = new Database();
$conn = $database->getConnection();

if (!$conn) {
    http_response_code(500);
    echo json_encode(['success' => false, 'message' => 'Database connection failed']);
    exit;
}

$driver_id = isset($_GET['driver_id']) ? intval($_GET['driver_id']) : null;
$start_date = isset($_GET['start_date']) ? $_GET['start_date'] : null;
$end_date = isset($_GET['end_date']) ? $_GET['end_date'] : null;
$limit = isset($_GET['limit']) ? intval($_GET['limit']) : 50;
$offset = isset($_GET['offset']) ? intval($_GET['offset']) : 0;

try {
    $query = "SELECT 
                dt.*,
                d.name as driver_name,
                d.license_number,
                d.vehicle_type,
                d.plate_number
              FROM driver_trips dt
              JOIN drivers d ON dt.driver_id = d.id
              WHERE d.is_active = TRUE";
    
    $params = [];
    
    if ($driver_id) {
        $query .= " AND dt.driver_id = :driver_id";
        $params[':driver_id'] = $driver_id;
    }
    
    if ($start_date && strtotime($start_date)) {
        $query .= " AND dt.trip_date >= :start_date";
        $params[':start_date'] = $start_date;
    }
    
    if ($end_date && strtotime($end_date)) {
        $query .= " AND dt.trip_date <= :end_date";
        $params[':end_date'] = $end_date;
    }
    
    $query .= " ORDER BY dt.trip_date DESC, dt.start_time DESC LIMIT :limit OFFSET :offset";
    
    $stmt = $conn->prepare($query);
    
    foreach ($params as $key => $value) {
        if ($key === ':driver_id' || $key === ':limit' || $key === ':offset') {
            $stmt->bindValue($key, $value, PDO::PARAM_INT);
        } else {
            $stmt->bindValue($key, $value);
        }
    }
    
    $stmt->bindValue(':limit', $limit, PDO::PARAM_INT);
    $stmt->bindValue(':offset', $offset, PDO::PARAM_INT);
    
    $stmt->execute();
    
    $trips = [];
    while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
        // Format duration
        $duration = null;
        if ($row['end_time']) {
            $start = new DateTime($row['start_time']);
            $end = new DateTime($row['end_time']);
            $interval = $start->diff($end);
            $duration = $interval->format('%H:%I:%S');
        }
        
        $row['duration'] = $duration;
        $trips[] = $row;
    }
    
    // Get total count for pagination
    $count_query = "SELECT COUNT(*) as total 
                    FROM driver_trips dt
                    JOIN drivers d ON dt.driver_id = d.id
                    WHERE d.is_active = TRUE";
    
    $count_params = [];
    if ($driver_id) {
        $count_query .= " AND dt.driver_id = :driver_id";
        $count_params[':driver_id'] = $driver_id;
    }
    if ($start_date && strtotime($start_date)) {
        $count_query .= " AND dt.trip_date >= :start_date";
        $count_params[':start_date'] = $start_date;
    }
    if ($end_date && strtotime($end_date)) {
        $count_query .= " AND dt.trip_date <= :end_date";
        $count_params[':end_date'] = $end_date;
    }
    
    $count_stmt = $conn->prepare($count_query);
    foreach ($count_params as $key => $value) {
        $count_stmt->bindValue($key, $value);
    }
    $count_stmt->execute();
    $total = $count_stmt->fetch(PDO::FETCH_ASSOC)['total'];
    
    echo json_encode([
        'success' => true,
        'trips' => $trips,
        'total' => intval($total),
        'limit' => $limit,
        'offset' => $offset
    ]);
    
} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => 'Database error: ' . $e->getMessage()
    ]);
}
?>
