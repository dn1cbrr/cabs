<?php
echo "=== API Endpoints Test ===\n\n";

$endpoints = [
    'GET http://localhost/transit/api/test.php' => 'Basic API Test',
    'GET http://localhost/transit/api/drivers/trips/history.php' => 'Trip History',
    'GET http://localhost/transit/api/auth/login.php' => 'Login (should fail - method not allowed)',
    'GET http://localhost/transit/api/drivers/trips/add.php' => 'Add Trip (should fail - method not allowed)',
];

foreach ($endpoints as $url => $description) {
    echo "Testing: $description\n";
    echo "URL: $url\n";
    
    $parts = explode(' ', $url, 2);
    $method = $parts[0];
    $endpoint = $parts[1];
    
    $ch = curl_init();
    curl_setopt($ch, CURLOPT_URL, $endpoint);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_TIMEOUT, 10);
    curl_setopt($ch, CURLOPT_CUSTOMREQUEST, $method);
    
    $response = curl_exec($ch);
    $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
    $error = curl_error($ch);
    curl_close($ch);
    
    if ($error) {
        echo "❌ CURL Error: $error\n";
    } else {
        echo "✅ HTTP Status: $httpCode\n";
        if ($httpCode == 200) {
            $data = json_decode($response, true);
            if ($data && isset($data['success'])) {
                echo "✅ Response: " . ($data['success'] ? 'SUCCESS' : 'FAILED') . "\n";
                if (isset($data['message'])) {
                    echo "   Message: " . $data['message'] . "\n";
                }
            } else {
                echo "⚠️  Response: " . substr($response, 0, 100) . "...\n";
            }
        } elseif ($httpCode == 405) {
            echo "✅ Method Not Allowed (Expected for POST-only endpoints)\n";
        } else {
            echo "⚠️  Response: " . substr($response, 0, 100) . "...\n";
        }
    }
    echo "\n" . str_repeat("-", 50) . "\n\n";
}

echo "=== Test Complete ===\n";
?>
