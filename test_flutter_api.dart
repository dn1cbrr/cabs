import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  print('Testing Flutter API Connection...');
  
  try {
    // Test the API connection
    final response = await http.get(
      Uri.parse('http://localhost:8000/test.php'),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    print('Status Code: ${response.statusCode}');
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('Response: ${response.body}');
      
      if (data['success']) {
        print('✅ API Connection Successful!');
        print('Message: ${data['message']}');
        print('User Count: ${data['user_count']}');
        print('Timestamp: ${data['timestamp']}');
      } else {
        print('❌ API returned success=false');
        print('Message: ${data['message']}');
      }
    } else {
      print('❌ HTTP Error: ${response.statusCode}');
      print('Response: ${response.body}');
    }
  } catch (e) {
    print('❌ Network Error: $e');
  }
  
  print('\nTesting with the Flutter app base URL...');
  
  try {
    // Test with the Flutter app base URL
    final response = await http.get(
      Uri.parse('http://localhost:8000/test.php'),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    print('Status Code: ${response.statusCode}');
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('Response: ${response.body}');
      
      if (data['success']) {
        print('✅ API Connection with Flutter Base URL Successful!');
        print('Message: ${data['message']}');
        print('User Count: ${data['user_count']}');
        print('Timestamp: ${data['timestamp']}');
      } else {
        print('❌ API returned success=false');
        print('Message: ${data['message']}');
      }
    } else {
      print('❌ HTTP Error: ${response.statusCode}');
      print('Response: ${response.body}');
    }
  } catch (e) {
    print('❌ Network Error with Flutter Base URL: $e');
  }
}
