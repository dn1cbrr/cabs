<?php
// Enhanced PHPMailer configuration with better security and error handling
use PHPMailer\PHPMailer\PHPMailer;
use PHPMailer\PHPMailer\Exception;

require_once __DIR__ . '/../../vendor/autoload.php';

class EnhancedEmailConfig {
    private $mail;
    private $maxRetries = 3;
    private $retryDelay = 1; // seconds
    
    public function __construct() {
        $this->mail = new PHPMailer(true);
        $this->setupMailer();
    }
    
    private function setupMailer() {
        try {
            $this->mail->isSMTP();
            $this->mail->Host = $_ENV['SMTP_HOST'] ?? 'smtp.gmail.com';
            $this->mail->SMTPAuth = true;
            
            // Use environment variables for security
            $this->mail->Username = $_ENV['SMTP_USERNAME'] ?? 'cabreradaniel9034@gmail.com';
            $this->mail->Password = $_ENV['SMTP_PASSWORD'] ?? 'Cabrera0656!';
            
            // Enhanced security settings
            $this->mail->SMTPSecure = $_ENV['SMTP_SECURE'] ?? 'tls';
            $this->mail->Port = $_ENV['SMTP_PORT'] ?? 587;
            $this->mail->setFrom($_ENV['SMTP_FROM_EMAIL'] ?? 'noreply@transitapp.com', $_ENV['SMTP_FROM_NAME'] ?? 'Transit App');
            
            // Security headers
            $this->mail->addCustomHeader('X-Mailer', 'TransitApp-PHPMailer');
            $this->mail->addCustomHeader('X-Auto-Response-Suppress', 'OOF, DR, RN, NRN, AutoReply');
            
            // Enhanced SMTP options
            $this->mail->SMTPOptions = [
                'ssl' => [
                    'verify_peer' => true,
                    'verify_peer_name' => true,
                    'allow_self_signed' => false
                ]
            ];
            
            // Timeouts
            $this->mail->Timeout = 30;
            $this->mail->SMTPKeepAlive = true;
            
            // Debug settings (controlled by environment)
            $this->mail->SMTPDebug = $_ENV['SMTP_DEBUG'] ?? 0;
            
            $this->mail->CharSet = 'UTF-8';
            
        } catch (Exception $e) {
            error_log("Enhanced Email configuration error: " . $e->getMessage());
            throw $e;
        }
    }
    
    public function sendWithRetry($callback) {
        $attempts = 0;
        $lastException = null;
        
        while ($attempts < $this->maxRetries) {
            try {
                return $callback();
            } catch (Exception $e) {
                $lastException = $e;
                $attempts++;
                
                if ($attempts < $this->maxRetries) {
                    sleep($this->retryDelay * $attempts);
                    error_log("Email attempt {$attempts} failed, retrying: " . $e->getMessage());
                }
            }
        }
        
        error_log("All email attempts failed after {$this->maxRetries} tries: " . $lastException->getMessage());
        throw $lastException;
    }
    
    public function sendPasswordResetEmail($email, $resetLink, $username) {
        return $this->sendWithRetry(function() use ($email, $resetLink, $username) {
            $this->mail->clearAddresses();
            $this->mail->addAddress($email, $username);
            $this->mail->isHTML(true);
            $this->mail->Subject = 'Password Reset Request - Transit App';
            
            $body = $this->getPasswordResetTemplate($username, $resetLink);
            $this->mail->Body = $body;
            $this->mail->AltBody = $this->getPasswordResetText($username, $resetLink);
            
            return $this->mail->send();
        });
    }
    
    public function sendEmailVerification($email, $verificationLink, $username) {
        return $this->sendWithRetry(function() use ($email, $verificationLink, $username) {
            $this->mail->clearAddresses();
            $this->mail->addAddress($email, $username);
            $this->mail->isHTML(true);
            $this->mail->Subject = 'Email Verification - Transit App';
            
            $body = $this->getEmailVerificationTemplate($username, $verificationLink);
            $this->mail->Body = $body;
            $this->mail->AltBody = $this->getEmailVerificationText($username, $verificationLink);
            
            return $this->mail->send();
        });
    }
    
    public function sendWelcomeEmail($email, $username) {
        return $this->sendWithRetry(function() use ($email, $username) {
            $this->mail->clearAddresses();
            $this->mail->addAddress($email, $username);
            $this->mail->isHTML(true);
            $this->mail->Subject = 'Welcome to Transit App!';
            
            $body = $this->getWelcomeTemplate($username);
            $this->mail->Body = $body;
            $this->mail->AltBody = $this->getWelcomeText($username);
            
            return $this->mail->send();
        });
    }
    
