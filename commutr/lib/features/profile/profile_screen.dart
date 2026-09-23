import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/routing/app_routes.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _notifications = true;
  bool _locationSharing = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Profile',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AppColors.border, height: 1),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Passenger Header Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: const BoxDecoration(
                    color: Color(0xFFDBEAFE),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text(
                      'P',
                      style: TextStyle(
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.w800,
                        fontSize: 22,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Passenger',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w800,
                        fontSize: 17,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Member since 2024',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Privacy Notice Banner
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 2),
                  child: Icon(Icons.lock_outline_rounded, size: 16, color: Color(0xFF64748B)),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Your individual location is not shown to other passengers. Only aggregated, verified signals are used for bus tracking.',
                    style: TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Account Section
          _buildSectionTitle('Account'),
          _buildCard([
            _buildActionRow(
              iconText: '📍',
              label: 'Saved Stops',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('3 Saved Stops in Thane West'), duration: Duration(seconds: 1)),
                );
              },
            ),
            _buildDivider(),
            _buildActionRow(
              iconText: '🗺',
              label: 'Saved Routes',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Saved: TMT 50, TMT 2'), duration: Duration(seconds: 1)),
                );
              },
            ),
          ]),

          const SizedBox(height: 16),

          // Preferences Section
          _buildSectionTitle('Preferences'),
          _buildCard([
            _buildToggleRow(
              iconText: '🔔',
              label: 'Notifications',
              value: _notifications,
              onChanged: (val) => setState(() => _notifications = val),
            ),
            _buildDivider(),
            _buildToggleRow(
              iconText: '📡',
              label: 'Location Sharing',
              value: _locationSharing,
              onChanged: (val) => setState(() => _locationSharing = val),
            ),
          ]),

          const SizedBox(height: 16),

          // Privacy Section
          _buildSectionTitle('Privacy'),
          _buildCard([
            _buildActionRow(
              iconText: '🔒',
              label: 'Location Permissions',
              onTap: () => Navigator.pushNamed(context, AppRoutes.privacy),
            ),
            _buildDivider(),
            _buildActionRow(
              iconText: '🛡',
              label: 'Privacy Settings',
              onTap: () => Navigator.pushNamed(context, AppRoutes.privacy),
            ),
          ]),

          const SizedBox(height: 16),

          // Driver & Operator Portal
          _buildSectionTitle('Driver Console'),
          _buildCard([
            _buildActionRow(
              iconText: '🚏',
              label: 'Switch to Driver / Conductor Mode',
              onTap: () => Navigator.pushNamed(context, AppRoutes.driver),
            ),
          ]),

          const SizedBox(height: 16),

          // Support Section
          _buildSectionTitle('Support'),
          _buildCard([
            _buildActionRow(
              iconText: '💬',
              label: 'Help & Support',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Thane Municipal Transit Helpline: 1800-222-108'), duration: Duration(seconds: 2)),
                );
              },
            ),
            _buildDivider(),
            _buildActionRow(
              iconText: 'ℹ️',
              label: 'About Commutr',
              onTap: () {
                showAboutDialog(
                  context: context,
                  applicationName: 'Commutr',
                  applicationVersion: 'v1.0.0',
                  applicationLegalese: 'Crowd-Sourced Real-Time Transit Sensor Fusion System',
                );
              },
            ),
          ]),

          const SizedBox(height: 20),

          if (_locationSharing)
            const Center(
              child: Text(
                'Location sharing: Only while travelling',
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 6),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: AppColors.textSecondary,
          letterSpacing: 0.6,
        ),
      ),
    );
  }

  Widget _buildCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      color: const Color(0xFFF1F5F9),
    );
  }

  Widget _buildActionRow({
    required String iconText,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Text(iconText, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const Icon(Icons.chevron_right_rounded, size: 20, color: Color(0xFFCBD5E1)),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleRow({
    required String iconText,
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Text(iconText, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Switch.adaptive(
            value: value,
            activeThumbColor: AppColors.primaryBlue,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
