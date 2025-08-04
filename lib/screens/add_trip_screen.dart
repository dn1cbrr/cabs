import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/trip_service.dart';
import '../services/auth_service.dart';
import '../models/user.dart';
import '../config/environment_config.dart';
import '../services/location_service.dart';

class AddTripScreen extends StatefulWidget {
  const AddTripScreen({super.key});

  @override
  State<AddTripScreen> createState() => _AddTripScreenState();
}

class _AddTripScreenState extends State<AddTripScreen> {
  final _formKey = GlobalKey<FormState>();
  final _routeController = TextEditingController();
  final _passengersController = TextEditingController();

  int? selectedDriverId;
  DateTime selectedDate = DateTime.now();
  TimeOfDay startTime = TimeOfDay.now();
  TimeOfDay? endTime;
  bool isSubmitting = false;
  User? currentUser;

  String? currentLocation; // Store current location string
  bool isLoadingLocation = false; // Track location loading state

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    try {
      final user = await AuthService.getCurrentUser();
      setState(() {
        currentUser = user;
        if (user != null) {
          selectedDriverId = user.id;
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading user data: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      helpText: 'Select trip date',
      confirmText: 'SELECT',
      cancelText: 'CANCEL',
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> _selectStartTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: startTime,
      helpText: 'Select start time',
      confirmText: 'SELECT',
      cancelText: 'CANCEL',
    );

    if (picked != null && picked != startTime) {
      setState(() {
        startTime = picked;
        // Reset end time if it's before new start time
        if (endTime != null && _isTimeBefore(picked, endTime!)) {
          endTime = null;
        }
      });
    }
  }

  Future<void> _selectEndTime() async {
    // Calculate default end time (1 hour after start time)
    TimeOfDay defaultEndTime = TimeOfDay(
      hour: (startTime.hour + 1) % 24,
      minute: startTime.minute,
    );
    
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: endTime ?? defaultEndTime,
      helpText: 'Select end time',
      confirmText: 'SELECT',
      cancelText: 'CANCEL',
    );

    if (picked != null) {
      if (_isTimeBefore(picked, startTime)) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('End time must be after start time'),
              backgroundColor: Colors.orange,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        return;
      }
      
      setState(() {
        endTime = picked;
      });
    }
  }

  bool _isTimeBefore(TimeOfDay time1, TimeOfDay time2) {
    return time1.hour < time2.hour || 
           (time1.hour == time2.hour && time1.minute < time2.minute);
  }

