import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import '../config/environment_config.dart';
import '../services/websocket.dart';

class SeatMonitoringDashboard extends StatefulWidget {
  const SeatMonitoringDashboard({super.key});

  @override
  State<SeatMonitoringDashboard> createState() =>
      _SeatMonitoringDashboardState();
}

class _SeatMonitoringDashboardState extends State<SeatMonitoringDashboard> {
  List<Map<String, dynamic>> allSeats = [];
  List<Map<String, dynamic>> filteredSeats = [];
  List<Map<String, dynamic>> trips = [];
  List<String> vehicles = [];
  String selectedVehicle = 'All';
  String searchQuery = '';
  bool isLoading = true;
  String errorMessage = '';
  late WebSocketService _webSocketService;
  StreamSubscription? _seatSubscription;

  @override
  void initState() {
    super.initState();
    _webSocketService = WebSocketService();
    _loadSeatData();
    _loadTripData();
    _initializeWebSocket();
  }

  Future<void> _loadSeatData() async {
    try {
      // Simulate loading seat data without device grouping
      await Future.delayed(const Duration(seconds: 1));

      setState(() {
        // Flatten seat data - no device grouping, just individual seats
        allSeats = [
          {'seatNumber': 1, 'isOccupied': false, 'vehicle': 'Vehicle 1'},
          {'seatNumber': 2, 'isOccupied': true, 'vehicle': 'Vehicle 1'},
          {'seatNumber': 3, 'isOccupied': false, 'vehicle': 'Vehicle 1'},
          {'seatNumber': 4, 'isOccupied': true, 'vehicle': 'Vehicle 1'},
          {'seatNumber': 5, 'isOccupied': false, 'vehicle': 'Vehicle 2'},
          {'seatNumber': 6, 'isOccupied': true, 'vehicle': 'Vehicle 2'},
          {'seatNumber': 7, 'isOccupied': false, 'vehicle': 'Vehicle 2'},
          {'seatNumber': 8, 'isOccupied': false, 'vehicle': 'Vehicle 2'},
          {'seatNumber': 9, 'isOccupied': true, 'vehicle': 'Vehicle 3'},
          {'seatNumber': 10, 'isOccupied': false, 'vehicle': 'Vehicle 3'},
          {'seatNumber': 11, 'isOccupied': true, 'vehicle': 'Vehicle 3'},
          {'seatNumber': 12, 'isOccupied': false, 'vehicle': 'Vehicle 3'},
        ];

        // Extract unique vehicles
        vehicles = ['All', ...allSeats.map((seat) => seat['vehicle']).toSet()];

        // Initialize filtered seats
        _applyFilters();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Failed to load seat data';
      });
    }
  }

