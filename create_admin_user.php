<?php
include_once 'api/config/database.php';

$database = new Database();
$db = $database->getConnection();

if ($db) {
    echo "Database connection successful\n";
    
    try {
        // Admin user details
        $username = "decina@admin";
        $email = "decina@admin.com";
        $password = password_hash("admin@decina", PASSWORD_DEFAULT); // Hash the password
        $full_name = "Decina Admin";
        $role = "admin";
        
        // Check if user already exists
        $stmt = $db->prepare("SELECT id FROM users WHERE username = ?");
        $stmt->bindParam(1, $username);
        $stmt->execute();
        
        if ($stmt->rowCount() == 0) {
            // Insert new admin user
            $stmt = $db->prepare("INSERT INTO users (username, email, password, full_name, role) VALUES (?, ?, ?, ?, ?)");
            $stmt->bindParam(1, $username);
            $stmt->bindParam(2, $email);
            $stmt->bindParam(3, $password);
            $stmt->bindParam(4, $full_name);
            $stmt->bindParam(5, $role);
            
            if ($stmt->execute()) {
                echo "Admin user created successfully!\n";
                echo "Username: $username\n";
                echo "Password: admin@decina\n";
                echo "Role: $role\n";
            } else {
                echo "Error creating admin user\n";
            }
        } else {
            echo "Admin user already exists\n";
        }
    } catch (Exception $e) {
        echo "Error: " . $e->getMessage() . "\n";
    }
} else {
    echo "Database connection failed\n";
}
?>
