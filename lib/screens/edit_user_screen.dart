import 'package:flutter/material.dart';
import '../services/admin_user_service.dart';
import '../services/auth_service.dart';
import '../models/user.dart';

class EditUserScreen extends StatefulWidget {
  final User user;

  const EditUserScreen({super.key, required this.user});

  @override
  State<EditUserScreen> createState() => _EditUserScreenState();
}

class _EditUserScreenState extends State<EditUserScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _birthdayController = TextEditingController();
  final _licenseNameController = TextEditingController();
  final _licenseNumberController = TextEditingController();
  final _licenseAddressController = TextEditingController();
  final _licenseCodesController = TextEditingController();
  final _licenseExpirationController = TextEditingController();
  final _roleController = TextEditingController();
  bool _isLoading = false;
  User? _currentUser;
  bool _isCurrentUserAdmin = false;

  @override
  void initState() {
    super.initState();
    _usernameController.text = widget.user.username;
    _emailController.text = widget.user.email;
    _fullNameController.text = widget.user.fullName;
    _phoneNumberController.text = widget.user.phone ?? '';
    _birthdayController.text = widget.user.birthday?.toIso8601String() ?? '';
    _licenseNameController.text = widget.user.licenseName ?? '';
    _licenseNumberController.text = widget.user.licenseNumber ?? '';
    _licenseAddressController.text = widget.user.licenseAddress ?? '';
    _licenseCodesController.text = widget.user.licenseCodes ?? '';
    _licenseExpirationController.text =
        widget.user.licenseExpiration?.toIso8601String() ?? '';
    _roleController.text = widget.user.role;
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    final user = await AuthService.getCurrentUser();
    if (mounted) {
      setState(() {
        _currentUser = user;
        _isCurrentUserAdmin = user?.id == widget.user.id;
      });
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _fullNameController.dispose();
    _phoneNumberController.dispose();
    _birthdayController.dispose();
    _licenseNameController.dispose();
    _licenseNumberController.dispose();
    _licenseAddressController.dispose();
    _licenseCodesController.dispose();
    _licenseExpirationController.dispose();
    _roleController.dispose();
    super.dispose();
  }

  void _saveUser() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final userData = {
        'user_id': int.parse(widget.user.id),
        'username': _usernameController.text.trim(),
        'email': _emailController.text.trim(),
        'full_name': _fullNameController.text.trim(),
        'phone_number': _phoneNumberController.text.trim(),
        'birthday': _birthdayController.text,
        'license_name': _licenseNameController.text.trim(),
        'license_number': _licenseNumberController.text.trim(),
        'license_address': _licenseAddressController.text.trim(),
        'license_codes': _licenseCodesController.text.trim(),
        'license_expiration': _licenseExpirationController.text,
        'role': _roleController.text.trim(),
      };

      try {
        final result = await AdminUserService.instance.updateUser(userData);

        if (result['success'] == true) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('User updated successfully')),
            );
            Navigator.of(context).pop();
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to update user: ${result['message']}'),
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error updating user: $e')));
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  void _showArchiveConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.warning_amber, color: Colors.orange),
              SizedBox(width: 8),
              Text('Archive User'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Are you sure you want to archive this user?',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text('Username: ${widget.user.username}'),
              Text('Full Name: ${widget.user.fullName}'),
              Text('Email: ${widget.user.email}'),
              const SizedBox(height: 12),
              const Text(
                'The user will be archived and hidden from the active user list. This action can be reversed later.',
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _archiveUser();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
              child: const Text('Archive'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _archiveUser() async {
    if (_currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: Unable to verify current user')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await AdminUserService.instance.archiveUser(
        int.parse(widget.user.id),
        int.parse(_currentUser!.id),
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        if (result['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('User archived successfully'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop(true); // Return true to indicate archival
        } else {
          // Check if it's the self-archive error
          if (result['error_code'] == 'SELF_ARCHIVE_FORBIDDEN') {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  result['message'] ?? 'Cannot archive your own admin account',
                ),
                backgroundColor: Colors.orange,
                duration: const Duration(seconds: 5),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(result['message'] ?? 'Failed to archive user'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error archiving user: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit User'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _isLoading ? null : _saveUser,
            tooltip: 'Save',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    labelText: 'Username',
                    hintText: 'Enter username',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surface,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Username is required';
                    }
                    if (value.length < 3) {
                      return 'Username must be at least 3 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    hintText: 'Enter email',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surface,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Email is required';
                    }
                    if (!RegExp(
                      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                    ).hasMatch(value)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _fullNameController,
                  decoration: InputDecoration(
                    labelText: 'Full Name',
                    hintText: 'Enter full name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surface,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Full name is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneNumberController,
                  decoration: InputDecoration(
                    labelText: 'Phone Number',
                    hintText: 'Enter phone number',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surface,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Phone number is required';
                    }
                    if (!RegExp(r'^\+?[0-9]{10,15}$').hasMatch(value)) {
                      return 'Please enter a valid phone number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _birthdayController,
                  decoration: InputDecoration(
                    labelText: 'Birthday',
                    hintText: 'YYYY-MM-DD',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surface,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Birthday is required';
                    }
                    if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(value)) {
                      return 'Please enter a valid date (YYYY-MM-DD)';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _licenseNameController,
                  decoration: InputDecoration(
                    labelText: 'License Name',
                    hintText: 'Enter license name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surface,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'License name is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _licenseNumberController,
                  decoration: InputDecoration(
                    labelText: 'License Number',
                    hintText: 'Enter license number',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surface,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'License number is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _licenseAddressController,
                  decoration: InputDecoration(
                    labelText: 'License Address',
                    hintText: 'Enter license address',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surface,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'License address is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _licenseCodesController,
                  decoration: InputDecoration(
                    labelText: 'License Codes',
                    hintText: 'Enter license codes',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surface,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'License codes is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _licenseExpirationController,
                  decoration: InputDecoration(
                    labelText: 'License Expiration',
                    hintText: 'YYYY-MM-DD',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surface,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'License expiration is required';
                    }
                    if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(value)) {
                      return 'Please enter a valid date (YYYY-MM-DD)';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _roleController,
                  decoration: InputDecoration(
                    labelText: 'Role',
                    hintText: 'Enter role (admin/user)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surface,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Role is required';
                    }
                    if (!['admin', 'user'].contains(value.toLowerCase())) {
                      return 'Role must be either admin or user';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                if (_isLoading)
                  const Center(child: CircularProgressIndicator())
                else
                  Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _saveUser,
                          icon: const Icon(Icons.save),
                          label: const Text('Save Changes'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.primary,
                            foregroundColor: Theme.of(
                              context,
                            ).colorScheme.onPrimary,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Archive button - hidden if viewing own admin account
                      if (!_isCurrentUserAdmin)
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: _showArchiveConfirmation,
                            icon: const Icon(Icons.archive),
                            label: const Text('Archive User'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.orange,
                              side: const BorderSide(color: Colors.orange),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        )
                      else
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50,
                            border: Border.all(color: Colors.orange.shade300),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: Colors.orange.shade700,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'You cannot archive your own admin account. This is a safety measure to prevent system lockout.',
                                  style: TextStyle(
                                    color: Colors.orange.shade900,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
