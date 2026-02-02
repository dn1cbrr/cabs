<?php
/**
 * Users Endpoint Router
 * Routes user-related API requests to appropriate handlers
 * Supports both action-based routing (?action=get_users) and direct file requests (/get_users.php)
 */

// Get the request method
$request_method = $_SERVER['REQUEST_METHOD'];

// Get action from query string or body
$action = $_GET['action'] ?? $_POST['action'] ?? '';

// If no action is specified, try to extract it from the request URI
if (empty($action)) {
    $request_uri = $_SERVER['REQUEST_URI'] ?? '';
    
    // Extract the file name from the URI
    $uri_parts = explode('/', $request_uri);
    $last_part = end($uri_parts);
    
    // Remove query string if present
    $last_part = explode('?', $last_part)[0];
    
    // If it's a .php file, extract the action name
    if (strpos($last_part, '.php') !== false) {
        $action = str_replace('.php', '', $last_part);
        
        // Log the extracted action for debugging
        error_log("Users Router: Extracted action '$action' from URI: $request_uri");
    }
}

// Route based on action
try {
    switch ($action) {
        case 'get_users':
            if ($request_method === 'GET') {
                require_once 'get_users.php';
            } else {
                throw new Exception('Invalid request method for get_users');
            }
            break;

        case 'update_user':
            if ($request_method === 'POST') {
                require_once 'update_user.php';
            } else {
                throw new Exception('Invalid request method for update_user');
            }
            break;

        case 'delete_user':
            if ($request_method === 'DELETE' || $request_method === 'POST') {
                require_once 'delete_user.php';
            } else {
                throw new Exception('Invalid request method for delete_user');
            }
            break;

        case 'archive_user':
            if ($request_method === 'POST') {
                require_once 'archive_user.php';
            } else {
                throw new Exception('Invalid request method for archive_user');
            }
            break;

        case 'heartbeat':
            if ($request_method === 'POST' || $request_method === 'GET') {
                require_once 'heartbeat.php';
            } else {
                throw new Exception('Invalid request method for heartbeat');
            }
            break;

        default:
            // If no action specified, list available actions
            error_log("Users Router: No valid action found. Action: '$action', URI: " . ($_SERVER['REQUEST_URI'] ?? 'unknown'));
            http_response_code(400);
            echo json_encode([
                'success' => false,
                'message' => 'Action not specified or invalid',
                'requested_action' => $action,
                'request_uri' => $_SERVER['REQUEST_URI'] ?? 'unknown',
                'available_actions' => [
                    'get_users' => 'GET - Retrieve all users',
                    'update_user' => 'POST - Update a user',
                    'delete_user' => 'DELETE - Delete a user',
                    'archive_user' => 'POST - Archive a user',
                    'heartbeat' => 'POST - User heartbeat/activity'
                ],
                'usage_examples' => [
                    'Direct file: /api/users/get_users.php',
                    'Action parameter: /api/users?action=get_users'
                ]
            ]);
            break;
    }
} catch (Exception $e) {
    error_log("Users API Error: " . $e->getMessage());
    error_log("Stack trace: " . $e->getTraceAsString());
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'message' => $e->getMessage(),
        'error_type' => 'routing_error'
    ]);
}
?>
