<?php
// PHPMailer configuration with proper settings
use PHPMailer\PHPMailer\PHPMailer;
use PHPMailer\PHPMailer\Exception;

require_once __DIR__ . '/../../vendor/autoload.php';

class EmailConfig {
    private $mail;
    
    public function __construct() {
        $this->mail = new PHPMailer(true);
        $this->setupMailer();
    }
    
    private function setupMailer() {
        try {
            $this->mail->isSMTP();
            $this->mail->Host = 'smtp.gmail.com';
            $this->mail->SMTPAuth = true;
            
            // Use environment variables or configuration file for sensitive data
            $this->mail->Username = $_ENV['SMTP_USERNAME'] ?? 'nnnnnniel143@gmail.com';
            $this->mail->Password = $_ENV['SMTP_PASSWORD'] ?? 'Cabs090403!';
            
            $this->mail->SMTPSecure = 'tls';
            $this->mail->Port = 587;
            $this->mail->setFrom('noreply@transitapp.com', 'Transit App');
            $this->mail->SMTPDebug = 0; // Set to 2 for debugging
            $this->mail->CharSet = 'UTF-8';
            
            // Additional security settings
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
        .content { padding: 20px; background: #f9f9f9; }
        .button { display: inline-block; padding: 12px 24px; background: #007bff; color: white; text-decoration: none; border-radius: 4px; }
        .footer { margin-top: 20px; padding: 20px; background: #f1f1f1; font-size: 12px; color: #666; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>Transit App - Password Reset</h1>
        </div>
        <div class="content">
            <h2>Hello ' . htmlspecialchars($username) . '</h2>
            <p>We received a request to reset your password for your Transit App account.</p>
            <p>Click the button below to reset your password:</p>
            <p style="text-align: center;">
                <a href="' . htmlspecialchars($resetLink) . '" class="button">Reset Password</a>
            </p>
            <p>If the button doesn\'t work, copy and paste this link into your browser:</p>
            <p><code>' . htmlspecialchars($resetLink) . '</code></p>
            <p>This link will expire in 1 hour for security reasons.</p>
            <p>If you didn\'t request this password reset, please ignore this email.</p>
        </div>
        <div class="footer">
            <p>This is an automated message from Transit App. Please do not reply to this email.</p>
        </div>
    </div>
</body>
</html>';
            
            $this->mail->Body = $body;
            $this->mail->AltBody = "Hello {$username},\n\nWe received a request to reset your password.\n\nPlease visit: {$resetLink}\n\nThis link expires in 1 hour.\n\nIf you didn't request this, please ignore this email.";
            
            return $this->mail->send();
        } catch (Exception $e) {
            error_log("Email sending failed: " . $e->getMessage());
            return false;
        }
    }
    
    public function testConnection() {
        try {
            $this->mail->smtpConnect();
            return true;
        } catch (Exception $e) {
            error_log("SMTP connection test failed: " . $e->getMessage());
            return false;
        }
    }
}
?>
