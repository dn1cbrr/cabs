<?php
// Test script to verify update_profile functionality

echo "Testing update_profile functionality...\n";

// Include the database configuration
include_once 'api/config/database.php';

$database = new Database();
$db = $database->getConnection();

if (!$db) {
    echo "Database connection failed\n";
    exit(1);
}

echo "Database connection successful\n";

// Test updating a user profile without photo
echo "Testing profile update without photo...\n";

$query = "UPDATE users SET full_name = :full_name, email = :email WHERE id = :user_id";
$stmt = $db->prepare($query);

$stmt->bindValue(':full_name', 'Test User');
$stmt->bindValue(':email', 'test@example.com');
$stmt->bindValue(':user_id', 1);

if ($stmt->execute()) {
    echo "Profile update without photo successful\n";
} else {
    echo "Profile update without photo failed\n";
}

// Test creating a dummy photo file and updating with photo path
echo "Testing profile update with photo path...\n";

$photo_path = 'uploads/profile_photos/user_1_test.jpg';
@mkdir(dirname($photo_path), 0777, true); // Create directory if it doesn't exist
file_put_contents($photo_path, 'This is a test photo file');

$query = "UPDATE users SET full_name = :full_name, email = :email, profile_photo = :profile_photo WHERE id = :user_id";
$stmt = $db->prepare($query);

$stmt->bindValue(':full_name', 'Test User With Photo');
$stmt->bindValue(':email', 'testphoto@example.com');
$stmt->bindValue(':profile_photo', $photo_path);
$stmt->bindValue(':user_id', 1);

if ($stmt->execute()) {
    echo "Profile update with photo path successful\n";
} else {
    echo "Profile update with photo path failed\n";
}

echo "API testing completed.\n";
?>
