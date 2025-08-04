-- Converted PostgreSQL schema for Supabase

-- Create users table
CREATE TABLE IF NOT EXISTS users (
  id SERIAL PRIMARY KEY,
  username VARCHAR(50) NOT NULL UNIQUE,
  email VARCHAR(100) NOT NULL UNIQUE,
  password VARCHAR(255) NOT NULL,
  full_name VARCHAR(100) NOT NULL,
  phone_number VARCHAR(20),
  role VARCHAR(10) NOT NULL DEFAULT 'user' CHECK (role IN ('admin', 'user')),
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Create otp_verifications table for storing OTP codes
CREATE TABLE IF NOT EXISTS otp_verifications (
  id SERIAL PRIMARY KEY,
  user_id INT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  otp_code VARCHAR(10) NOT NULL,
  expires_at TIMESTAMP NOT NULL,
  is_verified BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Create drivers table
CREATE TABLE IF NOT EXISTS drivers (
  id SERIAL PRIMARY KEY,
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
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  is_active BOOLEAN DEFAULT TRUE
);

-- Create trigger function to update updated_at on row update
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ language 'plpgsql';

-- Attach trigger to drivers table
CREATE TRIGGER update_drivers_updated_at
BEFORE UPDATE ON drivers
FOR EACH ROW
EXECUTE PROCEDURE update_updated_at_column();

-- Create driver_trips table
CREATE TABLE IF NOT EXISTS driver_trips (
  id SERIAL PRIMARY KEY,
  driver_id INT NOT NULL REFERENCES drivers(id) ON DELETE CASCADE,
  trip_date DATE NOT NULL,
  start_time TIMESTAMP NOT NULL,
  end_time TIMESTAMP,
  route_details TEXT NOT NULL,
  total_passengers INT DEFAULT 0,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Attach trigger to driver_trips table
CREATE TRIGGER update_driver_trips_updated_at
BEFORE UPDATE ON driver_trips
FOR EACH ROW
EXECUTE PROCEDURE update_updated_at_column();

-- Indexes
CREATE INDEX idx_driver_date ON driver_trips (driver_id, trip_date);
CREATE INDEX idx_trip_date ON driver_trips (trip_date);
