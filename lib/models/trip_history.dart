class TripHistory {
  final int id;
  final int driverId;
  final String driverName;
  final String licenseNumber;
  final String vehicleType;
  final String plateNumber;
  final DateTime tripDate;
  final DateTime startTime;
  final DateTime? endTime;
  final String routeDetails;
  final int totalPassengers;
  final DateTime createdAt;
  final DateTime updatedAt;

  TripHistory({
    required this.id,
    required this.driverId,
    required this.driverName,
    required this.licenseNumber,
    required this.vehicleType,
    required this.plateNumber,
    required this.tripDate,
    required this.startTime,
    this.endTime,
    required this.routeDetails,
    required this.totalPassengers,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TripHistory.fromJson(Map<String, dynamic> json) {
    return TripHistory(
      id: json['id'],
      driverId: json['driver_id'],
      driverName: json['driver_name'] ?? '',
      licenseNumber: json['license_number'] ?? '',
      vehicleType: json['vehicle_type'] ?? '',
      plateNumber: json['plate_number'] ?? '',
      tripDate: DateTime.parse(json['trip_date']),
      startTime: DateTime.parse(json['start_time']),
      endTime: json['end_time'] != null ? DateTime.parse(json['end_time']) : null,
      routeDetails: json['route_details'] ?? '',
      totalPassengers: json['total_passengers'] ?? 0,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'driver_id': driverId,
      'driver_name': driverName,
      'license_number': licenseNumber,
      'vehicle_type': vehicleType,
      'plate_number': plateNumber,
      'trip_date': tripDate.toIso8601String().split('T')[0],
      'start_time': startTime.toIso8601String(),
      'end_time': endTime?.toIso8601String(),
      'route_details': routeDetails,
      'total_passengers': totalPassengers,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  String get formattedDuration {
    if (endTime == null) return 'In Progress';
    
    final duration = endTime!.difference(startTime);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }

  String get formattedDate {
    return '${tripDate.day}/${tripDate.month}/${tripDate.year}';
  }

  String get formattedStartTime {
    return '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}';
  }

  String get formattedEndTime {
    return endTime != null 
        ? '${endTime!.hour.toString().padLeft(2, '0')}:${endTime!.minute.toString().padLeft(2, '0')}'
        : 'In Progress';
  }
}
