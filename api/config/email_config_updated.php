<?php
// Updated PHPMailer configuration with environment variables
use PHPMailer\PHPMailer\PHPMailer;
use PHPMailer\PHPMailer\Exception;

require_once __DIR__ . '/../../vendor/autoload.php';

// Load environment variables
$envPath = __DIR__ . '/../../.env';
if (file_exists($envPath)) {
    $lines = file($envPath, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES);
    foreach ($lines as $line) {
        if (strpos($line, '=') !== false && strpos($line, '#') !== 0) {
            list($key, $value) = explode('=', $line, 2);
            $_ENV[trim($key)] = trim($value);
        }
    }
}

class EmailConfig {
    private $mail;
    
    public function __construct() {
        $this->mail = new PHPMailer(true);
        $this->setupMailer();
    }
    
    private function setupMailer() {
        try {
            $this->mail->isSMTP();
            $this->mail->Host = $_ENV['SMTP_HOST'] ?? 'smtp.gmail.com';
            $this->mail->SMTPAuth = true;
            $this->mail->Username = $_ENV['SMTP_USERNAME'] ?? 'cabreradaniel9034@gmail.com';
            $this->mail->Password = $_ENV['SMTP_PASSWORD'] ?? 'nwvm mchw ettg gtyc';
            $this->mail->SMTPSecure = $_ENV['SMTP_SECURE'] ?? 'tls';
            $this->mail->Port = $_ENV['SMTP_PORT'] ?? 587;
            $this->mail->setFrom($_ENV['SMTP_FROM_EMAIL'] ?? 'noreply@transitapp.com', $_ENV['SMTP_FROM_NAME'] ?? 'Transit App');
            $this->mail->SMTPDebug = $_ENV['SMTP_DEBUG'] ?? 0;
            $this->mail->CharSet = 'UTF-8';
            
            // Enhanced SMTP options
            $this->mail->SMTPOptions = [
                'ssl' => [
                    'verify_peer' => false,
                    'verify_peer_name' => false,
                    'allow_self_signed' => true
                ]
            ];
            
        } catch (Exception $e) {
            error_log("Email configuration error: " . $e->getMessage());
            throw $e;
        }
    }
    
    public function sendPasswordResetEmail($email, $resetLink, $username) {
        try {
            $this->mail->clearAddresses();
            $this->mail->addAddress($email, $username);
            $this->mail->isHTML(true);
            $this->mail->Subject = 'Password Reset Request - Transit App';
            
            $body = '<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Password Reset - Transit App</title>
    <style>
        body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
        .container { max-width: 600px; margin: 0 auto; padding: 20px; }
        .header { background: #007bff; color: white; padding: 20px; text-align: center; }
        .button { display: inline-block; padding: 12px 24px; background: #007bff; color: white; text-decoration: none; border-radius: 4px; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>Transit App - Password Reset</h1>
        </div>
        <div class="content">
            <h2>Hello ' . htmlspecialchars($username) . '</h2>
            <p>We received a request to reset your password. Click the button below to reset it:</p>
            <p><a href="' . htmlspecialchars($resetLink) . '" class="button">Reset Password</a></p>
            <p>This link will expire in 1 hour.</p>
        </div>
    </div>
</body>
</html>';
            
            $this->mail->Body = $body;
            $this->mail->AltBody = "Hello {$username},\n\nWe received a request to reset your password.\n\nPlease visit: {$resetLink}\n\nThis link expires in 1 hour.";
            
            return $this->mail->send();
        } catch (Exception $e) {
            error_log("Email sending failed: " . $e->getMessage());
            return false;
        }
    }
}
?>
