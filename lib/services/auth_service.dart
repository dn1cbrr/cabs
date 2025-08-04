import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../config/environment_config.dart';

class AuthService {
  // Base URL for API using environment configuration
  static String get baseUrl {
    return EnvironmentConfig.baseUrl;
  }
  
  // Login method
  static Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login.php'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200 && data['success']) {
        // Save user data to shared preferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_data', jsonEncode(data['user']));
        await prefs.setBool('is_logged_in', true);
        
        return {
          'success': true,
          'message': data['message'],
          'user': User.fromJson(data['user']),
        };
      } else {
        if (kDebugMode) {
          print('Login failed: ${data['message']}');
        }
        return {
          'success': false,
          'message': data['message'] ?? 'Login failed',
        };
      }
    } on SocketException catch (e) {
      if (kDebugMode) {
        print('Login SocketException: $e');
      }
      return {
        'success': false,
        'message': 'Connection failed. Please check your internet connection and server status.',
        'error_type': 'socket_exception',
        'details': e.message,
        'suggestions': [
          'Check if your web server is running',
          'Verify the server URL is correct',
          'Check your internet connection',
        ],
      };
    } on http.ClientException catch (e) {
      return {
        'success': false,
        'message': 'HTTP error: ${e.message}',
        'error_type': 'http_exception',
      };
    } catch (e) {
      if (kDebugMode) {
        print('Login network error: $e');
      }
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
        'error_type': 'general_error',
      };
    }
  }

  // Register method with license info
  static Future<Map<String, dynamic>> register(
    String username,
    String email,
    String password,
    String fullName, {
    String? phoneNumber,
    String? licenseName,
    String? licenseNumber,
    String? licenseAddress,
    String? licenseCodes,
    String? licenseExpiration,
    DateTime? birthday,
  }) async {
    try {
      final requestData = {
        'username': username,
        'email': email,
        'password': password,
        'full_name': fullName,
      };

      // Add phone number if provided
      if (phoneNumber != null) requestData['phone_number'] = phoneNumber;

      // Add license information if provided
      if (licenseName != null) requestData['license_name'] = licenseName;
      if (licenseNumber != null) requestData['license_number'] = licenseNumber;
      if (licenseAddress != null) requestData['license_address'] = licenseAddress;
      if (licenseCodes != null) requestData['license_codes'] = licenseCodes;
      if (licenseExpiration != null) requestData['license_expiration'] = licenseExpiration;
      
      // Add optional birthday
      if (birthday != null) {
        requestData['birthday'] = birthday.toIso8601String();
      }

      final response = await http.post(
        Uri.parse('$baseUrl/auth/register.php'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestData),
      );

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 201 && data['success']) {
        return {
          'success': true,
          'message': data['message'],
          'user': User.fromJson(data['user']),
          'otp_required': data['otp_required'] ?? false,
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Registration failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('is_logged_in') ?? false;
  }

  // Get current user data
  static Future<User?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString('user_data');
    
    if (userData != null) {
      return User.fromJson(jsonDecode(userData));
    }
    return null;
  }

  // Logout method
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_data');
    await prefs.setBool('is_logged_in', false);
  }

  // Test API connection
  static Future<Map<String, dynamic>> testConnection() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/test.php'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      final data = jsonDecode(response.body);
      return data;
    } catch (e) {
      return {
        'success': false,
        'message': 'Connection error: ${e.toString()}',
      };
    }
  }

  // Register driver method - automatically creates driver account
  static Future<Map<String, dynamic>> registerDriver({
    required String username,
    required String email,
    required String password,
    required String fullName,
    required String phoneNumber,
    required String licenseName,
    required String licenseNumber,
    required String licenseAddress,
    required String licenseCodes,
    required String licenseExpiration,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register_driver.php'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'username': username,
          'email': email,
          'password': password,
          'full_name': fullName,
          'phone_number': phoneNumber,
          'license_name': licenseName,
          'license_number': licenseNumber,
          'license_address': licenseAddress,
          'license_codes': licenseCodes,
          'license_expiration': licenseExpiration,
        }),
      );

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 201 && data['success']) {
        // Save user data to shared preferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_data', jsonEncode(data['user']));
        await prefs.setBool('is_logged_in', true);
        
        return {
          'success': true,
          'message': data['message'],
          'user': User.fromJson(data['user']),
          'driver': data['driver'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Driver registration failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  // Verify OTP method
  static Future<Map<String, dynamic>> verifyOtp(int userId, String otpCode) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/verify_otp.php'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'user_id': userId,
          'otp_code': otpCode,
        }),
      );

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200 && data['success']) {
        return {
          'success': true,
          'message': data['message'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'OTP verification failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  // Delete account method
  static Future<Map<String, dynamic>> deleteAccount(int userId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/delete_account.php'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'user_id': userId,
        }),
      );

      // Check if response body is valid JSON
      if (response.body.isEmpty) {
        return {
          'success': false,
          'message': 'Empty response from server',
        };
      }

      // Try to parse JSON, but catch format exceptions
      Map<String, dynamic> data;
      try {
        data = jsonDecode(response.body);
      } catch (e) {
        // If JSON parsing fails, return the raw response for debugging
        return {
          'success': false,
          'message': 'Invalid response format from server: ${response.body}',
        };
      }
      
      if (response.statusCode == 200 && data['success'] == true) {
        // Clear user data from shared preferences on successful deletion
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('user_data');
        await prefs.setBool('is_logged_in', false);
        
        return {
          'success': true,
          'message': data['message'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Account deletion failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }
}

