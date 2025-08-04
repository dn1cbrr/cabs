<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

require_once '../config/database.php';

$method = $_SERVER['REQUEST_METHOD'];

switch ($method) {
    case 'GET':
        getDrivers();
        break;
    case 'POST':
        addDriver();
        break;
    case 'PUT':
        updateDriver();
        break;
    case 'DELETE':
        deleteDriver();
        break;
    case 'OPTIONS':
        http_response_code(200);
        break;
    default:
        http_response_code(405);
        echo json_encode(['message' => 'Method not allowed']);
        break;
}

function getDrivers() {
    global $conn;
    
    if (!$conn) {
        http_response_code(500);
        echo json_encode([
            'success' => false,
            'message' => 'Database connection failed'
        ]);
        return;
    }
    
    try {
        $query = "SELECT * FROM drivers WHERE is_active = TRUE ORDER BY created_at DESC";
        $stmt = $conn->prepare($query);
        $stmt->execute();
        
        $drivers = [];
        while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
            $drivers[] = $row;
        }
        
        echo json_encode([
            'success' => true,
            'drivers' => $drivers
        ]);
    } catch (PDOException $e) {
        http_response_code(500);
        echo json_encode([
            'success' => false,
            'message' => 'Database error: ' . $e->getMessage()
        ]);
    }
}

function addDriver() {
    global $conn;
    
    if (!$conn) {
        http_response_code(500);
        echo json_encode([
            'success' => false,
            'message' => 'Database connection failed'
        ]);
        return;
    }
    
    $data = json_decode(file_get_contents("php://input"), true);
    
    if (!$data) {
        http_response_code(400);
        echo json_encode(['success' => false, 'message' => 'Invalid JSON data']);
        return;
    }
    
    $required_fields = ['name', 'birthday', 'age', 'address', 'contact', 
                       'license_name', 'license_number', 'license_address', 
                       'license_codes', 'expiration_date', 'vehicle_type', 'plate_number'];
    
    foreach ($required_fields as $field) {
        if (!isset($data[$field]) || empty($data[$field])) {
            http_response_code(400);
            echo json_encode(['success' => false, 'message' => "Missing required field: $field"]);
            return;
        }
    }
    
    // Validate age is a number
    if (!is_numeric($data['age']) || $data['age'] < 18 || $data['age'] > 100) {
        http_response_code(400);
        echo json_encode(['success' => false, 'message' => 'Invalid age value']);
        return;
    }
    
    // Validate date formats
    if (!strtotime($data['birthday']) || !strtotime($data['expiration_date'])) {
        http_response_code(400);
        echo json_encode(['success' => false, 'message' => 'Invalid date format']);
        return;
    }
    
    // Sanitize input data
    $sanitized_data = array_map(function($value) {
        return htmlspecialchars(strip_tags(trim($value)));
    }, $data);
    
    try {
        $query = "INSERT INTO drivers (name, birthday, age, address, contact, license_name, 
                  license_number, license_address, license_codes, expiration_date, vehicle_type, plate_number) 
                  VALUES (:name, :birthday, :age, :address, :contact, :license_name, 
                          :license_number, :license_address, :license_codes, :expiration_date, 
                          :vehicle_type, :plate_number)";
        
        $stmt = $conn->prepare($query);
        
        $stmt->bindParam(':name', $sanitized_data['name']);
        $stmt->bindParam(':birthday', $sanitized_data['birthday']);
        $stmt->bindParam(':age', $sanitized_data['age'], PDO::PARAM_INT);
        $stmt->bindParam(':address', $sanitized_data['address']);
        $stmt->bindParam(':contact', $sanitized_data['contact']);
        $stmt->bindParam(':license_name', $sanitized_data['license_name']);
        $stmt->bindParam(':license_number', $sanitized_data['license_number']);
        $stmt->bindParam(':license_address', $sanitized_data['license_address']);
        $stmt->bindParam(':license_codes', $sanitized_data['license_codes']);
        $stmt->bindParam(':expiration_date', $sanitized_data['expiration_date']);
        $stmt->bindParam(':vehicle_type', $sanitized_data['vehicle_type']);
        $stmt->bindParam(':plate_number', $sanitized_data['plate_number']);
        
        if ($stmt->execute()) {
            echo json_encode([
                'success' => true,
                'message' => 'Driver added successfully',
                'driver_id' => $conn->lastInsertId()
            ]);
        } else {
            echo json_encode([
                'success' => false,
                'message' => 'Failed to add driver'
            ]);
        }
    } catch (PDOException $e) {
        http_response_code(500);
        echo json_encode([
            'success' => false,
            'message' => 'Database error: ' . $e->getMessage()
        ]);
    }
}

