import 'dart:io';
import 'dart:async';

/// Available environment types
enum EnvironmentType {
  localDevelopment,
  localNetwork,
  production,
  emulator,
  staging,
}

/// Server configuration class for managing different deployment environments
class ServerConfig {
  String _baseUrl;
  String _webSocketUrl;
  EnvironmentType _environment;
  Duration _timeout;

  /// Default timeout for HTTP requests
  static const Duration defaultTimeout = Duration(seconds: 30);

  /// Create a new ServerConfig instance
  ServerConfig({
    String? baseUrl,
    String? webSocketUrl,
    EnvironmentType? environment,
    Duration? timeout,
  }) : _baseUrl =
           baseUrl ??
           _getDefaultBaseUrl(environment ?? _getCurrentEnvironment()),
       _webSocketUrl =
           webSocketUrl ??
           _getDefaultWebSocketUrl(environment ?? _getCurrentEnvironment()),
       _environment = environment ?? _getCurrentEnvironment(),
       _timeout = timeout ?? defaultTimeout;

  /// Get the current environment based on platform and settings
  static EnvironmentType _getCurrentEnvironment() {
    if (Platform.isAndroid && Platform.localHostname.contains('localhost')) {
      return EnvironmentType.emulator;
    }

    // Check for production flag
    const bool isProduction = bool.fromEnvironment(
      'PRODUCTION',
      defaultValue: false,
    );
    if (isProduction) {
      return EnvironmentType.production;
    }

    // Check for staging flag
    const bool isStaging = bool.fromEnvironment('STAGING', defaultValue: false);
    if (isStaging) {
      return EnvironmentType.staging;
    }

    // Default to local development
    return EnvironmentType.localDevelopment;
  }

  /// Get default base URL for a given environment
  static String _getDefaultBaseUrl(EnvironmentType env) {
    switch (env) {
      case EnvironmentType.localDevelopment:
        return 'http://localhost/transit/api';
      case EnvironmentType.localNetwork:
        return 'http://192.168.1.100/transit/api';
      case EnvironmentType.emulator:
        return 'http://10.0.2.2/transit/api';
      case EnvironmentType.staging:
        return 'https://staging.your-domain.com/api';
      case EnvironmentType.production:
        return 'https://your-production-domain.com/api';
    }
  }

  /// Get default WebSocket URL for a given environment
  static String _getDefaultWebSocketUrl(EnvironmentType env) {
    switch (env) {
      case EnvironmentType.localDevelopment:
        return 'ws://localhost:8080/seats';
      case EnvironmentType.localNetwork:
        return 'ws://192.168.1.100:8080/seats';
      case EnvironmentType.emulator:
        return 'ws://10.0.2.2:8080/seats';
      case EnvironmentType.staging:
        return 'wss://staging.your-domain.com/seats';
      case EnvironmentType.production:
        return 'wss://your-production-domain.com/seats';
    }
  }

  /// Get current base URL
  String get baseUrl => _baseUrl;

  /// Get current WebSocket URL
  String get webSocketUrl => _webSocketUrl;

  /// Get current environment
  EnvironmentType get environment => _environment;

  /// Get current timeout duration
  Duration get timeout => _timeout;

  /// Set base URL
  void setBaseUrl(String url) {
    _baseUrl = url;
  }

  /// Set WebSocket URL
  void setWebSocketUrl(String url) {
    _webSocketUrl = url;
  }

  /// Set environment type
  void setEnvironment(EnvironmentType env) {
    _environment = env;
    // Update URLs to match new environment
    _baseUrl = _getDefaultBaseUrl(env);
    _webSocketUrl = _getDefaultWebSocketUrl(env);
  }

  /// Set timeout duration
  void setTimeout(Duration duration) {
    _timeout = duration;
  }

