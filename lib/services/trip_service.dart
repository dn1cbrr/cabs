import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import '../models/trip_history.dart';
import '../config/environment_config.dart';
import '../utils/network_diagnostics.dart';

class TripService {
  static String get baseUrl => EnvironmentConfig.baseUrl;
  static const Duration _timeout = Duration(seconds: 30);

  static Future<Map<String, dynamic>> addTrip(Map<String, dynamic> tripData) async {
    try {
      // First, test connectivity to the trips endpoint
      final connectivityTest = await NetworkDiagnostics.testTripsEndpoint();
      if (!connectivityTest['success']) {
        return {
          'success': false,
          'message': 'Cannot connect to server: ${connectivityTest['message']}',
          'error_type': 'connectivity',
          'suggestions': NetworkDiagnostics.getSuggestedFixes({'tripsEndpoint': connectivityTest}),
        };
      }

      // Format datetime fields to be PHP-compatible
      final formattedTripData = _formatTripDataForAPI(tripData);

      // Make the actual request with timeout
      final response = await http.post(
        Uri.parse('${EnvironmentConfig.tripsBaseUrl}/add.php'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(formattedTripData),
      ).timeout(_timeout);

      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          final data = json.decode(response.body);
          return data;
        } catch (e) {
          return {
            'success': false,
            'message': 'Invalid response format from server',
            'error_type': 'parse_error',
            'raw_response': response.body,
          };
        }
      } else {
        return {
          'success': false,
          'message': 'Server error: ${response.statusCode}',
          'error_type': 'server_error',
          'status_code': response.statusCode,
          'response_body': response.body,
        };
      }
    } on SocketException catch (e) {
      return {
        'success': false,
        'message': 'Network connection failed. Please check your internet connection and server status.',
        'error_type': 'network_error',
        'details': e.message,
        'suggestions': [
          'Check if XAMPP or your web server is running',
          'Verify the server URL: ${EnvironmentConfig.tripsBaseUrl}',
          'If using an emulator, ensure localhost is accessible',
          'If using a physical device, use your computer\'s IP address instead of localhost',
        ],
      };
    } on HttpException catch (e) {
      return {
        'success': false,
        'message': 'HTTP error occurred: ${e.message}',
        'error_type': 'http_error',
        'details': e.toString(),
      };
    } on FormatException catch (e) {
      return {
        'success': false,
        'message': 'Invalid data format: ${e.message}',
        'error_type': 'format_error',
        'details': 'Check if all required fields are properly formatted',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Unexpected error: ${e.toString()}',
        'error_type': 'unknown_error',
        'details': e.runtimeType.toString(),
      };
    }
  }

  /// Test connection to the trips API
  static Future<Map<String, dynamic>> testConnection() async {
    return await NetworkDiagnostics.testTripsEndpoint();
  }

  /// Format trip data to be compatible with PHP API
  static Map<String, dynamic> _formatTripDataForAPI(Map<String, dynamic> tripData) {
    final formattedData = Map<String, dynamic>.from(tripData);
    
    // Format start_time to MySQL datetime format (without microseconds)
    if (formattedData['start_time'] != null) {
      final startTimeStr = formattedData['start_time'].toString();
      try {
        DateTime startTime;
        if (startTimeStr.contains('T')) {
          // Parse ISO 8601 format
          startTime = DateTime.parse(startTimeStr);
        } else {
          // Already in a different format, try to parse
          startTime = DateTime.parse(startTimeStr);
        }
        // Format to MySQL datetime format (YYYY-MM-DD HH:MM:SS)
        formattedData['start_time'] = startTime.toLocal().toString().substring(0, 19);
      } catch (e) {
        // If parsing fails, leave as is and let server handle the error
        print('Warning: Could not format start_time: $e');
      }
    }
    
    // Format end_time to MySQL datetime format (without microseconds)
    if (formattedData['end_time'] != null) {
      final endTimeStr = formattedData['end_time'].toString();
      try {
        DateTime endTime;
        if (endTimeStr.contains('T')) {
          // Parse ISO 8601 format
          endTime = DateTime.parse(endTimeStr);
        } else {
          // Already in a different format, try to parse
          endTime = DateTime.parse(endTimeStr);
        }
        // Format to MySQL datetime format (YYYY-MM-DD HH:MM:SS)
        formattedData['end_time'] = endTime.toLocal().toString().substring(0, 19);
      } catch (e) {
        // If parsing fails, leave as is and let server handle the error
        print('Warning: Could not format end_time: $e');
      }
    }
    
    // Ensure trip_date is in YYYY-MM-DD format
    if (formattedData['trip_date'] != null) {
      final tripDateStr = formattedData['trip_date'].toString();
      try {
        DateTime tripDate;
        if (tripDateStr.contains('T')) {
          tripDate = DateTime.parse(tripDateStr);
        } else if (tripDateStr.contains('-') && tripDateStr.length == 10) {
          // Already in YYYY-MM-DD format
          tripDate = DateTime.parse(tripDateStr);
        } else {
          tripDate = DateTime.parse(tripDateStr);
        }
        // Format to YYYY-MM-DD
        formattedData['trip_date'] = tripDate.toLocal().toString().substring(0, 10);
      } catch (e) {
        print('Warning: Could not format trip_date: $e');
      }
    }
    
    return formattedData;
  }

  /// Validate trip data before sending
  static Map<String, dynamic>? validateTripData(Map<String, dynamic> tripData) {
    final requiredFields = ['driver_id', 'trip_date', 'start_time', 'route_details'];
    
    for (final field in requiredFields) {
      if (!tripData.containsKey(field) || tripData[field] == null || tripData[field].toString().trim().isEmpty) {
        return {
          'success': false,
          'message': 'Missing required field: $field',
          'error_type': 'validation_error',
        };
      }
    }

    // Validate driver_id is a number
    if (tripData['driver_id'] is! int && int.tryParse(tripData['driver_id'].toString()) == null) {
      return {
        'success': false,
        'message': 'Invalid driver ID format',
        'error_type': 'validation_error',
      };
    }

    // Validate total_passengers if provided
    if (tripData.containsKey('total_passengers')) {
      final passengers = int.tryParse(tripData['total_passengers'].toString());
      if (passengers == null || passengers < 0) {
        return {
          'success': false,
          'message': 'Invalid passenger count',
          'error_type': 'validation_error',
        };
      }
    }

    // Validate datetime formats
    if (tripData['start_time'] != null) {
      try {
        DateTime.parse(tripData['start_time'].toString());
      } catch (e) {
        return {
          'success': false,
          'message': 'Invalid start time format',
          'error_type': 'validation_error',
        };
      }
    }

    if (tripData['end_time'] != null) {
      try {
        DateTime.parse(tripData['end_time'].toString());
      } catch (e) {
        return {
          'success': false,
          'message': 'Invalid end time format',
          'error_type': 'validation_error',
        };
      }
    }

    if (tripData['trip_date'] != null) {
      try {
        DateTime.parse(tripData['trip_date'].toString());
      } catch (e) {
        return {
          'success': false,
          'message': 'Invalid trip date format',
          'error_type': 'validation_error',
        };
      }
    }

    return null; // No validation errors
  }

  static Future<List<TripHistory>> getTripHistory({
    int? driverId,
    DateTime? startDate,
    DateTime? endDate,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final params = <String, String>{
        'limit': limit.toString(),
        'offset': offset.toString(),
      };

      if (driverId != null) {
        params['driver_id'] = driverId.toString();
      }

      if (startDate != null) {
        params['start_date'] = startDate.toIso8601String().split('T')[0];
      }

      if (endDate != null) {
        params['end_date'] = endDate.toIso8601String().split('T')[0];
      }

      final uri = Uri.parse('${EnvironmentConfig.tripsBaseUrl}/history.php').replace(queryParameters: params);

      final response = await http.get(
        uri,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final trips = data['trips'] as List;
          return trips.map((trip) => TripHistory.fromJson(trip)).toList();
        } else {
          throw Exception(data['message'] ?? 'Failed to load trips');
        }
      } else {
        throw Exception('Failed to load trips: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading trips: $e');
    }
  }

  static Future<Map<String, dynamic>> getTripSummary(
    int? driverId,
    DateTime? startDate,
    DateTime? endDate,
  ) async {
    try {
      final trips = await getTripHistory(
        driverId: driverId,
        startDate: startDate,
        endDate: endDate,
        limit: 1000,
      );

      if (trips.isEmpty) {
        return {
          'total_trips': 0,
          'total_passengers': 0,
          'total_duration': '0h 0m',
          'average_passengers_per_trip': 0,
        };
      }

      int totalPassengers = 0;
      Duration totalDuration = Duration.zero;
      int completedTrips = 0;

      for (final trip in trips) {
        totalPassengers += trip.totalPassengers;
        if (trip.endTime != null) {
          totalDuration += trip.endTime!.difference(trip.startTime);
          completedTrips++;
        }
      }

      final totalHours = totalDuration.inHours;
      final totalMinutes = totalDuration.inMinutes.remainder(60);

      return {
        'total_trips': trips.length,
        'total_passengers': totalPassengers,
        'total_duration': '${totalHours}h ${totalMinutes}m',
        'average_passengers_per_trip': trips.isNotEmpty
            ? (totalPassengers / trips.length).toStringAsFixed(1)
            : '0',
        'completed_trips': completedTrips,
      };
    } catch (e) {
      throw Exception('Error calculating summary: $e');
    }
  }
}
