import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../models/bus_state.dart';

/// Reusable transit status badge / pill component
/// Accurately reflects data quality, verification level, and service status.
class StatusBadge extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color textColor;
  final IconData? icon;

  const StatusBadge({
    super.key,
    required this.label,
    required this.backgroundColor,
    required this.textColor,
    this.icon,
  });

  factory StatusBadge.fromConfidence(ConfidenceLevel confidence) {
    switch (confidence) {
      case ConfidenceLevel.high:
        return const StatusBadge(
          label: 'High confidence',
          backgroundColor: AppColors.successLight,
          textColor: AppColors.success,
          icon: Icons.verified_user_outlined,
        );
      case ConfidenceLevel.medium:
        return const StatusBadge(
          label: 'Medium confidence',
          backgroundColor: AppColors.primaryBlueLight,
          textColor: AppColors.primaryBlue,
          icon: Icons.sensors_outlined,
        );
      case ConfidenceLevel.limited:
        return const StatusBadge(
          label: 'Limited live data',
          backgroundColor: AppColors.warningLight,
          textColor: AppColors.warning,
          icon: Icons.warning_amber_rounded,
        );
      case ConfidenceLevel.none:
        return const StatusBadge(
          label: 'No live data',
          backgroundColor: AppColors.borderLight,
          textColor: AppColors.textSecondary,
          icon: Icons.schedule_outlined,
        );
    }
  }

  factory StatusBadge.fromTrackingSource(TrackingSource source) {
    switch (source) {
      case TrackingSource.crowd:
        return const StatusBadge(
          label: 'Crowd-verified',
          backgroundColor: AppColors.primaryBlueLight,
          textColor: AppColors.primaryBlue,
          icon: Icons.groups_outlined,
        );
      case TrackingSource.driver:
        return const StatusBadge(
          label: 'Driver anchor',
          backgroundColor: AppColors.successLight,
          textColor: AppColors.success,
          icon: Icons.badge_outlined,
        );
      case TrackingSource.hybrid:
        return const StatusBadge(
          label: 'Hybrid fused',
          backgroundColor: AppColors.primaryBlueLight,
          textColor: AppColors.primaryBlue,
          icon: Icons.sync_alt_outlined,
        );
      case TrackingSource.lastKnown:
        return const StatusBadge(
          label: 'Last known',
          backgroundColor: AppColors.warningLight,
          textColor: AppColors.warning,
          icon: Icons.history_outlined,
        );
      case TrackingSource.scheduled:
        return const StatusBadge(
          label: 'Scheduled',
          backgroundColor: AppColors.borderLight,
          textColor: AppColors.textSecondary,
          icon: Icons.calendar_today_outlined,
        );
      case TrackingSource.noLiveData:
        return const StatusBadge(
          label: 'No live data',
          backgroundColor: AppColors.borderLight,
          textColor: AppColors.textSecondary,
          icon: Icons.cloud_off_outlined,
        );
    }
  }

  factory StatusBadge.fromServiceStatus(ServiceStatus status) {
    switch (status) {
      case ServiceStatus.normal:
        return const StatusBadge(
          label: 'On Schedule',
          backgroundColor: AppColors.successLight,
          textColor: AppColors.success,
          icon: Icons.check_circle_outline,
        );
      case ServiceStatus.possibleDisruption:
        return const StatusBadge(
          label: 'Possible Disruption',
          backgroundColor: AppColors.warningLight,
          textColor: AppColors.warning,
          icon: Icons.warning_amber_rounded,
        );
      case ServiceStatus.confirmedDisruption:
        return const StatusBadge(
          label: 'Confirmed Disruption',
          backgroundColor: AppColors.dangerLight,
          textColor: AppColors.danger,
          icon: Icons.error_outline,
        );
      case ServiceStatus.detour:
        return const StatusBadge(
          label: 'Route Detour',
          backgroundColor: AppColors.warningLight,
          textColor: AppColors.warning,
          icon: Icons.alt_route,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: textColor),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.1,
            ),
          ),
        ],
      ),
    );
  }
}
