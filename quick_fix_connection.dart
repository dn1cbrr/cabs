import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  print('🔧 Flutter API Connection Fix');
  print('============================\n');

  // Get your computer's IP address
  print('📍 Step 1: Find Your Computer IP Address');
  print('Run this command in Command Prompt:');
  print('   ipconfig');
  print('Look for "IPv4 Address" under your active network adapter\n');

  // Test current configuration
  print('🧪 Step 2: Testing Current Configuration');

  final testUrls = [
    'http://10.0.2.2/transit/api/test.php', // Android emulator
    'http://localhost/transit/api/test.php', // iOS simulator
    'http://127.0.0.1/transit/api/test.php', // Localhost
    'http://192.168.1.7/transit/api/test.php', // Your current IP
  ];

  for (var url in testUrls) {
    print('Testing: $url');
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ SUCCESS: $data');
      } else {
        print(
          '❌ HTTP ${response.statusCode}: ${response.body.substring(0, 100)}...',
        );
      }
    } catch (e) {
      print('❌ ERROR: $e');
    }
    print('---');
  }

  print('\n🔧 Step 3: Quick Fix Instructions');
  print('1. Start your PHP server (Apache/XAMPP/WAMP)');
  print('2. Update IP address in lib/config/network_config.dart');
  print('3. Ensure the transit folder is in your web server directory');
  print(
    '4. Test the URL in browser first: http://localhost/transit/api/test.php',
  );
}
