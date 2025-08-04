# DECINA TRANSPORT - Database Integration Setup Guide

## Overview
This guide will help you set up the complete database integration for the DECINA TRANSPORT Flutter app with PHP API backend.

## Prerequisites
- XAMPP (Apache + MySQL + PHP)
- Flutter SDK
- VS Code or Android Studio
- Web browser

## Step 1: Database Setup

### 1.1 Start XAMPP Services
1. Open XAMPP Control Panel
2. Start **Apache** and **MySQL** services

### 1.2 Import Database
1. Open browser and go to: `http://localhost/phpmyadmin`
2. Click **"Import"** tab
3. Select `database/transit_db.sql` file
4. Click **"Go"** to import
5. Verify `transit_db` database is created with `users` table

## Step 2: API Setup

### 2.1 Copy API Files
1. Copy the entire `api` folder to your XAMPP `htdocs` directory
2. The structure should be: `C:/xampp/htdocs/transit/api/`

### 2.2 Test API Connection
1. Open browser and go to: `http://localhost/transit/api/test.php`
2. You should see a JSON response with success message and user count

### 2.3 Update API URL (if needed)
If your XAMPP is on a different port or path, update the `baseUrl` in:
- `lib/services/auth_service.dart` (line 8)

## Step 3: Flutter App Setup

### 3.1 Install Dependencies
Run the following command in your Flutter project directory:
```bash
flutter pub get
```

### 3.2 Run the App
```bash
flutter run
```

## Step 4: Testing the Integration

### 4.1 Test API Connection
1. Launch the Flutter app
2. Click **"Test API Connection"** button
3. You should see a green success message

### 4.2 Test Login
Use these sample credentials:

**Admin User:**
- Username: `admin`
- Password: `admin123`

**Regular User:**
- Username: `user1`
- Password: `user123`

## File Structure

```
transit/
├── api/
│   ├── config/
│   │   └── database.php          # Database connection
│   ├── auth/
│   │   ├── login.php            # Login endpoint
│   │   └── register.php         # Registration endpoint
│   └── test.php                 # API test endpoint
├── database/
│   ├── transit_db.sql           # Database schema
│   ├── test_queries.sql         # Test queries
│   └── README.md                # Database setup guide
├── lib/
│   ├── models/
│   │   └── user.dart            # User model
│   ├── services/
│   │   └── auth_service.dart    # API service
│   ├── screens/
│   │   └── dashboard_screen.dart # Dashboard UI
│   └── main.dart                # Main app
└── pubspec.yaml                 # Flutter dependencies
```

## API Endpoints

- **GET** `/api/test.php` - Test API connection
- **POST** `/api/auth/login.php` - User login
- **POST** `/api/auth/register.php` - User registration

## Features Implemented

✅ Database connection with error handling  
✅ User authentication (login/logout)  
✅ Session management with SharedPreferences  
✅ Responsive UI with loading states  
✅ Dashboard with user information  
✅ Role-based access (admin/user)  
✅ API connection testing  

## Troubleshooting

### Common Issues:

1. **API Connection Failed**
   - Check if XAMPP Apache is running
   - Verify API files are in correct location
   - Check the baseUrl in auth_service.dart

2. **Database Connection Error**
   - Ensure MySQL is running in XAMPP
   - Verify database was imported correctly
   - Check database credentials in database.php

3. **Login Failed**
   - Verify sample users exist in database
   - Check password hashing (sample passwords use bcrypt)
   - Test API endpoints directly in browser

4. **Flutter Dependencies Error**
   - Run `flutter clean`
   - Run `flutter pub get`
   - Restart your IDE

## Next Steps

After successful setup, you can:
1. Add more features to the dashboard
2. Implement user registration
3. Add more database tables
4. Enhance the UI/UX
5. Add push notifications
6. Implement booking system

## Support

If you encounter any issues, check:
1. XAMPP error logs
2. Flutter console output
3. Browser developer tools (Network tab)
4. Database query logs in phpMyAdmin
