import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../components/components.dart';
import '../constants/responsive_utils.dart';
import '../services/services.dart';
class ProfilePage extends StatefulWidget {
  final String? userId;

  const ProfilePage({super.key, this.userId});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _emailController = TextEditingController();
  bool _isEditing = false;
  bool _isLoading = true;
  Map<String, dynamic>? _userData;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    if (widget.userId == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final firestoreService = context.read<FirestoreService>();
      final authService = context.read<AuthService>();
      
      final userData = await firestoreService.getUserProfile(widget.userId!);
      
      final currentUser = authService.currentUser;
      
      if (mounted) {
        setState(() {
          _userData = userData;
          _nameController.text = userData?['name'] ?? '';
          _phoneController.text = userData?['phone'] ?? '';
          _addressController.text = userData?['address'] ?? '';
          _emailController.text = currentUser?.email ?? userData?['email'] ?? '';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _saveProfile() async {
    if (widget.userId == null) return;

    try {
      final firestoreService = context.read<FirestoreService>();
      
      await firestoreService.saveUserProfile(
        widget.userId!,
        {
          'name': _nameController.text.trim(),
          'phone': _phoneController.text.trim(),
          'address': _addressController.text.trim(),
          'email': _emailController.text.trim(),
        },
      );

      if (mounted) {
        setState(() => _isEditing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving profile: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.orange),
      );
    }

    return SingleChildScrollView(
      padding: Responsive.screenPadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Profile Module',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 18),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Card
              Expanded(
                child: GlowCard(
                  glowColor: Colors.purple,
                  child: Column(
                    children: [
                      // Avatar
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [Colors.orange, Colors.orangeAccent],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.orange.withAlpha((0.5 * 255).toInt()),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.person,
                          size: 48,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        _emailController.text.isNotEmpty 
                          ? _emailController.text 
                          : 'user@example.com',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Premium Member',
                        style: TextStyle(color: Colors.orange),
                      ),
                      const SizedBox(height: 18),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _StatWidget(value: '12', label: 'Orders'),
                          _StatWidget(value: '4.8', label: 'Rating'),
                          _StatWidget(value: '2 Years', label: 'Member'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 24),

              // Edit Profile Form
              Expanded(
                child: GlowCard(
                  glowColor: Colors.blue,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Profile Information',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                setState(() => _isEditing = !_isEditing);
                              },
                              icon: Icon(
                                _isEditing ? Icons.close : Icons.edit,
                                color: Colors.orange,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        StyledTextField(
                          controller: _nameController,
                          label: 'Full Name',
                          hint: 'Enter your name',
                          icon: Icons.person,
                          enabled: _isEditing,
                        ),
                        const SizedBox(height: 12),
                        StyledTextField(
                          controller: _emailController,
                          label: 'Email',
                          hint: 'Enter your email',
                          icon: Icons.email,
                          enabled: false, // Email is read-only from Firebase Auth
                        ),
                        const SizedBox(height: 12),
                        StyledTextField(
                          controller: _phoneController,
                          label: 'Phone Number',
                          hint: 'Enter your phone',
                          icon: Icons.phone,
                          enabled: _isEditing,
                        ),
                        const SizedBox(height: 12),
                        StyledTextField(
                          controller: _addressController,
                          label: 'Address',
                          hint: 'Enter your address',
                          icon: Icons.location_on,
                          enabled: _isEditing,
                        ),
                        const SizedBox(height: 18),
                        if (_isEditing)
                          SizedBox(
                            width: double.infinity,
                            child: StyledButton(
                              text: 'Save Changes',
                              icon: Icons.save,
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  _saveProfile();
                                }
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          GlowCard(
            glowColor: Colors.teal,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Settings',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                _buildSettingItem(Icons.notifications, 'Notifications', true),
                _buildSettingItem(Icons.dark_mode, 'Dark Mode', true),
                _buildSettingItem(Icons.language, 'Language', false),
                _buildSettingItem(Icons.help, 'Help & Support', false),
                _buildSettingItem(Icons.privacy_tip, 'Privacy Policy', false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem(IconData icon, String title, bool isSwitch) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.orange),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ),
          if (isSwitch)
            Switch(
              value: true,
              onChanged: (_) {},
              activeTrackColor: Colors.orange,
            )
          else
            const Icon(Icons.chevron_right, color: Colors.white38),
        ],
      ),
    );
  }
}

class _StatWidget extends StatelessWidget {
  final String value;
  final String label;

  const _StatWidget({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.orange,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white70),
        ),
      ],
    );
  }
}

