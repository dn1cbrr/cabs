import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/environment_config_updated.dart';

class NetworkDiagnostics {
  static const Duration _timeout = Duration(seconds: 10);

  /// Test basic connectivity to the API server
  static Future<Map<String, dynamic>> testApiConnection() async {
    try {
      final response = await http.get(
        Uri.parse(EnvironmentConfig.testUrl),
        headers: {'Content-Type': 'application/json'},
      ).timeout(_timeout);

      return {
        'success': response.statusCode == 200,
        'statusCode': response.statusCode,
        'message': response.statusCode == 200 
            ? 'API connection successful' 
            : 'API returned status ${response.statusCode}',
        'responseBody': response.body,
      };
    } on SocketException catch (e) {
      return {
        'success': false,
        'error': 'network',
        'message': 'Network error: Cannot reach server. Check if the server is running.',
        'details': e.message,
      };
    } on HttpException catch (e) {
      return {
        'success': false,
        'error': 'http',
        'message': 'HTTP error: ${e.message}',
        'details': e.toString(),
      };
    } on FormatException catch (e) {
      return {
        'success': false,
        'error': 'format',
        'message': 'Invalid response format from server',
        'details': e.message,
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'unknown',
        'message': 'Unexpected error: ${e.toString()}',
        'details': e.runtimeType.toString(),
      };
    }
  }

  /// Test specific endpoint connectivity
  static Future<Map<String, dynamic>> testEndpoint(String endpoint) async {
    try {
      final response = await http.get(
        Uri.parse('${EnvironmentConfig.baseUrl}$endpoint'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(_timeout);

      return {
        'success': true,
        'statusCode': response.statusCode,
        'message': 'Endpoint accessible',
        'endpoint': endpoint,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Endpoint not accessible: ${e.toString()}',
        'endpoint': endpoint,
      };
    }
  }

  /// Test trips endpoint specifically
  static Future<Map<String, dynamic>> testTripsEndpoint() async {
    try {
      // Test with a simple GET request first to see if endpoint is reachable
      final response = await http.get(
        Uri.parse('${EnvironmentConfig.tripsBaseUrl}/add.php'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(_timeout);

      return {
        'success': response.statusCode == 405 || response.statusCode == 200, // 405 is expected for GET on POST endpoint
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

  /// Comprehensive diagnostic report
  static Future<Map<String, dynamic>> runFullDiagnostics() async {
    final results = <String, dynamic>{};
    
    // Test basic API connection
    results['apiConnection'] = await testApiConnection();
    
    // Test trips endpoint
    results['tripsEndpoint'] = await testTripsEndpoint();
    
    // Test other endpoints
    results['authEndpoint'] = await testEndpoint('/auth/login.php');
    results['driversEndpoint'] = await testEndpoint('/drivers/index.php');
    
    // Overall status
    final apiSuccess = results['apiConnection']['success'] == true;
    final tripsSuccess = results['tripsEndpoint']['success'] == true;
    
    results['overall'] = {
      'success': apiSuccess && tripsSuccess,
      'message': apiSuccess && tripsSuccess 
          ? 'All diagnostics passed'
          : 'Some diagnostics failed - check individual results',
      'timestamp': DateTime.now().toIso8601String(),
      'baseUrl': EnvironmentConfig.baseUrl,
      'tripsUrl': EnvironmentConfig.tripsBaseUrl,
    };
    
    return results;
  }

  /// Get suggested fixes based on diagnostic results
  static List<String> getSuggestedFixes(Map<String, dynamic> diagnostics) {
    final suggestions = <String>[];
    
    final apiConnection = diagnostics['apiConnection'];
    final tripsEndpoint = diagnostics['tripsEndpoint'];
    
    if (apiConnection != null && apiConnection['success'] != true) {
      if (apiConnection['error'] == 'network') {
        suggestions.addAll([
          'Check if XAMPP or your web server is running',
          'Verify the server is running on the correct port (usually 80 or 8080)',
          'If using an emulator, make sure localhost is accessible',
          'If using a physical device, replace localhost with your computer\'s IP address',
        ]);
      }
    }
    
    if (tripsEndpoint != null && tripsEndpoint['success'] != true) {
      suggestions.addAll([
        'Check if the trips API endpoint exists at: ${EnvironmentConfig.tripsBaseUrl}/add.php',
        'Verify database connection in the PHP backend',
        'Check PHP error logs for backend issues',
      ]);
    }
    
    if (suggestions.isEmpty) {
      suggestions.add('All diagnostics passed. The issue might be with request data or server processing.');
    }
    
    return suggestions;
  }
}
