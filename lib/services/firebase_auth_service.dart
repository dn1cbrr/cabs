import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// Firebase Authentication Service
/// Handles anonymous authentication for Firestore access
/// This works alongside the existing MySQL-based AuthService
class FirebaseAuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static bool _isInitialized = false;

  /// Get current Firebase user
  static User? get currentUser => _auth.currentUser;

  /// Check if user is signed in to Firebase
  static bool get isSignedIn => _auth.currentUser != null;

  /// Initialize Firebase Authentication
  /// Signs in anonymously to enable Firestore access
  static Future<bool> initialize() async {
    if (_isInitialized) {
      debugPrint('✅ Firebase Auth: Already initialized');
      return true;
    }

    try {
      debugPrint('🔐 Firebase Auth: Initializing...');

      // Check if already signed in
      if (_auth.currentUser != null) {
        debugPrint('✅ Firebase Auth: User already signed in (UID: ${_auth.currentUser!.uid})');
        _isInitialized = true;
        return true;
      }

      // Sign in anonymously
      final userCredential = await _auth.signInAnonymously();
      
      if (userCredential.user != null) {
        debugPrint('✅ Firebase Auth: Anonymous sign-in successful');
        debugPrint('   UID: ${userCredential.user!.uid}');
        _isInitialized = true;
        return true;
      } else {
        debugPrint('❌ Firebase Auth: Sign-in returned null user');
        return false;
      }
    } catch (e) {
      debugPrint('❌ Firebase Auth: Initialization failed');
      debugPrint('   Error: $e');
      
      // Provide helpful error messages
      if (e.toString().contains('network')) {
        debugPrint('   💡 Tip: Check internet connection');
      } else if (e.toString().contains('disabled')) {
        debugPrint('   💡 Tip: Enable Anonymous Auth in Firebase Console');
        debugPrint('   👉 https://console.firebase.google.com/project/transit-driver-tracking/authentication/providers');
      }
      
      return false;
    }
  }

  /// Ensure user is authenticated
  /// Attempts to sign in if not already authenticated
  static Future<bool> ensureAuthenticated() async {
    if (isSignedIn) {
      return true;
    }

    debugPrint('⚠️ Firebase Auth: User not signed in, attempting sign-in...');
    return await initialize();
  }

  /// Sign out from Firebase (optional - usually not needed for anonymous auth)
  static Future<void> signOut() async {
    try {
      await _auth.signOut();
      _isInitialized = false;
      debugPrint('✅ Firebase Auth: Signed out successfully');
    } catch (e) {
      debugPrint('❌ Firebase Auth: Sign-out failed: $e');
    }
  }

  /// Get current user UID (for Firestore document IDs)
  static String? getCurrentUserUid() {
    return _auth.currentUser?.uid;
  }

  /// Listen to auth state changes
  static Stream<User?> authStateChanges() {
    return _auth.authStateChanges();
  }

  /// Re-authenticate if session expired
  static Future<bool> reAuthenticate() async {
    try {
      if (_auth.currentUser == null) {
        debugPrint('🔄 Firebase Auth: Re-authenticating...');
        return await initialize();
      }
      return true;
    } catch (e) {
      debugPrint('❌ Firebase Auth: Re-authentication failed: $e');
      return false;
    }
  }

  /// Get authentication status details
  static Map<String, dynamic> getStatus() {
    final user = _auth.currentUser;
    return {
      'isInitialized': _isInitialized,
      'isSignedIn': user != null,
      'uid': user?.uid,
      'isAnonymous': user?.isAnonymous ?? false,
      'creationTime': user?.metadata.creationTime?.toIso8601String(),
      'lastSignInTime': user?.metadata.lastSignInTime?.toIso8601String(),
    };
  }

  /// Test Firebase Auth connection
  static Future<bool> testConnection() async {
    try {
      debugPrint('🧪 Firebase Auth: Testing connection...');
      
      // Try to get current user or sign in
      if (_auth.currentUser != null) {
        debugPrint('✅ Firebase Auth: Connection test passed (already signed in)');
        return true;
      }

      // Try anonymous sign-in
      final result = await _auth.signInAnonymously();
      
      if (result.user != null) {
        debugPrint('✅ Firebase Auth: Connection test passed (new sign-in)');
        return true;
      }

      debugPrint('❌ Firebase Auth: Connection test failed (null user)');
      return false;
    } catch (e) {
      debugPrint('❌ Firebase Auth: Connection test failed');
      debugPrint('   Error: $e');
      return false;
    }
  }
}
