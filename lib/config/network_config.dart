import 'dart:io';

class NetworkConfig {
  // Centralized network configuration
  static const String _devBaseUrl = 'http://192.168.1.7/transit/api';
  static const String _wsUrl = 'ws://192.168.1.7:8080/seats';
  
  // Production URLs
  static const String _prodBaseUrl = 'https://your-production-domain.com/api';
  static const String _prodWsUrl = 'wss://your-production-domain.com/seats';
  
  static bool get isProduction => false;
  
  // Get appropriate URLs based on environment
  static String get baseUrl => isProduction ? _prodBaseUrl : _devBaseUrl;
  static String get wsUrl => isProduction ? _prodWsUrl : _wsUrl;
  
  // API endpoints
  static String get authBaseUrl => '$baseUrl/auth';
  static String get tripsBaseUrl => '$baseUrl/drivers/trips';
  static String get driversBaseUrl => '$baseUrl/drivers';
  static String get testUrl => '$baseUrl/test.php';
  
  // WebSocket endpoints
  static String get seatWebSocketUrl => wsUrl;
  
  // Network diagnostics
  static Future<bool> testConnection() async {
    try {
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 5);
      final request = await client.getUrl(Uri.parse(testUrl));
      final response = await request.close();
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
  
  // Get current network info
  static Map<String, dynamic> getNetworkInfo() {
    return {
      'baseUrl': baseUrl,
      'wsUrl': wsUrl,
      'isProduction': isProduction,
      'platform': Platform.operatingSystem,
    };
  }
}
