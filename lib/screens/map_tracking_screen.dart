import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../services/location_service.dart';

class MapTrackingScreen extends StatefulWidget {
  const MapTrackingScreen({super.key});

  @override
  State<MapTrackingScreen> createState() => _MapTrackingScreenState();
}

class _MapTrackingScreenState extends State<MapTrackingScreen> {
  GoogleMapController? _mapController;
  LatLng? _currentPosition;
  Set<Marker> _markers = <Marker>{};

  @override
  void initState() {
    super.initState();
    _requestPermissionsAndStartTracking();
  }

  /// Request location permissions and then start tracking
  void _requestPermissionsAndStartTracking() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await LocationService.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Location services are disabled. Please enable location services on your device.'),
            ),
          );
        }
        return;
      }

      // Check and request location permissions
      var permission = await LocationService.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await LocationService.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Location permissions are denied. Please grant location permissions in app settings.'),
              ),
            );
          }
          return;
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Location permissions are permanently denied. Please grant location permissions in app settings.'),
            ),
          );
        }
        return;
      }

      // If we have permissions, start tracking
      _startTracking();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error requesting location permissions: $e')),
        );
      }
    }
  }

  void _startTracking() async {
    try {
      // Get initial position
      Position? position = await LocationService.getCurrentPosition();
      if (position == null) return;
      _currentPosition = LatLng(position.latitude, position.longitude);
      
      // Update map camera
      if (_mapController != null && _currentPosition != null) {
        _mapController!.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: _currentPosition!,
              zoom: 15,
            ),
          ),
        );
      }
      
      // Add marker for current position
      _updateMarker();
      
      // Start listening to position updates
      LocationService.getPositionStream().listen((Position newPosition) {
        if (mounted) {
          setState(() {
            _currentPosition = LatLng(newPosition.latitude, newPosition.longitude);
            _updateMarker();
            
            // Move camera to new position
            if (_mapController != null) {
              _mapController!.animateCamera(
                CameraUpdate.newCameraPosition(
                  CameraPosition(
                    target: _currentPosition!,
                    zoom: 15,
                  ),
                ),
              );
            }
          });
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error getting location: $e')),
        );
      }
    }
  }

  void _updateMarker() {
    if (_currentPosition != null) {
      setState(() {
        _markers = {
          Marker(
            markerId: const MarkerId('current_location'),
            position: _currentPosition!,
            infoWindow: const InfoWindow(title: 'Your Location'),
            icon: BitmapDescriptor.defaultMarker,
          ),
        };
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Device Tracking'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: _getCurrentLocation,
            tooltip: 'View Location Now',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _currentPosition == null
                ? const Center(child: CircularProgressIndicator())
                : GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: _currentPosition ?? const LatLng(0, 0),
                      zoom: 15,
                    ),
                    onMapCreated: (GoogleMapController controller) {
                      _mapController = controller;
                    },
                    markers: _markers,
                    myLocationEnabled: true,
                    myLocationButtonEnabled: false, // We'll use our custom button
                    zoomControlsEnabled: true,
                  ),
          ),
          // Add a refresh button at the bottom as well
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              onPressed: _getCurrentLocation,
              icon: const Icon(Icons.refresh),
              label: const Text('View Location Now'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _getCurrentLocation,
        child: const Icon(Icons.my_location),
        tooltip: 'View Location Now',
      ),
    );
  }

  /// Get current location and update the map
  void _getCurrentLocation() async {
    try {
      Position? position = await LocationService.getCurrentPosition();
      if (position != null && mounted) {
        setState(() {
          _currentPosition = LatLng(position.latitude, position.longitude);
          _updateMarker();
          
          // Move camera to new position
          if (_mapController != null) {
            _mapController!.animateCamera(
              CameraUpdate.newCameraPosition(
                CameraPosition(
                  target: _currentPosition!,
                  zoom: 15,
                ),
              ),
            );
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error getting location: $e')),
        );
      }
    }
  }
}
