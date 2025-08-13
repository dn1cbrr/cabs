<?php
// Test script to trigger the forgot password functionality

$apiUrl = 'http://transit.local/api/auth/forgot_password.php';


// You can change this to a specific email you want to test
$testEmail = 'nnnnnniel143@gmail.com'; 

$data = ['email' => $testEmail];

$ch = curl_init($apiUrl);

curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_POST, true);
curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($data));
curl_setopt($ch, CURLOPT_HTTPHEADER, [
    'Content-Type: application/json',
    'Content-Length: ' . strlen(json_encode($data))
]);

$response = curl_exec($ch);
$httpcode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
$error = curl_error($ch);

curl_close($ch);

echo "<h2>Forgot Password Test</h2>";
echo "<p><strong>API URL:</strong> " . $apiUrl . "</p>";
echo "<p><strong>Email Sent:</strong> " . $testEmail . "</p>";
echo "<hr>";
echo "<p><strong>HTTP Status Code:</strong> " . $httpcode . "</p>";
echo "<p><strong>API Response:</strong></p>";
echo "<pre>";
print_r(json_decode($response, true));
echo "</pre>";

if ($error) {
    echo "<p><strong>cURL Error:</strong> " . $error . "</p>";
}
?>
