<?php
include_once 'api/config/database.php';

$database = new Database();
$db = $database->getConnection();

if ($db) {
    echo "Database connection successful\n";
    
    try {
        // Create a test user with a known password
        $username = "testuser";
        $email = "test@example.com";
        $password = password_hash("testpass", PASSWORD_DEFAULT); // Hash the password
        $full_name = "Test User";
        $role = "user";
        
        // Check if user already exists
        $stmt = $db->prepare("SELECT id FROM users WHERE username = ?");
        $stmt->bindParam(1, $username);
        $stmt->execute();
        
        if ($stmt->rowCount() == 0) {
            // Insert new user
            $stmt = $db->prepare("INSERT INTO users (username, email, password, full_name, role) VALUES (?, ?, ?, ?, ?)");
            $stmt->bindParam(1, $username);
            $stmt->bindParam(2, $email);
            $stmt->bindParam(3, $password);
            $stmt->bindParam(4, $full_name);
            $stmt->bindParam(5, $role);
            
            if ($stmt->execute()) {
                echo "Test user created successfully!\n";
                echo "Username: $username\n";
                echo "Password: testpass\n";
            } else {
                echo "Error creating test user\n";
            }
        } else {
            echo "Test user already exists\n";
        }
    } catch (Exception $e) {
        echo "Error: " . $e->getMessage() . "\n";
    }
} else {
    echo "Database connection failed\n";
}
?>
