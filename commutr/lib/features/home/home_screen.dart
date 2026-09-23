import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/routing/app_routes.dart';
import '../../models/bus_state.dart';
import '../../services/transit_provider.dart';
import '../../widgets/status_badge.dart';
import '../../services/location/location_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  String _getTimeGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final transit = context.watch<TransitProvider>();
    final busState = transit.busState;
    final isDisruption = transit.serviceStatus == ServiceStatus.confirmedDisruption;
    final isDetour = transit.serviceStatus == ServiceStatus.detour;
    final isLocationGranted = transit.permissionState == LocationPermissionState.granted;
    final nearestStop = transit.getNearestStopForUser();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // -------------------------------------------------------------
              // 1. Top Header: Welcome with user's name & Profile avatar
              // -------------------------------------------------------------
              Container(
                color: AppColors.surface,
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${_getTimeGreeting()}, ${transit.userName} 👋',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 3),
                          const Text(
                            'Where are you travelling today?',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Profile Avatar & Driver Pill
                    Row(
                      children: [
                        // Discreet Driver console toggle for operator testing
                        InkWell(
                          onTap: () => Navigator.pushNamed(context, AppRoutes.driver),
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              color: AppColors.primaryBlueLight,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFFBFDBFE)),
                            ),
                            child: Row(
                              children: [
                                const Text(
                                  'Driver',
                                  style: TextStyle(
                                    color: AppColors.primaryBlue,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(width: 4),
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
                        // Avatar Circle
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: AppColors.primaryBlueLight,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.primaryBlue, width: 1.5),
                          ),
                          child: Center(
                            child: Text(
                              transit.userName.isNotEmpty
                                  ? transit.userName[0].toUpperCase()
                                  : 'U',
                              style: const TextStyle(
                                color: AppColors.primaryBlue,
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                      ],
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
                              : 'TMT 50 is running on a temporary detour via Pokhran Rd.',
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

              // -------------------------------------------------------------
              // 2. Main Primary Card: Track Your Bus
              // -------------------------------------------------------------
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border, width: 1.2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: AppColors.primaryBlueLight,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.directions_bus_rounded,
                              color: AppColors.primaryBlue,
                              size: 26,
                            ),
                          ),
                          const SizedBox(width: 14),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Track Your Bus',
                                  style: TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Find buses, stops and live arrival times',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      // Large Prominent Button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryBlue,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () => Navigator.pushNamed(context, AppRoutes.search),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Track Your Bus',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              SizedBox(width: 8),
                              Icon(Icons.arrow_forward_rounded, size: 18),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // -------------------------------------------------------------
              // 3. Nearby Bus Stops
              // -------------------------------------------------------------
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Nearby Bus Stops',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (!isLocationGranted)
                          InkWell(
                            onTap: () => transit.requestLocationPermission(),
                            child: const Text(
                              'Enable GPS',
                              style: TextStyle(
                                color: AppColors.primaryBlue,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStopCard(
                            context,
                            name: nearestStop.stop.name,
                            routesText: 'TMT 65, 50, 68',
                            distanceText: isLocationGranted
                                ? '${nearestStop.distanceMeters} m walk'
                                : 'Approx. 50 m',
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                AppRoutes.search,
                                arguments: {'from': nearestStop.stop.name},
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildStopCard(
                            context,
                            name: 'Thane Station West',
                            routesText: 'Major Terminal',
                            distanceText: '400 m • 5 min',
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                AppRoutes.search,
                                arguments: {'from': 'Thane Station West'},
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              // -------------------------------------------------------------
              // 4. Recent Searches
              // -------------------------------------------------------------
              if (transit.recentSearches.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Recent Searches',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ...transit.recentSearches.take(3).map((s) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: InkWell(
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                AppRoutes.search,
                                arguments: {'from': s.from, 'to': s.to},
                              );
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.history_rounded, size: 18, color: AppColors.textMuted),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      '${s.from} → ${s.to}',
                                      style: const TextStyle(
                                        color: AppColors.textPrimary,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: AppColors.textMuted),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
              ],

              // -------------------------------------------------------------
              // 5. Popular / Saved Routes
              // -------------------------------------------------------------
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
                      'Thane TMT',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // Route 1: TMT 65
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildRouteCard(
                  context,
                  routeNo: 'TMT 65',
                  destination: 'Thane Station West → Wagle Estate',
                  eta: 'Arriving in 3 min',
                  etaSub: 'Arriving at Teen Hath Naka',
                  badge: const StatusBadge(
                    label: 'LIVE',
                    backgroundColor: AppColors.successLight,
                    textColor: AppColors.success,
                    icon: Icons.sensors,
                  ),
                  onTap: () {
                    transit.setSelectedRouteById('tmt-65');
                    Navigator.pushNamed(context, AppRoutes.busDetails);
                  },
                ),
              ),

              const SizedBox(height: 10),

              // Route 2: TMT 50
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildRouteCard(
                  context,
                  routeNo: 'TMT 50',
                  destination: 'Thane Station West → Manpada',
                  eta: isDisruption
                      ? 'Delayed'
                      : busState != null
                          ? 'Arriving in 4 min'
                          : '10:25 AM',
                  etaSub: 'Arriving at Majiwada',
                  badge: isDisruption
                      ? const StatusBadge(
                          label: 'CONFIRMED DISRUPTION',
                          backgroundColor: AppColors.dangerLight,
                          textColor: AppColors.danger,
                          icon: Icons.error_outline,
                        )
                      : const StatusBadge(
                          label: 'LIVE',
                          backgroundColor: AppColors.successLight,
                          textColor: AppColors.success,
                          icon: Icons.sensors,
                        ),
                  onTap: () {
                    transit.setSelectedRouteById('tmt-50');
                    Navigator.pushNamed(context, AppRoutes.busDetails);
                  },
                ),
              ),

              const SizedBox(height: 10),

              // Route 3: TMT 2
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildRouteCard(
                  context,
                  routeNo: 'TMT 2',
                  destination: 'Thane Station West → Balkum',
                  eta: 'Scheduled in 8 min',
                  etaSub: 'Scheduled arrival',
                  badge: const StatusBadge(
                    label: 'SCHEDULED',
                    backgroundColor: AppColors.borderLight,
                    textColor: AppColors.textSecondary,
                    icon: Icons.schedule,
                  ),
                  onTap: () {
                    transit.setSelectedRouteById('tmt-2');
                    Navigator.pushNamed(context, AppRoutes.routeDetails);
                  },
                ),
              ),

              const SizedBox(height: 14),

              // 6. Report Issue Card for Passengers
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: InkWell(
                  onTap: () => Navigator.pushNamed(context, AppRoutes.reportProblem),
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.warning.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.report_problem_rounded, color: AppColors.warning, size: 20),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Report a Transit Issue',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Report delayed buses, route blockages, or breakdowns',
                                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.textMuted, size: 14),
                      ],
                    ),
                  ),
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
    required String distanceText,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
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
                  distanceText,
                  style: const TextStyle(
                    color: AppColors.primaryBlue,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
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
                  fontWeight: FontWeight.w800,
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
                    fontSize: 13,
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

