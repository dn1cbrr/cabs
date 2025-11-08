<?php
function generateSecureToken($length = 32) {
    // Generate a cryptographically secure random token
    return bin2hex(random_bytes($length));
}

function generateOTP($length = 6) {
    // Generate a numeric OTP
    $otp = '';
    for ($i = 0; $i < $length; $i++) {
        $otp .= random_int(0, 9);
    }
    return $otp;
}

function validateToken($token, $maxAge = 86400) {
    // Basic token validation
    if (empty($token) || strlen($token) < 10) {
        return false;
    }
    
    // In a more advanced implementation, you might want to:
    // 1. Check token against database
    // 2. Verify token hasn't expired
    // 3. Check token usage count
    
    return true;
}
?>
