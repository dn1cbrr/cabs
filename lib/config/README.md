# Server Configuration Guide

This guide explains how to configure the server connection for the Transit app.

## Quick Start

### Using the Configuration Wizard
The app includes a built-in configuration wizard that makes setup easy:

```dart
// Show the configuration wizard in a dialog
showDialog(
  context: context,
  builder: (context) => AlertDialog(
    title: const Text('Server Configuration'),
    content: ConfigWizard(
      onConfigChanged: () {
        // Refresh your app when config changes
        setState(() {});
      },
    ),
  ),
);
```

### Manual Configuration
You can also configure manually using the ServerConfig class:

```dart
import 'package:transit/config/server_config.dart';

// Get current configuration
final currentEnv = ServerConfig.currentEnvironment;
final baseUrl = ServerConfig.baseUrl;
final wsUrl = ServerConfig.webSocketUrl;

// Test server connection
final isConnected = await ServerConfig.testServerConnection();
```

## Environment Types

| Environment | Description | Default URL |
|-------------|-------------|-------------|
| `localDevelopment` | Local development on same machine | `http://localhost/transit/api` |
| `localNetwork` | Local network testing | `http://192.168.1.100/transit/api` |
| `emulator` | Android emulator testing | `http://10.0.2.2/transit/api` |
| `staging` | Staging server | `https://staging.your-domain.com/api` |
| `production` | Production server | `https://your-production-domain.com/api` |

## Environment Detection

The app automatically detects the environment based on:

1. **Platform detection**: Android vs other platforms
2. **Hostname checking**: localhost vs network addresses
3. **Build flags**: PRODUCTION and STAGING flags
4. **Default fallback**: Local development

## Build Flags

You can override environment detection using build flags:

```bash
# Production build
flutter run --dart-define=PRODUCTION=true

# Staging build
flutter run --dart-define=STAGING=true

# Local development (default)
flutter run
```

## Testing Connection

Always test your server connection after configuration:

```dart
final success = await ServerConfig.testServerConnection();
if (success) {
  print('Server is accessible!');
} else {
  print('Server connection failed');
}
```

## Custom Configuration

For custom server URLs, use the configuration wizard or set them directly:

```dart
// Custom URLs
final customConfig = {
  'baseUrl': 'https://my-custom-server.com/api',
  'webSocketUrl': 'wss://my-custom-server.com/seats',
};
```

## Troubleshooting

### Common Issues

1. **Connection refused**: Check if server is running and accessible
2. **CORS errors**: Ensure server has proper CORS headers
3. **Network issues**: Verify firewall and network settings
4. **Wrong IP**: Use `ipconfig` (Windows) or `ifconfig` (Mac/Linux) to find correct IP

### Testing Tools

- Use the built-in configuration wizard
- Check `ServerConfig.getConfigInfo()` for current settings
- Use `ServerConfig.testServerConnection()` to verify connectivity

## Server Requirements

Your server must:
- Support HTTP/HTTPS for API endpoints
- Support WebSocket connections for real-time features
- Have proper CORS configuration
- Return 200 status for `/test.php` endpoint
