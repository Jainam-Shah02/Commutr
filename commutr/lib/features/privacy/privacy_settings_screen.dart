import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../widgets/app_header.dart';

class PrivacySettingsScreen extends StatefulWidget {
  const PrivacySettingsScreen({super.key});

  @override
  State<PrivacySettingsScreen> createState() => _PrivacySettingsScreenState();
}

class _PrivacySettingsScreenState extends State<PrivacySettingsScreen> {
  bool _locationAccess = true;
  bool _backgroundLocation = false;
  bool _notifications = true;
  bool _rideSharing = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AppHeader(
        title: 'Privacy & Permissions',
        subtitle: 'Passenger Anonymity Standards',
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Informational Banner
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFDBEAFE)),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'How we use your location',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E40AF),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'We use aggregated and verified movement signals to estimate bus movement. Individual passenger locations are not shown on the map or shared with other users.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF1D4ED8),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Permissions Toggles Card
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                _buildToggleItem(
                  title: 'Location access',
                  subtitle: 'Allow app to access location',
                  value: _locationAccess,
                  onChanged: (val) => setState(() => _locationAccess = val),
                ),
                _buildDivider(),
                _buildToggleItem(
                  title: 'Background location',
                  subtitle: 'Only needed while app is open',
                  value: _backgroundLocation,
                  onChanged: (val) => setState(() => _backgroundLocation = val),
                ),
                _buildDivider(),
                _buildToggleItem(
                  title: 'Notifications',
                  subtitle: 'Bus alerts and arrival updates',
                  value: _notifications,
                  onChanged: (val) => setState(() => _notifications = val),
                ),
                _buildDivider(),
                _buildToggleItem(
                  title: 'Ride location sharing',
                  subtitle: 'Share location while travelling',
                  value: _rideSharing,
                  onChanged: (val) => setState(() => _rideSharing = val),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Actions
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textPrimary,
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: AppColors.border),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('System location permissions are verified active.'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                  child: const Text(
                    'Manage Permissions',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFEF2F2),
                    foregroundColor: AppColors.danger,
                    elevation: 0,
                    side: const BorderSide(color: Color(0xFFFCA5A5)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      _rideSharing = false;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Location sharing stopped.'),
                        backgroundColor: AppColors.danger,
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                  child: const Text(
                    'Stop Sharing',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildToggleItem({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
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
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
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

  Widget _buildDivider() {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      color: const Color(0xFFF1F5F9),
    );
  }
}
