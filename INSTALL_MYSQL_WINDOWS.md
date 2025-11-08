# MySQL Installation Guide for Windows

## 🎯 **Root Cause Identified**
Your database connection is failing because **MySQL/MariaDB is not installed or running** on your Windows system.

## 📥 **Installation Options**

### **Option 1: XAMPP (Recommended for this project)**
1. **Download XAMPP:**
   - Go to: https://www.apachefriends.org/download.html
   - Download XAMPP for Windows
   - Choose the version with PHP 8.x

2. **Install XAMPP:**
   - Run the installer as Administrator
   - Install to: `C:\xampp`
   - Select components: Apache, MySQL, PHP, phpMyAdmin

3. **Start MySQL:**
   - Open XAMPP Control Panel
   - Click "Start" next to MySQL
   - MySQL will run on port 3306

### **Option 2: MySQL Community Server**
1. **Download MySQL:**
   - Go to: https://dev.mysql.com/downloads/installer/
   - Download MySQL Installer for Windows
   - Choose "MySQL Community Server"

2. **Install MySQL:**
   - Run the installer
   - Choose "Developer Default" setup type
   - Set root password (remember it!)
   - Default port: 3306

### **Option 3: MariaDB (MySQL-compatible)**
1. **Download MariaDB:**
   - Go to: https://mariadb.org/download/
   - Download MariaDB for Windows
   - Install with default settings

## 🔧 **Post-Installation Steps**

### **1. Verify Installation**
```bash
# Test MySQL connection
mysql -u root -p
# or
mysql -u root
```

### **2. Create Database and User**
```sql
-- Connect to MySQL
mysql -u root -p

-- Create database
CREATE DATABASE transit_db;
USE transit_db;

-- Create user for the app
CREATE USER 'transit_user'@'localhost' IDENTIFIED BY 'transit_pass123';
GRANT ALL PRIVILEGES ON transit_db.* TO 'transit_user'@'localhost';
FLUSH PRIVILEGES;

-- Import database schema
SOURCE database/transit_db.sql;
EXIT;
```

### **3. Update Configuration**
Update `api/config/database.php`:
```php
<?php
// Update these values based on your MySQL setup
define('DB_HOST', 'localhost');
define('DB_NAME', 'transit_db');
define('DB_USER', 'transit_user'); // or 'root'
define('DB_PASS', 'transit_pass123'); // or your root password
?>
```

### **4. Test Connection**
```bash
# Run the debug script again
php debug_connection.php
```

## 🚀 **Quick Start Commands**

### **For XAMPP:**
1. Install XAMPP
2. Start XAMPP Control Panel
3. Start Apache and MySQL services
4. Open phpMyAdmin: http://localhost/phpmyadmin
5. Create database: `transit_db`
6. Import database/transit_db.sql

### **For MySQL Server:**
1. Install MySQL
2. Start MySQL service: `net start mysql`
3. Connect: `mysql -u root -p`
4. Create database and user as shown above

## ✅ **Verification Steps**

After installation, verify:
1. **MySQL service is running**
2. **Database `transit_db` exists**
3. **User credentials work**
4. **PHP can connect to MySQL**
5. **API endpoints are accessible**

## 🆘 **Troubleshooting**

If you encounter issues:
1. **Check Windows Firewall** - allow MySQL port 3306
2. **Verify MySQL service** - check Windows Services
3. **Test with phpMyAdmin** - http://localhost/phpmyadmin
4. **Check PHP extensions** - ensure mysqli and pdo_mysql are enabled
5. **Review MySQL logs** - check for connection errors

## 📞 **Need Help?**

If you're unsure which option to choose:
- **For beginners**: Use XAMPP (easiest setup)
- **For production**: Use MySQL Community Server
- **For compatibility**: MariaDB works great too

Once MySQL is installed, run `php debug_connection.php` again to verify everything works!
