      # ESP32 WebSocket Server Setup Guide for Arduino IDE

## Overview
This guide will help you set up the ESP32 WebSocket server for real-time seat monitoring using Arduino IDE. The server provides WebSocket connections for Flutter apps to receive live seat occupancy data.

## Prerequisites
- Arduino IDE (version 1.8.x or later)
- ESP32 development board
- IR sensor module (TCRT5000 or similar)
- LEDs (Green, Red, Status LED)
- Jumper wires
- Breadboard or PCB

## Step 1: Install Arduino IDE
1. Download Arduino IDE from [arduino.cc](https://www.arduino.cc/en/software)
2. Install the IDE on your computer (Windows/Mac/Linux)

## Step 2: Install ESP32 Board Package
1. Open Arduino IDE
2. Go to **File > Preferences**
3. In **Additional Board Manager URLs**, add:
   ```
   https://raw.githubusercontent.com/espressif/arduino-esp32/gh-pages/package_esp32_index.json
   ```
4. Go to **Tools > Board > Boards Manager**
5. Search for "ESP32" and install **"ESP32 by Espressif Systems"**

## Step 3: Install Required Libraries
1. Go to **Tools > Manage Libraries**
2. Install these libraries:
   - **WebSockets** by Markus Sattler (search for "WebSockets")
   - **ArduinoJson** by Benoit Blanchon (search for "ArduinoJson")

## Step 4: Hardware Connections
Connect the following components to your ESP32:

| Component | ESP32 Pin | Description |
|-----------|-----------|-------------|
| IR Sensor Signal | GPIO 4 | Analog input for seat detection |
| Green LED | GPIO 18 | Indicates seat is occupied |
| Red LED | GPIO 19 | Indicates seat is vacant |
| Status LED | GPIO 2 | Shows system status |
| IR Sensor VCC | 3.3V | Power supply |
| IR Sensor GND | GND | Ground connection |

## Step 5: Configure WiFi Settings
1. Open `ESP32_WebSocket_Server.ino`
2. Find these lines and update with your WiFi credentials:
```cpp
const char* ssid = "YOUR_WIFI_SSID";
const char* password = "YOUR_WIFI_PASSWORD";
```

## Step 6: Upload the Code
1. Connect ESP32 to computer via USB cable
2. Select your ESP32 board:
   - **Tools > Board > ESP32 Arduino > ESP32 Dev Module**
3. Select the correct COM port:
   - **Tools > Port > COMx** (Windows) or **/dev/ttyUSBx** (Linux/Mac)
4. Click **Upload** button (→) or press **Ctrl+U**

## Step 7: Monitor Output
1. Open **Tools > Serial Monitor** or press **Ctrl+Shift+M**
2. Set baud rate to **115200**
3. You should see connection messages and IP address

## Step 8: Testing the Setup
1. After successful upload, ESP32 will connect to WiFi
2. Note the IP address shown in Serial Monitor
3. The WebSocket server will be available at: `ws://[IP_ADDRESS]:81`

## Step 9: Flutter App Configuration
Update your Flutter app's WebSocket URL:
```dart
const String websocketUrl = 'ws://[YOUR_ESP32_IP]:81';
```

## Troubleshooting

### Common Issues and Solutions

**1. Board not detected**
- Try different USB cable
- Install CP2102 drivers (check Device Manager)
- Try different USB port

**2. Compilation errors**
- Ensure all libraries are installed correctly
- Check ESP32 board package is installed
- Verify code syntax

**3. WiFi connection issues**
- Check SSID and password spelling
- Ensure 2.4GHz WiFi (ESP32 doesn't support 5GHz)
- Move closer to router

**4. WebSocket connection fails**
- Verify ESP32 IP address in Serial Monitor
- Check firewall settings
- Ensure port 81 is not blocked

### Serial Monitor Commands
- **Reset ESP32**: Press EN button on board
- **Enter Download Mode**: Hold BOOT button while pressing EN

## Advanced Configuration

### Adjusting Sensor Sensitivity
Modify the threshold value in the code:
```cpp
const int IR_THRESHOLD = 500; // Adjust based on your sensor
```

### Changing WebSocket Port
Modify the port number:
```cpp
WebSocketsServer webSocket = WebSocketsServer(81); // Change to desired port
```

### Adding More Seats
1. Duplicate the sensor and LED connections
2. Update `seatId` for each additional seat
3. Modify the JSON structure to handle multiple seats

## Testing with Flutter App
1. Install the Flutter app on your device
2. Ensure device is on same WiFi network as ESP32
3. Update WebSocket URL in Flutter app
4. Test seat occupancy detection by placing objects on the sensor

## Performance Optimization
- Use shorter sensor reading intervals for faster response
- Implement debouncing to prevent false triggers
- Add error handling for network disconnections

## Security Considerations
- Change default WiFi credentials
- Consider adding authentication for WebSocket connections
- Use WPA2/WPA3 encryption for WiFi

## Additional Resources
- [ESP32 Arduino Core Documentation](https://docs.espressif.com/projects/arduino-esp32/en/latest/)
- [WebSocket Library Documentation](https://github.com/Links2004/arduinoWebSockets)
- [ArduinoJson Library Documentation](https://arduinojson.org/)
