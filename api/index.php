<?php
/**
 * Main API Entry Point for Transit App
 * Routes all API requests to appropriate handlers
 */

// Enable error reporting for development
ini_set('display_errors', 0);
ini_set('log_errors', 1);
error_reporting(E_ALL);

// Set headers for API responses
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With");

// Handle preflight OPTIONS request
if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    http_response_code(200);
    exit();
}

// Get the request URI and method
$request_uri = $_SERVER['REQUEST_URI'];
$request_method = $_SERVER['REQUEST_METHOD'];

// Remove query string from URI
$uri_parts = explode('?', $request_uri);
$path = $uri_parts[0];

// Remove the base path (api/) from the URI
$path = str_replace('/api', '', $path);
$path = ltrim($path, '/');

// Split the path into segments
$path_segments = explode('/', $path);
$endpoint = $path_segments[0] ?? '';

// Route the request
try {
    switch ($endpoint) {
        case 'auth':
            require_once 'auth/index.php';
            break;

        case 'users':
            require_once 'users/index.php';
            break;

        case 'drivers':
            require_once 'drivers/index.php';
            break;

        case 'trips':
            require_once 'trips/index.php';
            break;

        case 'test':
            require_once 'test.php';
            break;

        default:
            // Return 404 for unknown endpoints
            http_response_code(404);
            echo json_encode([
                'success' => false,
                'message' => 'Endpoint not found',
                'available_endpoints' => ['auth', 'users', 'drivers', 'trips', 'test']
            ]);
            break;
    }
} catch (Exception $e) {
    // Log the error
    error_log("API Error: " . $e->getMessage());

    // Return generic error response
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => 'Internal server error'
    ]);
}
?>
