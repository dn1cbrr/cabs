import 'package:flutter/material.dart';
import '../config/server_config.dart';

/// Configuration Demo Page - demonstrates server configuration management
class ConfigDemoPage extends StatefulWidget {
  const ConfigDemoPage({super.key});

  @override
  State<ConfigDemoPage> createState() => _ConfigDemoPageState();
}

class _ConfigDemoPageState extends State<ConfigDemoPage> {
  late ServerConfig _config;
  bool _isTestingConnection = false;
  bool _connectionResult = false;
  String _connectionMessage = '';

  @override
  void initState() {
    super.initState();
    _config = ServerConfig();
  }

  Future<void> _testConnection() async {
    setState(() {
      _isTestingConnection = true;
      _connectionMessage = 'Testing connection...';
    });

    try {
      final result = await _config.testServerConnection();
      setState(() {
        _connectionResult = result;
        _connectionMessage = result
            ? 'Connection successful!'
            : 'Connection failed. Please check your configuration.';
      });
    } catch (e) {
      setState(() {
        _connectionResult = false;
        _connectionMessage = 'Error: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isTestingConnection = false;
      });
    }
  }

  void _resetToDefaults() {
    setState(() {
      _config.resetToDefaults();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Configuration reset to defaults')),
    );
  }

  void _applyRecommendedConfig(String scenario) {
    setState(() {
      _config.setConfig(scenario);
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Applied $scenario configuration')));
  }

  @override
  Widget build(BuildContext context) {
    final configInfo = _config.getConfigInfo();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Server Configuration Demo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _resetToDefaults,
            tooltip: 'Reset to defaults',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Current Configuration Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current Configuration',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    ...configInfo.entries.map(
                      (entry) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Row(
                          children: [
                            Text(
                              '${entry.key}: ',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                entry.value.toString(),
                                style: const TextStyle(fontFamily: 'monospace'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Environment Presets
            Text(
              'Environment Presets',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton(
                  onPressed: () => _applyRecommendedConfig('localhost'),
                  child: const Text('Localhost'),
                ),
                ElevatedButton(
                  onPressed: () => _applyRecommendedConfig('local-network'),
                  child: const Text('Local Network'),
                ),
                ElevatedButton(
                  onPressed: () => _applyRecommendedConfig('emulator'),
                  child: const Text('Emulator'),
                ),
                ElevatedButton(
                  onPressed: () => _applyRecommendedConfig('production'),
                  child: const Text('Production'),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Manual Configuration
            Text(
              'Manual Configuration',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'Base URL',
                        border: OutlineInputBorder(),
                      ),
                      controller: TextEditingController(text: _config.baseUrl),
                      onChanged: (value) => _config.setBaseUrl(value),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'WebSocket URL',
                        border: OutlineInputBorder(),
                      ),
                      controller: TextEditingController(
                        text: _config.webSocketUrl,
                      ),
                      onChanged: (value) => _config.setWebSocketUrl(value),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'Timeout (seconds)',
                        border: OutlineInputBorder(),
                      ),
                      controller: TextEditingController(
                        text: _config.timeout.inSeconds.toString(),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        final seconds = int.tryParse(value) ?? 30;
                        _config.setTimeout(Duration(seconds: seconds));
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Connection Test
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isTestingConnection ? null : _testConnection,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _connectionResult ? Colors.green : null,
                ),
                child: _isTestingConnection
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Test Connection'),
              ),
            ),
            const SizedBox(height: 8),
            if (_connectionMessage.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _connectionResult
                      ? Colors.green[100]
                      : Colors.red[100],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  _connectionMessage,
                  style: TextStyle(
                    color: _connectionResult
                        ? Colors.green[900]
                        : Colors.red[900],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
