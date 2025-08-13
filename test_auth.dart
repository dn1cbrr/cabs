import 'package:transit/services/auth_service.dart';

void main() async {
  print('Testing AuthService.login...');
  final result = await AuthService.login('testuser', 'password');
  print('Login result: $result');
}
