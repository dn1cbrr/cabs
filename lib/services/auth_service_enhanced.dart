import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../config/environment_config.dart';

class AuthServiceEnhanced {
  static String get baseUrl => EnvironmentConfig.baseUrl;
  
  /// Enhanced method to handle HTML responses gracefully
  static Future<Map<String, dynamic>> _handleResponse(http.Response response) async {
    try {
      // Check if response is HTML
      final contentType = response.headers['content-type'] ?? '';
      final isHtml = contentType.contains('text/html') || response.body.trim().startsWith('<!DOCTYPE') || response.body.trim().startsWith('<html');
      
      if (isHtml) {
        // Extract error message from HTML if possible
        String errorMessage = 'Server returned HTML instead of JSON';
        if (response.statusCode == 404) {
          errorMessage = 'Endpoint not found (404)';
        } else if (response.statusCode == 500) {
          errorMessage = 'Server error (500)';
        }
        
        return {
          'success': false,
          'message': errorMessage,
          'error_type': 'html_response',
          'status_code': response.statusCode,
          'raw_response': response.body.substring(0, 500), // First 500 chars for debugging
        };
      }
      
      // Try to parse JSON
      Map<String, dynamic> data;
      try {
        data = jsonDecode(response.body);
      } catch (e) {
        return {
          'success': false,
          'message': 'Invalid JSON response from server',
          'error_type': 'json_parse_error',
          'parse_error': e.toString(),
          'raw_response': response.body.substring(0, 500),
        };
      }
      
      return {
        'success': response.statusCode >= 200 && response.statusCode < 300,
        'data': data,
        'status_code': response.statusCode,
      };
      
    } catch (e) {
      return {
        'success': false,
        'message': 'Error processing response: ${e.toString()}',
        'error_type': 'response_processing_error',
      };
    }
  }
  
  /// Enhanced login method with better error handling
  static Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final url = '$baseUrl/auth/login.php';
      
      if (kDebugMode) {
        print('Attempting login to: $url');
      }
      
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () => http.Response('{"error": "Request timeout"}', 408),
      );
      
      final result = await _handleResponse(response);
      
      if (result['success'] == true && result['data'] != null) {
        final data = result['data'] as Map<String, dynamic>;
        
        if (data['success'] == true) {
          // Save user data
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('user_data', jsonEncode(data['user']));
          await prefs.setBool('is_logged_in', true);
          
          return {
            'success': true,
            'message': data['message'] ?? 'Login successful',
            'user': User.fromJson(data['user']),
          };
        } else {
          return {
            'success': false,
            'message': data['message'] ?? 'Login failed',
          };
        }
      } else {
        return {
          'success': false,
          'message': result['message'] ?? 'Login request failed',
          'error_type': result['error_type'],
          'debug_info': result,
        };
      }
      
    } on SocketException catch (e) {
      return {
        'success': false,
        'message': 'Connection failed. Please check your internet connection and server status.',
        'error_type': 'socket_exception',
        'details': e.message,
        'suggestions': [
          'Check if your web server is running',
          'Verify the server URL is correct: $baseUrl',
          'Check your internet connection',
          'Try accessing $baseUrl/test.php in your browser',
        ],
      };
    } on FormatException catch (e) {
      return {
        'success': false,
        'message': 'Server returned invalid data format',
        'error_type': 'format_exception',
        'details': e.toString(),
        'suggestions': [
          'Check if the API endpoint exists',
          'Verify server configuration',
          'Check server logs for PHP errors',
        ],
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
        'error_type': 'general_error',
      };
    }
  }
  
  /// Enhanced forgot password method
  static Future<Map<String, dynamic>> forgotPassword(String email) async {
    try {
      final url = '$baseUrl/auth/forgot_password_improved.php';
      
      if (kDebugMode) {
        print('Attempting forgot password to: $url');
      }
      
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': email,
        }),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () => http.Response('{"error": "Request timeout"}', 408),
      );
      
      final result = await _handleResponse(response);
      
      if (result['success'] && result['data'] != null) {
        final data = result['data'];
        return {
          'success': data['success'] ?? false,
          'message': data['message'] ?? 'Password reset email sent',
          'debug_info': kDebugMode ? data : null,
        };
      } else {
        return {
          'success': false,
          'message': result['message'] ?? 'Failed to send reset email',
          'error_type': result['error_type'],
          'debug_info': result,
        };
      }
      
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
        'error_type': 'general_error',
      };
    }
  }
  
  /// Test API connection with detailed debugging
  static Future<Map<String, dynamic>> testConnection() async {
    try {
      final url = '$baseUrl/test.php';
      
      if (kDebugMode) {
        print('Testing connection to: $url');
      }
      
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Accept': 'application/json',
        },
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () => http.Response('{"error": "Request timeout"}', 408),
      );
      
      return await _handleResponse(response);
      
    } catch (e) {
      return {
        'success': false,
        'message': 'Connection test failed: ${e.toString()}',
        'error_type': 'connection_test_failed',
      };
    }
  }
  
  /// Get detailed network diagnostics
  static Future<Map<String, dynamic>> getNetworkDiagnostics() async {
    final results = {
      'base_url': baseUrl,
      'timestamp': DateTime.now().toIso8601String(),
      'endpoints_tested': <String, dynamic>{},
    };
    
    // Test basic connectivity
    final testResult = await testConnection();
    results['endpoints_tested']?['test.php'] = testResult;
    
    return results;
  }
}

extension on Object? {
  void operator []=(String index, Map<String, dynamic> newValue) {}
}
