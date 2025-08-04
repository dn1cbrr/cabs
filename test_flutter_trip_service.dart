import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

// Mock the Flutter dependencies for testing
class EnvironmentConfig {
  static String get tripsBaseUrl => 'http://localhost/transit/api/drivers/trips';
}

class NetworkDiagnostics {
  static Future<Map<String, dynamic>> testTripsEndpoint() async {
    try {
      final response = await http.get(
        Uri.parse('${EnvironmentConfig.tripsBaseUrl}/add.php'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      return {
        'success': response.statusCode == 405 || response.statusCode == 200,
        'statusCode': response.statusCode,
        'message': response.statusCode == 405 
            ? 'Trips endpoint is accessible (returns 405 for GET as expected)'
            : 'Trips endpoint response: ${response.statusCode}',
        'responseBody': response.body,
      };
    } on SocketException catch (e) {
      return {
        'success': false,
        'error': 'network',
        'message': 'Cannot reach trips endpoint. Server may not be running.',
        'details': e.message,
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'unknown',
        'message': 'Error testing trips endpoint: ${e.toString()}',
      };
    }
  }

  static List<String> getSuggestedFixes(Map<String, dynamic> diagnostics) {
    return ['Test completed successfully'];
  }
}

// Simplified TripService for testing
class TripService {
  static const Duration _timeout = Duration(seconds: 30);

  static Future<Map<String, dynamic>> addTrip(Map<String, dynamic> tripData) async {
    try {
      // Test connectivity first
      final connectivityTest = await NetworkDiagnostics.testTripsEndpoint();
      if (!connectivityTest['success']) {
        return {
          'success': false,
          'message': 'Cannot connect to server: ${connectivityTest['message']}',
          'error_type': 'connectivity',
          'suggestions': NetworkDiagnostics.getSuggestedFixes({'tripsEndpoint': connectivityTest}),
        };
      }

      // Make the actual request
      final response = await http.post(
        Uri.parse('${EnvironmentConfig.tripsBaseUrl}/add.php'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(tripData),
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
}

void main() async {
  print('🧪 Testing Flutter Trip Service...\n');

  // Test data
  final tripData = {
    'driver_id': 1,
    'trip_date': '2024-01-15',
    'start_time': '2024-01-15T09:00:00',
    'route_details': 'Flutter test route from Makati to BGC',
    'total_passengers': 3,
  };

  print('📤 Testing trip submission...');
  print('Trip data: ${json.encode(tripData)}');
  print('');

  try {
    final result = await TripService.addTrip(tripData);
    
    if (result['success'] == true) {
      print('✅ SUCCESS: Trip added successfully!');
      print('Response: ${json.encode(result)}');
    } else {
      print('❌ FAILED: ${result['message']}');
      print('Error type: ${result['error_type']}');
      if (result['suggestions'] != null) {
        print('Suggestions: ${result['suggestions']}');
      }
    }
  } catch (e) {
    print('❌ EXCEPTION: ${e.toString()}');
  }

  print('\n🔍 Testing connectivity diagnostics...');
  final diagnostics = await NetworkDiagnostics.testTripsEndpoint();
  print('Connectivity test result: ${json.encode(diagnostics)}');
}
