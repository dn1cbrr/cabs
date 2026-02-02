import 'package:flutter/material.dart';
import '../services/admin_user_service.dart';
import 'edit_user_screen.dart';
import '../models/user.dart';
import 'package:intl/intl.dart';

class AdminUserManagementScreen extends StatefulWidget {
  const AdminUserManagementScreen({super.key});

  @override
  State<AdminUserManagementScreen> createState() =>
      _AdminUserManagementScreenState();
}

class _AdminUserManagementScreenState extends State<AdminUserManagementScreen> {
  List<User> users = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      final userList = await AdminUserService.instance.fetchUsers();
      if (mounted) {
        setState(() {
          users = userList;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        // Show detailed error message
        String errorMessage = 'Error loading users';
        if (e.toString().contains('Network error')) {
          errorMessage = 'Network error: Please check your internet connection';
        } else if (e.toString().contains('Invalid response format')) {
          errorMessage = 'Server error: Invalid response format. Please contact support.';
        } else if (e.toString().contains('parsing user data')) {
          errorMessage = 'Data error: Unable to parse user information';
        } else {
          errorMessage = 'Error loading users: ${e.toString()}';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: _loadUsers,
            ),
          ),
        );
      }
    }
  }

  Future<void> _refreshUsers() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      final userList = await AdminUserService.instance.fetchUsers();
      if (mounted) {
        setState(() {
          users = userList;
          _isLoading = false;
        });
        
        // Show success message on refresh
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Users refreshed successfully (${userList.length} users)'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        // Show detailed error message
        String errorMessage = 'Error refreshing users';
        if (e.toString().contains('Network error')) {
          errorMessage = 'Network error: Please check your internet connection';
        } else if (e.toString().contains('Invalid response format')) {
          errorMessage = 'Server error: Invalid response format. Please contact support.';
        } else {
          errorMessage = 'Error refreshing users: ${e.toString()}';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: _refreshUsers,
            ),
          ),
        );
      }
    }
  }

  void _navigateToEditUser(User user) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditUserScreen(user: user)),
    ).then((_) {
      if (mounted) {
        _refreshUsers();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshUsers,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading users...'),
                ],
              ),
            )
          : users.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.people_outline,
                        size: 64,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'No users found',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Pull down to refresh',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _refreshUsers,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Refresh'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
              onRefresh: _refreshUsers,
              child: ListView.builder(
                padding: const EdgeInsets.all(8.0),
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];
                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.symmetric(vertical: 4.0),
                    child: ListTile(
                      leading: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: user.isOnline ? Colors.green : Colors.grey,
                        ),
                      ),
                      title: Row(
                        children: [
                          Expanded(
                            child: Text(
                              user.fullName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (user.isOnline)
                            const Text(
                              'Online',
                              style: TextStyle(
                                color: Colors.green,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            )
                          else if (user.lastSeen != null)
                            Text(
                              'Last seen: ${DateFormat('MMM d, HH:mm').format(user.lastSeen!)}',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            )
                          else
                            const Text(
                              'Offline',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                        ],
                      ),
                      subtitle: Text(
                        '${user.username} - ${user.role.toUpperCase()}',
                      ),
                      onTap: () => _navigateToEditUser(user),
                      trailing: const Icon(Icons.chevron_right),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
