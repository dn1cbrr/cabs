import 'package:flutter/material.dart';
import '../services/driver_service.dart';

class DriverTestScreen extends StatefulWidget {
  const DriverTestScreen({super.key});

  @override
  State<DriverTestScreen> createState() => _DriverTestScreenState();
}

class _DriverTestScreenState extends State<DriverTestScreen> {
  List<Map<String, dynamic>> drivers = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadDrivers();
  }

  Future<void> _loadDrivers() async {
    setState(() => _isLoading = true);
    try {
      final driverList = await DriverService.getDrivers();
      setState(() {
        drivers = driverList;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading drivers: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Driver Test Screen'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: drivers.length,
              itemBuilder: (context, index) {
                final driver = drivers[index];
                return ListTile(
                  title: Text(driver['name'] ?? 'Unknown Driver'),
                  subtitle: Text('${driver['vehicle_type']} - ${driver['plate_number']}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _removeDriver(driver['license_number'] ?? '', index),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadDrivers,
        child: const Icon(Icons.refresh),
      ),
    );
  }

  Future<void> _removeDriver(String licenseNumber, int index) async {
    try {
      final result = await DriverService.removeDriver(licenseNumber);
      if (result['success'] == true) {
        setState(() {
          drivers.removeAt(index);
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Driver removed successfully')),
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
}