  Future<void> _submitTrip() async {
    if (!_formKey.currentState!.validate()) return;
    if (selectedDriverId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Driver information not available'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

    // Dismiss keyboard
    FocusScope.of(context).unfocus();

    setState(() {
      isSubmitting = true;
    });

    try {
      final startDateTime = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        startTime.hour,
        startTime.minute,
      );

      DateTime? endDateTime;
      if (endTime != null) {
        endDateTime = DateTime(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day,
          endTime!.hour,
          endTime!.minute,
        );
      }

      final tripData = {
        'driver_id': selectedDriverId,
        'trip_date': selectedDate.toIso8601String().split('T')[0],
        'start_time': startDateTime.toIso8601String(),
        'end_time': endDateTime?.toIso8601String(),
        'route_details': currentLocation ?? _routeController.text.trim(),
        'total_passengers': int.parse(_passengersController.text),
      };

      // Validate trip data before sending
      final validationError = TripService.validateTripData(tripData);
      if (validationError != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(validationError['message']),
              backgroundColor: Colors.orange,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        return;
      }

      final result = await TripService.addTrip(tripData);

      if (result['success'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Trip added successfully'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
          Navigator.pop(context, true);
        }
      } else {
        if (mounted) {
          _handleTripError(result);
        }
      }
    } on FormatException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Invalid input format: ${e.message}'),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding trip: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isSubmitting = false;
        });
      }
    }
  }

  void _handleTripError(Map<String, dynamic> result) {
    final errorType = result['error_type'] ?? 'unknown';
    final message = result['message'] ?? 'Failed to add trip';
    
    // Show the main error message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
      ),
    );

    // For connectivity errors, show additional help
    if (errorType == 'connectivity' || errorType == 'network_error') {
      _showConnectivityHelp(result);
    }
  }

  void _showConnectivityHelp(Map<String, dynamic> result) {
    final suggestions = result['suggestions'] as List<String>? ?? [];
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.wifi_off, color: Colors.red),
            SizedBox(width: 8),
            Text('Connection Problem'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Cannot connect to the server. Here are some things to check:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...suggestions.map((suggestion) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
                  Expanded(child: Text(suggestion)),
                ],
              ),
            )),
            const SizedBox(height: 12),
            const Text(
              'Current server URL:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              '${EnvironmentConfig.tripsBaseUrl}/add.php',
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _testConnection();
            },
            child: const Text('Test Connection'),
          ),
        ],
      ),
    );
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      isLoadingLocation = true;
    });

    try {
      final position = await LocationService.getCurrentPosition();
      if (position != null) {
        final locationString = LocationService.formatPosition(position);
        setState(() {
          currentLocation = locationString;
          isLoadingLocation = false;
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Location obtained successfully'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        isLoadingLocation = false;
      });
      
      if (mounted) {
        String errorMessage = 'Failed to get location';
        if (e.toString().contains('Location services are disabled')) {
          errorMessage = 'Please enable location services';
        } else if (e.toString().contains('Location permissions are denied')) {
          errorMessage = 'Please grant location permission';
        } else if (e.toString().contains('permanently denied')) {
          errorMessage = 'Location permission permanently denied. Please enable in settings';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label: 'Retry',
              onPressed: _getCurrentLocation,
            ),
          ),
        );
      }
    }
  }

  Future<void> _testConnection() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Testing connection...'),
          ],
        ),
      ),
    );

    try {
      final result = await TripService.testConnection();
      
      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Row(
              children: [
                Icon(
                  result['success'] ? Icons.check_circle : Icons.error,
                  color: result['success'] ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 8),
                Text(result['success'] ? 'Connection OK' : 'Connection Failed'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(result['message'] ?? 'No message'),
                if (result['statusCode'] != null) ...[
                  const SizedBox(height: 8),
                  Text('Status Code: ${result['statusCode']}'),
                ],
                if (result['details'] != null) ...[
                  const SizedBox(height: 8),
                  Text('Details: ${result['details']}'),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Test failed: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Add New Trip'),
          elevation: 0,
        ),
        body: currentUser == null
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Loading user data...'),
                  ],
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildDatePicker(),
                      const SizedBox(height: 16),
                      _buildTimePickers(),
                      const SizedBox(height: 16),
                      _buildLocationButton(),
                      const SizedBox(height: 16),
                      _buildRouteField(),
                      const SizedBox(height: 16),
                      _buildPassengersField(),
                      const SizedBox(height: 32),
                      _buildSubmitButton(),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildDatePicker() {
    return Card(
      elevation: 2,
      child: ListTile(
        leading: const Icon(Icons.calendar_today, color: Colors.blue),
        title: const Text(
          'Trip Date',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
          style: const TextStyle(fontSize: 16),
        ),
        trailing: const Icon(Icons.edit, color: Colors.blue),
        onTap: _selectDate,
      ),
    );
  }

  Widget _buildTimePickers() {
    return Row(
      children: [
        Expanded(
          child: Card(
            elevation: 2,
            child: ListTile(
              leading: const Icon(Icons.access_time, color: Colors.green),
              title: const Text(
                'Start Time',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                startTime.format(context),
                style: const TextStyle(fontSize: 16),
              ),
              trailing: const Icon(Icons.edit, color: Colors.green),
              onTap: _selectStartTime,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Card(
            elevation: 2,
            child: ListTile(
              leading: const Icon(Icons.access_time, color: Colors.orange),
              title: const Text(
                'End Time',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                endTime?.format(context) ?? 'Not set',
                style: const TextStyle(fontSize: 16),
              ),
              trailing: const Icon(Icons.edit, color: Colors.orange),
              onTap: _selectEndTime,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLocationButton() {
    return Card(
      elevation: 2,
      child: ListTile(
        leading: isLoadingLocation
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.location_on, color: Colors.purple),
        title: const Text(
          'Current Location',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          currentLocation ?? 'Tap to get current location',
          style: const TextStyle(fontSize: 16),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: isLoadingLocation
            ? null
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (currentLocation != null)
                    IconButton(
                      icon: const Icon(Icons.clear, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          currentLocation = null;
                        });
                      },
                      tooltip: 'Clear location',
                    ),
                  const Icon(Icons.gps_fixed, color: Colors.purple),
                ],
              ),
        onTap: isLoadingLocation ? null : _getCurrentLocation,
      ),
    );
  }

  Widget _buildRouteField() {
    return TextFormField(
      controller: _routeController,
      decoration: InputDecoration(
        labelText: 'Route Details *',
        hintText: 'e.g., Manila to Quezon City via EDSA',
        border: const OutlineInputBorder(),
        prefixIcon: const Icon(Icons.route),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
      maxLines: 3,
      maxLength: 500,
      textCapitalization: TextCapitalization.sentences,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter route details';
        }
        if (value.trim().length < 5) {
          return 'Route details must be at least 5 characters';
        }
        return null;
      },
    );
  }

  Widget _buildPassengersField() {
    return TextFormField(
      controller: _passengersController,
      decoration: InputDecoration(
        labelText: 'Total Passengers *',
        hintText: 'Enter number of passengers',
        border: const OutlineInputBorder(),
        prefixIcon: const Icon(Icons.people),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
      ],
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter passenger count';
        }
        final passengers = int.tryParse(value);
        if (passengers == null) {
          return 'Please enter a valid number';
        }
        if (passengers < 1) {
          return 'Passenger count must be at least 1';
        }
        if (passengers > 100) {
          return 'Passenger count seems too high (max: 100)';
        }
        return null;
      },
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton.icon(
        onPressed: isSubmitting ? null : _submitTrip,
        icon: isSubmitting
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Icon(Icons.add),
        label: isSubmitting
            ? const Text('Adding Trip...')
            : const Text('Add Trip'),
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _routeController.dispose();
    _passengersController.dispose();
    super.dispose();
  }
}
