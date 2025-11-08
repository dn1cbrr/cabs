<?php
// Simple SMTP connection test
require_once 'vendor/autoload.php';
use PHPMailer\PHPMailer\PHPMailer;

echo "=== Transit App SMTP Test ===\n\n";

// Test SMTP connection
$mail = new PHPMailer(true);

try {
    $mail->isSMTP();
    $mail->Host = 'smtp.gmail.com';
    $mail->SMTPAuth = true;
    $mail->Username = 'cabreradaniel9034@gmail.com'; // Replace with your email
    $mail->Password = 'nwvm mchw ettg gtyc';    // Replace with your app password
    $mail->SMTPSecure = 'tls';
    $mail->Port = 587;
    
    $mail->SMTPDebug = 2;
    $mail->Timeout = 30;
    
    echo "Testing SMTP connection...\n";
    $mail->smtpConnect();
    echo "✅ SMTP connection successful!\n";
    
} catch (Exception $e) {
    echo "❌ SMTP connection failed: " . $e->getMessage() . "\n";
    echo "\nTroubleshooting:\n";
    echo "1. Check your email and password\n";
    echo "2. For Gmail, use App Password instead of regular password\n";
    echo "3. Enable 2FA on your Google account\n";
    echo "4. Generate App Password at: https://myaccount.google.com/apppasswords\n";
}
?>
