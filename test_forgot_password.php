<?php
// Test script for forgot password functionality
// Run this from command line: php test_forgot_password.php

$testEmail = "test@example.com"; // Change this to a valid test email

echo "Testing forgot password functionality...\n";

// Test data
$data = array(
    "email" => $testEmail
);

// Convert to JSON
$jsonData = json_encode($data);

// Initialize cURL
$ch = curl_init();
curl_setopt($ch, CURLOPT_URL, "http://localhost/transit/api/auth/forgot_password.php");
curl_setopt($ch, CURLOPT_POST, 1);
curl_setopt($ch, CURLOPT_POSTFIELDS, $jsonData);
curl_setopt($ch, CURLOPT_HTTPHEADER, array('Content-Type: application/json'));
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);

// Execute request
$response = curl_exec($ch);
$httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
curl_close($ch);

// Display results
echo "HTTP Code: " . $httpCode . "\n";
echo "Response: " . $response . "\n";

// Parse JSON response
$decodedResponse = json_decode($response, true);
if ($decodedResponse && $decodedResponse['success']) {
    echo "✅ Forgot password test successful!\n";
    if (isset($decodedResponse['reset_link'])) {
        echo "Reset Link: " . $decodedResponse['reset_link'] . "\n";
    }
} else {
    echo "❌ Forgot password test failed!\n";
    if (isset($decodedResponse['message'])) {
        echo "Error: " . $decodedResponse['message'] . "\n";
    }
}

// Check if logs were created
$logFile = __DIR__ . '/logs/password_reset.log';
if (file_exists($logFile)) {
    echo "\n📋 Log file created: " . $logFile . "\n";
    echo "Last log entry:\n";
    echo shell_exec("tail -n 5 " . $logFile);
}
?>
