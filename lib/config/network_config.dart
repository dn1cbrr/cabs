import 'dart:io';

class NetworkConfig {
  // Get the correct IP address for your development environment
  static String get baseUrl {
    if (Platform.isAndroid) {
      // For Android emulator
      return 'http://10.0.2.2/transit/api';
    } else if (Platform.isIOS) {
      // For iOS simulator
      return 'http://localhost/transit/api';
    } else {
      // For physical devices and web
      // You need to update this to your computer's actual IP address
      return 'http://192.168.1.7/transit/api'; // Change this to your actual IP
    }
  }

  // Alternative method to get IP from user input
  static String customBaseUrl = '';

  static void setCustomBaseUrl(String ipAddress) {
    customBaseUrl = 'http://$ipAddress/transit/api';
  }

  static String get currentBaseUrl {
    return customBaseUrl.isNotEmpty ? customBaseUrl : baseUrl;
  }

  // WebSocket URLs - convert HTTP to WS protocol
  static String get seatWebSocketUrl {
    String httpUrl = currentBaseUrl;
    // Convert http:// to ws:// and https:// to wss://
    if (httpUrl.startsWith('https://')) {
      return httpUrl.replaceFirst('https://', 'wss://');
    } else {
      return httpUrl.replaceFirst('http://', 'ws://');
    }
  }

  // Test URLs
  static String get testUrl => '$currentBaseUrl/test.php';
  static String get authBaseUrl => '$currentBaseUrl/auth';
  static String get tripsBaseUrl => '$currentBaseUrl/drivers/trips';
}
