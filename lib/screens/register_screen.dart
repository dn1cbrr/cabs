import 'package:flutter/material.dart';
import 'package:transit/services/auth_service.dart';
import 'dashboard_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _fullNameController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      if (_passwordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Passwords do not match!')),
        );
        return;
      }

      setState(() => _isLoading = true);

      // Store BuildContext-dependent objects before async gap
      final scaffoldMessenger = ScaffoldMessenger.of(context);
      final navigator = Navigator.of(context);

      try {
        final result = await AuthService.register(
          _usernameController.text,
          _emailController.text,
          _passwordController.text,
          _fullNameController.text,
          phoneNumber: _phoneNumberController.text,
        );

        if (!mounted) return;

        setState(() => _isLoading = false);

        if (result['success']) {
          scaffoldMessenger.showSnackBar(
            SnackBar(content: Text(result['message'])),
          );

          // Check if OTP is required
          if (result['otp_required'] == true) {
            // Show OTP verification dialog and wait for result
            final otpVerified = await _showOtpDialog(context, result['user'].id);

            if (otpVerified == true) {
              if (!mounted) return;
              // Get current user and navigate to dashboard
              final currentUser = await AuthService.getCurrentUser();
              if (mounted && currentUser != null) {
                navigator.pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => DashboardScreen(user: currentUser),
                  ),
                );
              }
            }
          } else {
            // Redirect to user dashboard
            navigator.pushReplacement(
              MaterialPageRoute(
                builder: (context) => DashboardScreen(user: result['user']),
              ),
            );
          }
        } else {
          scaffoldMessenger.showSnackBar(
            SnackBar(content: Text(result['message'])),
          );
        }
      } catch (e) {
        if (!mounted) return;
        setState(() => _isLoading = false);
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }


  Future<bool?> _showOtpDialog(BuildContext context, int userId) async {
    final otpController = TextEditingController();

    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            bool isLoading = false;

            Future<void> handleVerify() async {
              setState(() => isLoading = true);

              final scaffoldMessenger = ScaffoldMessenger.of(context);

              try {
                final result =
                    await AuthService.verifyOtp(userId, otpController.text);

                if (!context.mounted) return;

                if (result['success']) {
                  Navigator.of(dialogContext).pop(true);
                } else {
                  scaffoldMessenger.showSnackBar(
                    SnackBar(content: Text(result['message'])),
                  );
                  setState(() => isLoading = false);
                }
              } catch (e) {
                if (!context.mounted) return;
                scaffoldMessenger.showSnackBar(
                  SnackBar(content: Text('Error: ${e.toString()}')),
                );
                setState(() => isLoading = false);
              }
            }

            return AlertDialog(
              title: const Text('Verify OTP'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                      'Please enter the OTP sent to your email or phone number'),
                  const SizedBox(height: 20),
                  TextField(
                    controller: otpController,
                    decoration: const InputDecoration(
                      labelText: 'OTP Code',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 20),
                  if (isLoading) const CircularProgressIndicator(),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: isLoading
                      ? null
                      : () => Navigator.of(dialogContext).pop(false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: isLoading ? null : handleVerify,
                  child: const Text('Verify'),
                ),
              ],
            );
          },
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register New Account'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Create Account',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              // Account Information Section
              const Text(
                'Account Information',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) => value?.isEmpty ?? true ? 'Please enter username' : null,
              ),
              const SizedBox(height: 10),
              
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Please enter email';
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value!)) {
                    return 'Please enter valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              
              TextFormField(
                controller: _fullNameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (value) => value?.isEmpty ?? true ? 'Please enter full name' : null,
              ),
              const SizedBox(height: 10),
              
              TextFormField(
                controller: _phoneNumberController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) => value?.isEmpty ?? true ? 'Please enter phone number' : null,
              ),
              const SizedBox(height: 10),
              
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
                validator: (value) => value?.isEmpty ?? true ? 'Please enter password' : null,
              ),
              const SizedBox(height: 10),
              
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: _obscureConfirmPassword,
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(_obscureConfirmPassword ? Icons.visibility : Icons.visibility_off),
                    onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                  ),
                ),
                validator: (value) => value?.isEmpty ?? true ? 'Please confirm password' : null,
              ),
              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleRegister,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Register', style: TextStyle(fontSize: 18)),
                ),
              ),
              
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Already have an account?'),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Login'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
