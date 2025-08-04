-- Create driver_trips table for tracking trip history
CREATE TABLE IF NOT EXISTS driver_trips (
    id INT AUTO_INCREMENT PRIMARY KEY,
    driver_id INT NOT NULL,
    trip_date DATE NOT NULL,
    start_time DATETIME NOT NULL,
    end_time DATETIME,
    route_details TEXT NOT NULL,
    total_passengers INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (driver_id) REFERENCES drivers(id) ON DELETE CASCADE,
    INDEX idx_driver_date (driver_id, trip_date),
    INDEX idx_trip_date (trip_date)
);

-- Insert sample trip data for testing
INSERT INTO driver_trips (driver_id, trip_date, start_time, end_time, route_details, total_passengers) VALUES
(1, '2024-01-15', '2024-01-15 08:00:00', '2024-01-15 17:30:00', 'Manila to Quezon City via EDSA', 45),
(1, '2024-01-16', '2024-01-16 07:45:00', '2024-01-16 18:00:00', 'Quezon City to Makati via C5', 52),
(2, '2024-01-15', '2024-01-15 09:00:00', '2024-01-15 16:45:00', 'Pasig to Taguig via Ortigas', 38);
