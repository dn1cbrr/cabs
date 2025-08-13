<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");

require_once '../config/database.php';

// Handle preflight requests
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    exit(0);
}

$data = json_decode(file_get_contents("php://input"));

if (isset($data->trip_id) && isset($data->new_occupancy)) {
    $trip_id = $data->trip_id;
    $new_occupancy = $data->new_occupancy;

    $database = new Database();
    $db = $database->getConnection();

    // First, get the seat capacity for the trip
    $query = "SELECT seat_capacity FROM driver_trips WHERE id = :trip_id";
    $stmt = $db->prepare($query);
    $stmt->bindParam(':trip_id', $trip_id);
    $stmt->execute();
    $row = $stmt->fetch(PDO::FETCH_ASSOC);

    if ($row) {
        $seat_capacity = $row['seat_capacity'];

        // Determine the new occupancy status
        if ($new_occupancy >= $seat_capacity) {
            $occupancy_status = 'full';
        } elseif ($new_occupancy >= $seat_capacity * 0.8) {
            $occupancy_status = 'limited';
        } else {
            $occupancy_status = 'available';
        }

        // Now, update the trip with the new occupancy and status
        $query = "UPDATE driver_trips SET current_occupancy = :new_occupancy, occupancy_status = :occupancy_status WHERE id = :trip_id";
        $stmt = $db->prepare($query);

        $stmt->bindParam(':new_occupancy', $new_occupancy);
        $stmt->bindParam(':occupancy_status', $occupancy_status);
        $stmt->bindParam(':trip_id', $trip_id);


        if ($stmt->execute()) {
            echo json_encode(array("message" => "Occupancy updated successfully."));
        } else {
            echo json_encode(array("message" => "Unable to update occupancy."));
        }
    } else {
        echo json_encode(array("message" => "Trip not found."));
    }
} else {
    echo json_encode(array("message" => "Incomplete data."));
}
?>
