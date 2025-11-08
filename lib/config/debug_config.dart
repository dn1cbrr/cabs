import 'package:flutter/material.dart';
import '../config/network_config.dart';

class DebugConfig {
  static bool isDebugMode = true;

  static void showDebugInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Debug Info'),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Base URL: ${NetworkConfig.currentBaseUrl}'),
            Text('Test URL: ${NetworkConfig.testUrl}'),
            Text('Debug Mode: $isDebugMode'),
          ],
        ),
      ),
    );
  }
}
