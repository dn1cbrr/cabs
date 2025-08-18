// Import necessary packages for HTTP requests and data handling
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

// Authentication service class handling login/logout and API communication
class AuthService {
  // Dynamic base URL based on platform (Android/iOS/Web)
  static String get baseUrl {
    if (Platform.isAndroid) {
      // Use 10.0.2.2 for Android emulator to access host machine localhost
      return 'http://10.0.2.2/transit/api';

    } else {
      // Use virtual host for other platforms
      return'http://transit.local/api';//'http://192.168.1.7/transit/api'; //
    }
  }

  // Login method - sends credentials to PHP backend
  static Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      // POST request to login endpoint
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

      // Parse JSON response
      final data = jsonDecode(response.body);
      
      // Check if login was successful
      if (response.statusCode == 200 && data['success']) {
        // Save user data to shared preferences for persistent login
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_data', jsonEncode(data['user']));
        await prefs.setBool('is_logged_in', true);
        
        return {
          'success': true,
          'message': data['message'],
          'user': User.fromJson(data['user']), // Convert JSON to User object
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Login failed',
        };
      }
    } on SocketException catch (e) {
      return {
        'success': false,
        'message': 'Connection failed: Unable to reach server. Please check your network connection and server status.',
        'error_type': 'network',
        'details': e.message,
      };
    } on FormatException catch (e) {
      return {
        'success': false,
        'message': 'Invalid response format from server',
        'error_type': 'format',
        'details': e.toString(),
      };
    } on HttpException catch (e) {
      return {
        'success': false,
        'message': 'HTTP error occurred',
        'error_type': 'http',
        'details': e.message,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Unexpected error: ${e.toString()}',
        'error_type': 'unknown',
      };
    }
  }

  // Register method - creates new user account
  static Future<Map<String, dynamic>> register(
    String username,
    String email,
    String password,
    String fullName, {
    String? phoneNumber,
    DateTime? birthday,
    DateTime? expirationDate,
  }) async {
    try {
      // Build request data with optional fields
      final requestData = {
        'username': username,
        'email': email,
        'password': password,
        'full_name': fullName,
        'phone_number': phoneNumber,
      };

      // Add optional date fields if provided
      if (birthday != null) {
        requestData['birthday'] = birthday.toIso8601String();
      }
      if (expirationDate != null) {
        requestData['expiration_date'] = expirationDate.toIso8601String();
      }

      // POST request to register endpoint
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

  // Check if user is logged in using shared preferences
  static Future<bool> isLoggedIn({SharedPreferences? prefs}) async {
    final instance = prefs ?? await SharedPreferences.getInstance();
    return instance.getBool('is_logged_in') ?? false;
  }

  // Get current user data from shared preferences
  static Future<User?> getCurrentUser({SharedPreferences? prefs}) async {
    final instance = prefs ?? await SharedPreferences.getInstance();
    final userData = instance.getString('user_data');
    
    if (userData != null) {
      return User.fromJson(jsonDecode(userData));
    }
    return null;
  }


  // Logout - clear stored user data
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

      return jsonDecode(response.body);
    } catch (e) {
      return {
        'success': false,
        'message': 'Connection error: ${e.toString()}',
      };
    }
  }
  
  static Future<Map<String, dynamic>> verifyOtp(int userId, String otp) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/verify_otp.php'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'user_id': userId,
          'otp': otp,
        }),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  static Future<Map<String, dynamic>> forgotPassword(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/forgot_password.php'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'email': email}),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }


  static Future<Map<String, dynamic>> deleteAccount(int userId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/delete_account.php'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'user_id': userId}),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }
}
