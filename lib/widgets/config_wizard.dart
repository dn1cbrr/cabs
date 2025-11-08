import 'package:flutter/material.dart';
import '../config/server_config.dart';

/// Configuration Wizard Widget - provides a guided setup for server configuration
class ConfigWizard extends StatefulWidget {
  final Function(ServerConfig)? onConfigSaved;

  const ConfigWizard({super.key, this.onConfigSaved});

  @override
  State<ConfigWizard> createState() => _ConfigWizardState();
}

class _ConfigWizardState extends State<ConfigWizard> {
  late ServerConfig _config;
  final _formKey = GlobalKey<FormState>();
  final _baseUrlController = TextEditingController();
  final _webSocketUrlController = TextEditingController();
  final _timeoutController = TextEditingController();

  bool _isTesting = false;
  @override
  void initState() {
    super.initState();
    _config = ServerConfig();
    _baseUrlController.text = _config.baseUrl;
    _webSocketUrlController.text = _config.webSocketUrl;
    _timeoutController.text = _config.timeout.inSeconds.toString();
  }

  @override
  void dispose() {
    _baseUrlController.dispose();
    _webSocketUrlController.dispose();
    _timeoutController.dispose();
    super.dispose();
  }

  Future<void> _testConnection() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isTesting = true;
    });

    try {
      final testConfig = ServerConfig(
        baseUrl: _baseUrlController.text,
        webSocketUrl: _webSocketUrlController.text,
        timeout: Duration(seconds: int.parse(_timeoutController.text)),
      );

      final result = await testConfig.testServerConnection();

      setState(() {});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result ? 'Connection successful!' : 'Connection failed',
          ),
          backgroundColor: result ? Colors.green : Colors.red,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isTesting = false;
      });
    }
  }

  void _applyRecommendedConfig(String scenario) {
    setState(() {
      _config.setConfig(scenario);
      _baseUrlController.text = _config.baseUrl;
      _webSocketUrlController.text = _config.webSocketUrl;
    });
  }

  void _saveConfig() {
    if (!_formKey.currentState!.validate()) return;

    final newConfig = ServerConfig(
      baseUrl: _baseUrlController.text,
      webSocketUrl: _webSocketUrlController.text,
      timeout: Duration(seconds: int.parse(_timeoutController.text)),
    );

    widget.onConfigSaved?.call(newConfig);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Configuration saved successfully!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Server Configuration',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 20),

            // Environment Selection
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Environment',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: () => _applyRecommendedConfig('localhost'),
                          child: const Text('Localhost'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () =>
                              _applyRecommendedConfig('local-network'),
                          child: const Text('Local Network'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () => _applyRecommendedConfig('emulator'),
                          child: const Text('Emulator'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Base URL
            TextFormField(
              controller: _baseUrlController,
              decoration: const InputDecoration(
                labelText: 'Base URL',
                hintText: 'http://localhost/transit/api',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a base URL';
                }
                if (!value.startsWith('http')) {
                  return 'Please enter a valid URL';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // WebSocket URL
            TextFormField(
              controller: _webSocketUrlController,
              decoration: const InputDecoration(
                labelText: 'WebSocket URL',
                hintText: 'ws://localhost:8080/seats',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a WebSocket URL';
                }
                if (!value.startsWith('ws')) {
                  return 'Please enter a valid WebSocket URL';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Timeout
            TextFormField(
              controller: _timeoutController,
              decoration: const InputDecoration(
                labelText: 'Timeout (seconds)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a timeout';
                }
                final timeout = int.tryParse(value);
                if (timeout == null || timeout <= 0) {
                  return 'Please enter a valid timeout';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Test Connection Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isTesting ? null : _testConnection,
                child: _isTesting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Test Connection'),
              ),
            ),
            const SizedBox(height: 16),

            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveConfig,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                ),
                child: const Text('Save Configuration'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
