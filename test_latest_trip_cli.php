<?php
// A CLI script to test the database connection and the query from get_latest_trip.php

// Since this is run from the root, the path to database.php is relative to the root
require_once 'api/config/database.php';

echo "Testing database connection...\n";

$database = new Database();
$db = $database->getConnection();

if ($db === null) {
    echo "Database connection failed.\n";
    exit();
}

echo "Database connection successful.\n\n";

echo "Fetching latest trip...\n";

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
        echo "Latest trip found:\n";
        print_r($trip);
    } else {
        echo "No trips found.\n";
    }
} catch (PDOException $e) {
    echo "An error occurred while fetching the latest trip: " . $e->getMessage() . "\n";
}
?>
