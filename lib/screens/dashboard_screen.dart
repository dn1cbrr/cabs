import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import 'driver_list_screen.dart';
import 'driver_dashboard.dart';
import 'admin_user_management_screen.dart';
import 'admin_routes_screen.dart';
import 'seat_management_screen.dart';
import 'seat_visualization_screen.dart';
import '../models/trip.dart';
import '../services/trip_service.dart';
import '../widgets/seat_availability_widget.dart';

class DashboardScreen extends StatefulWidget {
  final User user;

  const DashboardScreen({super.key, required this.user});

  @override
  State<DashboardScreen> createState() {
    return _DashboardScreenState();
  }
}

class _DashboardScreenState extends State<DashboardScreen> {
  Trip? _latestTrip;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchLatestTrip();
  }

  Future<void> _fetchLatestTrip() async {
    try {
      final trip = await TripService.getLatestTrip();
      if (mounted) {
        setState(() {
          _latestTrip = trip;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  void _handleLogout() async {
    await AuthService.logout();
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('DECINA TRANSPORT'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _handleLogout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Card
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome, ${widget.user.fullName}!',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Role: ${widget.user.role.toUpperCase()}',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: widget.user.role == 'admin'
                                  ? Colors.red
                                  : Theme.of(context).colorScheme.secondary,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Username: ${widget.user.username}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      Text(
                        'Email: ${widget.user.email}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Latest Trip / Seat Availability
              Text(
                'Current Trip Status',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              _buildSeatAvailability(),
              const SizedBox(height: 24),
              // Quick Actions
              Text(
                'Quick Actions',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              // Action Buttons Grid
              GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  if (widget.user.role == 'admin')
                    _buildActionCard(
                      context,
                      'View All Routes',
                      Icons.route,
                      Colors.blue,
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return const AdminRoutesScreen();
                            },
                          ),
                        );
                      },
                    ),
                  _buildActionCard(
                    context,
                    'Driver Dashboard',
                    Icons.dashboard,
                    Colors.indigo,
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return const DriverDashboard();
                          },
                        ),
                      );
                    },
                  ),
                  _buildActionCard(
                    context,
                    'View Vehicle Location',
                    Icons.location_on,
                    Colors.green,
                    () {
                      Navigator.pushNamed(context, '/map-tracking');
                    },
                  ),
                  _buildActionCard(
                    context,
                    'View Seat Monitoring',
                    Icons.monitor_heart,
                    Colors.teal,
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return const SeatVisualizationScreen();
                          },
                        ),
                      );
                    },
                  ),
                  if (widget.user.role == 'admin')
                    _buildActionCard(
                      context,
                      'Manage Users',
                      Icons.person_search,
                      Colors.orange,
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return const AdminUserManagementScreen();
                            },
                          ),
                        );
                      },
                    ),
                  if (widget.user.role == 'admin')
                    _buildActionCard(
                      context,
                      'Manage Drivers',
                      Icons.person_add,
                      Colors.purple,
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return const DriverListScreen();
                            },
                          ),
                        );
                      },
                    ),
                ],
              ),
            ],
          ),
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
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 48,
                color: color,
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSeatAvailability() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Card(
        color: Colors.red.shade50,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Error loading trip data: $_errorMessage',
            style: TextStyle(color: Colors.red.shade700),
          ),
        ),
      );
    }

    if (_latestTrip == null) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(
            child: Text(
              'No active trips found at the moment.',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ),
        ),
      );
    }

    return SeatAvailabilityWidget(trip: _latestTrip!);
  }
}
