import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: false,
        title: const Text(
          'Profile',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),

          child: Column(
            children: [
              // ==========================================
              // PROFILE HEADER
              // ==========================================
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),

                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: AppColors.border),
                ),

                child: Column(
                  children: [
                    // Avatar
                    Container(
                      width: 86,
                      height: 86,

                      decoration: BoxDecoration(
                        color: AppColors.surfaceBlush,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.primary, width: 2),
                      ),

                      child: const Icon(
                        Icons.person_rounded,
                        size: 44,
                        color: AppColors.primary,
                      ),
                    ),

                    const SizedBox(height: 16),

                    const Text(
                      'Shrey',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),

                    const SizedBox(height: 5),

                    const Text(
                      'shrey@example.com',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Edit profile
                    OutlinedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Edit Profile will be available soon.',
                            ),
                          ),
                        );
                      },

                      icon: const Icon(Icons.edit_outlined, size: 18),

                      label: const Text('Edit Profile'),

                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,

                        side: const BorderSide(color: AppColors.border),

                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ==========================================
              // STATISTICS
              // ==========================================
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      icon: Icons.code_rounded,
                      value: '24',
                      label: 'Snippets',
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: _buildStatCard(
                      icon: Icons.star_rounded,
                      value: '8',
                      label: 'Favorites',
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: _buildStatCard(
                      icon: Icons.folder_outlined,
                      value: '6',
                      label: 'Categories',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // ==========================================
              // ACCOUNT
              // ==========================================
              _buildSectionTitle('Account'),

              const SizedBox(height: 10),

              _buildMenuCard(
                icon: Icons.person_outline_rounded,
                title: 'Personal Information',
                subtitle: 'Manage your profile details',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Personal Information will be available soon.',
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 10),

              _buildMenuCard(
                icon: Icons.lock_outline_rounded,
                title: 'Change Password',
                subtitle: 'Update your account password',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Change Password will be available soon.'),
                    ),
                  );
                },
              ),

              const SizedBox(height: 24),

              // ==========================================
              // PREFERENCES
              // ==========================================
              _buildSectionTitle('Preferences'),

              const SizedBox(height: 10),

              _buildMenuCard(
                icon: Icons.notifications_none_rounded,
                title: 'Notifications',
                subtitle: 'Manage notification preferences',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Notifications will be available soon.'),
                    ),
                  );
                },
              ),

              const SizedBox(height: 10),

              _buildMenuCard(
                icon: Icons.palette_outlined,
                title: 'Appearance',
                subtitle: 'Blush Sand theme',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Theme settings will be available soon.'),
                    ),
                  );
                },
              ),

              const SizedBox(height: 24),

              // ==========================================
              // LOGOUT
              // ==========================================
              SizedBox(
                width: double.infinity,
                height: 52,

                child: OutlinedButton.icon(
                  onPressed: () {
                    _showLogoutDialog(context);
                  },

                  icon: const Icon(Icons.logout_rounded),

                  label: const Text('Log Out'),

                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,

                    side: const BorderSide(color: AppColors.border),

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),

                    textStyle: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                'CodeSnippet Vault',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),

              const SizedBox(height: 4),

              const Text(
                'Your personal code library',
                style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================
  // STAT CARD
  // ==========================================

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),

      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),

      child: Column(
        children: [
          Icon(icon, size: 22, color: AppColors.primary),

          const SizedBox(height: 8),

          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: 3),

          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // SECTION TITLE
  // ==========================================

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,

      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  // ==========================================
  // MENU CARD
  // ==========================================

  Widget _buildMenuCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: AppColors.surface,

      borderRadius: BorderRadius.circular(16),

      child: InkWell(
        onTap: onTap,

        borderRadius: BorderRadius.circular(16),

        child: Container(
          padding: const EdgeInsets.all(16),

          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),

            border: Border.all(color: AppColors.border),
          ),

          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,

                decoration: BoxDecoration(
                  color: AppColors.surfaceBlush,
                  borderRadius: BorderRadius.circular(12),
                ),

                child: Icon(icon, color: AppColors.primary, size: 22),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================
  // LOGOUT DIALOG
  // ==========================================

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,

      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surface,

          title: const Text(
            'Log Out?',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),

          content: const Text(
            'Are you sure you want to log out of CodeSnippet Vault?',
            style: TextStyle(color: AppColors.textSecondary),
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },

              child: const Text('Cancel'),
            ),

            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Logout will be connected to Firebase soon.'),
                  ),
                );
              },

              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
              ),

              child: const Text('Log Out'),
            ),
          ],
        );
      },
    );
  }
}