  Future<void> _loadTripData() async {
    try {
      final response = await http.get(
        Uri.parse('${EnvironmentConfig.baseUrl}/trips/available.php'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          setState(() {
            trips = List<Map<String, dynamic>>.from(data['trips']);
          });
        } else {
          throw Exception(data['message'] ?? 'Failed to load trips');
        }
      } else {
        throw Exception('Failed to load trips: ${response.statusCode}');
      }
    } catch (e) {
      // Fallback to mock trip data
      setState(() {
        trips = [
          {
            'route_details': 'Route A - Downtown',
            'trip_date': '2024-01-15',
            'start_time': '09:00 AM',
            'available_seats': 3,
            'seat_capacity': 8,
            'occupancy_status': 'available',
            'vehicle': 'Vehicle 1',
          },
          {
            'route_details': 'Route B - Airport',
            'trip_date': '2024-01-15',
            'start_time': '10:30 AM',
            'available_seats': 1,
            'seat_capacity': 8,
            'occupancy_status': 'limited',
            'vehicle': 'Vehicle 2',
          },
          {
            'route_details': 'Route C - University',
            'trip_date': '2024-01-15',
            'start_time': '11:00 AM',
            'available_seats': 2,
            'seat_capacity': 4,
            'occupancy_status': 'available',
            'vehicle': 'Vehicle 3',
          },
        ];
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _initializeWebSocket() {
    _seatSubscription = _webSocketService.seatStatusStream.listen((seatData) {
      if (mounted) {
        setState(() {
          final seatIndex = allSeats.indexWhere(
            (seat) =>
                seat['seatNumber'] == seatData['seatNumber'] &&
                seat['vehicle'] == seatData['vehicle'],
          );
          if (seatIndex != -1) {
            allSeats[seatIndex]['isOccupied'] = seatData['isOccupied'];
            _applyFilters();
          }
        });
      }
    });
  }

  void _applyFilters() {
    setState(() {
      filteredSeats = allSeats.where((seat) {
        final matchesVehicle =
            selectedVehicle == 'All' || seat['vehicle'] == selectedVehicle;
        final matchesSearch =
            searchQuery.isEmpty ||
            seat['seatNumber'].toString().contains(searchQuery.toLowerCase()) ||
            seat['vehicle'].toLowerCase().contains(searchQuery.toLowerCase());
        return matchesVehicle && matchesSearch;
      }).toList();
    });
  }

  @override
  void dispose() {
    _seatSubscription?.cancel();
    _webSocketService.dispose();
    super.dispose();
  }

  Future<void> _updateSeatStatus(
    int seatNumber,
    String vehicle,
    bool newStatus,
  ) async {
    try {
      // Update local state immediately for responsive UI
      setState(() {
        final seatIndex = allSeats.indexWhere(
          (seat) =>
              seat['seatNumber'] == seatNumber && seat['vehicle'] == vehicle,
        );
        if (seatIndex != -1) {
          allSeats[seatIndex]['isOccupied'] = newStatus;
          _applyFilters();
        }
      });

      // Simulate API call - replace with actual endpoint
      final response = await http.post(
        Uri.parse('http://192.168.1.7/transit/api/seats/update_status.php'),
        body: json.encode({
          'seatNumber': seatNumber,
          'vehicle': vehicle,
          'isOccupied': newStatus,
        }),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode != 200) {
        // Revert on error
        setState(() {
          final seatIndex = allSeats.indexWhere(
            (seat) =>
                seat['seatNumber'] == seatNumber && seat['vehicle'] == vehicle,
          );
          if (seatIndex != -1) {
            allSeats[seatIndex]['isOccupied'] = !newStatus;
            _applyFilters();
          }
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update seat status')),
        );
      }
    } catch (e) {
      // Revert on error
      setState(() {
        final seatIndex = allSeats.indexWhere(
          (seat) =>
              seat['seatNumber'] == seatNumber && seat['vehicle'] == vehicle,
        );
        if (seatIndex != -1) {
          allSeats[seatIndex]['isOccupied'] = !newStatus;
          _applyFilters();
        }
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    }
  }

  void _showSeatDetailsDialog(Map<String, dynamic> seat) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Seat ${seat['seatNumber']}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Vehicle: ${seat['vehicle']}'),
              const SizedBox(height: 8),
              Text(
                'Status: ${seat['isOccupied'] ? 'Occupied' : 'Available'}',
                style: TextStyle(
                  color: seat['isOccupied'] ? Colors.red : Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text('Tap the button below to change seat status:'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                _updateSeatStatus(
                  seat['seatNumber'],
                  seat['vehicle'],
                  !seat['isOccupied'],
                );
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: seat['isOccupied'] ? Colors.green : Colors.red,
              ),
              child: Text(
                seat['isOccupied'] ? 'Mark Available' : 'Mark Occupied',
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seat Monitoring'),
        backgroundColor: Colors.blue[800],
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _loadSeatData();
              _loadTripData();
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
          ? Center(child: Text(errorMessage))
          : RefreshIndicator(
              onRefresh: () async {
                await _loadSeatData();
                await _loadTripData();
              },
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSummarySection(),
                    const SizedBox(height: 20),
                    _buildSeatsGrid(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSummarySection() {
    final totalSeats = filteredSeats.length;
    final occupiedSeats = filteredSeats.where((s) => s['isOccupied']).length;
    final availableSeats = totalSeats - occupiedSeats;
    final occupancyRate = totalSeats > 0
        ? (occupiedSeats / totalSeats * 100).toStringAsFixed(1)
        : '0.0';

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Current Status',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildSummaryItem('Total', totalSeats.toString(), Colors.blue),
                _buildSummaryItem(
                  'Occupied',
                  occupiedSeats.toString(),
                  Colors.red,
                ),
                _buildSummaryItem(
                  'Available',
                  availableSeats.toString(),
                  Colors.green,
                ),
                _buildSummaryItem('Rate', '$occupancyRate%', Colors.orange),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildSeatsGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Real-time Seat Status',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              '${filteredSeats.length} seats',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (filteredSeats.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Text('No seats match your filters'),
            ),
          )
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 1,
            ),
            itemCount: filteredSeats.length,
            itemBuilder: (context, index) {
              final seat = filteredSeats[index];
              return _buildSeatCard(
                seat['seatNumber'],
                seat['isOccupied'],
                seat['vehicle'],
                allSeats.indexOf(seat),
              );
            },
          ),
      ],
    );
  }

  Widget _buildSeatCard(
    int seatNumber,
    bool isOccupied,
    String vehicle,
    int originalIndex,
  ) {
    final isHighlighted =
        searchQuery.isNotEmpty &&
        (seatNumber.toString().contains(searchQuery.toLowerCase()) ||
            vehicle.toLowerCase().contains(searchQuery.toLowerCase()));

    return GestureDetector(
      onTap: () {
        final seat = allSeats[originalIndex];
        _showSeatDetailsDialog(seat);
      },
      child: Card(
        elevation: isHighlighted ? 8 : 2,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: isOccupied
                ? Colors.red.withOpacity(0.1)
                : Colors.green.withOpacity(0.1),
            border: isHighlighted
                ? Border.all(color: Colors.blue, width: 2)
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.chair,
                size: 32,
                color: isOccupied ? Colors.red : Colors.green,
              ),
              const SizedBox(height: 4),
              // Text(
              //   'S$seatNumber',
              //   style: const TextStyle(
              //     fontSize: 14,
              //     fontWeight: FontWeight.bold,
              //   ),
              // ),
              // Text(
              //   vehicle,
              //   style: const TextStyle(fontSize: 10, color: Colors.grey),
              // ),
              const SizedBox(height: 4),
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: isOccupied ? Colors.red : Colors.green,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
