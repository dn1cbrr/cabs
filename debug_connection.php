<?php
// Comprehensive database connection debugger
echo "=== Transit App Database Connection Debug ===\n\n";

// Test 1: Basic PHP/MySQL connection
echo "1. Testing PHP/MySQL connection...\n";
$host = 'localhost';
$dbname = 'transit_db';
$username = 'root';
$password = '';

try {
    $pdo = new PDO("mysql:host=$host;dbname=$dbname;charset=utf8mb4", $username, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    echo "   ✅ Basic PDO connection: SUCCESS\n";
    
    // Test 2: Check if database exists
    $stmt = $pdo->query("SELECT DATABASE() as current_db");
    $result = $stmt->fetch();
    echo "   ✅ Current database: {$result['current_db']}\n";
    
    // Test 3: Check users table
    $stmt = $pdo->query("SELECT COUNT(*) as user_count FROM users");
    $result = $stmt->fetch();
    echo "   ✅ Users table has {$result['user_count']} records\n";
    
    // Test 4: Check all tables
    echo "\n2. Checking database tables...\n";
    $stmt = $pdo->query("SHOW TABLES");
    $tables = $stmt->fetchAll(PDO::FETCH_COLUMN);
    foreach ($tables as $table) {
        echo "   📋 Found table: $table\n";
    }
    
    // Test 5: Check PHP configuration
    echo "\n3. Checking PHP configuration...\n";
    echo "   PHP Version: " . phpversion() . "\n";
    echo "   PDO MySQL: " . (extension_loaded('pdo_mysql') ? "✅ Available" : "❌ Missing") . "\n";
    echo "   MySQLi: " . (extension_loaded('mysqli') ? "✅ Available" : "❌ Missing") . "\n";
    
} catch(PDOException $e) {
    echo "   ❌ Database connection failed: " . $e->getMessage() . "\n";
    echo "   💡 Suggestions:\n";
    echo "      - Check if MySQL is running: sudo systemctl status mysql\n";
    echo "      - Check if database 'transit_db' exists\n";
    echo "      - Check username/password in api/config/database.php\n";
    echo "      - Check MySQL user permissions\n";
}

// Test 6: Check API endpoints
echo "\n4. Testing API endpoints...\n";
$endpoints = [
    'test.php',
    'auth/login.php',
    'auth/register.php',
    'drivers/index.php',
    'trips/get_latest_trip.php'
];

foreach ($endpoints as $endpoint) {
    $url = "http://localhost/transit/api/$endpoint";
    $headers = @get_headers($url);
    if ($headers && strpos($headers[0], '200') !== false) {
        echo "   ✅ $endpoint: Accessible\n";
    } else {
        echo "   ❌ $endpoint: Not accessible\n";
    }
}

echo "\n=== Debug Complete ===\n";
?>
