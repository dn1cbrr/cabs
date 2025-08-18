import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/seat_websocket_service.dart';
import '../models/seat_device.dart';
import '../widgets/visual_chair_widget.dart';

class SeatManagementScreen extends StatefulWidget {
  const SeatManagementScreen({super.key});

  @override
  State<SeatManagementScreen> createState() => _SeatManagementScreenState();
}

class _SeatManagementScreenState extends State<SeatManagementScreen> {
  late SeatWebSocketService _webSocketService;
  List<SeatDevice> _seats = [];
  Map<String, Map<String, dynamic>> _userLocations = {};
  bool _isLoading = true;
  bool _isConnected = false;

  @override
  void initState() {
    super.initState();
    _webSocketService = SeatWebSocketService();
    _webSocketService.connect();
    _setupListeners();
    
    // Initialize with mock data for ESP32 integration
    _initializeMockSeats();
  }

  void _initializeMockSeats() {
    setState(() {
      _seats = [
        SeatDevice(
          id: 'seat_1',
          name: 'Driver Seat',
          address: '0x01',
          seat1: 0,
          seat2: 0,
          seat3: 0,
          seat4: 1,
          timestamp: DateTime.now(),
        ),
        SeatDevice(
          id: 'seat_2',
          name: 'Passenger Seat 1',
          address: '0x02',
          seat1: 0,
          seat2: 1,
          seat3: 0,
          seat4: 0,
          timestamp: DateTime.now(),
        ),
        SeatDevice(
          id: 'seat_3',
          name: 'Passenger Seat 2',
          address: '0x03',
          seat1: 0,
          seat2: 0,
          seat3: 0,
          seat4: 0,
          timestamp: DateTime.now(),
        ),
        SeatDevice(
          id: 'seat_4',
          name: 'Passenger Seat 3',
          address: '0x04',
          seat1: 1,
          seat2: 0,
          seat3: 0,
          seat4: 0,
          timestamp: DateTime.now(),
        ),
      ];
      _isLoading = false;
    });
  }

  void _setupListeners() {
    _webSocketService.seatUpdates.listen((seats) {
      if (mounted) {
        setState(() {
          _seats = seats;
          _isLoading = false;
        });
      }
    });

    _webSocketService.userLocationUpdates.listen((location) {
      if (mounted) {
        setState(() {
          _userLocations[location['user_id']] = location;
        });
      }
    });
  }

  void _simulateIRSensorChange(String seatId, bool isOccupied) {
    // This simulates ESP32 IR sensor data
    setState(() {
      final seatIndex = _seats.indexWhere((seat) => seat.id == seatId);
      if (seatIndex != -1) {
        final updatedSeat = SeatDevice(
          id: _seats[seatIndex].id,
          name: _seats[seatIndex].name,
          address: _seats[seatIndex].address,
          seat1: seatId == 'seat_1' ? (isOccupied ? 1 : 0) : _seats[seatIndex].seat1,
          seat2: seatId == 'seat_2' ? (isOccupied ? 1 : 0) : _seats[seatIndex].seat2,
          seat3: seatId == 'seat_3' ? (isOccupied ? 1 : 0) : _seats[seatIndex].seat3,
          seat4: seatId == 'seat_4' ? (isOccupied ? 1 : 0) : _seats[seatIndex].seat4,
          timestamp: DateTime.now(),
        );
        _seats[seatIndex] = updatedSeat;
      }
    });
    
    // Send update via WebSocket
    _webSocketService.sendSeatStatus(seatId, isOccupied);
  }

  @override
  void dispose() {
    _webSocketService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seat Management'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _isLoading = true;
              });
              _initializeMockSeats();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Connection Status
          Container(
            padding: const EdgeInsets.all(8),
            color: _isConnected ? Colors.green : Colors.red,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _isConnected ? Icons.wifi : Icons.wifi_off,
                  color: Colors.white,
                ),
                const SizedBox(width: 8),
                Text(
                  _isConnected ? 'Connected to ESP32' : 'Disconnected',
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
          
          // Summary Cards
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildSummaryCard(
                  'Available',
                  _seats.where((seat) => seat.hasAvailableSeats).length.toString(),
                  Colors.green,
                ),
                _buildSummaryCard(
                  'Occupied',
                  _seats.where((seat) => !seat.hasAvailableSeats).length.toString(),
                  Colors.red,
                ),
                _buildSummaryCard(
                  'Total',
                  _seats.length.toString(),
                  Colors.blue,
                ),
              ],
            ),
          ),
          
          // Visual Chairs Grid
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1,
                    ),
                    itemCount: _seats.length,
                    itemBuilder: (context, index) {
                      final seat = _seats[index];
                      return Column(
                        children: [
                          VisualChairWidget(
                            seatId: seat.id,
                            isAvailable: seat.hasAvailableSeats,
                            userId: _userLocations[seat.id]?['user_id'],
                            onStatusChanged: (isAvailable) {
                              _simulateIRSensorChange(seat.id, !isAvailable);
                            },
                            showUserInfo: true,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            seat.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            seat.hasAvailableSeats ? 'Available' : 'Occupied',
                            style: TextStyle(
                              color: seat.hasAvailableSeats ? Colors.green : Colors.red,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Simulate ESP32 sensor data
          final randomSeat = _seats[DateTime.now().millisecond % _seats.length];
          _simulateIRSensorChange(
            randomSeat.id,
            !randomSeat.hasAvailableSeats,
          );
        },
        child: const Icon(Icons.sensors),
        tooltip: 'Simulate IR Sensor',
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
