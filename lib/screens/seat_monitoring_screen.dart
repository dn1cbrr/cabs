import 'package:flutter/material.dart';
import 'dart:async';
import '../services/seat_websocket_service.dart';
import '../models/seat_device.dart';
import '../widgets/visual_chair_widget.dart';

class SeatMonitoringScreen extends StatefulWidget {
  const SeatMonitoringScreen({super.key});

  @override
  State<SeatMonitoringScreen> createState() => _SeatMonitoringScreenState();
}

class _SeatMonitoringScreenState extends State<SeatMonitoringScreen> {
  late SeatWebSocketService _webSocketService;
  StreamSubscription<List<SeatDevice>>? _seatDataSubscription;
  
  SeatDevice? _currentSeatData;
  bool _isConnected = false;
  bool _isConnecting = false;

  @override
  void initState() {
    super.initState();
    _webSocketService = SeatWebSocketService();
    _initializeWebSocket();
  }

  void _initializeWebSocket() {
    // Listen to seat data updates
    _seatDataSubscription = _webSocketService.seatUpdates.listen((seats) {
      if (seats.isNotEmpty && mounted) {
        setState(() {
          _currentSeatData = seats.first;
          _isConnected = true;
          _isConnecting = false;
        });
      }
    });

    // Connect to WebSocket
    _connectToWebSocket();
  }

  void _connectToWebSocket() {
    if (mounted) {
      setState(() {
        _isConnecting = true;
      });
    }
    
    try {
      _webSocketService.connect();
    } catch (e) {
      if (mounted) {
        setState(() {
          _isConnected = false;
          _isConnecting = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to connect to ESP32: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _requestSeatStatus() {
    // This would need to be implemented in the WebSocket service
    // For now, we'll just reconnect to refresh data
    _reconnect();
  }

  void _reconnect() {
    _webSocketService.disconnect();
    _connectToWebSocket();
  }

  @override
  void dispose() {
    _seatDataSubscription?.cancel();
    _webSocketService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seat Monitoring'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _requestSeatStatus,
            tooltip: 'Refresh Status',
          ),
          IconButton(
            icon: const Icon(Icons.settings_ethernet),
            onPressed: _reconnect,
            tooltip: 'Reconnect',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Connection Status Card
            _buildConnectionStatusCard(),
            const SizedBox(height: 16),
            
            // Device Info Card (if connected)
            if (_currentSeatData != null) _buildDeviceInfoCard(),
            if (_currentSeatData != null) const SizedBox(height: 16),
            
            // Seat Legend
            const SeatLegend(),
            const SizedBox(height: 24),
            
            // Seat Visualization
            Expanded(
              child: _buildSeatVisualization(),
            ),
            
            // Statistics
            if (_currentSeatData != null) _buildStatistics(),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectionStatusCard() {
    Color statusColor;
    String statusText;
    IconData statusIcon;

    if (_isConnecting) {
      statusColor = Colors.orange;
      statusText = 'Connecting to ESP32...';
      statusIcon = Icons.sync;
    } else if (_isConnected) {
      statusColor = Colors.green;
      statusText = 'Connected to ESP32';
      statusIcon = Icons.wifi;
    } else {
      statusColor = Colors.red;
      statusText = 'Disconnected from ESP32';
      statusIcon = Icons.wifi_off;
    }

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(statusIcon, color: statusColor, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    statusText,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: statusColor,
                    ),
                  ),
                  if (_currentSeatData != null)
                    Text(
                      'Last update: ${_formatTimestamp(_currentSeatData!.timestamp)}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                ],
              ),
            ),
            if (_isConnecting)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceInfoCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Device Information',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.device_hub, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text('Name: ${_currentSeatData!.name}'),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.location_on, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text('Address: ${_currentSeatData!.address}'),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.fingerprint, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text('ID: ${_currentSeatData!.id}'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeatVisualization() {
    if (_currentSeatData == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chair_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              _isConnected 
                ? 'Waiting for seat data...' 
                : 'Connect to ESP32 to view seat status',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            if (!_isConnected && !_isConnecting) ...[
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _connectToWebSocket,
                icon: const Icon(Icons.wifi),
                label: const Text('Connect to ESP32'),
              ),
            ],
          ],
        ),
      );
    }

    // Display 4 seats in a 2x2 grid layout
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'UV Seat Layout',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 24),
        
        // Row 1: Seats 1 and 2
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            VisualChairWidget(
              seatId: 'seat_1',
              isAvailable: _currentSeatData!.seat1 == 0,
              onStatusChanged: (isAvailable) => _showSeatDetails(1, !isAvailable),
            ),
            VisualChairWidget(
              seatId: 'seat_2',
              isAvailable: _currentSeatData!.seat2 == 0,
              onStatusChanged: (isAvailable) => _showSeatDetails(2, !isAvailable),
            ),
          ],
        ),
        
        const SizedBox(height: 20),
        
        // Aisle indicator
        Container(
          width: 100,
          height: 2,
          color: Colors.grey.shade400,
        ),
        const Text(
          'Aisle',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
        
        const SizedBox(height: 20),
        
        // Row 2: Seats 3 and 4
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            VisualChairWidget(
              seatId: 'seat_3',
              isAvailable: _currentSeatData!.seat3 == 0,
              onStatusChanged: (isAvailable) => _showSeatDetails(3, !isAvailable),
            ),
            VisualChairWidget(
              seatId: 'seat_4',
              isAvailable: _currentSeatData!.seat4 == 0,
              onStatusChanged: (isAvailable) => _showSeatDetails(4, !isAvailable),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatistics() {
    if (_currentSeatData == null) return const SizedBox.shrink();
    
    final occupiedCount = _currentSeatData!.occupiedSeats;
    final availableCount = _currentSeatData!.availableSeats;
    final totalSeats = 4;
    final occupancyPercentage = (occupiedCount / totalSeats * 100).round();

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Occupancy Statistics',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('Occupied', occupiedCount, Colors.red),
                _buildStatItem('Available', availableCount, Colors.green),
                _buildStatItem('Total', totalSeats, Colors.blue),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: occupiedCount / totalSeats,
              backgroundColor: Colors.grey.shade300,
              valueColor: AlwaysStoppedAnimation<Color>(
                occupancyPercentage > 75 ? Colors.red : 
                occupancyPercentage > 50 ? Colors.orange : Colors.green,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$occupancyPercentage% Occupied',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, int value, Color color) {
    return Column(
      children: [
        Text(
          '$value',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  void _showSeatDetails(int seatNumber, bool isOccupied) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Seat $seatNumber'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.chair,
              size: 48,
              color: isOccupied ? Colors.red : Colors.green,
            ),
            const SizedBox(height: 16),
            Text(
              'Status: ${isOccupied ? 'Occupied' : 'Available'}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isOccupied ? Colors.red : Colors.green,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Last updated: ${_formatTimestamp(_currentSeatData!.timestamp)}',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inSeconds < 60) {
      return '${difference.inSeconds}s ago';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else {
      return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    }
  }
}

class SeatLegend extends StatelessWidget {
  const SeatLegend({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLegendItem('Available', Colors.green),
            const SizedBox(width: 16),
            _buildLegendItem('Occupied', Colors.red),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }
}
