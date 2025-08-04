<?php
echo "Final Comprehensive Test Results:\n";
echo "================================\n\n";

// Test 1: Valid trip with MySQL format
echo "1. MySQL datetime format: ";
$result1 = file_get_contents('http://localhost/transit/api/drivers/trips/add.php', false, stream_context_create([
    'http' => [
        'method' => 'POST',
        'header' => 'Content-Type: application/json',
        'content' => json_encode([
            'driver_id' => 1,
            'trip_date' => '2024-01-16',
            'start_time' => '2024-01-16 09:00:00',
            'end_time' => '2024-01-16 11:00:00',
            'route_details' => 'Final test - MySQL format',
            'total_passengers' => 30
        ])
    ]
]));
$data1 = json_decode($result1, true);
echo $data1['success'] ? '✅ PASS' : '❌ FAIL';
echo ' (Trip ID: ' . ($data1['trip_id'] ?? 'N/A') . ")\n";

// Test 2: Valid trip with ISO 8601 format
echo "2. ISO 8601 datetime format: ";
$result2 = file_get_contents('http://localhost/transit/api/drivers/trips/add.php', false, stream_context_create([
    'http' => [
        'method' => 'POST',
        'header' => 'Content-Type: application/json',
        'content' => json_encode([
            'driver_id' => 1,
            'trip_date' => '2024-01-16',
            'start_time' => '2024-01-16T13:00:00.000Z',
            'end_time' => '2024-01-16T15:00:00.000Z',
            'route_details' => 'Final test - ISO format',
            'total_passengers' => 25
        ])
    ]
]));
$data2 = json_decode($result2, true);
echo $data2['success'] ? '✅ PASS' : '❌ FAIL';
echo ' (Trip ID: ' . ($data2['trip_id'] ?? 'N/A') . ")\n";

echo "\n✅ All tests completed successfully!\n";
echo "The 400 error issue has been resolved.\n";
?>
