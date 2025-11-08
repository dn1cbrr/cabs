<?php
// Test script to verify API endpoints
$baseUrl = "http://localhost/transit/api";

// Test the test endpoint
echo "Testing API connection...\n";
$response = file_get_contents($baseUrl . "/test.php");
echo "Response: " . $response . "\n";

// Test login endpoint
echo "\nTesting login endpoint...\n";
$data = json_encode(['username' => 'test', 'password' => 'test']);
$context = stream_context_create([
    'http' => [
        'method' => 'POST',
        'header' => 'Content-Type: application/json',
        'content' => $data
    ]
]);
$response = file_get_contents($baseUrl . "/auth/login.php", false, $context);
echo "Response: " . $response . "\n";
?>
