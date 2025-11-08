/*
 * ESP32 WebSocket Server for Real-Time Seat Monitoring
 * 
 * This code creates a WebSocket server on ESP32 that:
 * - Reads IR sensor data to detect seat occupancy
 * - Sends real-time updates to Flutter app via WebSocket
 * - Controls LED indicators for seat status
 * - Provides system status feedback
 * 
 * Author: Transit System Integration Team
 * Version: 2.0
 * Last Updated: 2024
 */

#include <WiFi.h>
#include <WebSocketsServer.h>
#include <ArduinoJson.h>

// ===========================
// CONFIGURATION SECTION
// ===========================

// WiFi Configuration - UPDATE THESE VALUES
const char* ssid = "YOUR_WIFI_SSID";        // Replace with your WiFi network name
const char* password = "YOUR_WIFI_PASSWORD";  // Replace with your WiFi password

// Pin Configuration - Can be changed based on your wiring
const int IR_SENSOR_PIN = 4;    // Analog pin for IR sensor (GPIO4)
const int GREEN_LED_PIN = 18;   // Green LED for occupied seat (GPIO18)
const int RED_LED_PIN = 19;     // Red LED for vacant seat (GPIO19)
const int STATUS_LED_PIN = 2;    // Built-in LED for system status (GPIO2)

// Sensor Configuration
const int IR_THRESHOLD = 500;   // Adjust this value based on your sensor sensitivity
const int SENSOR_READ_INTERVAL = 100; // Read sensor every 100ms
const int DEBOUNCE_DELAY = 50;   // Debounce delay in milliseconds

// ===========================
// GLOBAL VARIABLES
// ===========================

WebSocketsServer webSocket(81);   // WebSocket server on port 81
unsigned long lastSensorRead = 0; // Last time sensor was read
bool lastSeatState = false;       // Previous seat state (occupied/vacant)
bool currentSeatState = false;    // Current seat state
int seatId = 1;                // Unique identifier for this seat
String deviceName = "ESP32_Seat_01"; // Device identifier for Flutter app

// ===========================
// SETUP FUNCTION
// ===========================
void setup() {
  Serial.begin(115200);
  Serial.println("\n=== ESP32 Seat Monitoring System ===");
  Serial.println("Initializing...");
  
  // Initialize pins
  initializePins();
  
  // Connect to WiFi
  connectToWiFi();
  
  // Setup WebSocket server
  setupWebSocket();
  
  // Initialize system
  initializeSystem();
}

// ===========================
// MAIN LOOP
// ===========================
void loop() {
  // Handle WebSocket connections
  webSocket.loop();
  
  // Read sensor at specified intervals
  unsigned long currentTime = millis();
  if (currentTime - lastSensorRead >= SENSOR_READ_INTERVAL) {
    readSensorAndUpdateState();
    lastSensorRead = currentTime;
  }
}

// ===========================
// PIN INITIALIZATION
// ===========================
void initializePins() {
  pinMode(GREEN_LED_PIN, OUTPUT);
  pinMode(RED_LED_PIN, OUTPUT);
  pinMode(STATUS_LED_PIN, OUTPUT);
  
  // Turn off all LEDs initially
  digitalWrite(GREEN_LED_PIN, LOW);
  digitalWrite(RED_LED_PIN, LOW);
  digitalWrite(STATUS_LED_PIN, LOW);
  
  Serial.println("Pins initialized successfully");
}

// ===========================
// WIFI CONNECTION
// ===========================
void connectToWiFi() {
  Serial.print("Connecting to WiFi: ");
  Serial.println(ssid);
  
  WiFi.begin(ssid, password);
  
  // Blink status LED while connecting
  int attempts = 0;
  while (WiFi.status() != WL_CONNECTED && attempts < 20) {
    digitalWrite(STATUS_LED_PIN, HIGH);
    delay(250);
    digitalWrite(STATUS_LED_PIN, LOW);
    delay(250);
    Serial.print(".");
    attempts++;
  }
  
  if (WiFi.status() == WL_CONNECTED) {
    Serial.println("\nWiFi connected successfully!");
    Serial.print("IP Address: ");
    Serial.println(WiFi.localIP());
    Serial.print("WebSocket URL: ws://");
    Serial.print(WiFi.localIP());
    Serial.println(":81");
    
    // Turn on status LED to indicate successful connection
    digitalWrite(STATUS_LED_PIN, HIGH);
  } else {
    Serial.println("\nFailed to connect to WiFi. Restarting...");
    ESP.restart();
  }
}

// ===========================
// WEBSOCKET SETUP
// ===========================
void setupWebSocket() {
  webSocket.onEvent(onWebSocketEvent);
  webSocket.begin();
  Serial.println("WebSocket server started on port 81");
}

