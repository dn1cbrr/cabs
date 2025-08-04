import 'dart:io';
import 'package:http/http.dart' as http;

void main() async {
  print('🔍 Testing Transit App API Connection...\n');
  
  // Test different possible server configurations
  final testUrls = [
    'http://localhost/transit/api',
    'http://localhost:80/transit/api',
    'http://localhost:8080/transit/api',
    'http://127.0.0.1/transit/api',
    'http://127.0.0.1:80/transit/api',
    'http://127.0.0.1:8080/transit/api',
  ];
  
  for (final baseUrl in testUrls) {
    print('Testing: $baseUrl');
    await testApiEndpoint(baseUrl);
    print('');
  }
  
  print('📋 Summary:');
  print('- If any test shows ✅ SUCCESS, that URL configuration works');
  print('- Update lib/config/environment_config.dart with the working URL');
  print('- Make sure XAMPP or your web server is running');
  print('- Check that the transit database exists and is accessible');
}

Future<void> testApiEndpoint(String baseUrl) async {
  try {
    // Test basic API connection
    final testResponse = await http.get(
      Uri.parse('$baseUrl/test.php'),
      headers: {'Content-Type': 'application/json'},
    ).timeout(const Duration(seconds: 5));
    
    if (testResponse.statusCode == 200) {
      print('  ✅ Basic API: SUCCESS (${testResponse.statusCode})');
    } else {
      print('  ❌ Basic API: FAILED (${testResponse.statusCode})');
    }
    
    // Test trips endpoint (should return 405 for GET request)
    final tripsResponse = await http.get(
      Uri.parse('$baseUrl/drivers/trips/add.php'),
      headers: {'Content-Type': 'application/json'},
    ).timeout(const Duration(seconds: 5));
    
    if (tripsResponse.statusCode == 405) {
      print('  ✅ Trips Endpoint: ACCESSIBLE (405 - Method Not Allowed as expected)');
    } else if (tripsResponse.statusCode == 200) {
      print('  ✅ Trips Endpoint: ACCESSIBLE (${tripsResponse.statusCode})');
    } else {
      print('  ❌ Trips Endpoint: FAILED (${tripsResponse.statusCode})');
    }
    
  } on SocketException catch (e) {
    print('  ❌ Network Error: ${e.message}');
  } on HttpException catch (e) {
    print('  ❌ HTTP Error: ${e.message}');
  } catch (e) {
    print('  ❌ Error: ${e.toString()}');
  }
}
