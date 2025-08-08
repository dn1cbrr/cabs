# Password Reset Functionality Guide

## Overview
This guide explains how to use and configure the password reset functionality in the Transit App.

## Files Structure
```
api/auth/forgot_password.php     # Handles password reset requests
api/auth/reset_password.php      # Handles password reset completion
api/utils/email_helper.php       # Email sending utilities
api/config/email_config.php      # Email configuration
database/password_reset_table.sql # Database schema
```

## Database Setup

1. **Create password_resets table:**
   ```sql
   USE transit_db;
   SOURCE database/password_reset_table.sql;
   ```

2. **Verify users table has required columns:**
   ```sql
   SELECT id, email, username FROM users LIMIT 1;
   ```

## Configuration

### Email Configuration
1. **Update email settings in `api/config/email_config.php`:**
   - Replace `your-email@gmail.com` with your actual email
   - Replace `your-app-password` with your app-specific password
   - For Gmail: Use App Passwords (not regular password)

2. **Install PHPMailer (if not already installed):**
   ```bash
   composer require phpmailer/phpmailer
   ```

## Usage

### Request Password Reset
```bash
curl -X POST http://localhost/transit/api/auth/forgot_password.php \
  -H "Content-Type: application/json" \
  -d '{"email":"user@example.com"}'
```

### Reset Password
```bash
curl -X POST http://localhost/transit/api/auth/reset_password.php \
  -H "Content-Type: application/json" \
  -d '{"token":"your-reset-token","new_password":"newpassword123"}'
```

## Testing

### Manual Testing
1. **Run the test script:**
   ```bash
   php test_forgot_password.php
   ```

2. **Check logs:**
   - Password reset logs: `logs/password_reset.log`
   - PHP error logs: Check your web server error log

### Test Cases
1. **Valid email:** Should receive reset instructions
2. **Invalid email:** Should return generic success message
3. **Missing email:** Should return 400 error
4. **Expired token:** Should return appropriate error
5. **Used token:** Should return appropriate error

## Security Features
- **Token expiration:** Tokens expire after 1 hour
- **Single-use tokens:** Tokens are marked as used after reset
- **Secure token generation:** Uses `random_bytes()` for cryptographically secure tokens
- **Rate limiting:** Consider implementing rate limiting for production
- **HTTPS only:** Ensure HTTPS is used in production

## Production Considerations
1. **Email service:** Use a proper email service (SendGrid, AWS SES, etc.)
2. **Rate limiting:** Implement rate limiting to prevent abuse
3. **HTTPS:** Ensure all reset links use HTTPS
4. **Token storage:** Consider using Redis for token storage in high-traffic scenarios
5. **Logging:** Remove debug logging in production
6. **Email templates:** Use proper HTML email templates

## Troubleshooting

### Common Issues
1. **"Email address not found":** Check if email exists in users table
2. **"Failed to generate reset token":** Check database connection
3. **Email not sent:** Check email configuration and server logs
4. **Token expired:** Ensure tokens are generated with correct expiration time

### Debug Steps
1. Check PHP error logs
2. Verify database connection
3. Check email configuration
4. Test with `test_forgot_password.php`
5. Check `logs/password_reset.log` for detailed logs

## API Endpoints

### POST /api/auth/forgot_password.php
**Request:**
```json
{
  "email": "user@example.com"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Password reset instructions have been sent to your email address"
}
```

### POST /api/auth/reset_password.php
**Request:**
```json
{
  "token": "reset-token-here",
  "new_password": "newpassword123"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Password reset successfully"
}
