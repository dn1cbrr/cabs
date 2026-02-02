import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'firebase_auth_service.dart';

class RealtimeLocationService {
  static final _db = FirebaseFirestore.instance;
  static const String _collection = 'drivers_locations';
  static bool _settingsInitialized = false;

  /// Ensure Firestore settings are properly initialized
  static void _ensureSettingsInitialized() {
    if (_settingsInitialized) return;
    try {
      _db.settings = const Settings(
        persistenceEnabled: true,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      );
      _settingsInitialized = true;
      debugPrint('✅ Firestore: Settings initialized with persistence enabled');
    } catch (e) {
      // settings might already be in use, which is fine
      debugPrint('⚠️ Firestore: Could not re-initialize settings (already in use)');
      _settingsInitialized = true;
    }
  }

  /// Check if network is available
  static Future<bool> _isNetworkAvailable() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      return !connectivityResult.contains(ConnectivityResult.none) && 
             connectivityResult.isNotEmpty;
    } catch (e) {
      debugPrint('⚠️ Connectivity check failed: $e');
      return true; // Default to true if check fails
    }
  }

  /// Upsert driver location with online status
  static Future<void> upsertDriverLocation({
    required String driverId,
    required double latitude,
    required double longitude,
    String? userId,
    String? driverName,
    bool isOnline = true,
  }) async {
    _ensureSettingsInitialized();

    // CRITICAL: Ensure Firebase Authentication before Firestore writes
    if (!FirebaseAuthService.isSignedIn) {
      debugPrint('⚠️ Firestore: User not authenticated, attempting sign-in...');
      final authSuccess = await FirebaseAuthService.ensureAuthenticated();
      if (!authSuccess) {
        debugPrint('❌ Firestore: Cannot update location - Firebase Auth failed');
        debugPrint('   💡 Enable Anonymous Auth in Firebase Console');
        debugPrint('   👉 https://console.firebase.google.com/project/transit-driver-tracking/authentication/providers');
        return;
      }
      debugPrint('✅ Firestore: Authentication successful, proceeding with update');
    }

    // Fast check for network connectivity to avoid known Firebase sync errors 
    // when network is restricted or disallowed by settings
    if (!await _isNetworkAvailable()) {
      debugPrint('ℹ️ Firestore: Skipping update due to no network connectivity');
      return;
    }

    try {
      final docRef = _db.collection(_collection).doc(driverId);
      await docRef.set({
        'driverId': driverId,
        'userId': userId,
        'driverName': driverName,
        'lat': latitude,
        'lng': longitude,
        'isOnline': isOnline,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      
      debugPrint('✅ Firestore: Location updated for driver $driverId (lat: $latitude, lng: $longitude, online: $isOnline)');
    } catch (e) {
      final errorStr = e.toString();
      if (errorStr.contains('SYNC_OP_STATE_INVALID') || 
          errorStr.contains('disallowed by settings/network')) {
        debugPrint('⚠️ Firestore Sync Restricted: The operation was disallowed by system network/data settings.');
        debugPrint('   This typically happens in background or Data Saver mode. The update will sync when allowed.');
      } else {
        debugPrint('❌ Firestore Error: Failed to update location for driver $driverId');
        debugPrint('   Error details: $e');
      }
      // Don\'t throw - allow app to continue even if Firestore fails
      // MySQL updates will still work
    }
  }

  /// Set driver online/offline status in Firestore
  static Future<void> setDriverOnlineStatus({
    required String driverId,
    required bool isOnline,
  }) async {
    _ensureSettingsInitialized();
    
    // Ensure Firebase Authentication
    if (!FirebaseAuthService.isSignedIn) {
      debugPrint('⚠️ Firestore: User not authenticated for status update');
      await FirebaseAuthService.ensureAuthenticated();
      if (!FirebaseAuthService.isSignedIn) {
        debugPrint('❌ Firestore: Cannot update status - Firebase Auth failed');
        return;
      }
    }
    
    if (!await _isNetworkAvailable()) {
      debugPrint('ℹ️ Firestore: Skipping status update due to no network connectivity');
      return;
    }

    try {
      final docRef = _db.collection(_collection).doc(driverId);
      await docRef.set({
        'driverId': driverId,
        'isOnline': isOnline,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      
      debugPrint('✅ Firestore: Online status set to $isOnline for driver $driverId');
    } catch (e) {
      final errorStr = e.toString();
      if (errorStr.contains('SYNC_OP_STATE_INVALID') || 
          errorStr.contains('disallowed by settings/network')) {
        debugPrint('⚠️ Firestore Sync Restricted: The status update was disallowed by system network settings.');
      } else {
        debugPrint('❌ Firestore Error: Failed to set online status for driver $driverId');
        debugPrint('   Error details: $e');
      }
    }
  }

  /// Stream all driver locations
  static Stream<List<Map<String, dynamic>>> streamAllLocations() {
    _ensureSettingsInitialized();
    return _db
        .collection(_collection)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((d) => d.data()).toList());
  }

  /// Stream only online drivers
  static Stream<List<Map<String, dynamic>>> streamOnlineDrivers() {
    _ensureSettingsInitialized();
    return _db
        .collection(_collection)
        .where('isOnline', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((d) => d.data()).toList());
  }

  /// Stream drivers within a time window (e.g., last 5 minutes)
  static Stream<List<Map<String, dynamic>>> streamRecentDrivers({
    int minutesAgo = 5,
  }) {
    _ensureSettingsInitialized();
    final cutoffTime = DateTime.now().subtract(Duration(minutes: minutesAgo));
    
    return _db
        .collection(_collection)
        .where('updatedAt', isGreaterThan: Timestamp.fromDate(cutoffTime))
        .snapshots()
        .map((snapshot) => snapshot.docs.map((d) => d.data()).toList());
  }

  /// Delete driver location (when going offline)
  static Future<void> deleteDriverLocation(String driverId) async {
    _ensureSettingsInitialized();
    
    if (!await _isNetworkAvailable()) return;

    try {
      await _db.collection(_collection).doc(driverId).delete();
      debugPrint('✅ Firestore: Deleted location for driver $driverId');
    } catch (e) {
      final errorStr = e.toString();
      if (!errorStr.contains('SYNC_OP_STATE_INVALID') && 
          !errorStr.contains('disallowed by settings/network')) {
        debugPrint('❌ Firestore Error: Failed to delete location for driver $driverId');
        debugPrint('   Error details: $e');
      }
    }
  }

  /// Clean up old locations (older than specified minutes)
  static Future<void> cleanupOldLocations({int minutesAgo = 10}) async {
    _ensureSettingsInitialized();
    
    if (!await _isNetworkAvailable()) return;

    try {
      final cutoffTime = DateTime.now().subtract(Duration(minutes: minutesAgo));
      
      final snapshot = await _db
          .collection(_collection)
          .where('updatedAt', isLessThan: Timestamp.fromDate(cutoffTime))
          .get();

      if (snapshot.docs.isEmpty) return;

      final batch = _db.batch();
      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
      
      debugPrint('✅ Firestore: Cleaned up ${snapshot.docs.length} old locations');
    } catch (e) {
      final errorStr = e.toString();
      if (!errorStr.contains('SYNC_OP_STATE_INVALID') && 
          !errorStr.contains('disallowed by settings/network')) {
        debugPrint('❌ Firestore Error: Failed to cleanup old locations');
        debugPrint('   Error details: $e');
      }
    }
  }

  /// Get driver location by ID
  static Future<Map<String, dynamic>?> getDriverLocation(
    String driverId,
  ) async {
    _ensureSettingsInitialized();
    try {
      final doc = await _db.collection(_collection).doc(driverId).get();
      return doc.exists ? doc.data() : null;
    } catch (e) {
      debugPrint('❌ Firestore Error: Failed to get location for driver $driverId');
      debugPrint('   Error details: $e');
      return null;
    }
  }
  
  /// Test Firestore connection
  static Future<bool> testConnection() async {
    _ensureSettingsInitialized();
    
    // Check Firebase Authentication first
    if (!FirebaseAuthService.isSignedIn) {
      debugPrint('⚠️ Firestore: Not authenticated, attempting sign-in for test...');
      final authSuccess = await FirebaseAuthService.ensureAuthenticated();
      if (!authSuccess) {
        debugPrint('❌ Firestore: Connection test failed - Firebase Auth required');
        debugPrint('   💡 Enable Anonymous Auth in Firebase Console');
        return false;
      }
    }
    
    if (!await _isNetworkAvailable()) {
      debugPrint('❌ Firestore: Connection test failed - No network available');
      return false;
    }

    try {
      await _db
          .collection('test')
          .doc('connection_test')
          .set({
            'timestamp': FieldValue.serverTimestamp(),
            'test': true,
          });
      
      debugPrint('✅ Firestore: Connection test successful');
      
      // Clean up test document
      await _db.collection('test').doc('connection_test').delete();
      
      return true;
    } catch (e) {
      final errorStr = e.toString();
      debugPrint('❌ Firestore: Connection test failed');
      debugPrint('   Error details: $e');
      
      if (errorStr.contains('SYNC_OP_STATE_INVALID') || 
          errorStr.contains('disallowed by settings/network')) {
        debugPrint('   REASON: Operation disallowed by system network/data settings.');
      } else {
        debugPrint('   This might be due to:');
        debugPrint('   1. Firestore rules blocking writes');
        debugPrint('   2. No internet connection');
        debugPrint('   3. Firebase not properly initialized');
      }
      return false;
    }
  }
}
