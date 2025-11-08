<?php
// Email testing utility
require_once __DIR__ . '/../config/email_config_enhanced.php';

class EmailTester {
    private $emailConfig;
    
    public function __construct() {
        $this->emailConfig = new EnhancedEmailConfig();
    }
    
    public function testSMTPConnection() {
        try {
            $result = $this->emailConfig->testConnection();
            return [
                'success' => $result,
                'message' => $result ? 'SMTP connection successful' : 'SMTP connection failed'
            ];
        } catch (Exception $e) {
            return [
                'success' => false,
                'message' => 'SMTP connection error: ' . $e->getMessage()
            ];
        }
    }
    
    public function testPasswordResetEmail($email, $username) {
        try {
            $resetLink = "http://localhost/transit/reset-password.php?token=test_token_12345";
            $result = $this->emailConfig->sendPasswordResetEmail($email, $resetLink, $username);
            
            return [
                'success' => $result,
                'message' => $result ? 'Password reset email sent successfully' : 'Failed to send password reset email',
                'test_link' => $resetLink
            ];
        } catch (Exception $e) {
            return [
                'success' => false,
                'message' => 'Password reset email error: ' . $e->getMessage()
            ];
        }
    }
    
    public function testEmailVerification($email, $username) {
        try {
            $verificationLink = "http://localhost/transit/api/auth/verify_email.php?token=test_token_67890";
            $result = $this->emailConfig->sendEmailVerification($email, $verificationLink, $username);
            
            return [
                'success' => $result,
                'message' => $result ? 'Email verification sent successfully' : 'Failed to send email verification',
                'test_link' => $verificationLink
            ];
        } catch (Exception $e) {
            return [
                'success' => false,
                'message' => 'Email verification error: ' . $e->getMessage()
            ];
        }
    }
    
    public function testWelcomeEmail($email, $username) {
        try {
            $result = $this->emailConfig->sendWelcomeEmail($email, $username);
            
            return [
                'success' => $result,
                'message' => $result ? 'Welcome email sent successfully' : 'Failed to send welcome email'
            ];
        } catch (Exception $e) {
            return [
                'success' => false,
                'message' => 'Welcome email error: ' . $e->getMessage()
            ];
        }
    }
    
    public function testPasswordChangedNotification($email, $username) {
        try {
            $result = $this->emailConfig->sendPasswordChangedNotification($email, $username);
            
            return [
                'success' => $result,
                'message' => $result ? 'Password changed notification sent successfully' : 'Failed to send password changed notification'
            ];
        } catch (Exception $e) {
            return [
                'success' => false,
                'message' => 'Password changed notification error: ' . $e->getMessage()
            ];
        }
    }
    
    public function runAllTests($testEmail, $testUsername) {
        $results = [];
        
        echo "=== Email System Test Suite ===\n\n";
        
        // Test 1: SMTP Connection
        echo "1. Testing SMTP Connection...\n";
        $results['smtp_connection'] = $this->testSMTPConnection();
        echo "   Result: " . $results['smtp_connection']['message'] . "\n\n";
        
        // Test 2: Password Reset Email
        echo "2. Testing Password Reset Email...\n";
        $results['password_reset'] = $this->testPasswordResetEmail($testEmail, $testUsername);
        echo "   Result: " . $results['password_reset']['message'] . "\n";
        if (isset($results['password_reset']['test_link'])) {
            echo "   Test Link: " . $results['password_reset']['test_link'] . "\n";
        }
        echo "\n";
        
        // Test 3: Email Verification
        echo "3. Testing Email Verification...\n";
        $results['email_verification'] = $this->testEmailVerification($testEmail, $testUsername);
        echo "   Result: " . $results['email_verification']['message'] . "\n";
        if (isset($results['email_verification']['test_link'])) {
            echo "   Test Link: " . $results['email_verification']['test_link'] . "\n";
        }
        echo "\n";
        
        // Test 4: Welcome Email
        echo "4. Testing Welcome Email...\n";
        $results['welcome_email'] = $this->testWelcomeEmail($testEmail, $testUsername);
        echo "   Result: " . $results['welcome_email']['message'] . "\n\n";
        
        // Test 5: Password Changed Notification
        echo "5. Testing Password Changed Notification...\n";
        $results['password_changed'] = $this->testPasswordChangedNotification($testEmail, $testUsername);
        echo "   Result: " . $results['password_changed']['message'] . "\n\n";
        
        // Summary
        $passed = count(array_filter($results, function($r) { return $r['success']; }));
        $total = count($results);
        
        echo "=== Test Summary ===\n";
        echo "Passed: $passed/$total tests\n";
        
        if ($passed === $total) {
            echo "✅ All tests passed! Email system is working correctly.\n";
        } else {
            echo "❌ Some tests failed. Check the logs above for details.\n";
        }
        
        return $results;
    }
}

// CLI usage
if (php_sapi_name() === 'cli') {
    if ($argc < 3) {
        echo "Usage: php email_test.php <email> <username>\n";
        echo "Example: php email_test.php test@example.com \"Test User\"\n";
        exit(1);
    }
    
    $testEmail = $argv[1];
    $testUsername = $argv[2];
    
    $tester = new EmailTester();
    $tester->runAllTests($testEmail, $testUsername);
}

// Web usage
if ($_SERVER['REQUEST_METHOD'] === 'GET' && isset($_GET['test'])) {
    header('Content-Type: application/json');
    
    $testEmail = $_GET['email'] ?? 'test@example.com';
    $testUsername = $_GET['username'] ?? 'Test User';
    
    $tester = new EmailTester();
    $results = $tester->runAllTests($testEmail, $testUsername);
    
    echo json_encode($results, JSON_PRETTY_PRINT);
}
?>
