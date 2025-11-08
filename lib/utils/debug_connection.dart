import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../config/network_config.dart';

class DebugConnection {
  static Future<Map<String, dynamic>> diagnoseConnection() async {
    final results = {
      'server_reachable': false,
      'response_time': 0,
      'error_details': null,
      'database_connected': false,
      'user_count': 0,
      'timestamp': DateTime.now().toString(),
    };

    try {
      final stopwatch = Stopwatch()..start();
      final response = await http
          .get(
            Uri.parse(NetworkConfig.testUrl),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 10));

      stopwatch.stop();

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        results['server_reachable'] = true;
        results['response_time'] = stopwatch.elapsedMilliseconds;
        results['database_connected'] = data['success'] ?? false;
        results['user_count'] = data['user_count'] ?? 0;
      } else {
        results['error_details'] =
            'HTTP ${response.statusCode}: ${response.body}';
      }
    } on SocketException catch (e) {
      results['error_details'] = 'Network error: ${e.message}';
      results['troubleshooting'] = [
        'Check if server is running',
        'Verify IP address: ${NetworkConfig.currentBaseUrl}',
        'Check firewall settings',
        'Try accessing ${NetworkConfig.testUrl} in browser',
      ];
    } on TimeoutException {
      results['error_details'] = 'Connection timeout';
      results['troubleshooting'] = [
        'Server might be slow or unreachable',
        'Check network connectivity',
        'Verify server is running on correct port',
      ];
    } catch (e) {
      results['error_details'] = 'Unexpected error: ${e.toString()}';
    }

    return results;
  }

  static Future<Map<String, dynamic>> testAllEndpoints() async {
    final endpoints = [
      'test.php',
      'auth/login.php',
      'auth/register.php',
      'auth/forgot_password.php',
      'trips/get_latest_trip.php',
    ];

    final results = <String, dynamic>{};

    for (final endpoint in endpoints) {
      try {
        final response = await http
            .get(
              Uri.parse('${NetworkConfig.currentBaseUrl}/$endpoint'),
              headers: {'Content-Type': 'application/json'},
            )
            .timeout(const Duration(seconds: 5));

        results[endpoint] = {
          'status': response.statusCode,
          'reachable': response.statusCode < 500,
          'response_time': 0, // Will be measured
        };
      } catch (e) {
        results[endpoint] = {
          'status': 0,
          'reachable': false,
          'error': e.toString(),
        };
      }
    }

    return results;
  }

  static Future<void> showDebugDialog(BuildContext context) async {
    final results = await diagnoseConnection();

    if (context.mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Connection Diagnostics'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildStatusRow(
                  'Server Reachable',
                  results['server_reachable'],
                ),
                _buildStatusRow(
                  'Database Connected',
                  results['database_connected'],
                ),
                Text('Response Time: ${results['response_time']}ms'),
                Text('User Count: ${results['user_count']}'),
                if (results['error_details'] != null) ...[
                  const SizedBox(height: 16),
                  const Text(
                    'Error Details:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(results['error_details']),
                ],
                if (results['troubleshooting'] != null) ...[
                  const SizedBox(height: 16),
                  const Text(
                    'Troubleshooting:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  ...List.generate(
                    results['troubleshooting'].length,
                    (index) => Text('• ${results['troubleshooting'][index]}'),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await showDebugDialog(context);
              },
              child: const Text('Refresh'),
            ),
          ],
        ),
      );
    }
  }

  static Widget _buildStatusRow(String label, bool status) {
    return Row(
      children: [
        Text(label),
        const Spacer(),
        Icon(
          status ? Icons.check_circle : Icons.error,
          color: status ? Colors.green : Colors.red,
          size: 16,
        ),
      ],
    );
  }
}
