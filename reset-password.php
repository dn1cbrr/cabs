<?php
session_start();
require_once 'api/config/database.php';
require_once 'api/utils/email_config.php';

$database = new Database();
$db = $database->getConnection();

$error = '';
$success = '';

// Check if token is provided
if (!isset($_GET['token']) || empty($_GET['token'])) {
    header("Location: login.php");
    exit();
}

$token = $_GET['token'];

// Validate token
$query = "SELECT pr.user_id, pr.expires_at, pr.is_used, u.username, u.email 
          FROM password_resets pr 
          JOIN users u ON pr.user_id = u.id 
          WHERE pr.reset_token = ? AND pr.is_used = 0 
          LIMIT 1";

$stmt = $db->prepare($query);
$stmt->execute([$token]);
$resetData = $stmt->fetch(PDO::FETCH_ASSOC);

if (!$resetData) {
    $error = "Invalid or expired reset link.";
} else {
    // Check if token is expired
    $currentTime = date('Y-m-d H:i:s');
    if ($currentTime > $resetData['expires_at']) {
        $error = "This password reset link has expired. Please request a new one.";
    }
}

// Handle form submission
if ($_SERVER['REQUEST_METHOD'] === 'POST' && !$error) {
    $newPassword = $_POST['new_password'] ?? '';
    $confirmPassword = $_POST['confirm_password'] ?? '';
    
    if (empty($newPassword) || empty($confirmPassword)) {
        $error = "Please fill in both password fields.";
    } elseif (strlen($newPassword) < 8) {
        $error = "Password must be at least 8 characters long.";
    } elseif ($newPassword !== $confirmPassword) {
        $error = "Passwords do not match.";
    } else {
        // Hash new password
        $hashedPassword = password_hash($newPassword, PASSWORD_DEFAULT);
        
        // Update user password
        $updateQuery = "UPDATE users SET password = ? WHERE id = ?";
        $updateStmt = $db->prepare($updateQuery);
        
        if ($updateStmt->execute([$hashedPassword, $resetData['user_id']])) {
            // Mark token as used
            $markUsedQuery = "UPDATE password_resets SET is_used = 1 WHERE reset_token = ?";
            $markUsedStmt = $db->prepare($markUsedQuery);
            $markUsedStmt->execute([$token]);
            
            $success = "Your password has been reset successfully. You can now <a href='login.php'>login</a> with your new password.";
            
            // Clear any session data
            session_destroy();
        } else {
            $error = "Failed to reset password. Please try again.";
        }
    }
}
?>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Reset Password - Transit System</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <style>
        body {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        }
        .reset-container {
            background: white;
            border-radius: 15px;
            box-shadow: 0 15px 35px rgba(0,0,0,0.1);
            padding: 40px;
            max-width: 450px;
            width: 100%;
            margin: 20px;
        }
        .reset-header {
            text-align: center;
            margin-bottom: 30px;
        }
        .reset-header h2 {
            color: #333;
            font-weight: 600;
            margin-bottom: 10px;
        }
        .reset-header p {
            color: #666;
            font-size: 14px;
        }
        .form-group {
            margin-bottom: 25px;
        }
        .form-group label {
            font-weight: 600;
            color: #333;
            margin-bottom: 8px;
            display: block;
        }
        .form-control {
            border: 1px solid #ddd;
            border-radius: 8px;
            padding: 12px 15px;
            font-size: 16px;
            transition: all 0.3s ease;
        }
        .form-control:focus {
            border-color: #667eea;
            box-shadow: 0 0 0 0.2rem rgba(102, 126, 234, 0.25);
        }
        .btn-reset {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            border: none;
            border-radius: 8px;
            padding: 12px 30px;
            color: white;
            font-weight: 600;
            width: 100%;
            transition: all 0.3s ease;
        }
        .btn-reset:hover {
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(102, 126, 234, 0.4);
        }
        .alert {
            border-radius: 8px;
            margin-bottom: 20px;
        }
        .password-toggle {
            position: relative;
        }
        .password-toggle .toggle-icon {
            position: absolute;
            right: 15px;
            top: 50%;
            transform: translateY(-50%);
            cursor: pointer;
            color: #666;
        }
    </style>
</head>
<body>
    <div class="reset-container">
        <div class="reset-header">
            <i class="fas fa-key fa-3x text-primary mb-3"></i>
            <h2>Reset Your Password</h2>
            <?php if (!$error): ?>
                <p>Enter your new password below for account: <strong><?php echo htmlspecialchars($resetData['username']); ?></strong></p>
            <?php endif; ?>
        </div>

        <?php if ($error): ?>
            <div class="alert alert-danger">
                <i class="fas fa-exclamation-triangle"></i> <?php echo htmlspecialchars($error); ?>
            </div>
            <div class="text-center">
                <a href="forgot_password.php" class="btn btn-primary">Request New Reset Link</a>
            </div>
        <?php elseif ($success): ?>
            <div class="alert alert-success">
                <i class="fas fa-check-circle"></i> <?php echo $success; ?>
            </div>
        <?php else: ?>
            <form method="POST" action="">
                <div class="form-group">
                    <label for="new_password">New Password</label>
                    <div class="password-toggle">
                        <input type="password" class="form-control" id="new_password" name="new_password" required>
                        <i class="fas fa-eye toggle-icon" onclick="togglePassword('new_password')"></i>
                    </div>
                    <small class="text-muted">Must be at least 8 characters long</small>
                </div>
                
                <div class="form-group">
                    <label for="confirm_password">Confirm New Password</label>
                    <div class="password-toggle">
                        <input type="password" class="form-control" id="confirm_password" name="confirm_password" required>
                        <i class="fas fa-eye toggle-icon" onclick="togglePassword('confirm_password')"></i>
                    </div>
                </div>
                
                <button type="submit" class="btn btn-reset">
                    <i class="fas fa-lock"></i> Reset Password
                </button>
            </form>
        <?php endif; ?>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        function togglePassword(inputId) {
            const input = document.getElementById(inputId);
            const icon = input.nextElementSibling;
            
            if (input.type === 'password') {
                input.type = 'text';
                icon.classList.remove('fa-eye');
                icon.classList.add('fa-eye-slash');
            } else {
                input.type = 'password';
                icon.classList.remove('fa-eye-slash');
                icon.classList.add('fa-eye');
            }
        }

        // Form validation
        document.querySelector('form')?.addEventListener('submit', function(e) {
            const password = document.getElementById('new_password').value;
            const confirmPassword = document.getElementById('confirm_password').value;
            
            if (password !== confirmPassword) {
                e.preventDefault();
                alert('Passwords do not match!');
                return false;
            }
            
            if (password.length < 8) {
                e.preventDefault();
                alert('Password must be at least 8 characters long!');
                return false;
            }
        });
    </script>
</body>
</html>
