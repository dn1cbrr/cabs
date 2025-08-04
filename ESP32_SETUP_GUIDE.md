# ESP32 Bluetooth Seat Occupancy System Setup Guide

## Overview
This guide provides step-by-step instructions to set up the ESP32-based seat occupancy monitoring system with Bluetooth connectivity.

## Hardware Requirements
- **ESP32 DevKit** (any ESP32 board with BLE support)
- **Pressure sensors** (4x FSR or load cells for 4 seats)
- **Jumper wires** for connections
- **Breadboard** or PCB for prototyping
- **USB cable** for power/programming

## Software Requirements
- **Arduino IDE** with ESP32 board support
- **Flutter** with Flutter Blue Plus package
- **Node.js** (optional for backend integration)

## Step 1: Hardware Setup

### ESP32 Pin Connections
```
ESP32 Pin    | Component
-------------|------------------
GPIO32       | Seat Sensor 1
GPIO33       | Seat Sensor 2
GPIO25       | Seat Sensor 3
GPIO26       | Seat Sensor 4
GPIO2        | LED Indicator
GPIO4        | Buzzer
```

### Sensor Wiring
- Connect each pressure sensor to the corresponding GPIO pin
- Add pull-down resistors (10kΩ) between each sensor and ground
- Connect LED and buzzer to their respective pins

## Step 2: Software Setup

### ESP32 Arduino Code
1. Install Arduino IDE
2. Add ESP32 board support via Boards Manager
3. Upload the provided `esp32_seat_monitor.ino` file
4. Verify the code compiles and uploads successfully

### Flutter App Setup
1. Install Flutter SDK
2. Add dependencies to `pubspec.yaml`:
   ```yaml
   dependencies:
     flutter_blue_plus: ^1.31.15
   ```
3. Run `flutter pub get` to install dependencies

## Step 3: Configuration

### ESP32 Configuration
- Device Name: "TransitSeatMonitor"
- Service UUID: "4fafc201-1fb5-459e-8fcc-c5c9c331914b"
- Characteristic UUID: "beb5483e-36e1-4688-b7f5-ea07361b26a8"

### Flutter App Configuration
- Service UUID: "4fafc201-1fb5-459e-8fcc-c5c9c331914b"
- Characteristic UUID: "beb5483e-36e1-4688-b7f5-ea07361b26a8"

## Step 4: Testing

### ESP32 Testing
1. Upload the Arduino code
2. Connect pressure sensors
3. Test sensor readings via serial monitor
4. Verify BLE advertising

### Flutter App Testing
1. Run the Flutter app
2. Scan for ESP32 devices
3. Connect to the device
4. Verify data transmission

## Step 5: Integration

### Backend Integration
- Use the provided Flutter services to integrate with your backend
- Update seat occupancy data in real-time
- Sync with your transit app database

## Troubleshooting

### Common Issues
1. **ESP32 not detected**: Check power and connections
2. **BLE not working**: Verify service UUIDs and characteristics
3. **Data not updating**: Check sensor connections and thresholds

### Error Messages
- "Device not found": Ensure ESP32 is powered and advertising
- "Connection failed": Check Bluetooth permissions
- "Data not updating": Verify sensor readings and thresholds

## Deployment

### Production Setup
1. Use proper PCB instead of breadboard
2. Add proper power management
3. Implement error handling
4. Add logging and monitoring

### Maintenance
- Regular sensor calibration
- Battery monitoring
- Software updates

## Support
For any issues or questions, please refer to the GitHub repository or contact support.
