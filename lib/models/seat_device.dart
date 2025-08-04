class SeatDevice {
  final String id;
  final String name;
  final String address;
  final int seat1;
  final int seat2;
  final int seat3;
  final int seat4;
  final DateTime timestamp;

  SeatDevice({
    required this.id,
    required this.name,
    required this.address,
    required this.seat1,
    required this.seat2,
    required this.seat3,
    required this.seat4,
    required this.timestamp,
  });

  factory SeatDevice.fromJson(Map<String, dynamic> json) {
    return SeatDevice(
      id: json['id'] ?? '',
      name: json['name'] ?? 'Unknown Device',
      address: json['address'] ?? '',
      seat1: json['seat1'] ?? 0,
      seat2: json['seat2'] ?? 0,
      seat3: json['seat3'] ?? 0,
      seat4: json['seat4'] ?? 0,
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp'] ?? 0),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'seat1': seat1,
      'seat2': seat2,
      'seat3': seat3,
      'seat4': seat4,
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }

  int get occupiedSeats => seat1 + seat2 + seat3 + seat4;
  int get availableSeats => 4 - occupiedSeats;
  bool get isFull => occupiedSeats >= 4;
  bool get hasAvailableSeats => availableSeats > 0;

  @override
  String toString() {
    return 'SeatDevice(id: $id, name: $name, occupied: $occupiedSeats/4)';
  }
}
