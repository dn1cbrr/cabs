<?php
// Test script for get_latest_trip.php

// Define the URL of the API endpoint
$url = 'http://localhost/transit/api/trips/get_latest_trip.php';

// Initialize cURL session
$ch = curl_init();

// Set cURL options
curl_setopt($ch, CURLOPT_URL, $url);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);

// Execute the cURL request
$response = curl_exec($ch);

// Check for cURL errors
if (curl_errno($ch)) {
    echo 'Error:' . curl_error($ch);
}

// Close cURL session
curl_close($ch);

// Decode the JSON response
$data = json_decode($response, true);

// Print the response
echo "<pre>";
print_r($data);
echo "</pre>";

?>
