import 'dart:io';

class NetworkConfig {
  // IMPORTANT: Update this to your computer's actual IP address
  // Find your IP by running: ipconfig (Windows) or ifconfig (Mac/Linux)
  static const String _computerIp = '192.168.1.7'; // CHANGE THIS TO YOUR IP!

  // Platform-specific base URLs
  static String get baseUrl {
    if (Platform.isAndroid) {
      // Special IP for Android emulator to reach host machine
      return 'http://10.0.2.2/transit/api';
    } else if (Platform.isIOS) {
      // For iOS simulator
      return 'http://localhost/transit/api';
    } else {
      // For physical devices - use your computer's IP
      return 'http://$_computerIp/transit/api';
    }
  }

  // Allow runtime IP configuration
  static String _customIp = '192.168.1.7';

  static void setCustomIp(String ip) {
    _customIp = ip;
  }

  static String get currentBaseUrl {
    if (_customIp.isNotEmpty) {
      return 'http://$_customIp/transit/api';
    }
    return baseUrl;
  }

  // API endpoints
  static String get testUrl => '$currentBaseUrl/test.php';
  static String get authBaseUrl => '$currentBaseUrl/auth';
  static String get tripsBaseUrl => '$currentBaseUrl/drivers/trips';
}
