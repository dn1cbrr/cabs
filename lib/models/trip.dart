import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Trip {
  final int id;
  final int driverId;
  final String driverName;
  final String routeDetails;
  final String vehicleType;
  final int seatCapacity;
  final int currentOccupancy;
  final String occupancyStatus;
  final int availableSeats;
  final DateTime tripDate;
  final String startTime;

  Trip({
    required this.id,
    required this.driverId,
    required this.driverName,
    required this.routeDetails,
    required this.vehicleType,
    required this.seatCapacity,
    required this.currentOccupancy,
    required this.occupancyStatus,
    required this.availableSeats,
    required this.tripDate,
    required this.startTime,
  });

  factory Trip.fromJson(Map<String, dynamic> json) {
    // Defensive parsing with null checks and default values
    final seatCap = (json['seat_capacity'] ?? 0) as int;
    final currentOcc = (json['current_occupancy'] ?? 0) as int;

    return Trip(
      id: (json['id'] ?? 0) as int,
      driverId: (json['driver_id'] ?? 0) as int,
      driverName: json['driver_name'] as String? ?? 'N/A',
      routeDetails: json['route_details'] as String? ?? 'No route details',
      vehicleType: json['vehicle_type'] as String? ?? 'Standard',
      seatCapacity: seatCap,
      currentOccupancy: currentOcc,
      occupancyStatus: json['occupancy_status'] as String? ?? 'available',
      availableSeats: seatCap - currentOcc,
      tripDate:
          DateTime.tryParse(json['trip_date'] as String? ?? '') ?? DateTime.now(),
      startTime: json['start_time'] as String? ?? '00:00:00',
    );
  }

  String get formattedDate => DateFormat('MMM d, yyyy').format(tripDate);

  String get formattedStartTime {
    try {
      final parsedTime = DateFormat.Hms().parse(startTime); // Assuming 'HH:mm:ss'
      return DateFormat.jm().format(parsedTime); // e.g., '5:08 PM'
    } catch (e) {
      try {
        final parsedTime =
            DateFormat.Hm().parse(startTime); // Fallback for 'HH:mm'
        return DateFormat.jm().format(parsedTime);
      } catch (e) {
        return startTime; // Return raw string if parsing fails
      }
    }
  }

  double get occupancyPercentage {
    if (seatCapacity <= 0) {
      return 0.0;
    }
    return currentOccupancy / seatCapacity;
  }

  Color get occupancyColor {
    final percentage = occupancyPercentage;
    if (percentage >= 1.0) {
      return Colors.red.shade700;
    } else if (percentage >= 0.8) {
      return Colors.orange.shade700;
    }
    return Colors.green.shade700;
  }

  String get occupancyDisplay => '$currentOccupancy / $seatCapacity';

  bool get isAvailable => currentOccupancy < seatCapacity;
}
