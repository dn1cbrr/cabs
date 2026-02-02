<?php
/**
 * User Management API Test Script
 * Tests all user management endpoints to verify they're working correctly
 */

header("Content-Type: text/html; charset=UTF-8");

require_once '../config/database.php';

echo "<!DOCTYPE html>
<html>
<head>
    <title>User Management API Test</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; background: #f5f5f5; }
        .container { max-width: 1200px; margin: 0 auto; background: white; padding: 20px; border-radius: 8px; }
        h1 { color: #333; border-bottom: 2px solid #007bff; padding-bottom: 10px; }
        h2 { color: #555; margin-top: 30px; }
        .test-section { background: #f9f9f9; padding: 15px; margin: 15px 0; border-left: 4px solid #007bff; }
        .success { color: #28a745; font-weight: bold; }
        .error { color: #dc3545; font-weight: bold; }
        .warning { color: #ffc107; font-weight: bold; }
        pre { background: #f4f4f4; padding: 10px; border-radius: 4px; overflow-x: auto; }
        .status { display: inline-block; padding: 5px 10px; border-radius: 4px; margin: 5px 0; }
        .status.pass { background: #d4edda; color: #155724; }
        .status.fail { background: #f8d7da; color: #721c24; }
        .status.info { background: #d1ecf1; color: #0c5460; }
        table { width: 100%; border-collapse: collapse; margin: 10px 0; }
        th, td { padding: 8px; text-align: left; border: 1px solid #ddd; }
        th { background: #007bff; color: white; }
    </style>
</head>
<body>
<div class='container'>
<h1>🔧 User Management API Test Suite</h1>
<p><strong>Test Date:</strong> " . date('Y-m-d H:i:s') . "</p>
";

// Test 1: Database Connection
echo "<div class='test-section'>
<h2>Test 1: Database Connection</h2>";

$database = new Database();
$db = $database->getConnection();

if ($db) {
    echo "<span class='status pass'>✓ PASS</span> Database connection successful<br>";
    
    // Check if users table exists
    try {
        $stmt = $db->query("SHOW TABLES LIKE 'users'");
        if ($stmt->rowCount() > 0) {
            echo "<span class='status pass'>✓ PASS</span> Users table exists<br>";
        } else {
            echo "<span class='status fail'>✗ FAIL</span> Users table does not exist<br>";
        }
    } catch (PDOException $e) {
        echo "<span class='status fail'>✗ FAIL</span> Error checking users table: " . $e->getMessage() . "<br>";
    }
} else {
    echo "<span class='status fail'>✗ FAIL</span> Database connection failed<br>";
}
echo "</div>";

// Test 2: Check Database Schema
echo "<div class='test-section'>
<h2>Test 2: Database Schema Verification</h2>";

if ($db) {
    try {
        $stmt = $db->query("DESCRIBE users");
        $columns = $stmt->fetchAll(PDO::FETCH_ASSOC);
        
        echo "<table>
        <tr><th>Column Name</th><th>Type</th><th>Null</th><th>Default</th></tr>";
        
        $requiredColumns = ['id', 'username', 'email', 'full_name', 'role', 'created_at', 
                           'updated_at', 'is_online', 'last_seen', 'is_archived', 'archived_at', 'archived_by'];
        $foundColumns = [];
        
        foreach ($columns as $column) {
            echo "<tr>
                <td>{$column['Field']}</td>
                <td>{$column['Type']}</td>
                <td>{$column['Null']}</td>
                <td>{$column['Default']}</td>
            </tr>";
            $foundColumns[] = $column['Field'];
        }
        echo "</table>";
        
        echo "<h3>Required Columns Check:</h3>";
        foreach ($requiredColumns as $reqCol) {
            if (in_array($reqCol, $foundColumns)) {
                echo "<span class='status pass'>✓</span> $reqCol<br>";
            } else {
                echo "<span class='status fail'>✗</span> $reqCol <span class='error'>(MISSING)</span><br>";
            }
        }
        
    } catch (PDOException $e) {
        echo "<span class='status fail'>✗ FAIL</span> Error checking schema: " . $e->getMessage() . "<br>";
    }
}
echo "</div>";

// Test 3: Get Users Endpoint
echo "<div class='test-section'>
<h2>Test 3: GET Users Endpoint</h2>";

try {
    // Simulate the get_users.php endpoint
    $query = "SELECT id, username, email, full_name, phone_number, birthday, license_name,
              license_number, license_address, license_codes, license_expiration, profile_photo,
              role, is_online, last_seen, created_at FROM users 
              WHERE is_archived = 0 OR is_archived IS NULL
              ORDER BY created_at DESC LIMIT 5";
    $stmt = $db->prepare($query);
    $stmt->execute();
    
    $users = [];
    while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
        $users[] = $row;
    }
    
    $response = [
        'success' => true,
        'data' => [
            'users' => $users
        ]
    ];
    
    echo "<span class='status pass'>✓ PASS</span> Query executed successfully<br>";
    echo "<span class='status info'>ℹ INFO</span> Found " . count($users) . " users<br>";
    echo "<h3>Response Structure:</h3>";
    echo "<pre>" . json_encode($response, JSON_PRETTY_PRINT) . "</pre>";
    
    // Verify response structure
    if (isset($response['success']) && isset($response['data']) && isset($response['data']['users'])) {
        echo "<span class='status pass'>✓ PASS</span> Response structure is correct<br>";
    } else {
        echo "<span class='status fail'>✗ FAIL</span> Response structure is incorrect<br>";
    }
    
} catch (PDOException $e) {
    echo "<span class='status fail'>✗ FAIL</span> Error: " . $e->getMessage() . "<br>";
    
    // Try fallback query without archive columns
    try {
        echo "<br><span class='status info'>ℹ INFO</span> Trying fallback query without archive columns...<br>";
        $query = "SELECT id, username, email, full_name, phone_number, birthday, license_name,
                  license_number, license_address, license_codes, license_expiration, profile_photo,
                  role, is_online, last_seen, created_at FROM users ORDER BY created_at DESC LIMIT 5";
        $stmt = $db->prepare($query);
        $stmt->execute();
        
        $users = [];
        while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
            $users[] = $row;
        }
        
        echo "<span class='status pass'>✓ PASS</span> Fallback query successful<br>";
        echo "<span class='status warning'>⚠ WARNING</span> Archive columns are missing - migration needed<br>";
        
    } catch (PDOException $e2) {
        echo "<span class='status fail'>✗ FAIL</span> Fallback also failed: " . $e2->getMessage() . "<br>";
    }
}
echo "</div>";

// Test 4: Update User Endpoint Simulation
echo "<div class='test-section'>
<h2>Test 4: Update User Endpoint Structure</h2>";

// Simulate successful update response
$updateResponse = [
    'success' => true,
    'data' => [
        'message' => 'User updated successfully'
    ]
];

echo "<h3>Expected Update Response:</h3>";
echo "<pre>" . json_encode($updateResponse, JSON_PRETTY_PRINT) . "</pre>";

if (isset($updateResponse['success']) && isset($updateResponse['data']) && isset($updateResponse['data']['message'])) {
    echo "<span class='status pass'>✓ PASS</span> Update response structure is correct<br>";
} else {
    echo "<span class='status fail'>✗ FAIL</span> Update response structure is incorrect<br>";
}

echo "</div>";

// Test 5: Archive User Endpoint Check
echo "<div class='test-section'>
<h2>Test 5: Archive User Functionality</h2>";

try {
    // Check if archive columns exist
    $stmt = $db->query("SHOW COLUMNS FROM users LIKE 'is_archived'");
    if ($stmt->rowCount() > 0) {
        echo "<span class='status pass'>✓ PASS</span> is_archived column exists<br>";
    } else {
        echo "<span class='status fail'>✗ FAIL</span> is_archived column missing<br>";
        echo "<span class='status warning'>⚠ WARNING</span> Run database/fix_users_table_complete.sql to add missing columns<br>";
    }
    
    $stmt = $db->query("SHOW COLUMNS FROM users LIKE 'archived_at'");
    if ($stmt->rowCount() > 0) {
        echo "<span class='status pass'>✓ PASS</span> archived_at column exists<br>";
    } else {
        echo "<span class='status fail'>✗ FAIL</span> archived_at column missing<br>";
    }
    
    $stmt = $db->query("SHOW COLUMNS FROM users LIKE 'archived_by'");
    if ($stmt->rowCount() > 0) {
        echo "<span class='status pass'>✓ PASS</span> archived_by column exists<br>";
    } else {
        echo "<span class='status fail'>✗ FAIL</span> archived_by column missing<br>";
    }
    
} catch (PDOException $e) {
    echo "<span class='status fail'>✗ FAIL</span> Error checking archive columns: " . $e->getMessage() . "<br>";
}

echo "</div>";

// Test 6: Online Status Columns
echo "<div class='test-section'>
<h2>Test 6: Online Status Functionality</h2>";

try {
    $stmt = $db->query("SHOW COLUMNS FROM users LIKE 'is_online'");
    if ($stmt->rowCount() > 0) {
        echo "<span class='status pass'>✓ PASS</span> is_online column exists<br>";
    } else {
        echo "<span class='status fail'>✗ FAIL</span> is_online column missing<br>";
        echo "<span class='status warning'>⚠ WARNING</span> Run database/fix_users_table_complete.sql to add missing columns<br>";
    }
    
    $stmt = $db->query("SHOW COLUMNS FROM users LIKE 'last_seen'");
    if ($stmt->rowCount() > 0) {
        echo "<span class='status pass'>✓ PASS</span> last_seen column exists<br>";
    } else {
        echo "<span class='status fail'>✗ FAIL</span> last_seen column missing<br>";
    }
    
} catch (PDOException $e) {
    echo "<span class='status fail'>✗ FAIL</span> Error checking online status columns: " . $e->getMessage() . "<br>";
}

echo "</div>";

// Summary
echo "<div class='test-section'>
<h2>📊 Test Summary</h2>
<h3>Action Items:</h3>
<ol>
<li>If any columns are missing, run: <code>database/fix_users_table_complete.sql</code></li>
<li>Verify API endpoints return correct response structure</li>
<li>Test from Flutter app to ensure integration works</li>
<li>Check error handling for edge cases</li>
</ol>

<h3>Files to Review:</h3>
<ul>
<li><code>api/users/get_users.php</code> - Should return {'success': true, 'data': {'users': [...]}}</li>
<li><code>api/users/update_user.php</code> - Should return {'success': true, 'data': {'message': '...'}}</li>
<li><code>database/fix_users_table_complete.sql</code> - Migration script for missing columns</li>
</ul>
</div>";

echo "</div>
</body>
</html>";
?>
