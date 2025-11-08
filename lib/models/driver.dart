class Driver {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String vehicleType;
  final String vehicleNumber;
  final double rating;
  final bool isAvailable;
  final String? profileImage;
  final double? latitude;
  final double? longitude;
  final DateTime? lastActive;

  Driver({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.vehicleType,
    required this.vehicleNumber,
    this.rating = 5.0,
    this.isAvailable = true,
    this.profileImage,
    this.latitude,
    this.longitude,
    this.lastActive,
  });

  factory Driver.fromJson(Map<String, dynamic> json) {
    return Driver(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      vehicleType: json['vehicle_type'] ?? 'Sedan',
      vehicleNumber: json['vehicle_number'] ?? '',
      rating: (json['rating'] ?? 5.0).toDouble(),
      isAvailable: json['is_available'] ?? true,
      profileImage: json['profile_image'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      lastActive: json['last_active'] != null 
          ? DateTime.parse(json['last_active']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'vehicle_type': vehicleType,
      'vehicle_number': vehicleNumber,
      'rating': rating,
      'is_available': isAvailable,
      'profile_image': profileImage,
      'latitude': latitude,
      'longitude': longitude,
      'last_active': lastActive?.toIso8601String(),
    };
  }

  String get displayName => '$name - $vehicleType ($vehicleNumber)';
}

class DriverAvailability {
  final int driverId;
  final DateTime date;
  final List<String> availableSlots;
  final bool isAvailable;

  DriverAvailability({
    required this.driverId,
    required this.date,
    required this.availableSlots,
    this.isAvailable = true,
  });

  factory DriverAvailability.fromJson(Map<String, dynamic> json) {
    return DriverAvailability(
      driverId: json['driver_id'] ?? 0,
      date: DateTime.parse(json['date']),
      availableSlots: List<String>.from(json['available_slots'] ?? []),
      isAvailable: json['is_available'] ?? true,
    );
  }
}
