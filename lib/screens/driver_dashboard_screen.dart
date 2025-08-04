import 'package:flutter/material.dart';

class DriverDashboardScreen extends StatefulWidget {
  const DriverDashboardScreen({super.key});

  @override
  State<DriverDashboardScreen> createState() => _DriverDashboardScreenState();
}

class _DriverDashboardScreenState extends State<DriverDashboardScreen> {
  // List to hold seat occupancy status: true = occupied, false = free
  final List<bool> _seatOccupied = List<bool>.filled(18, false);

  // Widget to build a single seat representation
  Widget _buildSeat(int index) {
    bool occupied = _seatOccupied[index];
    return Container(
      margin: const EdgeInsets.all(4),
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: occupied ? Colors.red : Colors.green,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.black54),
      ),
      child: Center(
        child: Text(
          '${index + 1}',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Driver Dashboard'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Icon(Icons.directions_bus, size: 64, color: Colors.blue),
            const SizedBox(height: 16),
            const Text(
              'Driver Dashboard',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Welcome to the driver portal',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            const Text(
              'Seat Occupancy Monitoring',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: GridView.builder(
                itemCount: _seatOccupied.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 6,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                ),
                itemBuilder: (context, index) {
                  return _buildSeat(index);
                },
              ),
            ),
            // Placeholder for future integration with IoT device
            // For example, listen to a stream or API to update seat status
          ],
        ),
      ),
    );
  }
}
