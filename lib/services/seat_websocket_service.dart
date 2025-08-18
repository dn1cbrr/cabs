import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import '../models/seat_device.dart';
import 'package:logging/logging.dart';

final Logger _logger = Logger('SeatWebSocketService');

class SeatWebSocketService {
  static const String _wsUrl = 'ws://192.168.1.2:8080/seats'; // Change this to your ESP32 IP
  WebSocketChannel? _channel;
  Timer? _heartbeatTimer;
  final StreamController<List<SeatDevice>> _seatController = StreamController<List<SeatDevice>>.broadcast();
  final StreamController<Map<String, dynamic>> _userLocationController = StreamController<Map<String, dynamic>>.broadcast();

  Stream<List<SeatDevice>> get seatUpdates => _seatController.stream;
  Stream<Map<String, dynamic>> get userLocationUpdates => _userLocationController.stream;

  void connect() {
    try {
      _channel = WebSocketChannel.connect(Uri.parse(_wsUrl));
      
      _channel!.stream.listen(
        (message) {
          final data = jsonDecode(message);
          
          if (data['type'] == 'seat_update') {
            final seats = (data['seats'] as List)
                .map((seat) => SeatDevice.fromJson(seat))
                .toList();
            _seatController.add(seats);
          } else if (data['type'] == 'user_location') {
            _userLocationController.add(data);
          }
        },
        onError: (error) {
          print('WebSocket error: $error');
          _reconnect();
        },
        onDone: () {
          print('WebSocket connection closed');
          _reconnect();
        },
      );

      // Send initial connection message
      _channel!.sink.add(jsonEncode({
        'type': 'connect',
        'client_type': 'mobile_app'
      }));

      // Start heartbeat
      _startHeartbeat();
    } catch (e) {
      print('Failed to connect to WebSocket: $e');
      _reconnect();
    }
  }

  void _reconnect() {
    Future.delayed(const Duration(seconds: 3), () {
      if (_channel == null || _channel!.closeCode != null) {
        connect();
      }
    });
  }

  void _startHeartbeat() {
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (_channel != null) {
        _channel!.sink.add(jsonEncode({'type': 'ping'}));
      }
    });
  }

  void sendSeatStatus(String seatId, bool isOccupied) {
    if (_channel != null) {
      _channel!.sink.add(jsonEncode({
        'type': 'seat_status',
        'seat_id': seatId,
        'occupied': isOccupied,
        'timestamp': DateTime.now().toIso8601String()
      }));
    }
  }

  void sendUserLocation(String userId, double lat, double lng) {
    if (_channel != null) {
      _channel!.sink.add(jsonEncode({
        'type': 'user_location',
        'user_id': userId,
        'latitude': lat,
        'longitude': lng,
        'timestamp': DateTime.now().toIso8601String()
      }));
    }
  }

  void disconnect() {
    _heartbeatTimer?.cancel();
    _channel?.sink.close(status.goingAway);
    _channel = null;
  }

  void dispose() {
    disconnect();
    _seatController.close();
    _userLocationController.close();
  }
}
