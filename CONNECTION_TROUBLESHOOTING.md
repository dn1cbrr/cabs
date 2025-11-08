# Connection Error Troubleshooting Guide

## Error: FormatException: Unexpected character <!DOCTYPE HTML...>

This error occurs when your Flutter app receives HTML instead of JSON from the API.

## Immediate Fix Steps

### 1. Start Local Server
```bash
# Navigate to project directory
cd "d:/Intellif Flutter/transit"

# Start PHP development server
php -S localhost:80
```

### 2. Test API Endpoints
Open these URLs in your browser:
- **Test endpoint**: `http://localhost/transit/api/test.php`
- **Login endpoint**: `http://localhost/transit/api/auth/login.php`

### 3. Check Database
```bash
# Start MySQL and create database
mysql -u root -p
CREATE DATABASE transit_db;
USE transit_db;
SOURCE database/transit_db.sql;
```

### 4. Update Configuration
Update `api/config/database.php` with your MySQL password:
```php
define('DB_PASS', 'your_mysql_password'); // Add your password here
```

### 5. Platform-Specific URLs
- **Android Emulator**: `http://10.0.2.2/transit/api`
- **Physical Device**: Use your computer's IP (e.g., `http://192.168.1.7/transit/api`)
- **iOS Simulator**: `http://localhost/transit/api`

## Testing Commands
```bash
# Test API directly
php test_api_direct.php

# Test from Flutter
flutter run --debug
```

## Common Issues
1. **404 Error**: Server not running or wrong path
2. **500 Error**: Database connection issue
3. **CORS Error**: Already handled in PHP files
4. **Network Error**: Check firewall and network settings
