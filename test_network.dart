import 'dart:io';
import 'package:http/http.dart' as http;

void main() async {
  print('=== Network Diagnostics ===');
  print('Testing connectivity to API endpoints...');
  
  // Test URLs
  const baseUrl = 'http://192.168.1.7/transit/api';
  const testUrl = '$baseUrl/test.php';
  const tripsUrl = '$baseUrl/drivers/trips/add.php';
  
  print('\n1. Testing basic API connection...');
  await testEndpoint(testUrl, 'Basic API');
  
  print('\n2. Testing trips endpoint...');
  await testEndpoint(tripsUrl, 'Trips API');
  
  print('\n3. Testing server reachability...');
  await testServerReachability('192.168.1.7');
}

Future<void> testEndpoint(String url, String name) async {
  try {
    final response = await http.get(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
    ).timeout(Duration(seconds: 10));
    
    print('$name - Status: ${response.statusCode}');
    print('$name - Response: ${response.body.substring(0, response.body.length > 100 ? 100 : response.body.length)}...');
  } catch (e) {
    print('$name - Error: $e');
  }
}

Future<void> testServerReachability(String host) async {
  try {
    final result = await Process.run('ping', ['-n', '1', host]);
    print('Server ping result:');
    print(result.stdout);
  } catch (e) {
    print('Ping failed: $e');
  }
}
