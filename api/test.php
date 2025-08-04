<?php
include_once 'config/database.php';

header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET");
header("Access-Control-Allow-Headers: Content-Type");

$database = new Database();
$db = $database->getConnection();

if ($db) {
    // Test database connection and get user count
    try {
        $query = "SELECT COUNT(*) as user_count FROM users";
        $stmt = $db->prepare($query);
        $stmt->execute();
        $result = $stmt->fetch(PDO::FETCH_ASSOC);
        
        echo json_encode(array(
            "success" => true,
            "message" => "API is working and database is connected",
            "user_count" => $result['user_count'],
            "timestamp" => date('Y-m-d H:i:s')
        ));
    } catch (Exception $e) {
        echo json_encode(array(
            "success" => false,
            "message" => "Database query failed: " . $e->getMessage()
        ));
    }
} else {
    echo json_encode(array(
        "success" => false,
        "message" => "Database connection failed"
    ));
}
?>
