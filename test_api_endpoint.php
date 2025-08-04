<?php
// Simple test script to verify the add trip endpoint
$data = [
    'driver_id' => 1,
    'trip_date' => '2024-01-20',
    'start_time' => '2024-01-20 08:00:00',
    'end_time' => '2024-01-20 17:00:00',
    'route_details' => 'Test route from Manila to Quezon City',
    'total_passengers' => 45
];

$ch = curl_init();
curl_setopt($ch, CURLOPT_URL, 'http://localhost:8000/api/drivers/trips/add.php');
curl_setopt($ch, CURLOPT_POST, true);
curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($data));
curl_setopt($ch, CURLOPT_HTTPHEADER, ['Content-Type: application/json']);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);

$response = curl_exec($ch);
$http_code = curl_getinfo($ch, CURLINFO_HTTP_CODE);
curl_close($ch);

echo "HTTP Code: $http_code\n";
echo "Response: $response\n";
?>
