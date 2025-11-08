class OccupancyData {
  final String deviceId;
  final int totalSeats;
  final int occupiedSeats;
  final int availableSeats;
  final double occupancyPercentage;
  final DateTime lastUpdated;
  final DateTime lastUpdate;

  OccupancyData({
    required this.deviceId,
    required this.totalSeats,
    required this.occupiedSeats,
    required this.availableSeats,
    required this.occupancyPercentage,
    required this.lastUpdated,
    DateTime? lastUpdate,
  }) : lastUpdate = lastUpdate ?? lastUpdated;

  factory OccupancyData.fromJson(Map<String, dynamic> json) {
    return OccupancyData(
      deviceId: json['device_id'] ?? '',
      totalSeats: json['total_seats'] ?? 0,
      occupiedSeats: json['occupied_seats'] ?? 0,
      availableSeats: json['available_seats'] ?? 0,
      occupancyPercentage: (json['occupancy_percentage'] ?? 0.0).toDouble(),
      lastUpdated: json['last_updated'] != null
          ? DateTime.parse(json['last_updated'])
          : DateTime.now(),
      lastUpdate: json['last_update'] != null
          ? DateTime.parse(json['last_update'])
          : DateTime.now(),
    );
  }

  factory OccupancyData.fromSeat(
    String deviceId,
    int totalSeats,
    int occupiedSeats,
  ) {
    return OccupancyData(
      deviceId: deviceId,
      totalSeats: totalSeats,
      occupiedSeats: occupiedSeats,
      availableSeats: totalSeats - occupiedSeats,
      occupancyPercentage: totalSeats > 0
          ? (occupiedSeats / totalSeats) * 100
          : 0,
      lastUpdated: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'device_id': deviceId,
      'total_seats': totalSeats,
      'occupied_seats': occupiedSeats,
      'available_seats': availableSeats,
      'occupancy_percentage': occupancyPercentage,
      'last_updated': lastUpdated.toIso8601String(),
      'last_update': lastUpdate.toIso8601String(),
    };
  }

  bool get isAvailable => occupiedSeats < totalSeats;
  bool get isFull => occupiedSeats >= totalSeats;
}
