import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

/// Commutr 5-Tab Bottom Navigation Bar matching Figma design
class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final int unreadAlertsCount;

  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.unreadAlertsCount = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      child: SafeArea(
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                index: 0,
                label: 'Home',
                icon: Icons.home_outlined,
                activeIcon: Icons.home_rounded,
              ),
              _buildNavItem(
                index: 1,
                label: 'Live',
                icon: Icons.radar_outlined,
                activeIcon: Icons.radar,
              ),
              _buildNavItem(
                index: 2,
                label: 'Trips',
                icon: Icons.directions_bus_outlined,
                activeIcon: Icons.directions_bus_rounded,
              ),
              _buildNavItem(
                index: 3,
                label: 'Alerts',
                icon: Icons.notifications_none_outlined,
                activeIcon: Icons.notifications_rounded,
                badgeCount: unreadAlertsCount,
              ),
              _buildNavItem(
                index: 4,
                label: 'Profile',
                icon: Icons.person_outline_rounded,
                activeIcon: Icons.person_rounded,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required String label,
    required IconData icon,
    required IconData activeIcon,
    int badgeCount = 0,
  }) {
    final isSelected = currentIndex == index;
    final color = isSelected ? AppColors.primaryBlue : AppColors.textSecondary;

    return InkWell(
      onTap: () => onTap(index),
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(
                isSelected ? activeIcon : icon,
                color: color,
                size: 24,
              ),
              if (badgeCount > 0)
                Positioned(
                  top: -2,
                  right: -4,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                      color: AppColors.danger,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 8,
                      minHeight: 8,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
