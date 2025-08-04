import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import 'driver_list_screen.dart';
import 'driver_dashboard.dart';
import 'admin_user_management_screen.dart';
import 'admin_routes_screen.dart';

class DashboardScreen extends StatefulWidget {
  final User user;

  const DashboardScreen({super.key, required this.user});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
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
                            builder: (context) => const AdminRoutesScreen(),
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
                          builder: (context) => const DriverDashboard(),
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
                            builder: (context) => const AdminUserManagementScreen(),
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
                            builder: (context) => const DriverListScreen(),
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
}
