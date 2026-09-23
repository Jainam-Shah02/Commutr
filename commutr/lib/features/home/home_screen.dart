import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/routing/app_routes.dart';
import '../../models/bus_state.dart';
import '../../services/transit_provider.dart';
import '../../widgets/status_badge.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final transit = context.watch<TransitProvider>();
    final busState = transit.busState;
    final selectedRoute = transit.selectedRoute;
    final isDisruption = transit.serviceStatus == ServiceStatus.confirmedDisruption;
    final isDetour = transit.serviceStatus == ServiceStatus.detour;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Header with SmartCrowd Transit branding and Driver Console toggle
              Container(
                color: AppColors.surface,
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'SmartCrowd Transit',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Where are you going?',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.4,
                              ),
                            ),
                          ],
                        ),
                        InkWell(
                          onTap: () => Navigator.pushNamed(context, AppRoutes.driver),
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.primaryBlueLight,
                              border: Border.all(color: const Color(0xFFBFDBFE)),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Text(
                                  'Driver',
                                  style: TextStyle(
                                    color: AppColors.primaryBlue,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: transit.driverModeActive
                                        ? AppColors.success
                                        : AppColors.primaryBlue,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Search input trigger
                    InkWell(
                      onTap: () => Navigator.pushNamed(context, AppRoutes.search),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: const [
                            Icon(Icons.search, size: 20, color: AppColors.textSecondary),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Search bus, stop, or destination...',
                                style: TextStyle(
                                  color: AppColors.textMuted,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Active Alert Banner if disruption or detour is active
              if (isDisruption || isDetour) ...[
                Container(
                  margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDisruption ? AppColors.dangerLight : AppColors.warningLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDisruption ? const Color(0xFFFCA5A5) : const Color(0xFFFCD34D),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isDisruption ? Icons.error_outline : Icons.alt_route,
                        color: isDisruption ? AppColors.danger : AppColors.warning,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          isDisruption
                              ? 'TMT 50 breakdown reported. Alternate routes suggested.'
                              : 'TMT 50 is running on a temporary detour via Pokhran Rd 2.',
                          style: TextStyle(
                            color: isDisruption ? AppColors.danger : AppColors.warning,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 16),

              // Nearby Stops Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Nearby Stops',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStopCard(
                            context,
                            name: 'Thane Station West',
                            routesText: '4 routes',
                            walkTime: '2 min walk',
                            stopId: 'stop-1',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStopCard(
                            context,
                            name: 'Majiwada Junction',
                            routesText: '3 routes',
                            walkTime: '5 min walk',
                            stopId: 'stop-5',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // Saved Places Chips
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    _buildPlaceChip(
                      icon: Icons.home_rounded,
                      label: 'Home',
                      address: 'Ghodbunder Rd, Manpada',
                      onTap: () {
                        transit.setDestinationStopId('stop-7');
                        Navigator.pushNamed(context, AppRoutes.destinationTracking);
                      },
                    ),
                    const SizedBox(width: 10),
                    _buildPlaceChip(
                      icon: Icons.school_rounded,
                      label: 'College',
                      address: 'Cadbury Junction, Thane',
                      onTap: () {
                        transit.setDestinationStopId('stop-4');
                        Navigator.pushNamed(context, AppRoutes.destinationTracking);
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              // Popular Routes Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      'Popular Routes',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Thane Transit',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // Route 1: TMT 50 (Dynamic Live / Crowd Fused)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildRouteCard(
                  context,
                  routeNo: '${selectedRoute.operator} ${selectedRoute.routeNumber}',
                  destination: selectedRoute.name,
                  eta: isDisruption
                      ? 'Delayed'
                      : busState != null
                          ? '~${busState.etaMinutes} min'
                          : '10:25 AM',
                  etaSub: isDisruption
                      ? 'Disrupted'
                      : busState != null
                          ? 'Estimated arrival'
                          : 'Scheduled',
                  badge: isDisruption
                      ? const StatusBadge(
                          label: 'CONFIRMED DISRUPTION',
                          backgroundColor: AppColors.dangerLight,
                          textColor: AppColors.danger,
                          icon: Icons.error_outline,
                        )
                      : busState != null
                          ? const StatusBadge(
                              label: 'LIVE',
                              backgroundColor: AppColors.successLight,
                              textColor: AppColors.success,
                              icon: Icons.sensors,
                            )
                          : const StatusBadge(
                              label: 'SCHEDULED',
                              backgroundColor: AppColors.borderLight,
                              textColor: AppColors.textSecondary,
                              icon: Icons.schedule,
                            ),
                  onTap: () => Navigator.pushNamed(context, AppRoutes.busDetails),
                ),
              ),

              const SizedBox(height: 10),

              // Route 2: TMT 2 (Scheduled)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildRouteCard(
                  context,
                  routeNo: 'TMT 2',
                  destination: 'Thane Stn → Balkum',
                  eta: '10:35 AM',
                  etaSub: 'Scheduled',
                  badge: const StatusBadge(
                    label: 'SCHEDULED',
                    backgroundColor: AppColors.borderLight,
                    textColor: AppColors.textSecondary,
                    icon: Icons.schedule,
                  ),
                  onTap: () => Navigator.pushNamed(context, AppRoutes.routeDetails),
                ),
              ),

              const SizedBox(height: 10),

              // Route 3: TMT 1 (Scheduled)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildRouteCard(
                  context,
                  routeNo: 'TMT 1',
                  destination: 'Thane Stn → Wagle Naka',
                  eta: '10:50 AM',
                  etaSub: 'Scheduled',
                  badge: const StatusBadge(
                    label: 'SCHEDULED',
                    backgroundColor: AppColors.borderLight,
                    textColor: AppColors.textSecondary,
                    icon: Icons.schedule,
                  ),
                  onTap: () => Navigator.pushNamed(context, AppRoutes.routeDetails),
                ),
              ),

              const SizedBox(height: 10),

              // Route 4: BEST 251 (Limited Data)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildRouteCard(
                  context,
                  routeNo: 'BEST 251',
                  destination: 'Vesava → Andheri Stn',
                  eta: 'Sch. 11:15 AM',
                  etaSub: 'Limited live data',
                  badge: const StatusBadge(
                    label: 'LIMITED DATA',
                    backgroundColor: AppColors.warningLight,
                    textColor: AppColors.warning,
                    icon: Icons.warning_amber_rounded,
                  ),
                  onTap: () => Navigator.pushNamed(context, AppRoutes.busDetails),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStopCard(
    BuildContext context, {
    required String name,
    required String routesText,
    required String walkTime,
    required String stopId,
  }) {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, AppRoutes.stopDetails),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Icon(Icons.location_on_outlined, size: 20, color: AppColors.primaryBlue),
                Text(
                  walkTime,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              routesText,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceChip({
    required IconData icon,
    required String label,
    required String address,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: AppColors.primaryBlueLight,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 16, color: AppColors.primaryBlue),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      address,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRouteCard(
    BuildContext context, {
    required String routeNo,
    required String destination,
    required String eta,
    required String etaSub,
    required Widget badge,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primaryBlueLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                routeNo,
                style: const TextStyle(
                  color: AppColors.primaryBlue,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    destination,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 4),
                  badge,
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  eta,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                Text(
                  etaSub,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
