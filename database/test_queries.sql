-- =============================================
-- SIMPLE TEST QUERIES FOR TRANSIT DATABASE
-- =============================================

-- 1. Test database connection
SELECT 'Database connected successfully!' as message;

-- 2. Show all tables
SHOW TABLES;

-- 3. View all users
SELECT id, username, email, full_name, role, created_at FROM users;

-- 4. Test login for admin user
SELECT id, username, email, full_name, role 
FROM users 
WHERE username = 'admin';

-- 5. Test login for regular user
SELECT id, username, email, full_name, role 
FROM users 
WHERE username = 'user1';

-- 6. Count total users
SELECT COUNT(*) as total_users FROM users;
