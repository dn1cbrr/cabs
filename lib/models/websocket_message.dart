/// Standardized WebSocket message protocol for seat monitoring system
library;

import 'dart:convert';

/// Base message type for all WebSocket communications
abstract class WebSocketMessage {
  final String type;
  final int timestamp;

  WebSocketMessage({required this.type, int? timestamp})
    : timestamp = timestamp ?? DateTime.now().millisecondsSinceEpoch;

  Map<String, dynamic> toJson();
  String toJsonString() => jsonEncode(toJson());
}

/// Seat status update message
class SeatStatusMessage extends WebSocketMessage {
  final String seatId;
  final bool isOccupied;
  final double? sensorValue;
  final String? timestampStr;

  SeatStatusMessage({
    required this.seatId,
    required this.isOccupied,
    this.sensorValue,
    this.timestampStr,
  }) : super(type: 'seat_status');

  factory SeatStatusMessage.fromJson(Map<String, dynamic> json) {
    return SeatStatusMessage(
      seatId: json['seat_id'] as String,
      isOccupied: json['occupied'] as bool,
      sensorValue: json['sensor_value'] as double?,
      timestampStr: json['timestamp']?.toString(),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'seat_id': seatId,
    'occupied': isOccupied,
    'sensor_value': sensorValue,
    'timestamp': timestampStr ?? DateTime.now().toIso8601String(),
  };
}

/// User location update message
class UserLocationMessage extends WebSocketMessage {
  final String userId;
  final double latitude;
  final double longitude;
  final double? accuracy;

  UserLocationMessage({
    required this.userId,
    required this.latitude,
    required this.longitude,
    this.accuracy,
  }) : super(type: 'user_location');

  factory UserLocationMessage.fromJson(Map<String, dynamic> json) {
    return UserLocationMessage(
      userId: json['user_id'] as String,
      latitude: json['latitude'] as double,
      longitude: json['longitude'] as double,
      accuracy: json['accuracy'] as double?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'user_id': userId,
    'latitude': latitude,
    'longitude': longitude,
    'accuracy': accuracy,
    'timestamp': DateTime.now().toIso8601String(),
  };
}

/// Connection heartbeat message
class HeartbeatMessage extends WebSocketMessage {
  final String clientId;
  final bool isAlive;

  HeartbeatMessage({required this.clientId, this.isAlive = true})
    : super(type: 'heartbeat');

  factory HeartbeatMessage.fromJson(Map<String, dynamic> json) {
    return HeartbeatMessage(
      clientId: json['client_id'] as String,
      isAlive: json['is_alive'] as bool? ?? true,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'client_id': clientId,
    'is_alive': isAlive,
    'timestamp': DateTime.now().toIso8601String(),
  };
}

/// Error message
class ErrorMessage extends WebSocketMessage {
  final String error;
  final String? details;

  ErrorMessage({required this.error, this.details}) : super(type: 'error');

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'error': error,
    'details': details,
    'timestamp': DateTime.now().toIso8601String(),
  };
}

/// Connection control message
class ConnectionMessage extends WebSocketMessage {
  final String action;
  final String clientType;
  final String? clientId;

  ConnectionMessage({
    required this.action,
    required this.clientType,
    this.clientId,
  }) : super(type: 'connection');

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'action': action,
    'client_type': clientType,
    'client_id': clientId,
    'timestamp': DateTime.now().toIso8601String(),
  };
}
