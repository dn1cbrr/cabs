    <?php
// Test script to verify the trip adding fix
header("Content-Type: application/json; charset=UTF-8");

// Test data that mimics what Flutter sends
$test_data = [
    'driver_id' => 1,
    'trip_date' => '2024-01-20',
    'start_time' => '2024-01-20T08:00:00.000',  // ISO 8601 format from Flutter
    'end_time' => '2024-01-20T17:30:00.000',    // ISO 8601 format from Flutter
    'route_details' => 'Test route from Manila to Quezon City',
    'total_passengers' => 25
];

echo "Testing trip addition with ISO 8601 format...\n\n";
echo "Test data being sent:\n";
echo json_encode($test_data, JSON_PRETTY_PRINT) . "\n\n";

// Make a POST request to the add trip endpoint
$url = 'http://localhost/transit/api/drivers/trips/add.php';
$options = [
    'http' => [
        'header' => "Content-Type: application/json\r\n",
        'method' => 'POST',
        'content' => json_encode($test_data)
    ]
];

$context = stream_context_create($options);
$result = file_get_contents($url, false, $context);

if ($result === FALSE) {
    echo "Error: Could not connect to the API endpoint\n";
    echo "Make sure XAMPP is running and the API is accessible at: $url\n";
} else {
    echo "API Response:\n";
    $response = json_decode($result, true);
    echo json_encode($response, JSON_PRETTY_PRINT) . "\n\n";
    
    if (isset($response['success']) && $response['success']) {
        echo "✅ SUCCESS: Trip was added successfully!\n";
        echo "Trip ID: " . $response['trip_id'] . "\n";
    } else {
        echo "❌ FAILED: " . ($response['message'] ?? 'Unknown error') . "\n";
    }
}

// Test with different date formats
echo "\n" . str_repeat("-", 50) . "\n";
echo "Testing with different date formats...\n\n";

$test_formats = [
    [
        'name' => 'ISO 8601 with Z timezone',
        'start_time' => '2024-01-20T08:00:00Z',
        'end_time' => '2024-01-20T17:30:00Z'
    ],
    [
        'name' => 'ISO 8601 without milliseconds',
        'start_time' => '2024-01-20T08:00:00',
        'end_time' => '2024-01-20T17:30:00'
    ],
    [
        'name' => 'MySQL datetime format',
        'start_time' => '2024-01-20 08:00:00',
        'end_time' => '2024-01-20 17:30:00'
    ]
];

foreach ($test_formats as $format) {
    echo "Testing: " . $format['name'] . "\n";
    
    $test_data_format = $test_data;
    $test_data_format['start_time'] = $format['start_time'];
    $test_data_format['end_time'] = $format['end_time'];
    $test_data_format['route_details'] = 'Test route - ' . $format['name'];
    
    $options['http']['content'] = json_encode($test_data_format);
    $context = stream_context_create($options);
    $result = file_get_contents($url, false, $context);
    
    if ($result !== FALSE) {
        $response = json_decode($result, true);
        if (isset($response['success']) && $response['success']) {
            echo "✅ PASSED\n";
        } else {
            echo "❌ FAILED: " . ($response['message'] ?? 'Unknown error') . "\n";
        }
    } else {
        echo "❌ CONNECTION ERROR\n";
    }
    echo "\n";
}

echo "Test completed!\n";
?>
