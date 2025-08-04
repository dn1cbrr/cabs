import 'package:flutter/material.dart';
import 'trip_history_screen.dart';
import 'add_trip_screen.dart';
import 'profile_screen.dart';
import '../services/auth_service.dart';
import '../models/trip.dart';
import '../widgets/seat_availability_widget.dart';


class DriverDashboard extends StatefulWidget {
  const DriverDashboard({super.key});

  @override
  State<DriverDashboard> createState() => _DriverDashboardState();
}

class _DriverDashboardState extends State<DriverDashboard> {
  @override
  Widget build(BuildContext context) {
    // Dummy trip data for demonstration
    final dummyTrip = Trip(
      id: 1,
      driverId: 101,
      driverName: 'John Doe',
      routeDetails: 'City Center to Suburbs',
      vehicleType: 'Bus',
      seatCapacity: 40,
      currentOccupancy: 25,
      occupancyStatus: 'available',
      availableSeats: 15,
      tripDate: DateTime.now(),
      startTime: '14:00:00',
    );


    return Scaffold(

      appBar: AppBar(
        title: const Text('Driver Dashboard'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Driver Management',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: [
                  const Text(
                    'Current Trip Status',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  SeatAvailabilityWidget(
                    trip: dummyTrip,
                  ),

                  const SizedBox(height: 20),
                  const Text(
                    'Driver Actions',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  _buildActionCard(
                    context,
                    'View Profile',

                    Icons.person,
                    Colors.green,
                    () => _navigateToProfile(context),
                  ),
                  _buildActionCard(
                    context,
                    'Trip History',
                    Icons.history,
                    Colors.purple,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TripHistoryScreen(),
                      ),
                    ),
                  ),
                  _buildActionCard(
                    context,
                    'Add New Trip',
                    Icons.add_road,
                    Colors.indigo,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AddTripScreen(),
                      ),
                    ),
                  ),
                  _buildActionCard(
                    context,
                    'Driver Reports',
                    Icons.analytics,
                    Colors.orange,
                    () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Driver reports feature coming soon!'),
                      ),
                    ),
                  ),
                  _buildActionCard(
                    context,
                    'Delete Account',
                    Icons.delete,
                    Colors.red,
                    () => _showDeleteAccountDialog(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(icon, size: 32, color: color),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToProfile(BuildContext context) async {
    // Store context reference
    final navigator = Navigator.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    
    // Show loading indicator while fetching user data
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text('Loading profile...'),
            ],
          ),
        );
      },
    );

    try {
      // Get current user data
      final user = await AuthService.getCurrentUser();
      
      // Close loading dialog
      if (mounted) {
        navigator.pop();
      }
      
      if (user != null) {
        // Nav  igate to profile screen
        if (mounted) {
          navigator.push(
            MaterialPageRoute(
              builder: (context) => ProfileScreen(user: user),
            ),
          );
        }
      } else {
        // Show error if user not found
        if (mounted) {
          scaffoldMessenger.showSnackBar(
            const SnackBar(content: Text('User not found. Please log in again.')),
          );
        }
      }
    } catch (e) {
      // Close loading dialog
      if (mounted) {
        navigator.pop();
      }
      
      // Show error message
      if (mounted) {
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error loading profile: ${e.toString()}')),
        );
      }
    }
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Delete Account'),
          content: const Text('Are you sure you want to delete your account? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => _handleDeleteAccount(dialogContext),
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _handleDeleteAccount(BuildContext dialogContext) async {
    // Store context references before any async operations
    final navigator = Navigator.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    
    // Close the confirmation dialog first
    Navigator.of(dialogContext).pop();
    
    try {
      // Show progress dialog before async operation
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext progressContext) {
          return const AlertDialog(
            content: Row(
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 20),
                Text('Deleting account...'),
              ],
            ),
          );
        },
      );
      
      // Get current user to get user ID
      final user = await AuthService.getCurrentUser();
      if (user != null) {
        // Call delete account service
        final result = await AuthService.deleteAccount(user.id);
        
        // Close progress dialog
        if (mounted) {
          navigator.pop();
        }
        
        if (result['success']) {
          // Show success message and navigate to login
          if (mounted) {
            scaffoldMessenger.showSnackBar(
              SnackBar(content: Text(result['message'])),
            );
            // Navigate to login screen (assuming it's at route '/')
            navigator.pushNamedAndRemoveUntil('/', (route) => false);
          }
        } else {
          // Show error message
          if (mounted) {
            scaffoldMessenger.showSnackBar(
              SnackBar(content: Text(result['message'])),
            );
          }
        }
      } else {
        // Close progress dialog
        if (mounted) {
          navigator.pop();
        }
        
        // Show error if user not found
        if (mounted) {
          scaffoldMessenger.showSnackBar(
            const SnackBar(content: Text('User not found')),
          );
        }
      }
    } catch (e) {
      // Close progress dialog
      if (mounted) {
        navigator.pop();
      }
      
      // Show error message
      if (mounted) {
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error deleting account: ${e.toString()}')),
        );
      }
    }
  }
}
