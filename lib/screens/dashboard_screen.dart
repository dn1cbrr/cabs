import 'dart:async';
import 'package:flutter/material.dart';
import '../models/user.dart';
import '../models/trip.dart';
import '../services/auth_service.dart';
import '../services/trip_service.dart';
import 'driver_list_screen.dart';
import 'driver_dashboard.dart';
import 'admin_user_management_screen.dart';
import 'admin_routes_screen.dart';

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
  Timer? _loadingTimer;

  @override
  void initState() {
    super.initState();
    _fetchLatestTrip();
  }

  @override
  void dispose() {
    _loadingTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchLatestTrip() async {
    debugPrint('DashboardScreen: Starting to fetch latest trip...');

    // Set a timer to prevent infinite loading
    _loadingTimer = Timer(const Duration(seconds: 15), () {
      if (mounted && _isLoading) {
        debugPrint('DashboardScreen: Trip fetch timeout after 15 seconds');
        setState(() {
          _isLoading = false;
        });
      }
    });

    try {
      final trip = await TripService.getLatestTrip();
      _loadingTimer?.cancel();

      if (mounted) {
        debugPrint(
          'DashboardScreen: Successfully fetched trip: ${trip?.id ?? "null"}',
        );
        setState(() {
          _latestTrip = trip;
          _isLoading = false;
        });
      }
    } catch (e) {
      _loadingTimer?.cancel();
      debugPrint('DashboardScreen: Error fetching trip: $e');

      if (mounted) {
        setState(() {
          e.toString().replaceFirst('Exception: ', '');
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
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
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

              const SizedBox(height: 16),
              _buildSeatAvailability(),
              const SizedBox(height: 24),
              // Quick Actions
              Text(
                'Quick Actions',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
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
                  // _buildActionCard(
                  //context,
                  //'Seat Monitoring',
                  //Icons.chair,
                  //Colors.teal,
                  //() {
                  // Navigator.pushNamed(context, '/seat-monitoring');
                  // },
                  //),
                  _buildActionCard(
                    context,
                    ' Seat Monitor',
                    Icons.sensors,
                    Colors.deepOrange,
                    () {
                      Navigator.pushNamed(context, '/esp32-seat-monitoring');
                    },
                  ),
                  /*_buildActionCard(
                    context,
                    'ESP32 Setup & Diagnostics',
                    Icons.build,
                    Colors.blueGrey,
                    () {
                      Navigator.pushNamed(context, '/esp32-setup');
                    },
                  ),*/
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
              Icon(icon, size: 48, color: color),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSeatAvailability() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Loading trip information...',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    /*    if (_errorMessage != null) {
      return Card(
        color: Colors.red.shade50,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Icon(Icons.warning, size: 48, color: Colors.orange),
              const SizedBox(height: 16),
              Text(
                'Connection Issue',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _fetchLatestTrip,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    } */

    if (_latestTrip == null) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(
            child: Column(
              children: [
                Icon(Icons.directions_bus, size: 48, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No active trips found at the moment.',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return SeatAvailabilityWidget(trip: _latestTrip!);
  }
}

class SeatAvailabilityWidget extends StatelessWidget {
  final Trip trip;

  const SeatAvailabilityWidget({super.key, required this.trip});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Trip #${trip.id}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: trip.occupancyColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    trip.occupancyStatus.toUpperCase(),
                    style: TextStyle(
                      color: trip.occupancyColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              trip.routeDetails,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 4),
            Text(
              'Driver: ${trip.driverName}',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 4),
            Text(
              'Vehicle: ${trip.vehicleType}',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  trip.formattedDate,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(width: 16),
                Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  trip.formattedStartTime,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Seat Availability',
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: trip.occupancyPercentage,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    trip.occupancyColor,
                  ),
                  minHeight: 8,
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Occupied: ${trip.currentOccupancy}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      'Available: ${trip.availableSeats}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: trip.isAvailable ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Total: ${trip.seatCapacity}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
