import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/admin_service.dart';
import '../widget/admin_auth_guard.dart';

class AdminProfileScreen extends StatefulWidget {
  const AdminProfileScreen({Key? key}) : super(key: key);

  @override
  State<AdminProfileScreen> createState() => _AdminProfileScreenState();
}

class _AdminProfileScreenState extends State<AdminProfileScreen> {
  Map<String, dynamic>? _userData;
  bool _isLoading = true;
  bool _isEditing = false;

  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  final AdminService _adminService = AdminService();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _loadUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    try {
      // First try to get data from backend
      try {
        final backendUserData = await _adminService.getCurrentAdminProfile();
        if (mounted) {
          // Save the fetched data to SharedPreferences
          final SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('userData', json.encode(backendUserData));

          setState(() {
            _userData = backendUserData;
            _nameController.text = backendUserData['name'] ?? '';
            _emailController.text = backendUserData['email'] ?? '';
            _phoneController.text = backendUserData['phone'] ?? '';
            _isLoading = false;
          });
          return;
        }
      } catch (e) {
        // If backend fails, fall back to local data
        print('Backend fetch failed, using local data: $e');
      }

      // Fallback to local data
      final userData = await AdminHelper.getCurrentUser();
      if (userData != null && mounted) {
        // Ensure admin role is correctly set if this is an admin panel
        if (userData['role'] == null || userData['role'] == 'user') {
          userData['role'] = 'admin';
          // Update stored data with correct role
          final SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('userData', json.encode(userData));
        }

        setState(() {
          _userData = userData;
          _nameController.text = userData['name'] ?? '';
          _emailController.text = userData['email'] ?? '';
          _phoneController.text = userData['phone'] ?? '';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading profile: $e')));
      }
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      // Update local storage with new data
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final updatedUserData = {
        ..._userData!,
        'name': _nameController.text,
        'email': _emailController.text,
        'phone': _phoneController.text,
      };

      await prefs.setString('userData', json.encode(updatedUserData));

      setState(() {
        _userData = updatedUserData;
        _isEditing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error updating profile: $e')));
    }
  }

  void _cancelEditing() {
    setState(() {
      _nameController.text = _userData!['name'] ?? '';
      _emailController.text = _userData!['email'] ?? '';
      _phoneController.text = _userData!['phone'] ?? '';
      _isEditing = false;
    });
  }

  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                await AdminHelper.logout();
                if (mounted) {
                  Navigator.of(context).pop();
                  Navigator.pushReplacementNamed(context, '/login');
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AdminAuthGuard(
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          title: const Text(
            'Admin Profile',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          backgroundColor: Colors.deepPurple,
          elevation: 0,
          actions: [
            if (!_isEditing)
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.white),
                onPressed: () => setState(() => _isEditing = true),
              ),
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.white),
              onPressed: _showLogoutConfirmation,
            ),
          ],
        ),
        body:
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _userData == null
                ? const Center(child: Text('No user data found'))
                : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // Profile Header Card
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            gradient: const LinearGradient(
                              colors: [Colors.deepPurple, Colors.purple],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: Column(
                            children: [
                              // Profile Picture
                              Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withOpacity(0.2),
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 3,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.person,
                                  size: 50,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _userData!['name'] ?? 'Admin User',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  (_userData!['role']
                                                  ?.toString()
                                                  .toLowerCase() ==
                                              'admin' ||
                                          _userData!['role']
                                                  ?.toString()
                                                  .toLowerCase() ==
                                              'administrator')
                                      ? 'ADMIN'
                                      : (_userData!['role']
                                              ?.toString()
                                              .toUpperCase() ??
                                          'ADMIN'),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Profile Information Card
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.info_outline,
                                    color: Colors.deepPurple,
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Profile Information',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const Spacer(),
                                  if (_isEditing) ...[
                                    TextButton(
                                      onPressed: _cancelEditing,
                                      child: const Text('Cancel'),
                                    ),
                                    const SizedBox(width: 8),
                                    ElevatedButton(
                                      onPressed: _saveProfile,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.deepPurple,
                                      ),
                                      child: const Text('Save'),
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 20),
                              Form(
                                key: _formKey,
                                child: Column(
                                  children: [
                                    _buildProfileField(
                                      'Name',
                                      _nameController,
                                      Icons.person_outline,
                                      validator: (value) {
                                        if (value?.isEmpty ?? true) {
                                          return 'Name is required';
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 16),
                                    _buildProfileField(
                                      'Email',
                                      _emailController,
                                      Icons.email_outlined,
                                      keyboardType: TextInputType.emailAddress,
                                      validator: (value) {
                                        if (value?.isEmpty ?? true) {
                                          return 'Email is required';
                                        }
                                        if (!RegExp(
                                          r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                                        ).hasMatch(value!)) {
                                          return 'Please enter a valid email';
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 16),
                                    _buildProfileField(
                                      'Phone',
                                      _phoneController,
                                      Icons.phone_outlined,
                                      keyboardType: TextInputType.phone,
                                      validator: (value) {
                                        if (value?.isEmpty ?? true) {
                                          return 'Phone is required';
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 16),
                                    _buildReadOnlyField(
                                      'Role',
                                      (_userData!['role']
                                                      ?.toString()
                                                      .toLowerCase() ==
                                                  'admin' ||
                                              _userData!['role']
                                                      ?.toString()
                                                      .toLowerCase() ==
                                                  'administrator')
                                          ? 'Administrator'
                                          : (_userData!['role']
                                                  ?.toString()
                                                  .toUpperCase() ??
                                              'ADMIN'),
                                      Icons.admin_panel_settings_outlined,
                                      statusColor: Colors.deepPurple,
                                    ),
                                    const SizedBox(height: 16),
                                    _buildReadOnlyField(
                                      'Status',
                                      _userData!['isVerified'] == true
                                          ? 'Verified'
                                          : 'Unverified',
                                      Icons.verified_user_outlined,
                                      statusColor:
                                          _userData!['isVerified'] == true
                                              ? Colors.green
                                              : Colors.orange,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Quick Actions Card
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(
                                    Icons.dashboard_outlined,
                                    color: Colors.deepPurple,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Quick Actions',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildActionButton(
                                      'Dashboard',
                                      Icons.dashboard,
                                      Colors.blue,
                                      () => Navigator.pushReplacementNamed(
                                        context,
                                        '/admin-dashboard',
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _buildActionButton(
                                      'Users',
                                      Icons.people,
                                      Colors.green,
                                      () => Navigator.pushNamed(
                                        context,
                                        '/admin-users',
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildActionButton(
                                      'Properties',
                                      Icons.home,
                                      Colors.orange,
                                      () => Navigator.pushNamed(
                                        context,
                                        '/admin-properties',
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _buildActionButton(
                                      'Vehicles',
                                      Icons.directions_car,
                                      Colors.purple,
                                      () => Navigator.pushNamed(
                                        context,
                                        '/admin-vehicles',
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
      ),
    );
  }

  Widget _buildProfileField(
    String label,
    TextEditingController controller,
    IconData icon, {
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      enabled: _isEditing,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.deepPurple),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.deepPurple, width: 2),
        ),
        filled: !_isEditing,
        fillColor: !_isEditing ? Colors.grey[100] : null,
      ),
    );
  }

  Widget _buildReadOnlyField(
    String label,
    String value,
    IconData icon, {
    Color? statusColor,
  }) {
    return TextFormField(
      initialValue: value,
      enabled: false,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: statusColor ?? Colors.deepPurple),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        filled: true,
        fillColor: Colors.grey[100],
        labelStyle: TextStyle(color: statusColor),
      ),
      style: TextStyle(
        color: statusColor ?? Colors.black87,
        fontWeight: statusColor != null ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }

  Widget _buildActionButton(
    String title,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 24),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}