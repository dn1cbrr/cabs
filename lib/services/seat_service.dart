import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/seat.dart';
import '../models/trip.dart';

class SeatService {
  static const String baseUrl = 'http://localhost/transit/api';

  final StreamController<List<Seat>> _seatController =
      StreamController<List<Seat>>.broadcast();
  final StreamController<List<Trip>> _tripController =
      StreamController<List<Trip>>.broadcast();

  Stream<List<Seat>> get occupancyStream => _seatController.stream;
  Stream<List<Trip>> get tripStream => _tripController.stream;

  Timer? _updateTimer;

  Future<List<Seat>> getSeatsByVehicle(String vehicleId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/seats.php?vehicle_id=$vehicleId'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final seats = (data['seats'] as List)
              .map((seat) => Seat.fromJson(seat))
              .toList();
          _seatController.add(seats);
          return seats;
        }
      }
      return [];
    } catch (e) {
      print('Error fetching seats: $e');
      return [];
    }
  }

  Future<List<Seat>> fetchOccupancyData(String vehicleId) async {
    return await getSeatsByVehicle(vehicleId);
  }

  Future<bool> updateSeatStatus(Seat seat) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/seats.php'),
        body: json.encode(seat.toJson()),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] == true;
      }
      return false;
    } catch (e) {
      print('Error updating seat: $e');
      return false;
    }
  }

  Future<List<Trip>> getTrips() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/trips.php'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final trips = (data['trips'] as List)
              .map((trip) => Trip.fromJson(trip))
              .toList();
          _tripController.add(trips);
          return trips;
        }
      }
      return [];
    } catch (e) {
      print('Error fetching trips: $e');
      return [];
    }
  }

  Future<bool> updateTripOccupancy(String tripId, int availableSeats) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/trips.php'),
        body: json.encode({
          'trip_id': tripId,
          'available_seats': availableSeats,
        }),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] == true;
      }
      return false;
    } catch (e) {
      print('Error updating trip: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>> getOccupancyForDevice(String deviceId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/device_occupancy.php?device_id=$deviceId'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return data;
        }
      }
      return {};
    } catch (e) {
      print('Error fetching device occupancy: $e');
      return {};
    }
  }

  void startRealTimeUpdates(String vehicleId) {
    _updateTimer?.cancel();
    _updateTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      fetchOccupancyData(vehicleId);
      getTrips();
    });
  }

  void dispose() {
    _updateTimer?.cancel();
    _seatController.close();
    _tripController.close();
  }
}
