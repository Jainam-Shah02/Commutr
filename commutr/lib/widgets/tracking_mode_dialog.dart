import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../core/routing/app_routes.dart';
import '../models/transit_route.dart';
import '../services/transit_provider.dart';

/// Modal Bottom Sheet allowing the commuter to choose their tracking mode:
/// Option 1: "I'm tracking this bus" (Waiting at stop)
/// Option 2: "I'm travelling on this bus" (Onboard passenger)
class TrackingModeSheet extends StatelessWidget {
  final TransitRoute route;

  const TrackingModeSheet({
    super.key,
    required this.route,
  });

  static Future<void> show(BuildContext context, TransitRoute route) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => TrackingModeSheet(route: route),
    );
  }

  @override
  Widget build(BuildContext context) {
    final transit = context.read<TransitProvider>();

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Bus badge & route
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlueLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${route.operator} ${route.routeNumber}',
                    style: const TextStyle(
                      color: AppColors.primaryBlue,
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    route.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Title
            const Text(
              'How are you using Commutr?',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Choose how you want to track this bus.',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 20),

            // OPTION 1: "I'm tracking this bus"
            _buildOptionCard(
              context,
              icon: Icons.search_rounded,
              iconBgColor: AppColors.primaryBlueLight,
              iconColor: AppColors.primaryBlue,
              title: "I'm tracking this bus",
              description: "I'm waiting for the bus and want to see where it is.",
              extraNote: "High confidence • 14 passengers currently on board this bus.",
              onTap: () {
                transit.setSelectedRouteById(route.id);
                transit.setTrackingMode(TrackingMode.tracking);
                Navigator.pop(context);
                Navigator.pushNamed(context, AppRoutes.busDetails);
              },
            ),

            const SizedBox(height: 12),

            // OPTION 2: "I'm travelling on this bus"
            _buildOptionCard(
              context,
              icon: Icons.airline_seat_recline_normal_rounded,
              iconBgColor: AppColors.successLight,
              iconColor: AppColors.success,
              title: "I'm travelling on this bus",
              description: "I'm already inside this bus.",
              extraNote: "Join 14 other passengers on board to verify live bus location.",
              onTap: () async {
                transit.setSelectedRouteById(route.id);
                transit.setTrackingMode(TrackingMode.travelling);
                // Prompt / ensure location consent
                try {
                  await transit.requestLocationPermission();
                } catch (_) {}
                if (context.mounted) {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, AppRoutes.busDetails);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionCard(
    BuildContext context, {
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required String title,
    required String description,
    String? extraNote,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border, width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    description,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      height: 1.35,
                    ),
                  ),
                  if (extraNote != null) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.verified_user_outlined, size: 13, color: AppColors.success),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            extraNote,
                            style: const TextStyle(
                              color: AppColors.success,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}
