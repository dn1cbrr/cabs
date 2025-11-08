import 'package:flutter/material.dart';
import '../utils/debug_connection_fixed.dart';
import '../config/network_config.dart';

class DebugScreen extends StatefulWidget {
  const DebugScreen({super.key});

  @override
  State<DebugScreen> createState() => _DebugScreenState();
}

class _DebugScreenState extends State<DebugScreen> {
  Map<String, dynamic>? _diagnosticResults;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _runDiagnostics();
  }

  Future<void> _runDiagnostics() async {
    setState(() {
      _isLoading = true;
    });

    final results = await DebugConnection.diagnoseConnection();
    final endpoints = await DebugConnection.testAllEndpoints();

    setState(() {
      _diagnosticResults = {...results, 'endpoints': endpoints};
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug & Diagnostics'),
        backgroundColor: Colors.blue,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _runDiagnostics,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSection('Network Configuration', [
                      _buildInfoRow('Base URL', NetworkConfig.currentBaseUrl),
                      _buildInfoRow('Test URL', NetworkConfig.testUrl),
                    ]),

                    if (_diagnosticResults != null) ...[
                      _buildSection('Connection Status', [
                        _buildStatusRow(
                          'Server Reachable',
                          _diagnosticResults!['server_reachable'],
                        ),
                        _buildStatusRow(
                          'Database Connected',
                          _diagnosticResults!['database_connected'],
                        ),
                        _buildInfoRow(
                          'Response Time',
                          '${_diagnosticResults!['response_time']}ms',
                        ),
                        _buildInfoRow(
                          'User Count',
                          _diagnosticResults!['user_count'].toString(),
                        ),
                      ]),

                      if (_diagnosticResults!['error_details'] != null)
                        _buildSection('Error Details', [
                          Text(
                            _diagnosticResults!['error_details'],
                            style: const TextStyle(color: Colors.red),
                          ),
                        ]),

                      if (_diagnosticResults!['troubleshooting'] != null)
                        _buildSection('Troubleshooting Steps', [
                          ...List.generate(
                            _diagnosticResults!['troubleshooting'].length,
                            (index) => Text(
                              '• ${_diagnosticResults!['troubleshooting'][index]}',
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ]),

                      _buildSection('Endpoint Testing', [
                        ...(_diagnosticResults!['endpoints']
                                as Map<String, dynamic>)
                            .entries
                            .map(
                              (entry) =>
                                  _buildEndpointRow(entry.key, entry.value),
                            ),
                      ]),
                    ],

                    const SizedBox(height: 20),
                    Center(
                      child: ElevatedButton.icon(
                        onPressed: _runDiagnostics,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Re-run Diagnostics'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildStatusRow(String label, bool status) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Icon(
            status ? Icons.check_circle : Icons.error,
            color: status ? Colors.green : Colors.red,
            size: 20,
          ),
          const SizedBox(width: 4),
          Text(status ? 'OK' : 'Failed'),
        ],
      ),
    );
  }

  Widget _buildEndpointRow(String endpoint, Map<String, dynamic> result) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Expanded(child: Text(endpoint, style: const TextStyle(fontSize: 12))),
          Icon(
            result['reachable'] ? Icons.check_circle : Icons.error,
            color: result['reachable'] ? Colors.green : Colors.red,
            size: 16,
          ),
        ],
      ),
    );
  }
}
