import 'package:flutter/material.dart';

class Trip {
  final String routeDetails;
  final DateTime tripDate;
  final String startTime;
  final int availableSeats;
  final int seatCapacity;
  final String occupancyStatus;
  final String? tripId;
  final String? driverName;
  final String? vehicleNumber;
  final String? vehicleType;
  final String? id;
  final String? driverId;

  Trip({
    required this.routeDetails,
    required this.tripDate,
    required this.startTime,
    required this.availableSeats,
    required this.seatCapacity,
    required this.occupancyStatus,
    this.tripId,
    this.driverName,
    this.vehicleNumber,
    this.vehicleType,
    this.id,
    this.driverId,
    required int currentOccupancy,
  });

  double get occupancyPercentage =>
      ((seatCapacity - availableSeats) / seatCapacity) * 100;

  bool get isAvailable => availableSeats > 0;
  bool get isFull => availableSeats == 0;

  String get currentOccupancy =>
      '${seatCapacity - availableSeats}/$seatCapacity';

  Color get occupancyColor {
    final percentage = occupancyPercentage;
    if (percentage < 50) return Colors.green;
    if (percentage < 80) return Colors.orange;
    return Colors.red;
  }

  String get formattedDate {
    return '${tripDate.day}/${tripDate.month}/${tripDate.year}';
  }

  String get formattedStartTime => startTime;

  Map<String, dynamic> toJson() {
    return {
      'route_details': routeDetails,
      'trip_date': tripDate.toIso8601String(),
      'start_time': startTime,
      'available_seats': availableSeats,
      'seat_capacity': seatCapacity,
      'occupancy_status': occupancyStatus,
      'trip_id': tripId,
      'driver_name': driverName,
      'vehicle_number': vehicleNumber,
      'vehicle_type': vehicleType,
      'id': id,
      'driver_id': driverId,
    };
  }

  factory Trip.fromJson(Map<String, dynamic> json) {
    return Trip(
      routeDetails: json['route_details'] as String,
      tripDate: DateTime.parse(json['trip_date'] as String),
      startTime: json['start_time'] as String,
      availableSeats: json['available_seats'] as int,
      seatCapacity: json['seat_capacity'] as int,
      occupancyStatus: json['occupancy_status'] as String,
      tripId: json['trip_id'] as String?,
      driverName: json['driver_name'] as String?,
      vehicleNumber: json['vehicle_number'] as String?,
      vehicleType: json['vehicle_type'] as String?,
      id: json['id'] as String?,
      driverId: json['driver_id'] as String?,
      currentOccupancy:
          (json['seat_capacity'] as int) - (json['available_seats'] as int),
    );
  }
}
