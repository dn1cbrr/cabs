import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import '../models/user.dart';
import '../services/user_service.dart';
import '../services/auth_service.dart';
import '../widgets/date_picker_field.dart';

class ProfileScreen extends StatefulWidget {
  final User user;

  const ProfileScreen({super.key, required this.user});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _fullNameController;
  late TextEditingController _emailController;
  late TextEditingController _usernameController;
  late TextEditingController _phoneNumberController;
  late TextEditingController _licenseNameController;
  late TextEditingController _licenseNumberController;
  late TextEditingController _licenseAddressController;
  late TextEditingController _licenseCodesController;
  late TextEditingController _licenseExpirationController;
  late DateTime? _birthday;
  late DateTime? _licenseExpirationDate;
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();

  bool _isEditing = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _birthday = widget.user.birthday;
    _licenseExpirationDate = widget.user.expirationDate;
  }

  void _initializeControllers() {
    _fullNameController = TextEditingController(text: widget.user.fullName);
    _emailController = TextEditingController(text: widget.user.email);
    _usernameController = TextEditingController(text: widget.user.username);
    _phoneNumberController = TextEditingController(text: '');
    _licenseNameController = TextEditingController(text: '');
    _licenseNumberController = TextEditingController(text: '');
    _licenseAddressController = TextEditingController(text: '');
    _licenseCodesController = TextEditingController(text: '');
    _licenseExpirationController = TextEditingController();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _usernameController.dispose();
    _phoneNumberController.dispose();
    _licenseNameController.dispose();
    _licenseNumberController.dispose();
    _licenseAddressController.dispose();
    _licenseCodesController.dispose();
    _licenseExpirationController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        // Prepare the data to update
        final Map<String, dynamic> profileData = {
          'user_id': widget.user.id,
          'full_name': _fullNameController.text,
          'email': _emailController.text,
          'phone_number': _phoneNumberController.text,
          'birthday': _birthday?.toIso8601String(),
          'license_name': _licenseNameController.text,
          'license_number': _licenseNumberController.text,
          'license_address': _licenseAddressController.text,
          'license_codes': _licenseCodesController.text,
          'license_expiration': _licenseExpirationDate?.toIso8601String(),
        };

        // Add profile photo if selected
        if (_profileImage != null) {
          profileData['profile_photo'] = _profileImage!.path;
        }

        final result = await UserService.updateUserProfile(profileData);

        if (mounted) {
          setState(() => _isLoading = false);

          if (result['success']) {
            // Update the user data in shared preferences
            final prefs = await SharedPreferences.getInstance();
            final userData = {
              'id': widget.user.id,
              'username': widget.user.username,
              'email': _emailController.text,
              'full_name': _fullNameController.text,
              'role': widget.user.role,
              'birthday': _birthday?.toIso8601String(),
              'expiration_date': _licenseExpirationDate?.toIso8601String(),
            };
            await prefs.setString('user_data', jsonEncode(userData));

            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Profile updated successfully')),
              );
              setState(() => _isEditing = false);
            }
          } else {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(result['message'] ?? 'Failed to update profile')),
              );
            }
          }
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error updating profile: ${e.toString()}')),
          );
        }
      }
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _profileImage = File(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: ${e.toString()}')),
        );
      }
    }
  }

  void _onBirthdaySelected(DateTime? date) {
    if (date != null) {
      setState(() {
        _birthday = date;
      });
    }
  }

  void _onLicenseExpirationSelected(DateTime? date) {
    if (date != null) {
      setState(() {
        _licenseExpirationDate = date;
        _licenseExpirationController.text = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      });
    }
  }

  void _showChangePasswordDialog() {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    bool obscureCurrent = true;
    bool obscureNew = true;
    bool obscureConfirm = true;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: const Row(
                children: [
                  Icon(Icons.lock, color: Colors.blue),
                  SizedBox(width: 8),
                  Text('Change Password'),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: currentPasswordController,
                      obscureText: obscureCurrent,
                      decoration: InputDecoration(
                        labelText: 'Current Password',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(obscureCurrent ? Icons.visibility : Icons.visibility_off),
                          onPressed: () {
                            setState(() => obscureCurrent = !obscureCurrent);
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: newPasswordController,
                      obscureText: obscureNew,
                      decoration: InputDecoration(
                        labelText: 'New Password',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(obscureNew ? Icons.visibility : Icons.visibility_off),
                          onPressed: () {
                            setState(() => obscureNew = !obscureNew);
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: confirmPasswordController,
                      obscureText: obscureConfirm,
                      decoration: InputDecoration(
                        labelText: 'Confirm New Password',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(obscureConfirm ? Icons.visibility : Icons.visibility_off),
                          onPressed: () {
                            setState(() => obscureConfirm = !obscureConfirm);
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: _isLoading ? null : () async {
                    if (newPasswordController.text != confirmPasswordController.text) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Passwords do not match'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                      return;
                    }

                    if (newPasswordController.text.length < 8) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Password must be at least 8 characters'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                      return;
                    }

                    setState(() => _isLoading = true);

                    final result = await AuthService.changePassword(
                      widget.user.id,
                      currentPasswordController.text,
                      newPasswordController.text,
                    );

                    if (mounted) {
                      setState(() => _isLoading = false);

                      if (result['success']) {
                        // ignore: use_build_context_synchronously
                        Navigator.pop(context);
                        // ignore: use_build_context_synchronously
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(result['message']),
                            backgroundColor: Colors.green,
                          ),
                        );
                      } else {
                        // ignore: use_build_context_synchronously
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(result['message']),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text('Change Password'),
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
        title: const Text('My Profile'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _isLoading ? null : _saveProfile,
              tooltip: 'Save Profile',
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Header
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.grey,
                            backgroundImage: _profileImage != null 
                              ? FileImage(_profileImage!) 
                              : widget.user.profilePhoto != null && widget.user.profilePhoto!.isNotEmpty
                                ? NetworkImage(widget.user.profilePhoto!) as ImageProvider
                                : null,
                            child: _profileImage == null && (widget.user.profilePhoto == null || widget.user.profilePhoto!.isEmpty)
                              ? const Icon(
                                  Icons.person,
                                  size: 50,
                                  color: Colors.white,
                                )
                              : null,
                          ),
                          if (_isEditing)
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: CircleAvatar(
                                radius: 20,
                                backgroundColor: Theme.of(context).colorScheme.primary,
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.camera_alt,
                                    size: 20,
                                    color: Colors.white,
                                  ),
                                  onPressed: _pickImage,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        widget.user.fullName,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        widget.user.role.toUpperCase(),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: widget.user.role == 'admin' 
                            ? Colors.red 
                            : Theme.of(context).colorScheme.secondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Personal Information Section
              Text(
                'Personal Information',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _fullNameController,
                enabled: _isEditing,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) => value?.isEmpty ?? true ? 'Please enter full name' : null,
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _emailController,
                enabled: _isEditing,
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
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _usernameController,
                enabled: false, // Username shouldn't be editable
                decoration: const InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person_outline),
                ),
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _phoneNumberController,
                enabled: _isEditing,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              
              DatePickerField(
                label: 'Birthday',
                hintText: 'Select birthday',
                icon: Icons.cake,
                initialDate: _birthday,
                onDateSelected: _onBirthdaySelected,
              ),
              const SizedBox(height: 24),
              
              // License Information Section
              Text(
                'License Information',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _licenseNameController,
                enabled: _isEditing,
                decoration: const InputDecoration(
                  labelText: 'License Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.badge),
                ),
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _licenseNumberController,
                enabled: _isEditing,
                decoration: const InputDecoration(
                  labelText: 'License Number',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.confirmation_number),
                ),
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _licenseAddressController,
                enabled: _isEditing,
                decoration: const InputDecoration(
                  labelText: 'License Address',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _licenseCodesController,
                enabled: _isEditing,
                decoration: const InputDecoration(
                  labelText: 'DL Codes',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.code),
                ),
              ),
              const SizedBox(height: 16),
              
              DatePickerField(
                label: 'License Expiration Date',
                hintText: 'Select expiration date',
                icon: Icons.date_range,
                initialDate: _licenseExpirationDate,
                onDateSelected: _onLicenseExpirationSelected,
              ),
              const SizedBox(height: 32),
              
              // Action Buttons
              if (!_isEditing)
                Center(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      setState(() => _isEditing = true);
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit Profile'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    ),
                  ),
                ),
              
              if (_isEditing)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: _isLoading ? null : () {
                        setState(() => _isEditing = false);
                      },
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton.icon(
                      onPressed: _isLoading ? null : _saveProfile,
                      icon: _isLoading 
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Icon(Icons.save),
                      label: const Text('Save'),
                    ),
                  ],
                ),
                
              const SizedBox(height: 32),
              
              // Change Password Section
              Text(
                'Security',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              Card(
                elevation: 4,
                child: ListTile(
                  leading: const Icon(Icons.lock, color: Colors.blue),
                  title: const Text('Change Password'),
                  subtitle: const Text('Update your account password'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    _showChangePasswordDialog();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

