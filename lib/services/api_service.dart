import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';

class ApiService {
  static const String baseUrl = 'http://192.168.1.7/transit/api';
  static const Duration timeoutDuration = Duration(seconds: 10);

  // Enhanced HTTP client with better error handling
  static Future<Map<String, dynamic>> makeRequest(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? body,
    String method = 'GET',
  }) async {
    try {
      // Check network connectivity
      final connectivity = Connectivity();
      final connectivityResult = await connectivity.checkConnectivity();
      if (connectivityResult.contains(ConnectivityResult.none) ||
          connectivityResult.isEmpty) {
        return {
          'success': false,
          'message': 'No internet connection',
          'error_type': 'network',
        };
      }

      final url = Uri.parse('$baseUrl/$endpoint');
      final requestHeaders = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        ...?headers,
      };

      http.Response response;

      switch (method.toUpperCase()) {
        case 'GET':
          response = await http
              .get(url, headers: requestHeaders)
              .timeout(timeoutDuration);
          break;
        case 'POST':
          response = await http
              .post(
                url,
                headers: requestHeaders,
                body: body != null ? jsonEncode(body) : null,
              )
              .timeout(timeoutDuration);
          break;
        case 'PUT':
          response = await http
              .put(
                url,
                headers: requestHeaders,
                body: body != null ? jsonEncode(body) : null,
              )
              .timeout(timeoutDuration);
          break;
        case 'DELETE':
          response = await http
              .delete(url, headers: requestHeaders)
              .timeout(timeoutDuration);
          break;
        default:
          throw Exception('Unsupported HTTP method');
      }

      // Check if response is HTML (error page)
      if (response.headers['content-type']?.contains('text/html') ?? false) {
        return {
          'success': false,
          'message':
              'Server returned HTML instead of JSON. Check server configuration.',
          'error_type': 'server_config',
          'status_code': response.statusCode,
          'response_body': response.body,
        };
      }

      // Try to parse JSON
      try {
        final data = jsonDecode(response.body);
        return {
          'success': response.statusCode >= 200 && response.statusCode < 300,
          'data': data,
          'status_code': response.statusCode,
        };
      } catch (e) {
        return {
          'success': false,
          'message': 'Invalid JSON response from server',
          'error_type': 'json_parse',
          'raw_response': response.body,
          'status_code': response.statusCode,
        };
      }
    } on SocketException catch (e) {
      return {
        'success': false,
        'message':
            'Cannot connect to server. Check server address and ensure server is running.',
        'error_type': 'connection',
        'details': e.message,
      };
    } on FormatException catch (e) {
      return {
        'success': false,
        'message': 'Invalid response format from server',
        'error_type': 'format',
        'details': e.message,
      };
    } on TimeoutException catch (e) {
      return {
        'success': false,
        'message': 'Request timed out. Server may be unreachable.',
        'error_type': 'timeout',
        'details': e.message,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Unexpected error occurred',
        'error_type': 'unknown',
        'details': e.toString(),
      };
    }
  }

  // Test API connection with detailed diagnostics
  static Future<Map<String, dynamic>> testConnection() async {
    final result = await makeRequest('test.php');

    if (result['success'] == true) {
      return {
        'connected': true,
        'message': 'API connection successful',
        'details': result['data'],
      };
    } else {
      return {
        'connected': false,
        'message': result['message'],
        'error_type': result['error_type'],
        'details': result,
      };
    }
  }

  // Get network diagnostics
  static Future<Map<String, dynamic>> getNetworkDiagnostics() async {
    final connectivity = Connectivity();
    final connectivityResult = await connectivity.checkConnectivity();
    final networkInfo = {
      'connectivity': connectivityResult.toString(),
      'base_url': baseUrl,
      'timestamp': DateTime.now().toIso8601String(),
    };

    final connectionTest = await testConnection();
    networkInfo['connection_test'] = connectionTest as String;

    return networkInfo;
  }
}
