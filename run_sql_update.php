<?php
// Script to run SQL update to add profile_photo column

echo "Running SQL update to add profile_photo column...\n";

// Include the database configuration
include_once 'api/config/database.php';

$database = new Database();
$db = $database->getConnection();

if (!$db) {
    echo "Database connection failed\n";
    exit(1);
}

echo "Database connection successful\n";

// Read the SQL file
$sql = file_get_contents('database/add_license_fields_to_users.sql');

// Remove comments and split by semicolon
$statements = explode(';', $sql);
foreach ($statements as $statement) {
    $statement = trim($statement);
    if (!empty($statement) && !str_starts_with($statement, '--')) {
        try {
            $stmt = $db->prepare($statement);
            $stmt->execute();
            echo "Executed: " . substr($statement, 0, 50) . "...\n";
        } catch (Exception $e) {
            echo "Error executing statement: " . $e->getMessage() . "\n";
            echo "Statement: " . $statement . "\n";
        }
    }
}

echo "SQL update completed.\n";
?>
