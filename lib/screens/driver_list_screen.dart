import 'package:flutter/material.dart';
import '../services/driver_service.dart';
import 'profile_screen.dart';
import '../services/auth_service.dart';
import '../models/user.dart';

class DriverListScreen extends StatefulWidget {
  const DriverListScreen({super.key});

  @override
  State<DriverListScreen> createState() => _DriverListScreenState();
}

class _DriverListScreenState extends State<DriverListScreen> {
  List<Map<String, dynamic>> drivers = [];
  bool _isLoading = false;
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadDrivers();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    final user = await AuthService.getCurrentUser();
    if (mounted) {
      setState(() {
        _currentUser = user;
      });
    }
  }

  Future<void> _loadDrivers() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      final driverList = await DriverService.getDrivers();
      if (mounted) {
        setState(() {
          drivers = driverList;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading drivers: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _refreshDrivers() async {
    try {
      final driverList = await DriverService.getDrivers();
      if (mounted) {
        setState(() {
          drivers = driverList;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error refreshing drivers: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _removeDriver(String licenseNumber, int index) async {
    try {
      final result = await DriverService.removeDriver(licenseNumber);
      
      if (result['success'] == true) {
        if (mounted) {
          setState(() {
            drivers.removeAt(index);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Driver removed successfully')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result['message'] ?? 'Failed to remove driver')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error removing driver: ${e.toString()}')),
        );
      }
    }
  }

  void _navigateToProfile() {
    if (_currentUser != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProfileScreen(user: _currentUser!),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not loaded yet')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Drivers'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: _navigateToProfile,
            tooltip: 'Profile',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _refreshDrivers,
              child: ListView.builder(
                padding: const EdgeInsets.all(8.0),
                itemCount: drivers.length,
                itemBuilder: (context, index) {
                  final driver = drivers[index];
                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.symmetric(vertical: 4.0),
                    child: ExpansionTile(
                      title: Text(
                        driver['name'] ?? 'Unknown Driver',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text('${driver['vehicle_type'] ?? 'N/A'} - ${driver['plate_number'] ?? 'N/A'}'),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildDriverInfoRow('Contact', driver['contact'] ?? 'N/A'),
                              _buildDriverInfoRow('Birthday', driver['birthday'] ?? 'N/A'),
                              _buildDriverInfoRow('Age', driver['age']?.toString() ?? 'N/A'),
                              _buildDriverInfoRow('Address', driver['address'] ?? 'N/A'),
                              const Divider(),
                              const Text(
                                'License Information',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              _buildDriverInfoRow('License Number', driver['license_number'] ?? 'N/A'),
                              _buildDriverInfoRow('DL Codes', driver['license_codes'] ?? 'N/A'),
                              _buildDriverInfoRow('Expiration', driver['expiration_date'] ?? 'N/A'),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  ElevatedButton.icon(
                                    onPressed: () => _removeDriver(
                                      driver['license_number'] ?? '', 
                                      index
                                    ),
                                    icon: const Icon(Icons.delete),
                                    label: const Text('Remove Driver'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      foregroundColor: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToProfile,
        tooltip: 'Profile',
        child: const Icon(Icons.person),
      ),
    );
  }

  Widget _buildDriverInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}
