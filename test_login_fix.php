<?php
// Test script to verify and fix login credentials
include_once 'api/config/database.php';

$database = new Database();
$db = $database->getConnection();

echo "=== Database Connection Test ===\n";
echo "Connected successfully!\n\n";

echo "=== Current Users ===\n";
$query = "SELECT id, username, email, full_name, role FROM users";
$stmt = $db->prepare($query);
$stmt->execute();

$users = $stmt->fetchAll(PDO::FETCH_ASSOC);
foreach ($users as $user) {
    echo "User: {$user['username']} ({$user['email']}) - Role: {$user['role']}\n";
}

echo "\n=== Testing Password Hashes ===\n";
$test_passwords = ['admin123', 'user123'];
$sample_users = ['admin', 'user1'];

foreach ($sample_users as $username) {
    $query = "SELECT password FROM users WHERE username = ?";
    $stmt = $db->prepare($query);
    $stmt->execute([$username]);
    $stored_hash = $stmt->fetchColumn();
    
    echo "Testing $username:\n";
    echo "Stored hash: $stored_hash\n";
    
    // Test both passwords
    foreach ($test_passwords as $test_pwd) {
        $is_valid = password_verify($test_pwd, $stored_hash);
        echo "  Password '$test_pwd': " . ($is_valid ? "VALID" : "INVALID") . "\n";
    }
    echo "\n";
}

echo "=== Fixing Sample Data ===\n";
// Update with correct password hashes
$correct_hashes = [
    'admin' => password_hash('admin123', PASSWORD_DEFAULT),
    'user1' => password_hash('user123', PASSWORD_DEFAULT)
];

foreach ($correct_hashes as $username => $hash) {
    $query = "UPDATE users SET password = ? WHERE username = ?";
    $stmt = $db->prepare($query);
    $stmt->execute([$hash, $username]);
    echo "Updated password for $username\n";
}

echo "\n=== Testing Login After Fix ===\n";
// Test the login
$test_credentials = [
    ['admin', 'admin123'],
    ['user1', 'user123']
];

foreach ($test_credentials as [$username, $password]) {
    $query = "SELECT password FROM users WHERE username = ?";
    $stmt = $db->prepare($query);
    $stmt->execute([$username]);
    $stored_hash = $stmt->fetchColumn();
    
    $is_valid = password_verify($password, $stored_hash);
    echo "Login test for $username/$password: " . ($is_valid ? "SUCCESS" : "FAILURE") . "\n";
}

echo "\n=== All tests completed! ===\n";
?>
