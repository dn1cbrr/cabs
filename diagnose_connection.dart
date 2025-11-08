import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

void main() async {
  print('🔧 Flutter API Connection Diagnostic');
  print('====================================\n');

  print('📍 Step 1: Current Configuration');
  print('Platform: ${Platform.operatingSystem}');
  print('Current IP in config: 192.168.1.7');
  print('');

  print('🧪 Step 2: Testing Connection URLs');

  final urls = [
    'http://localhost/transit/api/test.php',
    'http://127.0.0.1/transit/api/test.php',
    'http://192.168.1.7/transit/api/test.php',
    'http://10.0.2.2/transit/api/test.php', // Android emulator
  ];

  for (var url in urls) {
    print('Testing: $url');
    try {
      final response = await http.get(Uri.parse(url));
      print('Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        try {
          final data = jsonDecode(response.body);
          print('✅ SUCCESS - JSON Response: $data');
        } catch (e) {
          print(
            '❌ ERROR - Invalid JSON: ${response.body.substring(0, 100)}...',
          );
        }
      } else {
        print('❌ HTTP Error: ${response.body.substring(0, 100)}...');
      }
    } catch (e) {
      print('❌ Connection Error: $e');
    }
    print('---');
  }

  print('\n🔧 Step 3: How to Fix FormatException');
  print('1. Find your computer IP: Run "ipconfig" in Command Prompt');
  print('2. Update lib/config/network_config.dart');
  print('3. Change 192.168.1.7 to your actual IP');
  print('4. Ensure PHP server is running (XAMPP/WAMP)');
  print('5. Test in browser: http://localhost/transit/api/test.php');
}
