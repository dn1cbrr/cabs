<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");

require_once '../config/database.php';

$database = new Database();
$db = $database->getConnection();

if ($db === null) {
    http_response_code(500);
    echo json_encode(["message" => "Database connection failed."]);
    exit();
}

try {
    $query = "
        SELECT 
            t.id,
            t.driver_id,
            u.full_name AS driver_name,
            t.route_details,
            t.vehicle_type,
            t.seat_capacity,
            t.current_occupancy,
            t.trip_date,
            t.start_time
        FROM 
            trips t
        JOIN 
            users u ON t.driver_id = u.id
        WHERE 
            u.role = 'driver'
        ORDER BY 
            t.trip_date DESC, t.start_time DESC
        LIMIT 1
    ";

    $stmt = $db->prepare($query);
    $stmt->execute();

    $trip = $stmt->fetch(PDO::FETCH_ASSOC);

    if ($trip) {
        // Calculate additional fields
        $trip['available_seats'] = $trip['seat_capacity'] - $trip['current_occupancy'];
        $occupancy_percentage = ($trip['seat_capacity'] > 0) ? $trip['current_occupancy'] / $trip['seat_capacity'] : 0;
        
        if ($occupancy_percentage >= 1.0) {
            $trip['occupancy_status'] = 'full';
        } elseif ($occupancy_percentage >= 0.8) {
            $trip['occupancy_status'] = 'almost_full';
        } else {
            $trip['occupancy_status'] = 'available';
        }

        echo json_encode(["success" => true, "trip" => $trip]);
    } else {
        echo json_encode(["success" => false, "message" => "No trips found."]);
    }
} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode([
        "success" => false,
        "message" => "An error occurred while fetching the latest trip.",
        "error" => $e->getMessage()
    ]);
}
?>
