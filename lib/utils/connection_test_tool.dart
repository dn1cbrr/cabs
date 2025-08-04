import 'package:flutter/material.dart';
import '../config/environment_config.dart';
import 'network_diagnostics.dart';

class ConnectionTestTool extends StatefulWidget {
  const ConnectionTestTool({super.key});

  @override
  State<ConnectionTestTool> createState() => _ConnectionTestToolState();
}

class _ConnectionTestToolState extends State<ConnectionTestTool> {
  Map<String, dynamic>? diagnosticsResult;
  bool isRunning = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Connection Diagnostics'),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Current Configuration',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildConfigItem('Base URL', EnvironmentConfig.baseUrl),
                    _buildConfigItem('Trips URL', EnvironmentConfig.tripsBaseUrl),
                    _buildConfigItem('Auth URL', EnvironmentConfig.authBaseUrl),
                    _buildConfigItem('Test URL', EnvironmentConfig.testUrl),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: isRunning ? null : _runDiagnostics,
              icon: isRunning
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.play_arrow),
              label: Text(isRunning ? 'Running Diagnostics...' : 'Run Diagnostics'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
            const SizedBox(height: 16),
            if (diagnosticsResult != null) ...[
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                diagnosticsResult!['overall']['success']
                                    ? Icons.check_circle
                                    : Icons.error,
                                color: diagnosticsResult!['overall']['success']
                                    ? Colors.green
                                    : Colors.red,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Diagnostics Results',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildDiagnosticSection('Overall Status', diagnosticsResult!['overall']),
                          _buildDiagnosticSection('API Connection', diagnosticsResult!['apiConnection']),
                          _buildDiagnosticSection('Trips Endpoint', diagnosticsResult!['tripsEndpoint']),
                          _buildDiagnosticSection('Auth Endpoint', diagnosticsResult!['authEndpoint']),
                          _buildDiagnosticSection('Drivers Endpoint', diagnosticsResult!['driversEndpoint']),
                          const SizedBox(height: 16),
                          _buildSuggestions(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildConfigItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiagnosticSection(String title, Map<String, dynamic> data) {
    final success = data['success'] == true;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                success ? Icons.check_circle : Icons.error,
                color: success ? Colors.green : Colors.red,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(data['message'] ?? 'No message'),
                if (data['statusCode'] != null) ...[
                  const SizedBox(height: 4),
                  Text('Status Code: ${data['statusCode']}'),
                ],
                if (data['details'] != null) ...[
                  const SizedBox(height: 4),
                  Text('Details: ${data['details']}'),
                ],
                if (data['error'] != null) ...[
                  const SizedBox(height: 4),
                  Text('Error Type: ${data['error']}'),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestions() {
    if (diagnosticsResult == null) return const SizedBox.shrink();
    
    final suggestions = NetworkDiagnostics.getSuggestedFixes(diagnosticsResult!);
    
    if (suggestions.isEmpty) return const SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Suggested Fixes:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.orange,
          ),
        ),
        const SizedBox(height: 8),
        ...suggestions.map((suggestion) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
              Expanded(child: Text(suggestion)),
            ],
          ),
        )),
      ],
    );
  }

  Future<void> _runDiagnostics() async {
    setState(() {
      isRunning = true;
      diagnosticsResult = null;
    });

    try {
      final result = await NetworkDiagnostics.runFullDiagnostics();
      setState(() {
        diagnosticsResult = result;
      });
    } catch (e) {
      setState(() {
        diagnosticsResult = {
          'overall': {
            'success': false,
            'message': 'Failed to run diagnostics: ${e.toString()}',
          },
        };
      });
    } finally {
      setState(() {
        isRunning = false;
      });
    }
  }
}