function updateDriver() {
    global $conn;
    
    if (!$conn) {
        http_response_code(500);
        echo json_encode([
            'success' => false,
            'message' => 'Database connection failed'
        ]);
        return;
    }
    
    $data = json_decode(file_get_contents("php://input"), true);
    
    if (!$data || !isset($data['id'])) {
        http_response_code(400);
        echo json_encode(['success' => false, 'message' => 'Driver ID is required']);
        return;
    }
    
    // Validate ID is numeric
    if (!is_numeric($data['id'])) {
        http_response_code(400);
        echo json_encode(['success' => false, 'message' => 'Invalid driver ID']);
        return;
    }
    
    // Validate age if provided
    if (isset($data['age']) && (!is_numeric($data['age']) || $data['age'] < 18 || $data['age'] > 100)) {
        http_response_code(400);
        echo json_encode(['success' => false, 'message' => 'Invalid age value']);
        return;
    }
    
    // Validate date formats if provided
    if (isset($data['birthday']) && !strtotime($data['birthday'])) {
        http_response_code(400);
        echo json_encode(['success' => false, 'message' => 'Invalid birthday format']);
        return;
    }
    
    if (isset($data['expiration_date']) && !strtotime($data['expiration_date'])) {
        http_response_code(400);
        echo json_encode(['success' => false, 'message' => 'Invalid expiration date format']);
        return;
    }
    
    // Build dynamic query based on provided fields
    $fields = [];
    $params = [':id' => $data['id']];
    
    $allowed_fields = ['name', 'birthday', 'age', 'address', 'contact', 
                      'license_name', 'license_number', 'license_address', 
                      'license_codes', 'expiration_date', 'vehicle_type', 'plate_number'];
    
    foreach ($allowed_fields as $field) {
        if (isset($data[$field]) && !empty($data[$field])) {
            $fields[] = "$field = :$field";
            $params[":$field"] = htmlspecialchars(strip_tags(trim($data[$field])));
        }
    }
    
    if (empty($fields)) {
        http_response_code(400);
        echo json_encode(['success' => false, 'message' => 'No fields to update']);
        return;
    }
    
    try {
        $query = "UPDATE drivers SET " . implode(', ', $fields) . ", updated_at = NOW() WHERE id = :id";
        $stmt = $conn->prepare($query);
        
        foreach ($params as $key => $value) {
            if ($key === ':age' || $key === ':id') {
                $stmt->bindValue($key, $value, PDO::PARAM_INT);
            } else {
                $stmt->bindValue($key, $value);
            }
        }
        
        if ($stmt->execute()) {
            if ($stmt->rowCount() > 0) {
                echo json_encode([
                    'success' => true,
                    'message' => 'Driver updated successfully'
                ]);
            } else {
                echo json_encode([
                    'success' => false,
                    'message' => 'No driver found with the given ID or no changes made'
                ]);
            }
        } else {
            echo json_encode([
                'success' => false,
                'message' => 'Failed to update driver'
            ]);
        }
    } catch (PDOException $e) {
        http_response_code(500);
        echo json_encode([
            'success' => false,
            'message' => 'Database error: ' . $e->getMessage()
        ]);
    }
}

function deleteDriver() {
    global $conn;
    
    if (!$conn) {
        http_response_code(500);
        echo json_encode([
            'success' => false,
            'message' => 'Database connection failed'
        ]);
        return;
    }
    
    $data = json_decode(file_get_contents("php://input"), true);
    
    if (!$data || !isset($data['id'])) {
        // Also check for ID in URL parameters
        $id = isset($_GET['id']) ? $_GET['id'] : null;
        if (!$id) {
            http_response_code(400);
            echo json_encode(['success' => false, 'message' => 'Driver ID is required']);
            return;
        }
    } else {
        $id = $data['id'];
    }
    
    // Validate ID is numeric
    if (!is_numeric($id)) {
        http_response_code(400);
        echo json_encode(['success' => false, 'message' => 'Invalid driver ID']);
        return;
    }
    
    try {
        $query = "UPDATE drivers SET is_active = FALSE, updated_at = NOW() WHERE id = :id";
        $stmt = $conn->prepare($query);
        $stmt->bindParam(':id', $id, PDO::PARAM_INT);
        
        if ($stmt->execute()) {
            if ($stmt->rowCount() > 0) {
                echo json_encode([
                    'success' => true,
                    'message' => 'Driver deleted successfully'
                ]);
            } else {
                echo json_encode([
                    'success' => false,
                    'message' => 'No driver found with the given ID'
                ]);
            }
        } else {
            echo json_encode([
                'success' => false,
                'message' => 'Failed to delete driver'
            ]);
        }
    } catch (PDOException $e) {
        http_response_code(500);
        echo json_encode([
            'success' => false,
            'message' => 'Database error: ' . $e->getMessage()
        ]);
    }
}
?>
