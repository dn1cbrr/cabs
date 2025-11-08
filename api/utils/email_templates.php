<?php
class EmailTemplates {
    public static function getPasswordResetTemplate($username, $resetLink) {
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

    public static function getEmailVerificationTemplate($username, $verificationLink) {
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
}
?>
