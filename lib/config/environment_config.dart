class EnvironmentConfig {
  // Development environment - replace with your machine's IP address for device/emulator testing
  static String _devBaseUrl = 'http://localhost/transit/api'; // Updated to match XAMPP setup
  
  // Alternative URLs for different server configurations
  static const String _xamppUrl = 'http://localhost:80/transit/api';
  static const String _xamppAltUrl = 'http://localhost:8080/transit/api';
  static const String _localIpUrl = 'http://192.168.1.100/transit/api'; // Replace with your IP
  
  // Production environment
  static const String _prodBaseUrl = 'https://your-production-domain.com/api';
  
  // Current environment - change this based on build
  static const bool isProduction = false;
  
  // Method to update devBaseUrl dynamically (e.g., from environment variables or config files)
  static void setDevBaseUrl(String url) {
    _devBaseUrl = url;
  }
  
  // Method to set common server configurations
  static void useXamppDefault() {
    _devBaseUrl = _xamppUrl;
  }
  
  static void useXamppAlternative() {
    _devBaseUrl = _xamppAltUrl;
  }
  
  static void useLocalIp(String ipAddress, {int port = 80}) {
    _devBaseUrl = 'http://$ipAddress:$port/transit/api';
  }
  
  // Get the appropriate base URL
  static String get baseUrl {
    return isProduction ? _prodBaseUrl : _devBaseUrl;
  }
  
  // API endpoints
  static String get authBaseUrl => '$baseUrl/auth';
  static String get tripsBaseUrl => '$baseUrl/drivers/trips';
  static String get driversBaseUrl => '$baseUrl/drivers';
  
  // For testing connection
  static String get testUrl => '$baseUrl/test.php';
  static String get usersBaseUrl => '$baseUrl/users';
  
  // Get current configuration info
  static Map<String, dynamic> getConfigInfo() {
    return {
      'currentBaseUrl': baseUrl,
      'isProduction': isProduction,
      'authBaseUrl': authBaseUrl,
      'tripsBaseUrl': tripsBaseUrl,
      'driversBaseUrl': driversBaseUrl,
      'testUrl': testUrl,
      'availableConfigs': {
        'xamppDefault': _xamppUrl,
        'xamppAlternative': _xamppAltUrl,
        'localIpExample': _localIpUrl,
      }
    };
  }
  
  /*
  Instructions:
  - Replace the default IP address in _devBaseUrl with your machine's local network IP address.
  - This is necessary when running the app on a physical device or emulator that cannot access 'localhost'.
  - You can also call EnvironmentConfig.setDevBaseUrl('http://your-ip:port') at app startup to set dynamically.
  - Use EnvironmentConfig.useXamppDefault() for standard XAMPP setup
  - Use EnvironmentConfig.useXamppAlternative() if XAMPP runs on port 8080
  - Use EnvironmentConfig.useLocalIp('your-ip-address') for physical device testing
  */
}

