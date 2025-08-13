-- Create trips table
CREATE TABLE IF NOT EXISTS trips (
    id INT AUTO_INCREMENT PRIMARY KEY,
    driver_id INT NOT NULL,
    trip_date DATE NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME,
    route_details TEXT NOT NULL,
    vehicle_type VARCHAR(255) NOT NULL,
    seat_capacity INT NOT NULL,
    current_occupancy INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (driver_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Insert sample trip data for testing
INSERT INTO trips (driver_id, trip_date, start_time, route_details, vehicle_type, seat_capacity, current_occupancy) VALUES
(2, '2024-05-20', '08:00:00', 'Manila to Quezon City', 'Bus', 50, 25),
(3, '2024-05-20', '09:00:00', 'Pasig to Makati', 'Van', 18, 10);
