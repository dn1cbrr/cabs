<?php
// Include necessary files
require_once 'api/config/database.php';
require_once 'api/config/email_config.php';

// Initialize database connection
$database = new Database();
$db = $database->getConnection();

// Initialize variables
$error = '';
$success = '';
$token = '';
$isValidToken = false;

// Check if token is provided
if (isset($_GET['token'])) {
    $token = $_GET['token'];
    
    // Validate token
    $query = "SELECT pr.user_id, pr.expires_at, pr.is_used, u.username, u.email 
              FROM password_resets pr 
              JOIN users u ON pr.user_id = u.id 
              WHERE pr.reset_token = ? AND pr.is_used = 0 
              LIMIT 1";
    
    $stmt = $db->prepare($query);
    $stmt->execute([$token]);
    
    if ($stmt->rowCount() > 0) {
        $resetData = $stmt->fetch(PDO::FETCH_ASSOC);
        
        // Check if token is expired
        $currentTime = date('Y-m-d H:i:s');
        if ($currentTime <= $resetData['expires_at']) {
            $isValidToken = true;
            $username = $resetData['username'];
            $email = $resetData['email'];
        } else {
            $error = "This password reset link has expired. Please request a new one.";
        }
    } else {
        $error = "Invalid or expired password reset link.";
    }
} else {
    $error = "No reset token provided.";
}

// Handle form submission
if ($_SERVER['REQUEST_METHOD'] === 'POST' && $isValidToken) {
    $newPassword = $_POST['new_password'] ?? '';
    $confirmPassword = $_POST['confirm_password'] ?? '';
    
    // Validate passwords
    if (empty($newPassword) || empty($confirmPassword)) {
        $error = "Please enter both password fields.";
    } elseif (strlen($newPassword) < 8) {
        $error = "Password must be at least 8 characters long.";
    } elseif ($newPassword !== $confirmPassword) {
        $error = "Passwords do not match.";
    } else {
        // Update password
        $hashedPassword = password_hash($newPassword, PASSWORD_DEFAULT);
        
        try {
            $db->beginTransaction();
            
            // Update user password
            $updateQuery = "UPDATE users SET password = ? WHERE id = ?";
            $updateStmt = $db->prepare($updateQuery);
            $updateStmt->execute([$hashedPassword, $resetData['user_id']]);
            
            // Mark token as used
            $markUsedQuery = "UPDATE password_resets SET is_used = 1 WHERE reset_token = ?";
            $markUsedStmt = $db->prepare($markUsedQuery);
            $markUsedStmt->execute([$token]);
            
            $db->commit();
            $success = "Your password has been successfully reset. You can now log in with your new password.";
            
        } catch (Exception $e) {
            $db->rollBack();
            $error = "An error occurred while resetting your password. Please try again.";
        }
    }
}
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Reset Password - Transit App</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 20px;
        }
        
        .reset-container {
            background: white;
            border-radius: 10px;
            box-shadow: 0 15px 35px rgba(0, 0, 0, 0.1);
            padding: 40px;
            width: 100%;
            max-width: 400px;
        }
        
        .logo {
            text-align: center;
            margin-bottom: 30px;
        }
        
        .logo h1 {
            color: #007bff;
            font-size: 28px;
            margin-bottom: 10px;
        }
        
        .logo p {
            color: #666;
            font-size: 14px;
        }
        
        .form-group {
            margin-bottom: 20px;
        }
        
        label {
            display: block;
            margin-bottom: 5px;
            color: #333;
            font-weight: 500;
        }
        
        input[type="password"] {
            width: 100%;
            padding: 12px;
            border: 1px solid #ddd;
            border-radius: 5px;
            font-size: 16px;
            transition: border-color 0.3s;
        }
        
        input[type="password"]:focus {
            outline: none;
            border-color: #007bff;
        }
        
        .password-requirements {
            font-size: 12px;
            color: #666;
            margin-top: 5px;
        }
        
        .btn-reset {
            width: 100%;
            padding: 12px;
            background: #007bff;
            color: white;
            border: none;
            border-radius: 5px;
            font-size: 16px;
            cursor: pointer;
            transition: background-color 0.3s;
        }
        
        .btn-reset:hover:not(:disabled) {
            background: #0056b3;
        }
        
        .btn-reset:disabled {
            background: #ccc;
            cursor: not-allowed;
        }
        
        .error-message {
            background: #f8d7da;
            color: #721c24;
            padding: 12px;
            border-radius: 5px;
            margin-bottom: 20px;
            border: 1px solid #f5c6cb;
        }
        
        .success-message {
            background: #d4edda;
            color: #155724;
            padding: 12px;
            border-radius: 5px;
            margin-bottom: 20px;
            border: 1px solid #c3e6cb;
            text-align: center;
        }
        
        .login-link {
            text-align: center;
            margin-top: 20px;
            color: #666;
        }
        
        .login-link a {
            color: #007bff;
            text-decoration: none;
        }
        
        .login-link a:hover {
            text-decoration: underline;
        }
    </style>
</head>
<body>
    <div class="reset-container">
        <div class="logo">
            <h1>Transit App</h1>
            <p>Reset Your Password</p>
        </div>
        
        <?php if (!empty($error)): ?>
            <div class="error-message">
                <?php echo htmlspecialchars($error); ?>
            </div>
        <?php endif; ?>
        
        <?php if (!empty($success)): ?>
            <div class="success-message">
                <?php echo htmlspecialchars($success); ?>
            </div>
            <div class="login-link">
                <a href="login.php">Go to Login</a>
            </div>
        <?php elseif ($isValidToken): ?>
            <form method="POST" action="">
                <div class="form-group">
                    <label for="username">Username:</label>
                    <input type="text" id="username" value="<?php echo htmlspecialchars($username); ?>" disabled>
                </div>
                
                <div class="form-group">
                    <label for="email">Email:</label>
                    <input type="email" id="email" value="<?php echo htmlspecialchars($email); ?>" disabled>
                </div>
                
                <div class="form-group">
                    <label for="new_password">New Password:</label>
                    <input type="password" id="new_password" name="new_password" required minlength="8">
                    <div class="password-requirements">Must be at least 8 characters long</div>
                </div>
                
                <div class="form-group">
                    <label for="confirm_password">Confirm New Password:</label>
                    <input type="password" id="confirm_password" name="confirm_password" required minlength="8">
                </div>
                
                <button type="submit" class="btn-reset">Reset Password</button>
            </form>
        <?php endif; ?>
    </div>

    <script>
        // Client-side validation
        document.querySelector('form')?.addEventListener('submit', function(e) {
            const newPassword = document.getElementById('new_password').value;
            const confirmPassword = document.getElementById('confirm_password').value;
            
            if (newPassword !== confirmPassword) {
                e.preventDefault();
                alert('Passwords do not match!');
            }
            
            if (newPassword.length < 8) {
                e.preventDefault();
                alert('Password must be at least 8 characters long!');
            }
        });
    </script>
</body>
</html>
<?php
// Close database connection
$db = null;
?>
