import 'package:flutter/material.dart';

enum SeatStatus { available, occupied, reserved, maintenance, blocked }

enum SeatType { regular, premium, accessible, emergency }

class Seat {
  final String id;
  final String vehicleId;
  final String vehicleName;
  final String route;
  final int seatNumber;
  final SeatStatus status;
  final SeatType type;
  final double price;
  final String? deviceId;
  final DateTime? lastUpdated;
  final List<Booking> bookingHistory;
  final Map<String, dynamic> metadata;

  Seat({
    required this.id,
    required this.vehicleId,
    required this.vehicleName,
    required this.route,
    required this.seatNumber,
    required this.status,
    required this.type,
    required this.price,
    this.deviceId,
    this.lastUpdated,
    this.bookingHistory = const [],
    this.metadata = const {},
  });

  Seat copyWith({
    String? id,
    String? vehicleId,
    String? vehicleName,
    String? route,
    int? seatNumber,
    SeatStatus? status,
    SeatType? type,
    double? price,
    String? deviceId,
    DateTime? lastUpdated,
    List<Booking>? bookingHistory,
    Map<String, dynamic>? metadata,
  }) {
    return Seat(
      id: id ?? this.id,
      vehicleId: vehicleId ?? this.vehicleId,
      vehicleName: vehicleName ?? this.vehicleName,
      route: route ?? this.route,
      seatNumber: seatNumber ?? this.seatNumber,
      status: status ?? this.status,
      type: type ?? this.type,
      price: price ?? this.price,
      deviceId: deviceId ?? this.deviceId,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      bookingHistory: bookingHistory ?? this.bookingHistory,
      metadata: metadata ?? this.metadata,
    );
  }

  factory Seat.fromJson(Map<String, dynamic> json) {
    return Seat(
      id: json['id'],
      vehicleId: json['vehicleId'],
      vehicleName: json['vehicleName'],
      route: json['route'],
      seatNumber: json['seatNumber'],
      status: SeatStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => SeatStatus.available,
      ),
      type: SeatType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () => SeatType.regular,
      ),
      price: json['price']?.toDouble() ?? 0.0,
      deviceId: json['deviceId'],
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.parse(json['lastUpdated'])
          : null,
      bookingHistory: (json['bookingHistory'] as List? ?? [])
          .map((e) => Booking.fromJson(e))
          .toList(),
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vehicleId': vehicleId,
      'vehicleName': vehicleName,
      'route': route,
      'seatNumber': seatNumber,
      'status': status.toString().split('.').last,
      'type': type.toString().split('.').last,
      'price': price,
      'deviceId': deviceId,
      'lastUpdated': lastUpdated?.toIso8601String(),
      'bookingHistory': bookingHistory.map((e) => e.toJson()).toList(),
      'metadata': metadata,
    };
  }

  Color get statusColor {
    switch (status) {
      case SeatStatus.available:
        return Colors.green;
      case SeatStatus.occupied:
        return Colors.red;
      case SeatStatus.reserved:
        return Colors.orange;
      case SeatStatus.maintenance:
        return Colors.grey;
      case SeatStatus.blocked:
        return Colors.black;
    }
  }

  String get statusLabel {
    switch (status) {
      case SeatStatus.available:
        return 'Available';
      case SeatStatus.occupied:
        return 'Occupied';
      case SeatStatus.reserved:
        return 'Reserved';
      case SeatStatus.maintenance:
        return 'Maintenance';
      case SeatStatus.blocked:
        return 'Blocked';
    }
  }

  IconData get typeIcon {
    switch (type) {
      case SeatType.regular:
        return Icons.event_seat;
      case SeatType.premium:
        return Icons.airline_seat_recline_extra;
      case SeatType.accessible:
        return Icons.accessible;
      case SeatType.emergency:
        return Icons.warning;
    }
  }
}

class Booking {
  final String id;
  final String seatId;
  final String passengerName;
  final String passengerEmail;
  final String passengerPhone;
  final DateTime bookingTime;
  final DateTime? checkInTime;
  final DateTime? checkOutTime;
  final double amountPaid;
  final String paymentMethod;
  final BookingStatus status;
  final String? notes;

  Booking({
    required this.id,
    required this.seatId,
    required this.passengerName,
    required this.passengerEmail,
    required this.passengerPhone,
    required this.bookingTime,
    this.checkInTime,
    this.checkOutTime,
    required this.amountPaid,
    required this.paymentMethod,
    required this.status,
    this.notes,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'],
      seatId: json['seatId'],
      passengerName: json['passengerName'],
      passengerEmail: json['passengerEmail'],
      passengerPhone: json['passengerPhone'],
      bookingTime: DateTime.parse(json['bookingTime']),
      checkInTime: json['checkInTime'] != null
          ? DateTime.parse(json['checkInTime'])
          : null,
      checkOutTime: json['checkOutTime'] != null
          ? DateTime.parse(json['checkOutTime'])
          : null,
      amountPaid: json['amountPaid']?.toDouble() ?? 0.0,
      paymentMethod: json['paymentMethod'],
      status: BookingStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => BookingStatus.confirmed,
      ),
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'seatId': seatId,
      'passengerName': passengerName,
      'passengerEmail': passengerEmail,
      'passengerPhone': passengerPhone,
      'bookingTime': bookingTime.toIso8601String(),
      'checkInTime': checkInTime?.toIso8601String(),
      'checkOutTime': checkOutTime?.toIso8601String(),
      'amountPaid': amountPaid,
      'paymentMethod': paymentMethod,
      'status': status.toString().split('.').last,
      'notes': notes,
    };
  }
}

enum BookingStatus {
  pending,
  confirmed,
  checkedIn,
  completed,
  cancelled,
  noShow,
}
