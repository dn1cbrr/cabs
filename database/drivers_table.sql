-- Create drivers table
CREATE TABLE IF NOT EXISTS drivers (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    birthday DATE NOT NULL,
    age INT NOT NULL,
    address TEXT NOT NULL,
    contact VARCHAR(20) NOT NULL,
    license_name VARCHAR(100) NOT NULL,
    license_number VARCHAR(50) NOT NULL UNIQUE,
    license_address TEXT NOT NULL,
    license_codes VARCHAR(100) NOT NULL,
    expiration_date DATE NOT NULL,
    vehicle_type VARCHAR(50) NOT NULL,
    plate_number VARCHAR(20) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE
);

-- Insert sample drivers for testing
INSERT INTO drivers (name, birthday, age, address, contact, license_name, license_number, license_address, license_codes, expiration_date, vehicle_type, plate_number) VALUES
('John Doe', '1990-05-15', 34, '123 Main St, City', '09123456789', 'John Doe', 'D12345678', '123 Main St, City', 'DL Codes 1,2,3', '2025-12-31', 'SUV', 'ABC1234'),
('Jane Smith', '1985-08-22', 39, '456 Oak Ave, Town', '09876543210', 'Jane Smith', 'D87654321', '456 Oak Ave, Town', 'DL Codes 1,2', '2026-06-30', 'Sedan', 'XYZ5678');
