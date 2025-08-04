import 'environment_config.dart';

class AppConfig {
  // Use environment configuration for consistency
  static String get baseUrl => EnvironmentConfig.baseUrl;
  
  // API endpoints
  static String get authBaseUrl => '$baseUrl/auth';
  static String get tripsBaseUrl => '$baseUrl/drivers/trips';
  static String get driversBaseUrl => '$baseUrl/drivers';
}
