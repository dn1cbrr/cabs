class EnvironmentConfig {
  // Updated for physical device testing via USB
  static const String _devBaseUrl = 'http://192.168.1.5/transit/api';
  
  // Production environment
  static const String _prodBaseUrl = 'https://your-production-domain.com/api';
  
  // Current environment
  static const bool isProduction = false;
  
  // Get the appropriate base URL
  static String get baseUrl {
    return isProduction ? _prodBaseUrl : _devBaseUrl;
  }
  
  // API endpoints
  static String get authBaseUrl => '$baseUrl/auth';
  static String get tripsBaseUrl => '$baseUrl/drivers/trips';
  static String get driversBaseUrl => '$baseUrl/drivers';
  static String get testUrl => '$baseUrl/test.php';
  
  // Get current configuration info
  static Map<String, dynamic> getConfigInfo() {
    return {
      'currentBaseUrl': baseUrl,
      'isProduction': isProduction,
      'authBaseUrl': authBaseUrl,
      'tripsBaseUrl': tripsBaseUrl,
      'driversBaseUrl': driversBaseUrl,
      'testUrl': testUrl,
    };
  }
}
