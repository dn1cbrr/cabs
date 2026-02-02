import 'dart:async';
import 'dart:math' show sin, cos, sqrt, atan2;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/driver_location_service.dart';
import '../services/realtime_location_service.dart';
import 'package:intl/intl.dart';

class AdminDriverTrackingScreen extends StatefulWidget {
  const AdminDriverTrackingScreen({super.key});

  @override
  State<AdminDriverTrackingScreen> createState() =>
      _AdminDriverTrackingScreenState();
}

class _AdminDriverTrackingScreenState extends State<AdminDriverTrackingScreen> {
  GoogleMapController? _mapController;
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> _allDrivers = [];
  List<Map<String, dynamic>> _filteredDrivers = [];
  bool _isLoading = true;
  bool _autoRefresh = true;
  bool _showListView = false;
  Timer? _refreshTimer;
  StreamSubscription? _firebaseSubscription;

  String _filterStatus = 'all'; // all, online, offline
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadDriversWithLocations();
    _startAutoRefresh();
    _subscribeToFirebaseLocations(); // Start Firebase real-time streaming
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _firebaseSubscription?.cancel(); // Cancel Firebase subscription
    _searchController.dispose();
    super.dispose();
  }

  /// Subscribe to Firebase real-time location updates
  void _subscribeToFirebaseLocations() {
    print('🔥 Starting Firebase real-time location streaming...');
    
    _firebaseSubscription = RealtimeLocationService.streamAllLocations().listen(
      (firebaseLocations) {
        if (!mounted) return;
        
        print('📡 Firebase: Received ${firebaseLocations.length} location updates');
        
        // Create a map of existing drivers by user_id for quick lookup
        Map<String, Map<String, dynamic>> existingDriversMap = {};
        for (var driver in _allDrivers) {
          final userId = driver['user_id']?.toString();
          if (userId != null) {
            existingDriversMap[userId] = driver;
          }
        }
        
        bool hasUpdates = false;
        List<Map<String, dynamic>> newDrivers = [];
        
        // Process each Firebase location update
        for (var firebaseData in firebaseLocations) {
          final userId = firebaseData['userId']?.toString() ?? 
                         firebaseData['driverId']?.toString();
          if (userId == null) continue;
          
          final lat = (firebaseData['lat'] as num?)?.toDouble();
          final lng = (firebaseData['lng'] as num?)?.toDouble();
          final isOnline = firebaseData['isOnline'] as bool? ?? false;
          final driverName = firebaseData['driverName']?.toString() ?? 'User';
          final updatedAt = firebaseData['updatedAt'];
          
          if (lat == null || lng == null) continue;
          
          // Check if this user exists in our drivers list
          if (existingDriversMap.containsKey(userId)) {
            // Update existing driver
            final driver = existingDriversMap[userId]!;
            
            if (driver['latitude'] != lat || 
                driver['longitude'] != lng || 
                driver['is_online'] != isOnline) {
              
              driver['latitude'] = lat;
              driver['longitude'] = lng;
              driver['is_online'] = isOnline;
              
              // Update last_location_update from Firebase timestamp
              if (updatedAt is Timestamp) {
                driver['last_location_update'] = updatedAt.toDate().toIso8601String();
              } else {
                driver['last_location_update'] = DateTime.now().toIso8601String();
              }
              
              hasUpdates = true;
              print('✅ Updated driver ${driver['name']} - lat: $lat, lng: $lng, online: $isOnline');
            }
          } else {
            // This is a regular user (not in drivers table) - add them as a temporary driver
            String lastUpdateStr;
            if (updatedAt is Timestamp) {
              lastUpdateStr = updatedAt.toDate().toIso8601String();
            } else {
              lastUpdateStr = DateTime.now().toIso8601String();
            }
            
            final newDriver = {
              'id': userId,
              'user_id': userId,
              'name': driverName,
              'contact': 'N/A',
              'vehicle_type': 'User',
              'plate_number': 'N/A',
              'latitude': lat,
              'longitude': lng,
              'is_online': isOnline,
              'last_location_update': lastUpdateStr,
              'is_firebase_only': true, // Flag to identify Firebase-only users
            };
            
            newDrivers.add(newDriver);
            hasUpdates = true;
            print('✅ Added new user from Firebase: $driverName - lat: $lat, lng: $lng, online: $isOnline');
          }
        }
        
        // Add new Firebase-only users to the list
        if (newDrivers.isNotEmpty) {
          // Remove old Firebase-only entries first
          _allDrivers.removeWhere((d) => d['is_firebase_only'] == true);
          // Add new ones
          _allDrivers.addAll(newDrivers);
        }
        
        // Only trigger UI update if we actually have changes
        if (hasUpdates && mounted) {
          setState(() {
            _applyFilters();
          });
        }
      },
      onError: (e) {
        print('❌ Firebase stream error: $e');
        // Don't show error to user, just log it
        // MySQL polling will continue to work as fallback
      },
    );
    
    print('🔥 Firebase real-time streaming started successfully');
  }

  void _startAutoRefresh() {
    _refreshTimer?.cancel();
    if (_autoRefresh) {
      _refreshTimer = Timer.periodic(const Duration(seconds: 15), (timer) {
        if (mounted) {
          _loadDriversWithLocations(showLoading: false);
        }
      });
    }
  }

  void _toggleAutoRefresh() {
    setState(() {
      _autoRefresh = !_autoRefresh;
    });
    if (_autoRefresh) {
      _startAutoRefresh();
    } else {
      _refreshTimer?.cancel();
    }
  }

  Future<void> _loadDriversWithLocations({bool showLoading = true}) async {
    if (showLoading && mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      print('Fetching drivers with locations...');
      final result = await DriverLocationService.getDriversWithLocations();
      print('API Response: ${result['success']}');

      if (mounted) {
        setState(() {
          _isLoading = false;
          if (result['success']) {
            _allDrivers = List<Map<String, dynamic>>.from(result['drivers']);
            print('Loaded ${_allDrivers.length} drivers');

            // Debug: Print drivers with location data
            final driversWithLocation = _allDrivers
                .where((d) => d['latitude'] != null && d['longitude'] != null)
                .length;
            print('Drivers with location data: $driversWithLocation');

            _applyFilters();
          } else {
            print('Error from API: ${result['message']}');
            if (showLoading) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error: ${result['message']}'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        });
      }
    } catch (e) {
      print('Exception loading drivers: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        if (showLoading) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error loading drivers: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _applyFilters() {
    List<Map<String, dynamic>> filtered = List.from(_allDrivers);

    // Apply status filter
    if (_filterStatus == 'online') {
      filtered = filtered.where((driver) => _isDriverOnline(driver)).toList();
    } else if (_filterStatus == 'offline') {
      filtered = filtered.where((driver) => !_isDriverOnline(driver)).toList();
    }

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((driver) {
        final name = (driver['name'] ?? '').toString().toLowerCase();
        final contact = (driver['contact'] ?? '').toString().toLowerCase();
        final vehicle = (driver['vehicle_type'] ?? '').toString().toLowerCase();
        final plate = (driver['plate_number'] ?? '').toString().toLowerCase();
        final query = _searchQuery.toLowerCase();

        return name.contains(query) ||
            contact.contains(query) ||
            vehicle.contains(query) ||
            plate.contains(query);
      }).toList();
    }

    setState(() {
      _filteredDrivers = filtered;
    });
  }

  bool _isDriverOnline(Map<String, dynamic> driver) {
    if (driver['last_location_update'] == null) return false;

    try {
      final lastUpdate = DateTime.parse(driver['last_location_update']);
      final now = DateTime.now();
      final difference = now.difference(lastUpdate);

      // Consider online if updated within last 5 minutes
      return difference.inMinutes < 5;
    } catch (e) {
      return false;
    }
  }

  Color _getDriverStatusColor(Map<String, dynamic> driver) {
    if (driver['latitude'] == null || driver['longitude'] == null) {
      return Colors.grey;
    }

    if (_isDriverOnline(driver)) {
      return Colors.green;
    } else {
      return Colors.orange;
    }
  }

  String _getDriverStatus(Map<String, dynamic> driver) {
    if (driver['latitude'] == null || driver['longitude'] == null) {
      return 'No Location';
    }

    if (_isDriverOnline(driver)) {
      return 'Online';
    } else {
      return 'Offline';
    }
  }

  String _formatLastUpdate(String? timestamp) {
    if (timestamp == null) return 'Never';

    try {
      final dateTime = DateTime.parse(timestamp);
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inMinutes < 1) {
        return 'Just now';
      } else if (difference.inMinutes < 60) {
        return '${difference.inMinutes}m ago';
      } else if (difference.inHours < 24) {
        return '${difference.inHours}h ago';
      } else {
        return DateFormat('MMM dd, HH:mm').format(dateTime);
      }
    } catch (e) {
      return 'Unknown';
    }
  }

  Set<Marker> _buildDriverMarkers() {
    Set<Marker> markers = {};
    int markerIdCounter = 0;

    for (var driver in _filteredDrivers) {
      if (driver['latitude'] != null && driver['longitude'] != null) {
        final statusColor = _getDriverStatusColor(driver);
        final driverId = driver['id']?.toString() ?? 'driver_${markerIdCounter++}';
        
        // Determine marker color based on status
        double hue = BitmapDescriptor.hueRed;
        if (statusColor == Colors.green) {
          hue = BitmapDescriptor.hueGreen;
        } else if (statusColor == Colors.orange) {
          hue = BitmapDescriptor.hueOrange;
        } else if (statusColor == Colors.grey) {
          hue = BitmapDescriptor.hueAzure;
        }

        markers.add(
          Marker(
            markerId: MarkerId('driver_$driverId'),
            position: LatLng(
              double.parse(driver['latitude'].toString()),
              double.parse(driver['longitude'].toString()),
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(hue),
            infoWindow: InfoWindow(
              title: driver['name'] ?? 'Unknown Driver',
              snippet: '${_getDriverStatus(driver)} - ${driver['vehicle_type'] ?? 'N/A'}',
              onTap: () => _showDriverInfo(driver),
            ),
            onTap: () => _showDriverInfo(driver),
          ),
        );
      }
    }

    return markers;
  }

  void _showDriverInfo(Map<String, dynamic> driver) {
    final statusColor = _getDriverStatusColor(driver);
    final status = _getDriverStatus(driver);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(20),
          child: ListView(
            controller: scrollController,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.person, size: 30, color: statusColor),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          driver['name'] ?? 'Unknown Driver',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            status,
                            style: TextStyle(
                              color: statusColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildInfoRow(Icons.phone, 'Contact', driver['contact'] ?? 'N/A'),
              const Divider(height: 24),
              _buildInfoRow(
                Icons.directions_car,
                'Vehicle Type',
                driver['vehicle_type'] ?? 'N/A',
              ),
              const Divider(height: 24),
              _buildInfoRow(
                Icons.confirmation_number,
                'Plate Number',
                driver['plate_number'] ?? 'N/A',
              ),
              const Divider(height: 24),
              _buildInfoRow(
                Icons.location_on,
                'Coordinates',
                driver['latitude'] != null && driver['longitude'] != null
                    ? '${driver['latitude']}, ${driver['longitude']}'
                    : 'No location data',
              ),
              const Divider(height: 24),
              _buildInfoRow(
                Icons.access_time,
                'Last Update',
                _formatLastUpdate(driver['last_location_update']),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        if (driver['latitude'] != null &&
                            driver['longitude'] != null && _mapController != null) {
                          _mapController!.animateCamera(
                            CameraUpdate.newLatLngZoom(
                              LatLng(
                                double.parse(driver['latitude'].toString()),
                                double.parse(driver['longitude'].toString()),
                              ),
                              15,
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.my_location),
                      label: const Text('Center on Map'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.close),
                      label: const Text('Close'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _filterStatus == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _filterStatus = value;
          _applyFilters();
        });
      },
      selectedColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
      checkmarkColor: Theme.of(context).colorScheme.primary,
    );
  }

  Widget _buildDriverListItem(Map<String, dynamic> driver) {
    final statusColor = _getDriverStatusColor(driver);
    final status = _getDriverStatus(driver);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: Stack(
          children: [
            CircleAvatar(
              backgroundColor: statusColor.withOpacity(0.2),
              child: Icon(Icons.person, color: statusColor),
            ),
            if (_isDriverOnline(driver))
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.greenAccent,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
          ],
        ),
        title: Text(
          driver['name'] ?? 'Unknown Driver',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${driver['vehicle_type']} - ${driver['plate_number']}'),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _formatLastUpdate(driver['last_location_update']),
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                ),
              ],
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.location_on),
          onPressed: () {
            setState(() {
              _showListView = false;
            });
            if (driver['latitude'] != null && driver['longitude'] != null && _mapController != null) {
              _mapController!.animateCamera(
                CameraUpdate.newLatLngZoom(
                  LatLng(
                    double.parse(driver['latitude'].toString()),
                    double.parse(driver['longitude'].toString()),
                  ),
                  15,
                ),
              );
            }
          },
        ),
        onTap: () => _showDriverInfo(driver),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final onlineCount = _filteredDrivers
        .where((d) => _isDriverOnline(d))
        .length;
    final withLocationCount = _filteredDrivers
        .where((d) => d['latitude'] != null && d['longitude'] != null)
        .length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Driver Tracking'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: Icon(_showListView ? Icons.map : Icons.list),
            onPressed: () {
              setState(() {
                _showListView = !_showListView;
              });
            },
            tooltip: _showListView ? 'Map View' : 'List View',
          ),
          IconButton(
            icon: Icon(
              _autoRefresh ? Icons.pause : Icons.play_arrow,
              color: _autoRefresh ? Colors.green : Colors.grey,
            ),
            onPressed: _toggleAutoRefresh,
            tooltip: _autoRefresh ? 'Pause Auto-Refresh' : 'Start Auto-Refresh',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _loadDriversWithLocations(),
            tooltip: 'Refresh Now',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Search and Filter Bar
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.white,
                  child: Column(
                    children: [
                      TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search drivers...',
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() {
                                      _searchQuery = '';
                                      _applyFilters();
                                    });
                                  },
                                )
                              : null,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                            _applyFilters();
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildFilterChip('All', 'all'),
                            const SizedBox(width: 8),
                            _buildFilterChip('Online', 'online'),
                            const SizedBox(width: 8),
                            _buildFilterChip('Offline', 'offline'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Map or List View
                Expanded(
                  child: _showListView
                      ? _filteredDrivers.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.person_off,
                                      size: 64,
                                      color: Colors.grey[400],
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'No drivers found',
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.grey[600],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      _allDrivers.isEmpty
                                          ? 'No drivers registered in the system'
                                          : 'Try adjusting your filters',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[500],
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    ElevatedButton.icon(
                                      onPressed: () =>
                                          _loadDriversWithLocations(),
                                      icon: const Icon(Icons.refresh),
                                      label: const Text('Refresh'),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                itemCount: _filteredDrivers.length,
                                itemBuilder: (context, index) {
                                  return _buildDriverListItem(
                                    _filteredDrivers[index],
                                  );
                                },
                              )
                      : _filteredDrivers.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.location_off,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No drivers to display',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _allDrivers.isEmpty
                                    ? 'No drivers registered in the system'
                                    : 'No drivers match your current filters',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[500],
                                ),
                              ),
                              const SizedBox(height: 24),
                              ElevatedButton.icon(
                                onPressed: () => _loadDriversWithLocations(),
                                icon: const Icon(Icons.refresh),
                                label: const Text('Refresh'),
                              ),
                            ],
                          ),
                        )
                      : GoogleMap(
                          onMapCreated: (GoogleMapController controller) {
                            _mapController = controller;
                          },
                          initialCameraPosition: const CameraPosition(
                            target: LatLng(14.5995, 120.9842),
                            zoom: 12,
                          ),
                          markers: _buildDriverMarkers(),
                          myLocationEnabled: true,
                          myLocationButtonEnabled: true,
                          mapType: MapType.normal,
                          zoomControlsEnabled: true,
                          compassEnabled: true,
                        ),
                ),

                // Debug Info Bar (only show if no drivers have location data)
                if (_allDrivers.isNotEmpty &&
                    _allDrivers
                        .where(
                          (d) =>
                              d['latitude'] != null && d['longitude'] != null,
                        )
                        .isEmpty)
                  Container(
                    padding: const EdgeInsets.all(12),
                    color: Colors.orange.shade100,
                    child: Row(
                      children: [
                        const Icon(
                          Icons.info_outline,
                          color: Colors.orange,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'No location data available. Drivers need to open the tracking screen to share their location.',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.orange.shade900,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Status Bar
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatusItem(
                        Icons.circle,
                        'Online',
                        onlineCount.toString(),
                        Colors.green,
                      ),
                      _buildStatusItem(
                        Icons.location_on,
                        'With Location',
                        withLocationCount.toString(),
                        Colors.blue,
                      ),
                      _buildStatusItem(
                        Icons.people,
                        'Total',
                        _filteredDrivers.length.toString(),
                        Colors.grey,
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildStatusItem(
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }
}
