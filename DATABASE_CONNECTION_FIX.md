# Database Connection Fix Guide

## 🔧 Step-by-Step Solutions

### **1. Verify Database Server is Running**
```bash
# Check if MySQL/MariaDB is running
sudo systemctl status mysql
# or
sudo systemctl status mariadb

# If not running, start it:
sudo systemctl start mysql
# or
sudo systemctl start mariadb
```

### **2. Create Database and User**
```sql
-- Connect to MySQL as root
mysql -u root -p

-- Create database
CREATE DATABASE IF NOT EXISTS transit_db;
USE transit_db;

-- Create dedicated user (recommended for security)
CREATE USER IF NOT EXISTS 'transit_user'@'localhost' IDENTIFIED BY 'transit_pass123';
GRANT ALL PRIVILEGES ON transit_db.* TO 'transit_user'@'localhost';
FLUSH PRIVILEGES;

-- Import database schema
SOURCE database/transit_db.sql;
```

### **3. Update Database Configuration**
Update `api/config/database.php`:

```php
<?php
// Database configuration constants
define('DB_HOST', 'localhost');
define('DB_NAME', 'transit_db');
define('DB_USER', 'root'); // Change from 'root'
define('DB_PASS', ''); // Change from empty

class Database {
    private $host = DB_HOST;
    private $db_name = DB_NAME;
    private $username = DB_USER;
    private $password = DB_PASS;
    public $conn;

    public function getConnection() {
        $this->conn = null;
        
        try {
            $this->conn = new PDO(
                "mysql:host=" . $this->host . ";dbname=" . $this->db_name . ";charset=utf8mb4",
                $this->username,
                $this->password,
                [
                    PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
                    PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
                    PDO::ATTR_EMULATE_PREPARES => false,
                ]
            );
        } catch(PDOException $exception) {
            // Log error properly
            error_log("Database connection failed: " . $exception->getMessage());
            throw new Exception("Database connection failed. Please check configuration.");
        }
        
        return $this->conn;
    }
}
?>
```

### **4. Test Database Connection**
Create `test_db_connection.php`:

```php
<?php
require_once 'api/config/database.php';

echo "Testing database connection...\n";

try {
    $database = new Database();
    $db = $database->getConnection();
    
    if ($db) {
        echo "✅ Database connection successful!\n";
        
        // Test basic query
        $stmt = $db->query("SELECT COUNT(*) as user_count FROM users");
        $result = $stmt->fetch();
        echo "Users table has " . $result['user_count'] . " records\n";
    }
} catch (Exception $e) {
    echo "❌ Database connection failed: " . $e->getMessage() . "\n";
}
?>
```

### **5. Flutter Configuration Fix**
Update `lib/config/environment_config.dart`:

```dart
class EnvironmentConfig {
  static const String baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'http://localhost/transit/api',
  );
  
  static const String apiKey = String.fromEnvironment(
    'API_KEY',
    defaultValue: 'your-api-key-here',
  );
  
  static const bool debugMode = bool.fromEnvironment(
    'DEBUG_MODE',
    defaultValue: true,
  );
}
```

### **6. Environment-Specific URLs**
For different environments:

**Local Development:**
- URL: `http://localhost/transit/api`
- Database: `localhost:3306`

**Local Network:**
- URL: `http://192.168.1.100/transit/api`
- Database: `192.168.1.100:3306`

**Android Emulator:**
- URL: `http://10.0.2.2/transit/api`
- Database: `10.0.2.2:3306`

### **7. Quick Test Commands**

**Test PHP API:**
```bash
php -S localhost:8000 -t .
# Then visit: http://localhost:8000/api/test.php
```

**Test Database:**
```bash
php test_db_connection.php
```

**Test Flutter Connection:**
```bash
dart test_connection.dart
```

### **8. Common Error Fixes**

**Error: "Access denied for user"**
- Solution: Check username/password in database.php
- Run: `GRANT ALL PRIVILEGES ON transit_db.* TO 'transit_user'@'localhost';`

**Error: "Unknown database"**
- Solution: Create database manually
- Run: `CREATE DATABASE transit_db;`

**Error: "Connection refused"**
- Solution: Check MySQL is running on correct port
- Run: `sudo systemctl start mysql`

**Error: "Can't connect to MySQL server"**
- Solution: Check firewall or try different host
- Try: `telnet localhost 3306`

### **9. Verification Checklist**
- [ ] MySQL/MariaDB service is running
- [ ] Database `transit_db` exists
- [ ] User has proper permissions
- [ ] PHP PDO extension is installed
- [ ] API endpoints are accessible
- [ ] Flutter app can reach the API

### **10. Debug Script**
Run this to test everything:
```bash
# Make debug script executable
chmod +x debug_connection.sh

# Create debug script
cat > debug_connection.sh << 'EOF'
#!/bin/bash
echo "=== Database Connection Debug ==="
echo "1. Testing MySQL connection..."
mysql -u transit_user -ptransit_pass123 -e "SELECT 1;" transit_db

echo -e "\n2. Testing PHP API..."
curl -I http://localhost/transit/api/test.php

echo -e "\n3. Testing database from PHP..."
php test_db_connection.php

echo -e "\n4. Checking PHP extensions..."
php -m | grep -i pdo

echo -e "\n5. Checking MySQL service..."
sudo systemctl status mysql
EOF

# Run debug
./debug_connection.sh
