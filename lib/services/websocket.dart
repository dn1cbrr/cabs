import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;

class WebSocketService {
  static final WebSocketService _instance = WebSocketService._internal();
  factory WebSocketService() => _instance;
  WebSocketService._internal();

  WebSocketChannel? _channel;
  Timer? _reconnectTimer;
  bool _isConnected = false;

  // ⚡ Update IP and path to match your ESP32 setup
  final String _serverUrl = 'ws://192.168.1.2:81/ws';
  final int _reconnectInterval = 5; // seconds

  // Stream controllers
  final StreamController<Map<String, dynamic>> _seatStatusController =
      StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<String> _connectionStatusController =
      StreamController<String>.broadcast();

  // Public streams
  Stream<Map<String, dynamic>> get seatStatusStream =>
      _seatStatusController.stream;
  Stream<String> get connectionStatusStream =>
      _connectionStatusController.stream;

  bool get isConnected => _isConnected;

  Future<void> connect() async {
    try {
      _channel = WebSocketChannel.connect(Uri.parse(_serverUrl));
      _isConnected = true;
      _connectionStatusController.add('Connected');

      print('✅ WebSocket connected to ESP32');

      // Listen for messages
      _channel!.stream.listen(
        _onMessage,
        onError: _onError,
        onDone: _onConnectionClosed,
      );

      // Cancel any existing reconnect timer
      _reconnectTimer?.cancel();
    } catch (e) {
      print('❌ WebSocket connection error: $e');
      _isConnected = false;
      _connectionStatusController.add('Connection Failed');
      _scheduleReconnect();
    }
  }

  void disconnect() {
    _reconnectTimer?.cancel();
    _channel?.sink.close(status.goingAway);
    _isConnected = false;
    _connectionStatusController.add('Disconnected');
  }

  void _onMessage(dynamic message) {
    try {
      final data = jsonDecode(message);
      print('📩 Received from ESP32: $data');

      if (data['type'] == 'seat_status') {
        _seatStatusController.add(Map<String, dynamic>.from(data));
      }
    } catch (e) {
      print('⚠️ Error parsing message: $e');
    }
  }

  void _onError(error) {
    print('⚠️ WebSocket error: $error');
    _isConnected = false;
    _connectionStatusController.add('Error: $error');
    _scheduleReconnect();
  }

  void _onConnectionClosed() {
    print('🔌 WebSocket connection closed');
    _isConnected = false;
    _connectionStatusController.add('Disconnected');
    _scheduleReconnect();
  }

  void _scheduleReconnect() {
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer.periodic(Duration(seconds: _reconnectInterval), (
      timer,
    ) {
      if (!_isConnected) {
        print('🔄 Attempting to reconnect...');
        connect();
      } else {
        timer.cancel();
      }
    });
  }

  // Send message to ESP32
  void sendMessage(Map<String, dynamic> message) {
    if (_isConnected && _channel != null) {
      final jsonString = jsonEncode(message);
      _channel!.sink.add(jsonString);
      print('📤 Sent: $jsonString');
    }
  }

  // Request current status
  void requestStatus() {
    sendMessage({'type': 'get_status'});
  }

  // Update sensor threshold
  void updateThreshold(int threshold) {
    sendMessage({'type': 'set_threshold', 'threshold': threshold});
  }

  void dispose() {
    disconnect();
    _seatStatusController.close();
    _connectionStatusController.close();
  }
}
