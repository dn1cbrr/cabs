# Email Verification System Guide

## Overview
This guide explains how to implement and use the email verification system in the Transit application. The system ensures users verify their email addresses before accessing full functionality.

## System Components

### 1. Registration Endpoint (`/api/auth/register_enhanced.php`)
- **Purpose**: Registers new users and sends verification emails
- **Method**: POST
- **Content-Type**: application/json

#### Request Body:
```json
{
  "username": "string",
  "email": "string",
  "password": "string",
  "full_name": "string",
  "phone": "string",
  "birthday": "YYYY-MM-DD (optional)",
  "license_name": "string (optional)",
  "license_number": "string (optional)",
  "license_address": "string (optional)",
  "license_codes": "string (optional)",
  "license_expiration": "YYYY-MM-DD (optional)"
}
```

#### Response:
```json
{
  "success": true,
  "message": "User registered successfully. Please check your email to verify your account.",
  "user": {
    "id": 123,
    "username": "testuser",
    "email": "user@example.com",
    "full_name": "Test User",
    "phone": "+1234567890",
    "role": "user",
    "email_verified": false,
    "profile_photo": null
  },
  "email_sent": true
}
```

### 2. Email Verification Endpoint (`/api/auth/verify_email.php`)
- **Purpose**: Verifies user email using token
- **Method**: GET
- **Parameters**: `token` (verification token from email)

#### Example URL:
```
http://localhost:8000/api/auth/verify_email.php?token=abc123xyz
```

#### Response:
```json
{
  "success": true,
  "message": "Email verified successfully"
}
```

### 3. Required Files
- `api/auth/register_enhanced.php` - Registration endpoint
- `api/auth/verify_email.php` - Verification endpoint
- `api/utils/email_service.php` - Email sending functionality
- `api/utils/token_generator.php` - Token generation utilities

## Setup Instructions

### 1. Database Setup
Run the following SQL to ensure your users table has the required fields:

```sql
-- Ensure email verification fields exist
ALTER TABLE users ADD COLUMN IF NOT EXISTS email_verified BOOLEAN DEFAULT FALSE;
ALTER TABLE users ADD COLUMN IF NOT EXISTS email_verification_token VARCHAR(255);
ALTER TABLE users ADD COLUMN IF NOT EXISTS email_verification_expires DATETIME;

-- Create verification logs table
CREATE TABLE IF NOT EXISTS email_verification_logs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    email VARCHAR(255) NOT NULL,
    verification_token VARCHAR(255) NOT NULL,
    ip_address VARCHAR(45),
    user_agent TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id)
);
```

### 2. Email Configuration
Update your email configuration in `api/config/config.php`:

```php
<?php
// Email configuration
define('SMTP_HOST', 'smtp.gmail.com');
define('SMTP_PORT', 587);
define('SMTP_USERNAME', 'your-email@gmail.com');
define('SMTP_PASSWORD', 'your-app-password');
define('SMTP_FROM_EMAIL', 'noreply@yourapp.com');
define('SMTP_FROM_NAME', 'Transit App');
?>
```

### 3. Environment Variables
Set these environment variables:

```bash
# Email settings
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USERNAME=your-email@gmail.com
SMTP_PASSWORD=your-app-password
SMTP_FROM_EMAIL=noreply@yourapp.com
SMTP_FROM_NAME=Transit App

# App settings
APP_URL=http://localhost:8000
```

## Testing the System

### Method 1: Using the Test Script
Run the PHP test script:
```bash
php api/tests/test_email_verification.php
```

### Method 2: Using the HTML Test Page
1. Open `api/tests/email_verification_test.html` in your browser
2. Fill in the registration form
3. Check the test email for verification link
4. Use the verification form to complete the process

### Method 3: Using cURL
```bash
# Register user
curl -X POST http://localhost:8000/api/auth/register_enhanced.php \
  -H "Content-Type: application/json" \
  -d '{
    "username": "testuser",
    "email": "test@example.com",
    "password": "TestPass123!",
    "full_name": "Test User",
    "phone": "+1234567890"
  }'

# Verify email
curl "http://localhost:8000/api/auth/verify_email.php?token=YOUR_VERIFICATION_TOKEN"
```

## Email Templates

### Verification Email Template
The system uses a customizable email template located in `api/templates/verification_email.html`:

```html
<!DOCTYPE html>
<html>
<head>
    <title>Verify Your Email</title>
</head>
<body>
    <h2>Welcome to Transit App!</h2>
    <p>Please click the link below to verify your email address:</p>
    <a href="{{verification_url}}">Verify Email Address</a>
    <p>This link will expire in 24 hours.</p>
</body>
</html>
```

## Security Features

1. **Token Expiration**: Verification tokens expire after 24 hours
2. **One-Time Use**: Each token can only be used once
3. **Rate Limiting**: Prevents excessive verification attempts
4. **IP Logging**: Tracks verification attempts for security
5. **HTTPS Required**: All verification links should use HTTPS in production

## Error Handling

### Common Error Responses

#### Invalid Token
```json
{
  "success": false,
  "message": "Invalid or expired verification token"
}
```

#### Already Verified
```json
{
  "success": false,
  "message": "Email already verified"
}
```

#### Missing Token
```json
{
  "success": false,
  "message": "Verification token is required"
}
```

## Integration with Frontend

### React Example
```javascript
// Registration
const registerUser = async (userData) => {
  const response = await fetch('/api/auth/register_enhanced.php', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(userData)
  });
  return response.json();
};

// Verification
const verifyEmail = async (token) => {
  const response = await fetch(`/api/auth/verify_email.php?token=${token}`);
  return response.json();
};
```

### Flutter Example
```dart
// Registration
Future<Map<String, dynamic>> registerUser(Map<String, dynamic> userData) async {
  final response = await http.post(
    Uri.parse('http://localhost:8000/api/auth/register_enhanced.php'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode(userData),
  );
  return jsonDecode(response.body);
}

// Verification
Future<Map<String, dynamic>> verifyEmail(String token) async {
  final response = await http.get(
    Uri.parse('http://localhost:8000/api/auth/verify_email.php?token=$token'),
  );
  return jsonDecode(response.body);
}
```

## Troubleshooting

### Common Issues

1. **Emails not sending**
   - Check SMTP configuration
   - Verify email credentials
   - Check spam folder

2. **Token not found**
   - Ensure database has correct fields
   - Check token generation function

3. **Verification link not working**
   - Verify APP_URL is correct
   - Check token expiration
   - Ensure HTTPS in production

### Debug Mode
Enable debug mode by setting:
```php
define('DEBUG_MODE', true);
```

This will provide detailed error messages in the response.

## Production Deployment

1. **SSL Certificate**: Ensure HTTPS is enabled
2. **Email Service**: Use a reliable email service (SendGrid, AWS SES, etc.)
3. **Rate Limiting**: Implement rate limiting on verification endpoints
4. **Monitoring**: Set up monitoring for email delivery
5. **Backup**: Regular backup of verification logs

## Support
For issues or questions, please check:
- Error logs in `api/logs/`
- Database verification logs
- Email service logs
- Browser developer tools for frontend issues
