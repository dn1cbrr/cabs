import '../models/user.dart';

class AdminUserService {
  // Singleton implementation
  AdminUserService._();
  
  // Public singleton instance - can be replaced for testing
  static AdminUserService instance = AdminUserService._();
  
  // Method to fetch users
  Future<List<User>> fetchUsers() async {
    // Default implementation - override in tests
    return [];
  }
  
  // Method to update user
  Future<Map<String, dynamic>> updateUser(Map<String, dynamic> userData) async {
    // Default implementation - override in tests
    return {'success': true, 'message': 'User updated successfully'};
  }
}
