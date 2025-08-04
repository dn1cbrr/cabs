<?php
include_once 'api/config/database.php';

$database = new Database();
$db = $database->getConnection();

if ($db) {
    echo "Database connection successful\n";
    
    try {
        // Check if admin user exists
        $username = "decina@admin";
        $stmt = $db->prepare("SELECT id, username, role FROM users WHERE username = ?");
        $stmt->bindParam(1, $username);
        $stmt->execute();
        
        if ($user = $stmt->fetch(PDO::FETCH_ASSOC)) {
            echo "Admin user found in database:\n";
            print_r($user);
        } else {
            echo "Admin user not found in database\n";
        }
    } catch (Exception $e) {
        echo "Error: " . $e->getMessage() . "\n";
    }
} else {
    echo "Database connection failed\n";
}
?>