  /// Set configuration from recommended settings
  void setConfig(String scenario) {
    switch (scenario.toLowerCase()) {
      case 'localhost':
        _baseUrl = 'http://localhost/transit/api';
        _webSocketUrl = 'ws://localhost:8080/seats';
        _environment = EnvironmentType.localDevelopment;
        break;
      case 'local-network':
        _baseUrl = 'http://192.168.1.100/transit/api';
        _webSocketUrl = 'ws://192.168.1.100:8080/seats';
        _environment = EnvironmentType.localNetwork;
        break;
      case 'emulator':
        _baseUrl = 'http://10.0.2.2/transit/api';
        _webSocketUrl = 'ws://10.0.2.2:8080/seats';
        _environment = EnvironmentType.emulator;
        break;
      case 'production':
        _baseUrl = 'https://your-production-domain.com/api';
        _webSocketUrl = 'wss://your-production-domain.com/seats';
        _environment = EnvironmentType.production;
        break;
      default:
        _baseUrl = 'http://localhost/transit/api';
        _webSocketUrl = 'ws://localhost:8080/seats';
        _environment = EnvironmentType.localDevelopment;
    }
  }

  /// Reset configuration to defaults based on current environment
  void resetToDefaults() {
    _baseUrl = _getDefaultBaseUrl(_environment);
    _webSocketUrl = _getDefaultWebSocketUrl(_environment);
    _timeout = defaultTimeout;
  }

  /// Get configuration info for debugging
  Map<String, dynamic> getConfigInfo() {
    return {
      'environment': _environment.toString(),
      'baseUrl': _baseUrl,
      'webSocketUrl': _webSocketUrl,
      'timeout': _timeout.inSeconds,
      'platform': Platform.operatingSystem,
      'hostname': Platform.localHostname,
    };
  }

  /// Test if the configured server is accessible
  Future<bool> testServerConnection() async {
    try {
      final client = HttpClient();
      client.connectionTimeout = _timeout;
      final request = await client.getUrl(Uri.parse('$_baseUrl/test.php'));
      final response = await request.close();
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Create a copy of this configuration
  ServerConfig copyWith({
    String? baseUrl,
    String? webSocketUrl,
    EnvironmentType? environment,
    Duration? timeout,
  }) {
    return ServerConfig(
      baseUrl: baseUrl ?? _baseUrl,
      webSocketUrl: webSocketUrl ?? _webSocketUrl,
      environment: environment ?? _environment,
      timeout: timeout ?? _timeout,
    );
  }

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'baseUrl': _baseUrl,
      'webSocketUrl': _webSocketUrl,
      'environment': _environment.toString(),
      'timeout': _timeout.inMilliseconds,
    };
  }

  /// Create from JSON
  factory ServerConfig.fromJson(Map<String, dynamic> json) {
    return ServerConfig(
      baseUrl: json['baseUrl'],
      webSocketUrl: json['webSocketUrl'],
      environment: EnvironmentType.values.firstWhere(
        (e) => e.toString() == json['environment'],
        orElse: () => EnvironmentType.localDevelopment,
      ),
      timeout: Duration(milliseconds: json['timeout'] ?? 30000),
    );
  }

  /// Get static configuration (for backward compatibility)
  static String get staticBaseUrl {
    final env = _getCurrentEnvironment();
    return _getDefaultBaseUrl(env);
  }

  /// Get static WebSocket URL (for backward compatibility)
  static String get staticWebSocketUrl {
    final env = _getCurrentEnvironment();
    return _getDefaultWebSocketUrl(env);
  }

  /// Get static configuration info (for backward compatibility)
  static Map<String, dynamic> getStaticConfigInfo() {
    final env = _getCurrentEnvironment();
    return {
      'environment': env.toString(),
      'baseUrl': _getDefaultBaseUrl(env),
      'webSocketUrl': _getDefaultWebSocketUrl(env),
      'platform': Platform.operatingSystem,
      'hostname': Platform.localHostname,
    };
  }

  /// Test static server connection (for backward compatibility)
  static Future<bool> testStaticServerConnection() async {
    try {
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 5);
      final request = await client.getUrl(Uri.parse('$staticBaseUrl/test.php'));
      final response = await request.close();
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
