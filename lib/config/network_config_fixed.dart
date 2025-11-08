import 'dart:io';

class NetworkConfig {
  // Configuration for different environments
  static const String _androidEmulatorUrl = 'http://10.0.2.2/transit/api';
  static const String _iosSimulatorUrl = 'http://localhost/transit/api';
  static const String _defaultPhysicalUrl = 'http://192.168.1.7/transit/api';

  // Allow dynamic IP configuration
  static String _customIp = '';

  /// Set custom IP address for physical devices
  static void setCustomIp(String ipAddress) {
    _customIp = ipAddress;
  }

  /// Get the appropriate base URL based on platform
  static String get baseUrl {
    if (_customIp.isNotEmpty) {
      return 'http://$_customIp/transit/api';
    }

    if (Platform.isAndroid) {
      return _androidEmulatorUrl;
    } else if (Platform.isIOS) {
      return _iosSimulatorUrl;
    } else {
      return _defaultPhysicalUrl;
    }
  }

  /// Test if a URL is accessible
  static Future<bool> testConnection(String url) async {
    try {
      final request = await HttpClient().getUrl(Uri.parse('$url/test.php'));
      final response = await request.close();
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Get all possible URLs for testing
  static List<String> getTestUrls() {
    return [
      _androidEmulatorUrl,
      _iosSimulatorUrl,
      _defaultPhysicalUrl,
      if (_customIp.isNotEmpty) 'http://$_customIp/transit/api',
    ];
  }

  // WebSocket URLs - convert HTTP to WS protocol
  static String get seatWebSocketUrl {
    String httpUrl = baseUrl;
    // Convert http:// to ws:// and https:// to wss://
    if (httpUrl.startsWith('https://')) {
      return httpUrl.replaceFirst('https://', 'wss://');
    } else {
      return httpUrl.replaceFirst('http://', 'ws://');
    }
  }

  // API endpoints
  static String get testUrl => '$baseUrl/test.php';
  static String get authBaseUrl => '$baseUrl/auth';
  static String get tripsBaseUrl => '$baseUrl/drivers/trips';
}
