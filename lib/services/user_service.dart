import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../config/environment_config.dart';

class UserService {
  static String get baseUrl => EnvironmentConfig.authBaseUrl;

  static Future<Map<String, dynamic>> updateUserProfile(Map<String, dynamic> profileData) async {
    try {
      // Check if we have a profile photo to upload
      if (profileData.containsKey('profile_photo') && profileData['profile_photo'] != null) {
        // Use multipart request for file upload
        final uri = Uri.parse('$baseUrl/update_profile.php');
        final request = http.MultipartRequest('POST', uri);
        
        // Add form fields
        profileData.forEach((key, value) {
          if (key != 'profile_photo' && value != null) {
            request.fields[key] = value.toString();
          }
        });
        
        // Add profile photo file
        final filePath = profileData['profile_photo'] as String;
        final file = File(filePath);
        final fileName = file.path.split('/').last.split('\\').last; // Handle both / and \ path separators
        
        request.files.add(
          await http.MultipartFile.fromPath(
            'profile_photo',
            filePath,
            filename: fileName,
            contentType: MediaType('image', 'jpeg'),
          ),
        );
        
        final response = await request.send();
        final responseBody = await response.stream.bytesToString();
        
        if (response.statusCode == 200) {
          return json.decode(responseBody);
        } else {
          final errorData = json.decode(responseBody);
          return {
            'success': false,
            'message': errorData['message'] ?? 'Failed to update profile: ${response.statusCode}'
          };
        }
      } else {
        // Regular JSON request without file upload
        final response = await http.post(
          Uri.parse('$baseUrl/update_profile.php'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(profileData),
        );

        if (response.statusCode == 200) {
          return json.decode(response.body);
        } else {
          final errorData = json.decode(response.body);
          return {
            'success': false,
            'message': errorData['message'] ?? 'Failed to update profile: ${response.statusCode}'
          };
        }
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: Please check your connection and try again. Details: ${e.toString()}'
      };
    }
  }

  static Future<Map<String, dynamic>> getUserProfile(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/get_profile.php?user_id=$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final errorData = json.decode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'Failed to get profile: ${response.statusCode}'
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: Please check your connection and try again. Details: ${e.toString()}'
      };
    }
  }
}
