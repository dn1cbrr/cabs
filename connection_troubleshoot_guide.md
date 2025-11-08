# Connection Error Troubleshooting Guide

## Problem: FormatException - Unexpected character '<' at position 1

This error occurs when your Flutter app receives HTML instead of JSON from the API.

## Quick Diagnosis Steps

### 1. Check Your Current IP Address
Run this command to find your computer's IP:
```bash
ipconfig (Windows) or ifconfig (Mac/Linux)
```

### 2. Test API Endpoints in Browser
Try these URLs in your browser:
- http://localhost/transit/api/test.php
- http://[YOUR-IP]/transit/api/test.php

### 3. Verify Server is Running
Make sure your PHP server is running on the correct port.

## Platform-Specific Configuration

### Android Emulator
- Use: http://10.0.2.2/transit/api
- This IP routes to your host machine

### iOS Simulator
- Use: http://localhost/transit/api
- Or: http://127.0.0.1/transit/api

### Physical Device
- Use your computer's actual IP address
- Ensure both devices are on same network

## Common Fixes

1. **Update IP Address**: Replace 192.168.1.7 with your actual IP
2. **Check Server**: Ensure Apache/Nginx is running
3. **Verify Path**: Make sure /transit/api/ is accessible
4. **CORS Headers**: Ensure API sends proper CORS headers
