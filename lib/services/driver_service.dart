import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/environment_config.dart';

class DriverService {
  static String get baseUrl => EnvironmentConfig.driversBaseUrl;

  static Future<Map<String, dynamic>> addDriver(Map<String, dynamic> driverData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/add.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(driverData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        final errorData = json.decode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'Failed to add driver: ${response.statusCode}'
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: Please check your connection and try again. Details: ${e.toString()}'
      };
    }
  }

  static Future<List<Map<String, dynamic>>> getDrivers() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/index.php'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return List<Map<String, dynamic>>.from(data['drivers']);
        } else {
          throw Exception(data['message'] ?? 'Failed to load drivers');
        }
      } else {
        throw Exception('Failed to load drivers: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading drivers: $e');
    }
  }

  static Future<Map<String, dynamic>> removeDriver(String licenseNumber) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/remove.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'license_number': licenseNumber}),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to remove driver: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error removing driver: $e');
    }
  }
}