    public function sendPasswordChangedNotification($email, $username) {
        return $this->sendWithRetry(function() use ($email, $username) {
            $this->mail->clearAddresses();
            $this->mail->addAddress($email, $username);
            $this->mail->isHTML(true);
            $this->mail->Subject = 'Password Changed - Transit App';
            
            $body = $this->getPasswordChangedTemplate($username);
            $this->mail->Body = $body;
            $this->mail->AltBody = $this->getPasswordChangedText($username);
            
            return $this->mail->send();
        });
    }
    
    private function getPasswordResetTemplate($username, $resetLink) {
        return '<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Password Reset - Transit App</title>
    <style>
        body { font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Arial, sans-serif; line-height: 1.6; color: #333; margin: 0; padding: 0; }
        .container { max-width: 600px; margin: 0 auto; padding: 20px; }
        .header { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 30px; text-align: center; border-radius: 8px 8px 0 0; }
        .content { padding: 30px; background: #ffffff; border: 1px solid #e0e0e0; border-top: none; border-radius: 0 0 8px 8px; }
        .button { display: inline-block; padding: 15px 30px; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; text-decoration: none; border-radius: 5px; font-weight: bold; margin: 20px 0; }
        .security-notice { background: #fff3cd; border: 1px solid #ffeaa7; padding: 15px; border-radius: 5px; margin: 20px 0; }
        .footer { margin-top: 30px; padding: 20px; background: #f8f9fa; font-size: 12px; color: #666; text-align: center; border-radius: 8px; }
        .expiry-notice { color: #e74c3c; font-weight: bold; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>🔐 Transit App Password Reset</h1>
        </div>
        <div class="content">
            <h2>Hello ' . htmlspecialchars($username) . '</h2>
            <p>We received a request to reset your password for your Transit App account. If you made this request, click the button below to reset your password:</p>
            
            <div style="text-align: center;">
                <a href="' . htmlspecialchars($resetLink) . '" class="button">Reset My Password</a>
            </div>
            
            <div class="security-notice">
                <strong>Security Notice:</strong> This link will expire in 1 hour and can only be used once. If you didn\'t request this password reset, please ignore this email or contact support if you have concerns.
            </div>
            
            <p>If the button doesn\'t work, copy and paste this secure link into your browser:</p>
            <p><code style="background: #f8f9fa; padding: 10px; border-radius: 3px; word-break: break-all;">' . htmlspecialchars($resetLink) . '</code></p>
            
            <p class="expiry-notice">⚠️ This link expires at: ' . date('Y-m-d H:i:s', strtotime('+1 hour')) . '</p>
        </div>
        <div class="footer">
            <p>This is an automated security message from Transit App.<br>
            If you need help, contact support at support@transitapp.com</p>
            <p>Transit App Security Team</p>
        </div>
    </div>
</body>
</html>';
    }
    
    private function getEmailVerificationTemplate($username, $verificationLink) {
        return '<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Email Verification - Transit App</title>
    <style>
        body { font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Arial, sans-serif; line-height: 1.6; color: #333; margin: 0; padding: 0; }
        .container { max-width: 600px; margin: 0 auto; padding: 20px; }
        .header { background: linear-gradient(135deg, #28a745 0%, #20c997 100%); color: white; padding: 30px; text-align: center; border-radius: 8px 8px 0 0; }
        .content { padding: 30px; background: #ffffff; border: 1px solid #e0e0e0; border-top: none; border-radius: 0 0 8px 8px; }
        .button { display: inline-block; padding: 15px 30px; background: linear-gradient(135deg, #28a745 0%, #20c997 100%); color: white; text-decoration: none; border-radius: 5px; font-weight: bold; margin: 20px 0; }
        .footer { margin-top: 30px; padding: 20px; background: #f8f9fa; font-size: 12px; color: #666; text-align: center; border-radius: 8px; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>✉️ Verify Your Email - Transit App</h1>
        </div>
        <div class="content">
            <h2>Hello ' . htmlspecialchars($username) . '</h2>
            <p>Welcome to Transit App! Please verify your email address to complete your registration and access all features.</p>
            
            <div style="text-align: center;">
                <a href="' . htmlspecialchars($verificationLink) . '" class="button">Verify My Email</a>
            </div>
            
            <p>If the button doesn\'t work, copy and paste this link into your browser:</p>
            <p><code style="background: #f8f9fa; padding: 10px; border-radius: 3px; word-break: break-all;">' . htmlspecialchars($verificationLink) . '</code></p>
            
            <p>This verification link will expire in 24 hours for security reasons.</p>
        </div>
        <div class="footer">
            <p>Welcome to Transit App! We\'re excited to have you on board.</p>
        </div>
    </div>
</body>
</html>';
    }
    
    private function getWelcomeTemplate($username) {
        return '<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Welcome - Transit App</title>
    <style>
        body { font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Arial, sans-serif; line-height: 1.6; color: #333; margin: 0; padding: 0; }
        .container { max-width: 600px; margin: 0 auto; padding: 20px; }
        .header { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 30px; text-align: center; border-radius: 8px 8px 0 0; }
        .content { padding: 30px; background: #ffffff; border: 1px solid #e0e0e0; border-top: none; border-radius: 0 0 8px 8px; }
        .footer { margin-top: 30px; padding: 20px; background: #f8f9fa; font-size: 12px; color: #666; text-align: center; border-radius: 8px; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>🎉 Welcome to Transit App!</h1>
        </div>
        <div class="content">
            <h2>Hello ' . htmlspecialchars($username) . '</h2>
            <p>Welcome to Transit App! Your account has been successfully created and verified.</p>
            
            <p>You can now:</p>
            <ul>
                <li>Book and manage your trips</li>
                <li>Track your journey in real-time</li>
                <li>Manage your profile and preferences</li>
                <li>Get notifications about your trips</li>
            </ul>
            
            <p>Thank you for joining our community!</p>
        </div>
        <div class="footer">
            <p>Welcome aboard! The Transit App Team</p>
        </div>
    </div>
</body>
</html>';
    }
    
    private function getPasswordChangedTemplate($username) {
        return '<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Password Changed - Transit App</title>
    <style>
        body { font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Arial, sans-serif; line-height: 1.6; color: #333; margin: 0; padding: 0; }
        .container { max-width: 600px; margin: 0 auto; padding: 20px; }
        .header { background: linear-gradient(135deg, #28a745 0%, #20c997 100%); color: white; padding: 30px; text-align: center; border-radius: 8px 8px 0 0; }
        .content { padding: 30px; background: #ffffff; border: 1px solid #e0e0e0; border-top: none; border-radius: 0 0 8px 8px; }
        .footer { margin-top: 30px; padding: 20px; background: #f8f9fa; font-size: 12px; color: #666; text-align: center; border-radius: 8px; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>✅ Password Changed Successfully</h1>
        </div>
        <div class="content">
            <h2>Hello ' . htmlspecialchars($username) . '</h2>
            <p>This is a confirmation that your password has been successfully changed.</p>
            
            <p>If you made this change, no further action is needed.</p>
            
            <p><strong>If you did NOT make this change:</strong></p>
            <ul>
                <li>Immediately reset your password using the "Forgot Password" option</li>
                <li>Contact our support team at support@transitapp.com</li>
                <li>Review your account for any unauthorized activity</li>
            </ul>
        </div>
        <div class="footer">
            <p>Security Team - Transit App</p>
        </div>
    </div>
</body>
</html>';
    }
    
    // Text versions for email clients that don't support HTML
    private function getPasswordResetText($username, $resetLink) {
        return "Hello {$username},

We received a request to reset your password for your Transit App account.

Please visit this secure link to reset your password:
{$resetLink}

This link will expire in 1 hour for security reasons.

If you didn't request this password reset, please ignore this email.

Transit App Security Team";
    }
    
    private function getEmailVerificationText($username, $verificationLink) {
        return "Hello {$username},

Welcome to Transit App! Please verify your email address by visiting:
{$verificationLink}

This verification link will expire in 24 hours.

Welcome to our community!
Transit App Team";
    }
    
    private function getWelcomeText($username) {
        return "Hello {$username},

Welcome to Transit App! Your account has been successfully created and verified.

You can now:
- Book and manage your trips
- Track your journey in real-time
- Manage your profile and preferences
- Get notifications about your trips

Thank you for joining our community!

Transit App Team";
    }
    
    private function getPasswordChangedText($username) {
        return "Hello {$username},

This is a confirmation that your password has been successfully changed.

If you made this change, no further action is needed.

If you did NOT make this change:
- Immediately reset your password
- Contact support@transitapp.com
- Review your account for unauthorized activity

Transit App Security Team";
    }
    
    public function testConnection() {
        try {
            $this->mail->smtpConnect();
            return true;
        } catch (Exception $e) {
            error_log("Enhanced SMTP connection test failed: " . $e->getMessage());
            return false;
        }
    }
}
?>
