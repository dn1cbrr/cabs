-- Seat Occupancy Monitoring System Database Updates

-- 1. Add seat capacity and occupancy fields to driver_trips table
ALTER TABLE driver_trips 
ADD COLUMN seat_capacity INT DEFAULT 0,
ADD COLUMN current_occupancy INT DEFAULT 0,
ADD COLUMN occupancy_status ENUM('available', 'limited', 'full') DEFAULT 'available';

-- 2. Create view for seat availability

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

-- 3. Insert sample data for testing

INSERT INTO driver_trips (driver_id, route_details, seat_capacity, trip_date, start_time) VALUES
(1, 'Downtown to Airport', 4, '2024-01-15', '08:00:00'),
(2, 'City Center to Mall', 6, '2024-01-15', '09:30:00'),
(3, 'University to Downtown', 8, '2024-01-15', '10:00:00');
