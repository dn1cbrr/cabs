<?php
// Comprehensive SMTP Test Script for Transit App
require_once 'vendor/autoload.php';
use PHPMailer\PHPMailer\PHPMailer;

echo "=== Transit App SMTP Authentication Fix Test ===\n\n";

// Load environment variables
$envPath = __DIR__ . '/.env';
if (file_exists($envPath)) {
    $lines = file($envPath, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES);
    foreach ($lines as $line) {
        if (strpos($line, '=') !== false && strpos($line, '#') !== 0) {
            list($key, $value) = explode('=', $line, 2);
            $_ENV[trim($key)] = trim($value);
        }
    }
    echo "✅ Environment variables loaded from .env file\n";
} else {
    echo "❌ .env file not found. Using default values.\n";
}

// Test configuration
$config = [
    'host' => $_ENV['SMTP_HOST'] ?? 'smtp.gmail.com',
    'username' => $_ENV['SMTP_USERNAME'] ?? 'cabreradaniel9034@gmail.com',
    'password' => $_ENV['SMTP_PASSWORD'] ?? 'nwvm mchw ettg gtyc',
    'port' => $_ENV['SMTP_PORT'] ?? 587,
    'secure' => $_ENV['SMTP_SECURE'] ?? 'tls',
    'from_email' => $_ENV['SMTP_FROM_EMAIL'] ?? 'noreply@transitapp.com',
    'from_name' => $_ENV['SMTP_FROM_NAME'] ?? 'Transit App'
];

echo "\n=== Configuration Check ===\n";
echo "Host: {$config['host']}\n";
echo "Port: {$config['port']}\n";
echo "Username: {$config['username']}\n";
echo "Security: {$config['secure']}\n";
echo "From: {$config['from_name']} <{$config['from_email']}>\n";

// Test SMTP connection
$mail = new PHPMailer(true);
$mail->isSMTP();
$mail->Host = $config['host'];
$mail->SMTPAuth = true;
$mail->Username = $config['username'];
$mail->Password = $config['password'];
$mail->SMTPSecure = $config['secure'];
$mail->Port = $config['port'];
$mail->SMTPDebug = 2;
$mail->Timeout = 30;

echo "\n=== Testing SMTP Connection ===\n";
try {
    $mail->smtpConnect();
    echo "✅ SMTP Connection: SUCCESS\n";
    
    // Test authentication
    if ($mail->smtpConnect()) {
        echo "✅ SMTP Authentication: SUCCESS\n";
        
        // Test sending a simple email (optional)
        echo "\n=== Testing Email Sending ===\n";
        $mail->SMTPDebug = 0; // Disable debug for actual sending
        
        try {
            $mail->setFrom($config['from_email'], $config['from_name']);
            $mail->addAddress($config['username'], 'Test User');
            $mail->Subject = 'Transit App - SMTP Test Success';
            $mail->Body = 'This is a test email to verify SMTP configuration is working correctly.';
            
            $mail->send();
            echo "✅ Test Email: SENT SUCCESSFULLY\n";
        } catch (Exception $e) {
            echo "❌ Test Email: FAILED - " . $e->getMessage() . "\n";
        }
    }
    
} catch (Exception $e) {
    echo "❌ SMTP Connection: FAILED\n";
    echo "Error: " . $e->getMessage() . "\n";
    
    echo "\n=== Troubleshooting Guide ===\n";
    echo "1. Check your email and password in .env file\n";
    echo "2. For Gmail, use App Password instead of regular password\n";
    echo "3. Enable 2FA on your Google account\n";
    echo "4. Generate App Password at: https://myaccount.google.com/apppasswords\n";
    echo "5. Check firewall settings\n";
    echo "6. Verify port 587 is not blocked\n";
}

echo "\n=== Next Steps ===\n";
echo "1. If test passed: Your SMTP configuration is working\n";
echo "2. If test failed: Update SMTP_PASSWORD in .env file with correct credentials\n";
echo "3. For Gmail: Generate App Password and update .env file\n";
echo "4. Test password reset functionality\n";
?>
