<?php
require_once __DIR__ . '/../config/email_config.php';

class EmailHelper {
    
    public static function sendPasswordResetEmail($email, $resetLink, $username) {
        try {
            $emailConfig = new EmailConfig();
            return $emailConfig->sendPasswordResetEmail($email, $resetLink, $username);
        } catch (Exception $e) {
            error_log("Email sending failed: " . $e->getMessage());
            return false;
        }
    }
    
    public static function logPasswordReset($email, $resetLink, $username) {
        // Log the reset link for testing purposes
        $logFile = __DIR__ . '/../../logs/password_reset.log';
        
        // Create logs directory if it doesn't exist
        if (!is_dir(dirname($logFile))) {
            mkdir(dirname($logFile), 0755, true);
        }
        
        $logEntry = date('Y-m-d H:i:s') . " - Password reset requested\n";
        $logEntry .= "Email: {$email}\n";
        $logEntry .= "Username: {$username}\n";
        $logEntry .= "Reset link: {$resetLink}\n";
        $logEntry .= "----------------------------------------\n";
        
        file_put_contents($logFile, $logEntry, FILE_APPEND | LOCK_EX);
        
        // Also log to PHP error log
        error_log("Password reset requested for: {$email}");
        error_log("Username: {$username}");
        error_log("Reset link: {$resetLink}");
        
        return true;
    }
}
?>