// ===========================
// SENSOR READING
// ===========================
void readSensorAndUpdateState() {
  int sensorValue = analogRead(IR_SENSOR_PIN);
  
  // Apply debouncing
  static unsigned long lastDebounceTime = 0;
  static int lastSensorReading = 0;
  
  if (abs(sensorValue - lastSensorReading) > 10) {
    lastDebounceTime = millis();
  }
  
  if ((millis() - lastDebounceTime) > DEBOUNCE_DELAY) {
    // Determine seat state based on threshold
    currentSeatState = (sensorValue > IR_THRESHOLD);
    
    // Check if state has changed
    if (currentSeatState != lastSeatState) {
      Serial.print("Seat state changed: ");
      Serial.println(currentSeatState ? "OCCUPIED" : "VACANT");
      
      updateLEDs();
      sendWebSocketUpdate();
      
      lastSeatState = currentSeatState;
    }
  }
  
  lastSensorReading = sensorValue;
}

// ===========================
// LED CONTROL
// ===========================
void updateLEDs() {
  if (currentSeatState) {
    // Seat is occupied
    digitalWrite(GREEN_LED_PIN, HIGH);
    digitalWrite(RED_LED_PIN, LOW);
  } else {
    // Seat is vacant
    digitalWrite(GREEN_LED_PIN, LOW);
    digitalWrite(RED_LED_PIN, HIGH);
  }
}

// ===========================
// WEBSOCKET COMMUNICATION
// ===========================
void onWebSocketEvent(uint8_t num, WStype_t type, uint8_t * payload, size_t length) {
  switch (type) {
    case WStype_DISCONNECTED:
      Serial.printf("Client #%u disconnected\n", num);
      break;
      
    case WStype_CONNECTED:
      {
        IPAddress ip = webSocket.remoteIP(num);
        Serial.printf("Client #%u connected from %d.%d.%d.%d\n", num, ip[0], ip[1], ip[2], ip[3]);
        
        // Send initial state to newly connected client
        sendWebSocketUpdate();
      }
      break;
      
    case WStype_TEXT:
      {
        String message = String((char*)payload);
        Serial.printf("Received from client #%u: %s\n", num, message.c_str());
        
        // Handle commands from Flutter app
        handleWebSocketCommand(num, message);
      }
      break;
  }
}

// ===========================
// SEND WEBSOCKET UPDATE
// ===========================
void sendWebSocketUpdate() {
  StaticJsonDocument<200> doc;
  
  doc["type"] = "seat_update";
  doc["seatId"] = seatId;
  doc["isOccupied"] = currentSeatState;
  doc["timestamp"] = millis();
  doc["deviceName"] = deviceName;
  
  // Read sensor value for debugging
  doc["sensorValue"] = analogRead(IR_SENSOR_PIN);
  doc["threshold"] = IR_THRESHOLD;
  
  String jsonString;
  serializeJson(doc, jsonString);
  
  webSocket.broadcastTXT(jsonString);
  Serial.println("Sent update: " + jsonString);
}

// ===========================
// HANDLE COMMANDS
// ===========================
void handleWebSocketCommand(uint8_t clientNum, String command) {
  StaticJsonDocument<100> doc;
  DeserializationError error = deserializeJson(doc, command);
  
  if (error) {
    Serial.println("Invalid JSON received");
    return;
  }
  
  String type = doc["type"] | "";
  
  if (type == "get_status") {
    // Send current status
    sendWebSocketUpdate();
  } else if (type == "set_threshold") {
    // Update threshold value
    int newThreshold = doc["threshold"] | IR_THRESHOLD;
    IR_THRESHOLD = newThreshold;
    Serial.printf("Threshold updated to: %d\n", newThreshold);
    sendWebSocketUpdate();
  }
}

// ===========================
// SYSTEM INITIALIZATION
// ===========================
void initializeSystem() {
  Serial.println("\n=== System Ready ===");
  Serial.println("WebSocket URL: ws://" + WiFi.localIP().toString() + ":81");
  Serial.println("Seat ID: " + String(seatId));
  Serial.println("IR Threshold: " + String(IR_THRESHOLD));
  Serial.println("\nWaiting for connections...");
  
  // Send initial state
  updateLEDs();
  sendWebSocketUpdate();
}

// ===========================
// CALIBRATION FUNCTION
// ===========================
/*
 * Use this function to calibrate your IR sensor
 * Call this from setup() to find the optimal threshold
 */
void calibrateSensor() {
  Serial.println("\n=== Sensor Calibration ===");
  Serial.println("Place objects on the seat and note the sensor values:");
  
  for (int i = 0; i < 20; i++) {
    int value = analogRead(IR_SENSOR_PIN);
    Serial.print("Sensor Value: ");
    Serial.println(value);
    delay(1000);
  }
  
  Serial.println("Calibration complete. Update IR_THRESHOLD with the average occupied value.");
}
