# Transit App SMTP Authentication Fix Guide

## Problem
The email system is failing with "SMTP Error: Could not authenticate" when trying to send password reset emails.

## Quick Fix Steps

### 1. Update Email Configuration
Replace the hardcoded credentials in your email configuration files with proper environment variables.

### 2. Create Environment File
Create a `.env` file in your project root:

```bash
# Email Configuration
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_SECURE=tls
SMTP_USERNAME=cabreradaniel9034@gmail.com
SMTP_PASSWORD=nwvm mchw ettg gtyc
SMTP_FROM_EMAIL=noreply@transitapp.com
SMTP_FROM_NAME=Transit App
SMTP_DEBUG=0
```

### 3. For Gmail Users (Recommended)
1. Enable 2-factor authentication on your Google account
2. Generate an App Password:
   - Go to https://myaccount.google.com/apppasswords
   - Select "Mail" and generate a 16-character password
   - Use this as SMTP_PASSWORD (not your regular Gmail password)

### 4. Update Email Configuration Files
Replace the hardcoded credentials in `api/config/email_config.php`:

```php
// Replace these lines:
$this->mail->Username = 'cabreradaniel9034@gmail.com';
$this->mail->Password = 'nwvm mchw ettg gtyc';

// With:
$this->mail->Username = $_ENV['SMTP_USERNAME'] ?? 'cabreradaniel9034@gmail.com';
$this->mail->Password = $_ENV['SMTP_PASSWORD'] ?? 'ynwvm mchw ettg gtyc';
```

### 5. Test Email Configuration
Run the test script:
```bash
php test_email_connection.php
```

## Alternative Email Providers

| Provider | Host | Port | Notes |
|----------|------|------|-------|
| Gmail | smtp.gmail.com | 587 | Use App Password |
| Outlook | smtp-mail.outlook.com | 587 | Use regular password |
| Yahoo | smtp.mail.yahoo.com | 587 | Use App Password |

## Troubleshooting

1. **"Could not authenticate"** - Check username/password
2. **"Connection timed out"** - Check firewall/port settings
3. **"SMTP connect failed"** - Verify host and port settings

## Debug Mode
Enable debug output by setting SMTP_DEBUG=2 in your .env file to see detailed connection logs.
