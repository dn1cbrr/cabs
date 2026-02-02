import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'services/auth_service.dart';
import 'services/admin_user_service.dart';
import 'services/background_location_service.dart';
import 'services/firebase_auth_service.dart';
import 'models/user.dart';
import 'screens/dashboard_screen.dart';
import 'screens/register_screen.dart';
import 'screens/driver_dashboard_screen.dart';
import 'screens/driver_reports_screen.dart';
import 'screens/map_tracking_screen.dart';
import 'screens/trip_history_screen.dart';
import 'screens/add_trip_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/reset_password_screen.dart';
import 'screens/multi_sensor_test_screen.dart';
import 'screens/esp32_setup_screen.dart';
import 'screens/esp32_seat_monitoring_screen.dart';
import 'screens/esp32_connection_selection_screen.dart';
import 'screens/debug_tracking_screen.dart';
import 'utils/animations.dart';
import 'widgets/animated_widgets.dart';
import 'utils/responsive_utils.dart';
import 'dart:async';

void main() {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set up global error handling to prevent silent crashes
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint('Flutter Error: ${details.exception}');
  };

  // Run the app immediately to prevent black screen
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DECINA TRANSPORT',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme:
            ColorScheme.fromSeed(
              seedColor: const Color(0xFF6366F1), // Vibrant indigo
              brightness: Brightness.light,
            ).copyWith(
              primary: const Color(0xFF6366F1), // Indigo
              secondary: const Color(0xFF8B5CF6), // Purple
              tertiary: const Color(0xFFEC4899), // Pink accent
              surface: Colors.white,
              background: const Color(0xFFF8FAFC),
              error: const Color(0xFFEF4444),
              onPrimary: Colors.white,
              onSecondary: Colors.white,
              onSurface: const Color(0xFF1E293B),
              onBackground: const Color(0xFF0F172A),
            ),

        // Modern Google Fonts
        textTheme: GoogleFonts.poppinsTextTheme().copyWith(
          headlineLarge: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 32,
            letterSpacing: -0.5,
            color: const Color(0xFF0F172A),
          ),
          headlineMedium: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 28,
            letterSpacing: -0.5,
            color: const Color(0xFF1E293B),
          ),
          headlineSmall: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 24,
            letterSpacing: -0.3,
            color: const Color(0xFF1E293B),
          ),
          titleLarge: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            fontSize: 20,
            letterSpacing: -0.2,
          ),
          titleMedium: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            letterSpacing: 0,
          ),
          titleSmall: GoogleFonts.inter(
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
          bodyLarge: GoogleFonts.inter(
            fontSize: 16,
            letterSpacing: 0.1,
            height: 1.5,
          ),
          bodyMedium: GoogleFonts.inter(
            fontSize: 14,
            letterSpacing: 0.1,
            height: 1.5,
          ),
          bodySmall: GoogleFonts.inter(fontSize: 12, letterSpacing: 0.1),
        ),

        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: CupertinoPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          },
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            textStyle: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),

        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            side: const BorderSide(color: Color(0xFF6366F1), width: 2),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            textStyle: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFF1F5F9),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFEF4444), width: 2.5),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 18,
          ),
          labelStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF64748B),
          ),
          hintStyle: GoogleFonts.inter(
            fontSize: 14,
            color: const Color(0xFF94A3B8),
          ),
        ),

        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          color: Colors.white,
          shadowColor: const Color(0xFF6366F1).withOpacity(0.1),
        ),

        appBarTheme: AppBarTheme(
          elevation: 0,
          centerTitle: true,
          backgroundColor: Colors.transparent,
          foregroundColor: const Color(0xFF0F172A),
          titleTextStyle: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF0F172A),
            letterSpacing: -0.3,
          ),
        ),
      ),
      home: const MyHomePage(title: 'DECINA TRANSPORT'),
      routes: {
        '/driver-dashboard': (context) => const DriverDashboardScreen(),
        '/driver-reports': (context) => const DriverReportsScreen(),
        '/dashboard': (context) => DashboardScreen(
          user: User(id: '', username: '', email: '', fullName: '', role: ''),
        ), // This is a fallback, should use MaterialPageRoute instead
        '/map-tracking': (context) => const MapTrackingScreen(),
        '/trip-history': (context) => TripHistoryScreen(
          driverId: ModalRoute.of(context)!.settings.arguments as int?,
        ),
        '/add-trip': (context) => const AddTripScreen(),
        '/multi-sensor-test': (context) => const MultiSensorTestScreen(),
        '/esp32-setup': (context) => const ESP32SetupScreen(),
        '/esp32-connection-selection': (context) =>
            const ESP32ConnectionSelectionScreen(),
        '/esp32-seat-monitoring': (context) =>
            const ESP32SeatMonitoringScreen(),
        '/debug-tracking': (context) => const DebugTrackingScreen(),
        '/reset-password': (context) {
          final token = ModalRoute.of(context)!.settings.arguments as String?;
          return ResetPasswordScreen(token: token ?? '');
        },
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  Timer? _heartbeatTimer;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    // Initialize Firebase and check login status after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeAppAndCheckLogin();
    });
  }

  Future<void> _initializeAppAndCheckLogin() async {
    // 1. Initialize Firebase Core in the background with timeout
    try {
      if (Firebase.apps.isEmpty) {
        debugPrint('🔥 Initializing Firebase Core...');
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        ).timeout(
          const Duration(seconds: 5),
          onTimeout: () {
            debugPrint('⚠️ Firebase Core initialization timed out (non-blocking)');
            return Firebase.app(); // Return default app if already initialized or throw
          },
        );
        debugPrint('✅ Firebase Core initialized successfully');
      }
    } catch (e) {
      debugPrint('❌ Firebase Core initialization error (handled): $e');
      // Continue anyway - the app should still function for basic features
    }

    // 2. Initialize Firebase Anonymous Authentication (CRITICAL for Firestore)
    // This enables real-time driver tracking by allowing Firestore writes
    try {
      debugPrint('🔐 Initializing Firebase Anonymous Auth...');
      final authSuccess = await FirebaseAuthService.initialize().timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          debugPrint('⚠️ Firebase Auth initialization timed out');
          return false;
        },
      );

      if (authSuccess) {
        debugPrint('✅ Firebase Auth initialized - Firestore writes enabled');
        debugPrint('   UID: ${FirebaseAuthService.getCurrentUserUid()}');
      } else {
        debugPrint('⚠️ Firebase Auth initialization failed - Firestore writes may not work');
        debugPrint('   💡 Real-time driver tracking requires Firebase Authentication');
        debugPrint('   💡 Enable Anonymous Auth in Firebase Console if not already enabled');
      }
    } catch (e) {
      debugPrint('❌ Firebase Auth initialization error: $e');
      debugPrint('   ⚠️ Driver tracking may not work without Firebase Auth');
    }

    // 3. Proceed to check login status
    _checkLoginStatus();
  }

  void _checkLoginStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn = await AuthService.isLoggedIn(prefs: prefs);
      
      if (!mounted) return;
      
      if (isLoggedIn) {
        final user = await AuthService.getCurrentUser(prefs: prefs);
        
        if (!mounted) return;
        
        if (user != null) {
          // Start background location tracking for drivers (non-blocking)
          // Don't await this - let it run in background
          _initializeDriverTracking(user);

          // Navigate to dashboard immediately
          Navigator.of(context).pushReplacement(
            PageTransitions.slideFade(DashboardScreen(user: user)),
          );
        }
      }
    } catch (e) {
      debugPrint('Error checking login status: $e');
      // Continue to show login screen on error
    }
  }

  /// Initialize background location tracking for all users
  /// This runs in the background and doesn't block the UI
  Future<void> _initializeDriverTracking(User user) async {
    // Start tracking for ALL users (no role check)
    try {
      debugPrint(
        'Initializing background tracking for user: ${user.username}',
      );
      
      // Use a timeout to prevent indefinite waiting
      final success = await BackgroundLocationService.instance
          .startTracking()
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              debugPrint('Background tracking initialization timed out');
              return false;
            },
          );
          
      if (success) {
        debugPrint('Background location tracking started successfully');
      } else {
        debugPrint('Failed to start background location tracking');
      }
    } catch (e) {
      debugPrint('Error initializing user tracking: $e');
      // Don't throw - just log the error and continue
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _stopHeartbeat();
    super.dispose();
  }

  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final result = await AuthService.login(
          _usernameController.text.trim(),
          _passwordController.text,
        ).timeout(
          const Duration(seconds: 30),
          onTimeout: () => {
            'success': false,
            'message': 'Login request timed out. Please check your internet connection.',
            'error_type': 'timeout',
          },
        );

        if (!mounted) return;

        setState(() {
          _isLoading = false;
        });

        if (result['success']) {
          final user = result['user'] as User;
          _currentUserId = user.id;
          _startHeartbeat();

          // Start background location tracking for drivers (non-blocking)
          // Don't await this - let it run in background
          _initializeDriverTracking(user);

          // Navigate immediately
          Navigator.of(context).pushReplacement(
            PageTransitions.slideFade(DashboardScreen(user: user)),
          );
        } else {
          // Enhanced error message with more details
          String errorMessage = result['message'];
          if (result['error_type'] == 'network') {
            errorMessage +=
                '\nPlease check if the server is running and accessible.';
          } else if (result['error_type'] == 'format') {
            errorMessage += '\nServer response format is invalid.';
          } else if (result['error_type'] == 'timeout') {
            errorMessage += '\nThe request took too long to complete.';
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 5),
            ),
          );
        }
      } catch (e) {
        if (!mounted) return;
        
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An unexpected error occurred: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (_currentUserId != null) {
        AdminUserService.instance.sendHeartbeat(_currentUserId!);
      }
    });
  }

  void _stopHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
  }

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = ResponsiveUtils.responsivePadding(context, 24.0);
    final verticalPadding = ResponsiveUtils.responsivePadding(context, 16.0);

    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Text(
          widget.title,
          style: GoogleFonts.poppins(
            fontSize: ResponsiveUtils.responsiveFontSize(context, 20),
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF6366F1).withOpacity(0.05),
              Colors.white,
              Colors.white,
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: verticalPadding,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  FadeInAnimation(
                    duration: const Duration(milliseconds: 600),
                    child: ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                      ).createShader(bounds),
                      child: Text(
                        'Welcome Back!',
                        style: GoogleFonts.poppins(
                          fontSize: ResponsiveUtils.responsiveFontSize(
                            context,
                            32,
                          ),
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: ResponsiveUtils.responsiveSpacing(context, 12),
                  ),
                  FadeInAnimation(
                    delay: const Duration(milliseconds: 200),
                    duration: const Duration(milliseconds: 600),
                    child: Text(
                      'Sign in to access your dashboard',
                      style: GoogleFonts.inter(
                        fontSize: ResponsiveUtils.responsiveFontSize(
                          context,
                          16,
                        ),
                        color: const Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(
                    height: ResponsiveUtils.responsiveSpacing(context, 20),
                  ),
                  // Logo with scale animation
                  FadeInAnimation(
                    delay: const Duration(milliseconds: 300),
                    duration: const Duration(milliseconds: 800),
                    child: Center(
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.8, end: 1.0),
                        duration: const Duration(milliseconds: 800),
                        curve: Curves.elasticOut,
                        builder: (context, scale, child) {
                          return Transform.scale(scale: scale, child: child);
                        },
                        child: Image(
                          image: const AssetImage('lib/images/decinalogo.png'),
                          width: MediaQuery.of(context).size.width * 0.5,
                          height:
                              (MediaQuery.of(context).size.width * 0.5) *
                              (130 / 200),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: ResponsiveUtils.responsiveSpacing(context, 40),
                  ),

                  // Username Field with animation
                  AnimatedListItem(
                    index: 0,
                    delay: const Duration(milliseconds: 100),
                    child: AnimatedTextField(
                      controller: _usernameController,
                      labelText: 'Username',
                      hintText: 'Enter your username',
                      prefixIcon: Icons.person,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your username';
                        }
                        if (value.length < 3) {
                          return 'Username must be at least 3 characters';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Password Field with animation
                  AnimatedListItem(
                    index: 1,
                    delay: const Duration(milliseconds: 100),
                    child: AnimatedTextField(
                      controller: _passwordController,
                      labelText: 'Password',
                      hintText: 'Enter your password',
                      prefixIcon: Icons.lock,
                      obscureText: !_isPasswordVisible,
                      suffixIcon: AnimatedIconButton(
                        icon: _isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  AnimatedListItem(
                    index: 2,
                    delay: const Duration(milliseconds: 100),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            PageTransitions.slideRight(
                              const ForgotPasswordScreen(),
                            ),
                          );
                        },
                        child: Text(
                          'Forgot Password?',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Login Button with gradient
                  AnimatedListItem(
                    index: 3,
                    delay: const Duration(milliseconds: 100),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF6366F1).withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: AnimatedButton(
                        onPressed: _isLoading ? null : _handleLogin,
                        backgroundColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        elevation: 0,
                        child: _isLoading
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : Text(
                                'Sign In',
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Register Button with animation
                  AnimatedListItem(
                    index: 5,
                    delay: const Duration(milliseconds: 100),
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          PageTransitions.slideUp(const RegisterScreen()),
                        );
                      },
                      child: RichText(
                        text: TextSpan(
                          text: 'Don\'t have an account? ',
                          style: GoogleFonts.inter(
                            color: const Color(0xFF64748B),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                          children: [
                            TextSpan(
                              text: 'Register',
                              style: GoogleFonts.inter(
                                color: const Color(0xFF6366F1),
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ); //I love you Irish <3
  }
}
