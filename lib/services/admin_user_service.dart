import '../models/user.dart';
import 'api_service.dart';

class AdminUserService {
  // Singleton implementation
  AdminUserService._();

  // Public singleton instance - can be replaced for testing
  static AdminUserService instance = AdminUserService._();

  // Method to fetch users
  Future<List<User>> fetchUsers() async {
    try {
      final result = await ApiService.makeRequest('users?action=get_users');

      // Check for network/connection errors
      if (result['error_type'] != null) {
        throw Exception(result['message'] ?? 'Network error occurred');
      }

      // Check for successful response
      if (result['success'] == true) {
        // Handle both old and new response formats
        dynamic usersData;
        
        if (result['data'] != null && result['data']['users'] != null) {
          // New format: {'success': true, 'data': {'users': [...]}}
          usersData = result['data']['users'];
        } else if (result['data'] != null && result['data'] is List) {
          // Alternative format: {'success': true, 'data': [...]}
          usersData = result['data'];
        } else {
          throw Exception('Invalid response format: users data not found');
        }

        if (usersData is! List) {
          throw Exception('Invalid response format: users data is not a list');
        }

        return usersData.map((userData) {
          try {
            return User.fromJson(userData);
          } catch (e) {
            throw Exception('Error parsing user data: $e');
          }
        }).toList();
      } else {
        throw Exception(result['message'] ?? 'Failed to fetch users');
      }
    } catch (e) {
      // Re-throw with more context
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Error fetching users: $e');
    }
  }

  // Method to update user
  Future<Map<String, dynamic>> updateUser(Map<String, dynamic> userData) async {
    try {
      // Validate required fields before sending
      if (userData['user_id'] == null) {
        return {
          'success': false,
          'message': 'User ID is required',
        };
      }

      final result = await ApiService.makeRequest(
        'users?action=update_user',
        method: 'POST',
        body: userData,
      );

      // Check for network/connection errors
      if (result['error_type'] != null) {
        return {
          'success': false,
          'message': result['message'] ?? 'Network error occurred',
          'error_type': result['error_type'],
        };
      }

      if (result['success'] == true) {
        // Handle both old and new response formats
        String message = 'User updated successfully';
        
        if (result['data'] != null && result['data']['message'] != null) {
          message = result['data']['message'];
        } else if (result['message'] != null) {
          message = result['message'];
        }

        return {
          'success': true,
          'message': message,
        };
      } else {
        return {
          'success': false,
          'message': result['message'] ?? 'Failed to update user',
          'status_code': result['status_code'],
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error updating user: $e',
      };
    }
  }

  // Method to send heartbeat
  Future<Map<String, dynamic>> sendHeartbeat(String userId) async {
    try {
      final result = await ApiService.makeRequest(
        'users?action=heartbeat',
        method: 'POST',
        body: {'user_id': userId},
      );

      if (result['success'] == true) {
        return {
          'success': true,
          'message':
              result['data']?['message'] ?? 'Heartbeat sent successfully',
          'timestamp': result['data']?['timestamp'],
        };
      } else {
        return {
          'success': false,
          'message': result['message'] ?? 'Failed to send heartbeat',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error sending heartbeat: $e'};
    }
  }

  // Method to archive user (soft delete)
  Future<Map<String, dynamic>> archiveUser(int userId, int adminId) async {
    try {
      final result = await ApiService.makeRequest(
        'users?action=archive_user',
        method: 'POST',
        body: {'user_id': userId, 'admin_id': adminId},
      );

      if (result['success'] == true) {
        return {
          'success': true,
          'message': result['message'] ?? 'User archived successfully',
          'data': result['data'],
        };
      } else {
        return {
          'success': false,
          'message': result['message'] ?? 'Failed to archive user',
          'error_code': result['error_code'],
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error archiving user: $e'};
    }
  }
}
