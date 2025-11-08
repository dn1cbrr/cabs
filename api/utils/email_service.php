<?php
require_once '../config/email_config.php';

function sendVerificationEmail($email, $token, $fullName) {
    $subject = "Verify Your Email Address - Transit App";
    
    $verificationLink = "https://yourdomain.com/api/auth/verify_email.php?token=" . urlencode($token);
    
    $message = "
    <html>
    <head>
        <title>Email Verification</title>
        <style>
            body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
            .container { max-width: 600px; margin: 0 auto; padding: 20px; }
            .header { background-color: #007bff; color: white; padding: 20px; text-align: center; border-radius: 5px 5px 0 0; }
            .content { background-color: #f8f9fa; padding: 30px; border-radius: 0 0 5px 5px; }
            .button { display: inline-block; padding: 12px 24px; background-color: #007bff; color: white; text-decoration: none; border-radius: 5px; margin: 20px 0; }
            .footer { margin-top: 20px; font-size: 12px; color: #666; }
        </style>
    </head>
    <body>
        <div class='container'>
            <div class='header'>
                <h1>Welcome to Transit App!</h1>
            </div>
            <div class='content'>
                <h2>Hello, {$fullName}!</h2>
                <p>Thank you for registering with Transit App. To complete your registration and verify your email address, please click the button below:</p>
                
                <p style='text-align: center;'>
                    <a href='{$verificationLink}' class='button'>Verify Email Address</a>
                </p>
                
                <p>This link will expire in 24 hours. If you didn't create this account, you can safely ignore this email.</p>
                
                <p>If the button doesn't work, you can copy and paste this link into your browser:</p>
                <p><small>{$verificationLink}</small></p>
                
                <div class='footer'>
                    <p>Best regards,<br>The Transit App Team</p>
                </div>
            </div>
        </div>
    </body>
    </html>
    ";
    
    return sendEmail($email, $subject, $message);
}

function sendPasswordResetEmail($email, $token, $fullName) {
    $subject = "Reset Your Password - Transit App";
    
    $resetLink = "https://yourdomain.com/api/auth/reset_password.php?token=" . urlencode($token);
    
    $message = "
    <html>
    <head>
        <title>Password Reset</title>
        <style>
            body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
            .container { max-width: 600px; margin: 0 auto; padding: 20px; }
            .header { background-color: #dc3545; color: white; padding: 20px; text-align: center; border-radius: 5px 5px 0 0; }
            .content { background-color: #f8f9fa; padding: 30px; border-radius: 0 0 5px 5px; }
            .button { display: inline-block; padding: 12px 24px; background-color: #dc3545; color: white; text-decoration: none; border-radius: 5px; margin: 20px 0; }
            .footer { margin-top: 20px; font-size: 12px; color: #666; }
        </style>
    </head>
    <body>
        <div class='container'>
            <div class='header'>
                <h1>Password Reset Request</h1>
            </div>
            <div class='content'>
                <h2>Hello, {$fullName}!</h2>
                <p>We received a request to reset your password. Click the button below to create a new password:</p>
                
                <p style='text-align: center;'>
                    <a href='{$resetLink}' class='button'>Reset Password</a>
                </p>
                
                <p>This link will expire in 1 hour. If you didn't request this password reset, you can safely ignore this email.</p>
                
                <p>If the button doesn't work, you can copy and paste this link into your browser:</p>
                <p><small>{$resetLink}</small></p>
                
                <div class='footer'>
                    <p>Best regards,<br>The Transit App Team</p>
                </div>
            </div>
        </div>
    </body>
    </html>
    ";
    
    return sendEmail($email, $subject, $message);
}

function sendEmail($to, $subject, $htmlContent) {
    // Get email configuration
    $config = getEmailConfig();
    
    // Email headers
    $headers = "MIME-Version: 1.0" . "\r\n";
    $headers .= "Content-type:text/html;charset=UTF-8" . "\r\n";
    $headers .= "From: {$config['from_name']} <{$config['from_email']}>" . "\r\n";
    $headers .= "Reply-To: {$config['from_email']}" . "\r\n";
    
    // Send email
    if (mail($to, $subject, $htmlContent, $headers)) {
        return true;
    } else {
        // Log error or use alternative email service
        error_log("Failed to send email to: $to");
        return false;
    }
}

function getEmailConfig() {
    return [
        'from_email' => 'noreply@yourdomain.com',
        'from_name' => 'Transit App',
        'smtp_host' => 'smtp.yourdomain.com',
        'smtp_port' => 587,
        'smtp_username' => 'noreply@yourdomain.com',
        'smtp_password' => 'your_email_password'
    ];
}
?>
