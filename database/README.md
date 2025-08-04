# DECINA TRANSPORT DATABASE SETUP

## How to Import Database in XAMPP/phpMyAdmin

### Step 1: Start XAMPP
1. Open XAMPP Control Panel
2. Start **Apache** and **MySQL** services

### Step 2: Access phpMyAdmin
1. Open your web browser
2. Go to: `http://localhost/phpmyadmin`

### Step 3: Import Database
1. Click on **"Import"** tab in phpMyAdmin
2. Click **"Choose File"** button
3. Select the `transit_db.sql` file from this folder
4. Click **"Go"** button to import

**Note:** The SQL script can be safely run multiple times without errors. It uses `IF NOT EXISTS` clauses to prevent table creation conflicts and `INSERT IGNORE` to avoid duplicate data issues.

### Step 4: Verify Database
1. You should see `transit_db` database created
2. Click on `transit_db` to expand it
3. You should see `users` table with 2 sample records

### Step 5: Test Database
1. Click on **"SQL"** tab in phpMyAdmin
2. Copy and paste queries from `test_queries.sql`
3. Run each query to verify everything works

## Sample Login Credentials

- **Admin User:**
  - Username: `admin`
  - Password: `admin123`
  - Email: `admin@decinatransport.com`

- **Regular User:**
  - Username: `user1`
  - Password: `user123`
  - Email: `user1@example.com`

## Database Structure

- **Database Name:** `transit_db`
- **Table:** `users`
  - `id` - Primary key
  - `username` - Unique username
  - `email` - Unique email
  - `password` - Hashed password
  - `full_name` - User's full name
  - `role` - admin or user
  - `created_at` - Registration timestamp

## Next Steps

After importing this database, you can:
1. Connect your Flutter app to this database via PHP API
2. Add more tables as needed for your transport system
3. Modify user roles and permissions
