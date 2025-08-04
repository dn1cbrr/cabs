@echo off
echo Deploying Transit API to XAMPP...

REM Check if XAMPP htdocs directory exists
if not exist "C:\xampp\htdocs\" (
    echo Error: XAMPP htdocs directory not found at C:\xampp\htdocs\
    echo Please ensure XAMPP is installed or update the path in this script.
    pause
    exit /b 1
)

REM Create transit directory structure in htdocs
echo Creating directory structure...
if not exist "C:\xampp\htdocs\transit\" mkdir "C:\xampp\htdocs\transit\"
if not exist "C:\xampp\htdocs\transit\api\" mkdir "C:\xampp\htdocs\transit\api\"
if not exist "C:\xampp\htdocs\transit\api\config\" mkdir "C:\xampp\htdocs\transit\api\config\"
if not exist "C:\xampp\htdocs\transit\api\auth\" mkdir "C:\xampp\htdocs\transit\api\auth\"
if not exist "C:\xampp\htdocs\transit\api\drivers\" mkdir "C:\xampp\htdocs\transit\api\drivers\"
if not exist "C:\xampp\htdocs\transit\api\drivers\trips\" mkdir "C:\xampp\htdocs\transit\api\drivers\trips\"
if not exist "C:\xampp\htdocs\transit\api\users\" mkdir "C:\xampp\htdocs\transit\api\users\"
if not exist "C:\xampp\htdocs\transit\api\uploads\" mkdir "C:\xampp\htdocs\transit\api\uploads\"
if not exist "C:\xampp\htdocs\transit\api\uploads\profile_photos\" mkdir "C:\xampp\htdocs\transit\api\uploads\profile_photos\"

REM Copy API files
echo Copying API files...
copy "api\*.php" "C:\xampp\htdocs\transit\api\" >nul 2>&1
copy "api\config\*.php" "C:\xampp\htdocs\transit\api\config\" >nul 2>&1
copy "api\auth\*.php" "C:\xampp\htdocs\transit\api\auth\" >nul 2>&1
copy "api\drivers\*.php" "C:\xampp\htdocs\transit\api\drivers\" >nul 2>&1
copy "api\drivers\trips\*.php" "C:\xampp\htdocs\transit\api\drivers\trips\" >nul 2>&1
copy "api\users\*.php" "C:\xampp\htdocs\transit\api\users\" >nul 2>&1

REM Copy uploads directory (if exists)
if exist "api\uploads\profile_photos\*.*" (
    copy "api\uploads\profile_photos\*.*" "C:\xampp\htdocs\transit\api\uploads\profile_photos\" >nul 2>&1
)

echo.
echo ✅ API deployment completed!
echo.
echo The following endpoints should now be accessible:
echo - http://localhost/transit/api/test.php
echo - http://localhost/transit/api/drivers/trips/add.php
echo - http://localhost/transit/api/auth/login.php
echo - http://localhost/transit/api/drivers/index.php
echo.
echo Next steps:
echo 1. Ensure XAMPP Apache and MySQL services are running
echo 2. Import the database schema from the database/ folder
echo 3. Test the connection using: dart test_connection.dart
echo.
pause
