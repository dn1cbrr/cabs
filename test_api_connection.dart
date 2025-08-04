import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  try {
    final response = await http.get(
      Uri.parse('http://localhost:8000/test.php'),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    print('Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
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
    }
  } catch (e) {
    print('❌ Network Error: $e');
  }
}
