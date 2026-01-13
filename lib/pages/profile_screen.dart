import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../providers/theme_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late TextEditingController _roomController;
  late TextEditingController _phoneController;
  late TextEditingController _emergencyController;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    final user = Provider.of<UserProvider>(context, listen: false).currentUser;
    _roomController = TextEditingController(text: user?.roomNumber ?? '');
    _phoneController = TextEditingController(text: user?.phoneNumber ?? '');
    _emergencyController = TextEditingController(text: user?.emergencyContact ?? '');
  }

  @override
  void dispose() {
    _roomController.dispose();
    _phoneController.dispose();
    _emergencyController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final currentUser = userProvider.currentUser;

    if (currentUser != null) {
      final updatedUser = currentUser.copyWith(
        roomNumber: _roomController.text,
        phoneNumber: _phoneController.text,
        emergencyContact: _emergencyController.text,
      );

      await userProvider.updateUser(updatedUser);
      setState(() => _isEditing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.save : Icons.edit),
            onPressed: () {
              if (_isEditing) {
                _saveProfile();
              } else {
                setState(() => _isEditing = true);
              }
            },
          ),
        ],
      ),
      body: Consumer2<UserProvider, ThemeProvider>(
        builder: (context, userProvider, themeProvider, child) {
          final user = userProvider.currentUser;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.primary,
                        Theme.of(context).colorScheme.secondary,
                      ],
                    ),
                  ),
                  child: Center(
                    child: Text(
                      user?.name[0].toUpperCase() ?? 'U',
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  user?.name ?? 'User',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  '@${user?.username ?? 'username'}',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 30),
                if ((user?.role ?? 'student') != 'warden') ...[
                  _buildProfileCard(
                    context,
                    icon: Icons.meeting_room,
                    label: 'Room Number',
                    controller: _roomController,
                    enabled: _isEditing,
                  ),
                  const SizedBox(height: 16),
                ],
                _buildProfileCard(
                  context,
                  icon: Icons.phone,
                  label: 'Phone Number',
                  controller: _phoneController,
                  enabled: _isEditing,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                _buildProfileCard(
                  context,
                  icon: Icons.emergency,
                  label: 'Emergency Contact',
                  controller: _emergencyController,
                  enabled: _isEditing,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 30),
                Card(
                  child: ListTile(
                    leading: Icon(
                      themeProvider.isDarkMode
                          ? Icons.dark_mode
                          : Icons.light_mode,
                    ),
                    title: const Text('Dark Mode'),
                    trailing: Switch(
                      value: themeProvider.isDarkMode,
                      onChanged: (value) => themeProvider.toggleTheme(),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      userProvider.logout();
                      Navigator.of(context).pushReplacementNamed('/');
                    },
                    icon: const Icon(Icons.logout),
                    label: const Text('Logout'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      foregroundColor: Colors.red,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required TextEditingController controller,
    required bool enabled,
    TextInputType? keyboardType,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 16),
            Expanded(
              child: TextField(
                controller: controller,
                enabled: enabled,
                keyboardType: keyboardType,
                decoration: InputDecoration(
                  labelText: label,
                  border: InputBorder.none,
                  filled: false,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


