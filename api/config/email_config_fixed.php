<?php
// Fixed PHPMailer configuration with environment variables and better security
use PHPMailer\PHPMailer\PHPMailer;
use PHPMailer\PHPMailer\Exception;

require_once __DIR__ . '/../../vendor/autoload.php';

class FixedEmailConfig {
    private $mail;
    private $config;
    
    public function __construct() {
        $this->mail = new PHPMailer(true);
        $this->loadConfig();
        $this->setupMailer();
    }
    
    private function loadConfig() {
        // Load environment variables
        $this->config = [
            'host' => $_ENV['SMTP_HOST'] ?? 'smtp.gmail.com',
            'port' => $_ENV['SMTP_PORT'] ?? 587,
            'username' => $_ENV['SMTP_USERNAME'] ?? '',
            'password' => $_ENV['SMTP_PASSWORD'] ?? '',
            'from_email' => $_ENV['SMTP_FROM_EMAIL'] ?? 'noreply@transitapp.com',
            'from_name' => $_ENV['SMTP_FROM_NAME'] ?? 'Transit App',
            'secure' => $_ENV['SMTP_SECURE'] ?? 'tls',
            'debug' => $_ENV['SMTP_DEBUG'] ?? 0
        ];
        
        // Validate required configuration
        if (empty($this->config['username']) || empty($this->config['password'])) {
            throw new Exception("SMTP credentials not configured. Please check your .env file.");
        }
    }
    
    private function setupMailer() {
        try {
            $this->mail->isSMTP();
            $this->mail->Host = $this->config['host'];
            $this->mail->SMTPAuth = true;
            $this->mail->Username = $this->config['username'];
            $this->mail->Password = $this->config['password'];
            $this->mail->SMTPSecure = $this->config['secure'];
            $this->mail->Port = $this->config['port'];
            $this->mail->setFrom($this->config['from_email'], $this->config['from_name']);
            
            // Security settings
            $this->mail->SMTPOptions = [
                'ssl' => [
                    'verify_peer' => true,
                    'verify_peer_name' => true,
                    'allow_self_signed' => false
                ]
            ];
            
            $this->mail->CharSet = 'UTF-8';
            $this->mail->SMTPDebug = (int)$this->config['debug'];
            
        } catch (Exception $e) {
            error_log("Email configuration error: " . $e->getMessage());
            throw new Exception("Failed to configure email: " . $e->getMessage());
        }
    }
    
    public function sendPasswordResetEmail($email, $resetLink, $username) {
        try {
            $this->mail->clearAddresses();
            $this->mail->addAddress($email, $username);
            $this->mail->isHTML(true);
            $this->mail->Subject = 'Password Reset Request - Transit App';
            
            $body = $this->getPasswordResetTemplate($username, $resetLink);
            $this->mail->Body = $body;
            $this->mail->AltBody = $this->getPasswordResetText($username, $resetLink);
            
            return $this->mail->send();
        } catch (Exception $e) {
            error_log("Email sending failed: " . $e->getMessage());
            throw new Exception("Failed to send email: " . $e->getMessage());
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
    
    private function getPasswordResetTemplate($username, $resetLink) {
        return '<!DOCTYPE html>
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
            <p>If the button does not work, copy and paste this link into your browser:</p>
            <p><code>' . htmlspecialchars($resetLink) . '</code></p>
            <p>This link will expire in 1 hour for security reasons.</p>
            <p>If you did not request this password reset, please ignore this email.</p>
        </div>
        <div class="footer">
            <p>This is an automated message from Transit App. Please do not reply to this email.</p>
        </div>
    </div>
</body>
</html>';
    }
    
    private function getPasswordResetText($username, $resetLink) {
        return "Hello {$username},\n\nWe received a request to reset your password.\n\nPlease visit: {$resetLink}\n\nThis link expires in 1 hour.\n\nIf you didn't request this, please ignore this email.";
    }
}
?>
]]>
