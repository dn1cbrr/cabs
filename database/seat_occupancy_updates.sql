-- Seat Occupancy Monitoring System Database Updates

-- 1. Add seat capacity and occupancy fields to driver_trips table
ALTER TABLE driver_trips 
ADD COLUMN seat_capacity INT DEFAULT 0,
ADD COLUMN current_occupancy INT DEFAULT 0,
ADD COLUMN occupancy_status ENUM('available', 'limited', 'full') DEFAULT 'available';

-- 2. Create passenger_bookings table for detailed seat tracking
CREATE TABLE passenger_bookings (
    id INT AUTO_INCREMENT PRIMARY KEY,
    trip_id INT NOT NULL,
    passenger_name VARCHAR(255) NOT NULL,
    passenger_phone VARCHAR(20),
    seat_number VARCHAR(10),
    booking_status ENUM('reserved', 'confirmed', 'cancelled') DEFAULT 'reserved',
    booking_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (trip_id) REFERENCES driver_trips(id) ON DELETE CASCADE,
    INDEX idx_trip_id (trip_id),
    INDEX idx_booking_status (booking_status)
);

-- 3. Create trigger to update occupancy count automatically
DELIMITER $$
CREATE TRIGGER update_occupancy_on_booking
AFTER INSERT ON passenger_bookings
FOR EACH ROW
BEGIN
    IF NEW.booking_status = 'confirmed' THEN
        UPDATE driver_trips 
        SET current_occupancy = (
            SELECT COUNT(*) 
            FROM passenger_bookings 
            WHERE trip_id = NEW.trip_id AND booking_status = 'confirmed'
        ),
        occupancy_status = CASE
            WHEN (SELECT COUNT(*) FROM passenger_bookings WHERE trip_id = NEW.trip_id AND booking_status = 'confirmed') >= seat_capacity THEN 'full'
            WHEN (SELECT COUNT(*) FROM passenger_bookings WHERE trip_id = NEW.trip_id AND booking_status = 'confirmed') >= (seat_capacity * 0.8) THEN 'limited'
            ELSE 'available'
        END
        WHERE id = NEW.trip_id;
    END IF;
END$$
DELIMITER ;

-- 4. Create view for seat availability
CREATE VIEW trip_seat_availability AS
SELECT 
    dt.id,
    dt.driver_id,
    dt.route_details,
    dt.seat_capacity,
    dt.current_occupancy,
    dt.occupancy_status,
    (dt.seat_capacity - dt.current_occupancy) as available_seats,
    dt.trip_date,
    dt.start_time
FROM driver_trips dt;

-- 5. Insert sample data for testing
INSERT INTO driver_trips (driver_id, route_details, seat_capacity, trip_date, start_time) VALUES
(1, 'Downtown to Airport', 4, '2024-01-15', '08:00:00'),
(2, 'City Center to Mall', 6, '2024-01-15', '09:30:00'),
(3, 'University to Downtown', 8, '2024-01-15', '10:00:00');
