import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import '../models/seat_device.dart';
import '../config/network_config.dart';

class SeatWebSocketServiceFixed {
  WebSocketChannel? _channel;
  Timer? _heartbeatTimer;
  Timer? _reconnectTimer;
  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 5;
  static const Duration _initialReconnectDelay = Duration(seconds: 1);
  
  final StreamController<List<SeatDevice>> _seatController = 
      StreamController<List<SeatDevice>>.broadcast();
  final StreamController<Map<String, dynamic>> _userLocationController = 
      StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<ConnectionStatus> _connectionStatusController = 
      StreamController<ConnectionStatus>.broadcast();

  Stream<List<SeatDevice>> get seatUpdates => _seatController.stream;
  Stream<Map<String, dynamic>> get userLocationUpdates => _userLocationController.stream;
  Stream<ConnectionStatus> get connectionStatus => _connectionStatusController.stream;

  void connect() {
    _connectionStatusController.add(ConnectionStatus.connecting);
    _performConnection();
  }

  void _performConnection() {
    try {
      final wsUrl = NetworkConfig.seatWebSocketUrl;
      print('Connecting to WebSocket: $wsUrl');
      
      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));
      
      _channel!.stream.listen(
        (message) {
          _handleMessage(message);
        },
        onError: (error) {
          print('WebSocket error: $error');
          _handleConnectionError(error);
        },
        onDone: () {
          print('WebSocket connection closed');
          _handleDisconnection();
        },
      );

      // Send initial connection message
      _channel!.sink.add(jsonEncode({
        'type': 'connect',
        'client_type': 'mobile_app'
      }));

      _connectionStatusController.add(ConnectionStatus.connected);
      _reconnectAttempts = 0;
      _startHeartbeat();
      
    } catch (e) {
      print('Failed to connect to WebSocket: $e');
      _connectionStatusController.add(ConnectionStatus.error);
      _scheduleReconnect();
    }
  }

  void _handleMessage(String message) {
    try {
      final data = jsonDecode(message);
      
      if (data['type'] == 'seat_update') {
        final seats = (data['seats'] as List)
            .map((seat) => SeatDevice.fromJson(seat))
            .toList();
        _seatController.add(seats);
      } else if (data['type'] == 'user_location') {
        _userLocationController.add(data);
      }
    } catch (e) {
      print('Error parsing message: $e');
    }
  }

  void _handleConnectionError(dynamic error) {
    _connectionStatusController.add(ConnectionStatus.error);
    _scheduleReconnect();
  }

  void _handleDisconnection() {
    _connectionStatusController.add(ConnectionStatus.disconnected);
    _scheduleReconnect();
  }

  void _scheduleReconnect() {
    if (_reconnectAttempts >= _maxReconnectAttempts) {
      print('Max reconnect attempts reached, giving up');
      _connectionStatusController.add(ConnectionStatus.failed);
      return;
    }

    final delay = _initialReconnectDelay * (1 << _reconnectAttempts);
    _reconnectAttempts++;
    
    print('Scheduling reconnect in ${delay.inSeconds} seconds (attempt $_reconnectAttempts)');
    
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(delay, () {
      if (_channel == null || _channel!.closeCode != null) {
        _connectionStatusController.add(ConnectionStatus.reconnecting);
        _performConnection();
      }
    });
  }

  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (_channel != null && _connectionStatusController.hasListener) {
        try {
          _channel!.sink.add(jsonEncode({'type': 'ping'}));
        } catch (e) {
          print('Heartbeat failed: $e');
          _heartbeatTimer?.cancel();
          _scheduleReconnect();
        }
      }
    });
  }

  void sendSeatStatus(String seatId, bool isOccupied) {
    if (_channel != null && _connectionStatusController.hasListener) {
      try {
        _channel!.sink.add(jsonEncode({
          'type': 'seat_status',
          'seat_id': seatId,
          'occupied': isOccupied,
          'timestamp': DateTime.now().toIso8601String()
        }));
      } catch (e) {
        print('Failed to send seat status: $e');
      }
    }
  }

  void sendUserLocation(String userId, double lat, double lng) {
    if (_channel != null && _connectionStatusController.hasListener) {
      try {
        _channel!.sink.add(jsonEncode({
          'type': 'user_location',
          'user_id': userId,
          'latitude': lat,
          'longitude': lng,
          'timestamp': DateTime.now().toIso8601String()
        }));
      } catch (e) {
        print('Failed to send user location: $e');
      }
    }
  }

  void disconnect() {
    _heartbeatTimer?.cancel();
    _reconnectTimer?.cancel();
    _channel?.sink.close(status.goingAway);
    _channel = null;
    _connectionStatusController.add(ConnectionStatus.disconnected);
  }

  void dispose() {
    disconnect();
    _seatController.close();
    _userLocationController.close();
    _connectionStatusController.close();
  }
}

enum ConnectionStatus {
  disconnected,
  connecting,
  connected,
  reconnecting,
  error,
  failed,
}
