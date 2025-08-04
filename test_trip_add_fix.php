<?php
// Test script to verify the trip add fix
require_once 'api/config/database.php';

echo "Testing Trip Add Fix\n";
echo "===================\n\n";

// Test data similar to what Flutter would send
$testData = [
    'driver_id' => 1,
    'trip_date' => '2024-01-15',
    'start_time' => '2024-01-15 14:30:00', // MySQL format (what our Flutter fix now sends)
    'end_time' => '2024-01-15 16:30:00',
    'route_details' => 'Test route from Manila to Quezon City',
    'total_passengers' => 25
];

echo "Test data to be sent:\n";
echo json_encode($testData, JSON_PRETTY_PRINT) . "\n\n";

// Simulate the API call
$url = 'http://localhost/transit/api/drivers/trips/add.php';
$jsonData = json_encode($testData);

$ch = curl_init();
curl_setopt($ch, CURLOPT_URL, $url);
curl_setopt($ch, CURLOPT_POST, true);
curl_setopt($ch, CURLOPT_POSTFIELDS, $jsonData);
curl_setopt($ch, CURLOPT_HTTPHEADER, [
    'Content-Type: application/json',
    'Content-Length: ' . strlen($jsonData)
]);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);

$response = curl_exec($ch);
$httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
curl_close($ch);

echo "HTTP Response Code: $httpCode\n";
echo "Response:\n";
echo json_encode(json_decode($response), JSON_PRETTY_PRINT) . "\n\n";

// Test with ISO 8601 format (old Flutter format)
echo "Testing with ISO 8601 format (fallback):\n";
echo "========================================\n\n";

$testDataISO = [
    'driver_id' => 1,
    'trip_date' => '2024-01-15',
    'start_time' => '2024-01-15T14:30:00.000Z', // ISO 8601 format
    'end_time' => '2024-01-15T16:30:00.000Z',
    'route_details' => 'Test route with ISO format',
    'total_passengers' => 30
];

echo "Test data (ISO 8601):\n";
echo json_encode($testDataISO, JSON_PRETTY_PRINT) . "\n\n";

$jsonDataISO = json_encode($testDataISO);

$ch = curl_init();
curl_setopt($ch, CURLOPT_URL, $url);
curl_setopt($ch, CURLOPT_POST, true);
curl_setopt($ch, CURLOPT_POSTFIELDS, $jsonDataISO);
curl_setopt($ch, CURLOPT_HTTPHEADER, [
    'Content-Type: application/json',
    'Content-Length: ' . strlen($jsonDataISO)
]);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);

$response = curl_exec($ch);
$httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
curl_close($ch);

echo "HTTP Response Code: $httpCode\n";
echo "Response:\n";
echo json_encode(json_decode($response), JSON_PRETTY_PRINT) . "\n";
?>
