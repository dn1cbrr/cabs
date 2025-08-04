import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/trip_service.dart';
import '../services/auth_service.dart';
import '../models/user.dart';

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
        'route_details': _routeController.text.trim(),
        'total_passengers': int.parse(_passengersController.text),
      };

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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Failed to add trip'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
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
          return 'Passenger count seems too high (max: 17)';
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
