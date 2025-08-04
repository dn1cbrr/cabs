<?php
include_once '../config/database.php';

header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

// Handle preflight OPTIONS request
if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    exit(0);
}

$database = new Database();
$db = $database->getConnection();

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    // Get posted data
    $data = json_decode(file_get_contents("php://input"));
    
    // Check if data is valid
    if (
        !empty($data->name) && 
        !empty($data->birthday) && 
        !empty($data->age) && 
        !empty($data->address) && 
        !empty($data->contact) && 
        !empty($data->license_name) && 
        !empty($data->license_number) && 
        !empty($data->license_address) && 
        !empty($data->license_codes) && 
        !empty($data->expiration_date) && 
        !empty($data->vehicle_type) && 
        !empty($data->plate_number)
    ) {
        
        // Check if license number already exists
        $check_query = "SELECT id FROM drivers WHERE license_number = ?";
        $check_stmt = $db->prepare($check_query);
        $check_stmt->bindParam(1, $data->license_number);
        $check_stmt->execute();
        
        if ($check_stmt->rowCount() > 0) {
            http_response_code(409);
            echo json_encode(array(
                "success" => false,
                "message" => "Driver with this license number already exists"
            ));
        } else {
            // Insert new driver
            $query = "INSERT INTO drivers 
                     (name, birthday, age, address, contact, license_name, license_number, 
                      license_address, license_codes, expiration_date, vehicle_type, plate_number, 
                      status, created_at, updated_at) 
                     VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 'active', NOW(), NOW())";
            
            $stmt = $db->prepare($query);
            
            // Bind parameters
            $stmt->bindParam(1, $data->name);
            $stmt->bindParam(2, $data->birthday);
            $stmt->bindParam(3, $data->age);
            $stmt->bindParam(4, $data->address);
            $stmt->bindParam(5, $data->contact);
            $stmt->bindParam(6, $data->license_name);
            $stmt->bindParam(7, $data->license_number);
            $stmt->bindParam(8, $data->license_address);
            $stmt->bindParam(9, $data->license_codes);
            $stmt->bindParam(10, $data->expiration_date);
            $stmt->bindParam(11, $data->vehicle_type);
            $stmt->bindParam(12, $data->plate_number);
            
            if ($stmt->execute()) {
                $driver_id = $db->lastInsertId();
                
                http_response_code(201);
                echo json_encode(array(
                    "success" => true,
                    "message" => "Driver added successfully",
                    "driver_id" => $driver_id
                ));
            } else {
                http_response_code(500);
                echo json_encode(array(
                    "success" => false,
                    "message" => "Unable to add driver"
                ));
            }
        }
        
    } else {
        // Missing data
        http_response_code(400);
        echo json_encode(array(
            "success" => false,
            "message" => "All fields are required",
            "received_data" => $data
        ));
    }
    
} else {
    // Invalid request method
    http_response_code(405);
    echo json_encode(array(
        "success" => false,
        "message" => "Method not allowed"
    ));
}
?>
