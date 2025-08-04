import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  print('Testing Flutter App API Connection...');
  
  try {
    // Test the API connection using the correct base URL for XAMPP setup
    final response = await http.post(
      Uri.parse('http://localhost/transit/api/auth/login.php'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'username': 'testuser',
        'password': 'testpass',
      }),
    );

    print('Status Code: ${response.statusCode}');
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('Response: ${response.body}');
      
      if (data['success']) {
        print('✅ Flutter App API Connection Successful!');
        print('Message: ${data['message']}');
        print('User: ${data['user']['username']}');
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
}
