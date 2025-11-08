# Heroku Deployment Guide for Transit App

## Prerequisites
1. Heroku CLI installed
2. Git repository initialized
3. Heroku account created

## Step 1: Prepare Your Application

### 1.1 Create Required Files
The following files have been created for Heroku deployment:
- `Procfile` - Tells Heroku how to run your app
- `.env.example` - Template for environment variables
- `api/index.php` - Main API entry point
- `api/composer.json` - PHP dependencies

### 1.2 Environment Configuration
1. Copy `.env.example` to `.env`
2. Fill in your actual values:
   ```bash
   cp .env.example .env
   ```
3. Update the values in `.env` with your Heroku database credentials

## Step 2: Deploy to Heroku

### 2.1 Create Heroku App
```bash
heroku create your-transit-app-name
```

### 2.2 Add MySQL Database
```bash
heroku addons:create cleardb:ignite
```

### 2.3 Get Database Credentials
```bash
heroku config | grep CLEARDB_DATABASE_URL
```

The CLEARDB_DATABASE_URL will be in this format:
`mysql://username:password@host/database?reconnect=true`

Parse this URL to get:
- DB_HOST: host
- DB_USER: username
- DB_PASS: password
- DB_NAME: database

### 2.4 Set Environment Variables
```bash
heroku config:set DB_HOST=your-host
heroku config:set DB_NAME=your-database
heroku config:set DB_USER=your-username
heroku config:set DB_PASS=your-password
heroku config:set APP_ENV=production
heroku config:set SMTP_HOST=smtp.gmail.com
heroku config:set SMTP_PORT=587
heroku config:set SMTP_SECURE=tls
heroku config:set SMTP_USERNAME=your-email@gmail.com
heroku config:set SMTP_PASSWORD=your-app-password
heroku config:set SMTP_FROM_EMAIL=noreply@transitapp.com
heroku config:set SMTP_FROM_NAME="Transit App"
```

## Step 3: Database Setup

### 3.1 Push Code to Heroku
```bash
git add .
git commit -m "Prepare for Heroku deployment"
git push heroku main
```

### 3.2 Run Database Migrations
Connect to Heroku database and run your SQL files:
```bash
# Get database URL
heroku config:get CLEARDB_DATABASE_URL

# Use a MySQL client to connect and run migrations
mysql -h host -u username -p database < database/transit_db.sql
mysql -h host -u username -p database < database/password_reset_table.sql
mysql -h host -u username -p database < database/drivers_table.sql
mysql -h host -u username -p database < database/trips_table.sql
mysql -h host -u username -p database < database/driver_trips_table.sql
mysql -h host -u username -p database < database/seat_occupancy_updates.sql
```

## Step 4: Update Flutter App Configuration

### 4.1 Update API Base URL
In your Flutter app, update the API base URL to point to your Heroku app:

```dart
// In your API service files, change:
const String baseUrl = 'http://localhost/transit/api';
// To:
const String baseUrl = 'https://your-transit-app-name.herokuapp.com/api';
```

### 4.2 Update Firebase Configuration (if needed)
Ensure Firebase is configured for production.

## Step 5: Test Deployment

### 5.1 Test API Endpoints
```bash
# Test basic API connectivity
curl https://your-transit-app-name.herokuapp.com/api/test

# Test authentication endpoints
curl -X POST https://your-transit-app-name.herokuapp.com/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"password"}'
```

### 5.2 Check Logs
```bash
heroku logs --tail
```

## Step 6: Deploy Flutter App to Stores

### 6.1 Android (Google Play Store)
1. Build release APK:
   ```bash
   flutter build apk --release
   ```
2. Sign the APK and upload to Google Play Console

### 6.2 iOS (Apple App Store)
1. Build for iOS:
   ```bash
   flutter build ios --release
   ```
2. Open in Xcode and archive for App Store submission

## Troubleshooting

### Common Issues:

1. **Database Connection Failed**
   - Check environment variables are set correctly
   - Verify ClearDB addon is attached
   - Check database credentials

2. **Composer Dependencies**
   - Heroku automatically runs `composer install`
   - Check `api/composer.json` for correct dependencies

3. **PHP Version**
   - Heroku uses PHP 8.1 by default
   - Check `api/composer.json` platform config

4. **File Permissions**
   - Ensure proper permissions for uploaded files
   - Check `api/.htaccess` configuration

### Useful Commands:
```bash
# Check app status
heroku ps

# View config
heroku config

# Open app in browser
heroku open

# Scale dynos
heroku ps:scale web=1

# Database info
heroku addons:info cleardb
```

## Cost Estimation
- Heroku Eco dyno: $5/month
- ClearDB Ignite (MySQL): $9.99/month
- Total: ~$15/month for small production app

## Security Notes
- Never commit `.env` file to git
- Use HTTPS for all API calls
- Regularly update dependencies
- Monitor logs for security issues
