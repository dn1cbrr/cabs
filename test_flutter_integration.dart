import 'dart:convert';
import 'package:http/http.dart' as http;

// Test the Flutter TripService integration
void main() async {
  print('Testing Flutter TripService Integration');
  print('=====================================\n');

  // Run multiple test scenarios
  await runBasicTest();
  await runEdgeCaseTests();
  await runErrorHandlingTests();
}

/// Run the basic successful trip addition test
Future<void> runBasicTest() async {
  print('🧪 BASIC TEST: Successful Trip Addition');
  print('----------------------------------------');

  // Test data similar to what the Flutter app would send
  final testData = {
    'driver_id': 1,
    'trip_date': '2024-01-15',
    'start_time': '2024-01-15T14:30:00.000Z', // ISO 8601 format from Flutter
    'end_time': '2024-01-15T16:30:00.000Z',
    'route_details': 'Test route from Flutter integration',
    'total_passengers': 25
  };

  // Validate test data first
  final validationResult = validateTripData(testData);
  if (validationResult != null) {
    print('❌ VALIDATION FAILED: ${validationResult['message']}');
    return;
  }

  // Simulate the _formatTripDataForAPI method from TripService
  final formattedData = formatTripDataForAPI(testData);
  
  print('Original Flutter data:');
  print(_formatJsonForDisplay(testData));
  print('\nFormatted data for API:');
  print(_formatJsonForDisplay(formattedData));

  // Test the API call
  await _makeApiCall(formattedData, 'Basic Test');
  print('\n');
}

/// Run edge case tests
Future<void> runEdgeCaseTests() async {
  print('🧪 EDGE CASE TESTS');
  print('-------------------');

  // Test 1: Trip without end_time
  print('Test 1: Trip without end_time');
  final testData1 = {
    'driver_id': 1,
    'trip_date': '2024-01-16',
    'start_time': '2024-01-16T09:00:00.000Z',
    'route_details': 'Morning route without end time',
    'total_passengers': 15
  };
  await _makeApiCall(formatTripDataForAPI(testData1), 'No End Time Test');

  // Test 2: Trip with zero passengers
  print('\nTest 2: Trip with zero passengers');
  final testData2 = {
    'driver_id': 1,
    'trip_date': '2024-01-17',
    'start_time': '2024-01-17T10:00:00.000Z',
    'end_time': '2024-01-17T11:00:00.000Z',
    'route_details': 'Empty bus route',
    'total_passengers': 0
  };
  await _makeApiCall(formatTripDataForAPI(testData2), 'Zero Passengers Test');

  // Test 3: Different datetime format
  print('\nTest 3: Different datetime format (already MySQL format)');
  final testData3 = {
    'driver_id': 1,
    'trip_date': '2024-01-18',
    'start_time': '2024-01-18 08:30:00', // Already in MySQL format
    'end_time': '2024-01-18 10:30:00',
    'route_details': 'Route with MySQL datetime format',
    'total_passengers': 30
  };
  await _makeApiCall(formatTripDataForAPI(testData3), 'MySQL Format Test');
  print('\n');
}

/// Run error handling tests
Future<void> runErrorHandlingTests() async {
  print('🧪 ERROR HANDLING TESTS');
  print('------------------------');

  // Test 1: Missing required field
  print('Test 1: Missing required field (driver_id)');
  final testData1 = {
    'trip_date': '2024-01-19',
    'start_time': '2024-01-19T12:00:00.000Z',
    'route_details': 'Route without driver ID',
    'total_passengers': 20
  };
  
  final validation1 = validateTripData(testData1);
  if (validation1 != null) {
    print('✅ VALIDATION CAUGHT ERROR: ${validation1['message']}');
  } else {
    await _makeApiCall(formatTripDataForAPI(testData1), 'Missing Driver ID Test');
  }

  // Test 2: Invalid driver ID
  print('\nTest 2: Invalid driver ID (non-existent)');
  final testData2 = {
    'driver_id': 99999, // Non-existent driver
    'trip_date': '2024-01-20',
    'start_time': '2024-01-20T13:00:00.000Z',
    'end_time': '2024-01-20T14:00:00.000Z',
    'route_details': 'Route with invalid driver',
    'total_passengers': 18
  };
  await _makeApiCall(formatTripDataForAPI(testData2), 'Invalid Driver Test');

  // Test 3: Invalid date format
  print('\nTest 3: Invalid date format');
  final testData3 = {
    'driver_id': 1,
    'trip_date': 'invalid-date',
    'start_time': '2024-01-21T14:00:00.000Z',
    'route_details': 'Route with invalid date',
    'total_passengers': 22
  };
  
  final validation3 = validateTripData(testData3);
  if (validation3 != null) {
    print('✅ VALIDATION CAUGHT ERROR: ${validation3['message']}');
  } else {
    await _makeApiCall(formatTripDataForAPI(testData3), 'Invalid Date Test');
  }

  print('\n');
}

/// Make an API call and handle the response
Future<void> _makeApiCall(Map<String, dynamic> data, String testName) async {
  try {
    final response = await http.post(
      Uri.parse('http://localhost/transit/api/drivers/trips/add.php'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: json.encode(data),
    );

    print('API Response for $testName:');
    print('Status Code: ${response.statusCode}');
    
    // Try to parse and format the response
    try {
      final responseData = json.decode(response.body);
      print('Response Body:');
      print(_formatJsonForDisplay(responseData));
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (responseData['success'] == true) {
          print('✅ SUCCESS: ${responseData['message']}');
          if (responseData['trip_id'] != null) {
            print('Trip ID: ${responseData['trip_id']}');
          }
        } else {
          print('❌ FAILED: ${responseData['message']}');
        }
      } else {
        print('❌ HTTP ERROR: ${response.statusCode}');
      }
    } catch (e) {
      print('Response Body (raw): ${response.body}');
      print('❌ JSON PARSE ERROR: $e');
    }
  } catch (e) {
    print('❌ EXCEPTION in $testName: $e');
  }
}

/// Format JSON for better display with proper indentation
String _formatJsonForDisplay(Map<String, dynamic> data) {
  const encoder = JsonEncoder.withIndent('  ');
  return encoder.convert(data);
}

/// Replicate the _formatTripDataForAPI method from TripService
Map<String, dynamic> formatTripDataForAPI(Map<String, dynamic> tripData) {
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

/// Validate trip data before sending (replicated from TripService)
Map<String, dynamic>? validateTripData(Map<String, dynamic> tripData) {
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
