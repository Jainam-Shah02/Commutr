import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/routing/app_routes.dart';
import '../../models/bus_state.dart';
import '../../services/transit_provider.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/transit_map.dart';
import '../../services/realtime/transit_realtime_service.dart';

class LiveMapScreen extends StatefulWidget {
  const LiveMapScreen({super.key});

  @override
  State<LiveMapScreen> createState() => _LiveMapScreenState();
}

class _LiveMapScreenState extends State<LiveMapScreen> {
  bool _notified = false;
  bool _followBus = true;

  String _getOccupancyLabel(OccupancyLevel? occ) {
    switch (occ) {
      case OccupancyLevel.low:
        return 'Seats likely available';
      case OccupancyLevel.moderate:
        return 'Some seats available';
      case OccupancyLevel.high:
        return 'Standing room likely';
      default:
        return 'Moderate occupancy';
    }
  }

  String _getBadgeStatus(TransitProvider transit, BusState? busState) {
    if (transit.serviceStatus == ServiceStatus.confirmedDisruption) {
      return 'CONFIRMED DISRUPTION';
    }
    if (transit.serviceStatus == ServiceStatus.possibleDisruption) {
      return 'POSSIBLE DISRUPTION';
    }
    if (busState == null || transit.trackingSource == TrackingSource.noLiveData) {
      return 'LIMITED DATA';
    }
    if (transit.trackingSource == TrackingSource.scheduled) {
      return 'SCHEDULED';
    }
    return 'LIVE';
  }

  @override
  Widget build(BuildContext context) {
    final transit = context.watch<TransitProvider>();
    final busState = transit.busState;
    final route = transit.selectedRoute;
    final serviceStatus = transit.serviceStatus;

    final nextStopObj = route.stops.where((s) => s.id == busState?.nextStopId).firstOrNull ??
        (route.stops.isNotEmpty ? route.stops[1] : null);
    final currentStopObj = route.stops.where((s) => s.id == busState?.currentStopId).firstOrNull ??
        (route.stops.isNotEmpty ? route.stops[0] : null);

    final currentStopIndex = route.stops.indexWhere((s) => s.id == busState?.currentStopId);
    final upcomingStops = route.stops.sublist(
      (currentStopIndex >= 0 ? currentStopIndex + 1 : 1).clamp(0, route.stops.length),
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            // Real OpenStreetMap Area with Overlays
            Expanded(
              child: Stack(
                children: [
                  // Real Interactive OpenStreetMap Component
                  Positioned.fill(
                    child: TransitMap(
                      route: route,
                      bus: busState,
                      stops: route.stops,
                      userLocation: transit.userPosition,
                      destinationStopId: transit.destinationStopId,
                      followBus: _followBus,
                      onFollowBusChanged: (val) {
                        setState(() => _followBus = val);
                      },
                      onStopSelect: (stop) {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.stopDetails,
                          arguments: stop.id,
                        );
                      },
                      activePolyline: transit.activePolyline,
                      serviceStatus: serviceStatus,
                    ),
                  ),

                  // Top Header Overlay
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: EdgeInsets.only(
                        top: MediaQuery.of(context).padding.top + 8,
                        left: 16,
                        right: 16,
                      ),
                      child: Row(
                        children: [
                          Material(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            elevation: 2,
                            child: InkWell(
                              onTap: () {
                                if (Navigator.canPop(context)) {
                                  Navigator.pop(context);
                                } else {
                                  Navigator.pushReplacementNamed(context, AppRoutes.home);
                                }
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppColors.border),
                                ),
                                child: const Icon(
                                  Icons.chevron_left_rounded,
                                  size: 22,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.border),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.05),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    '${route.operator} ${route.routeNumber}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  StatusBadge(
                                    label: _getBadgeStatus(transit, busState),
                                    backgroundColor: busState != null
                                        ? AppColors.successLight
                                        : AppColors.borderLight,
                                    textColor: busState != null
                                        ? AppColors.success
                                        : AppColors.textSecondary,
                                  ),
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: transit.backendStatus == BackendConnectionStatus.live
                                          ? const Color(0xFF10B981).withValues(alpha: 0.12)
                                          : transit.backendStatus == BackendConnectionStatus.connecting
                                              ? const Color(0xFFF59E0B).withValues(alpha: 0.12)
                                              : const Color(0xFF64748B).withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          width: 5,
                                          height: 5,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: transit.backendStatus == BackendConnectionStatus.live
                                                ? const Color(0xFF10B981)
                                                : transit.backendStatus == BackendConnectionStatus.connecting
                                                    ? const Color(0xFFF59E0B)
                                                    : const Color(0xFF64748B),
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          transit.connectionStatusBadgeText,
                                          style: TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.w700,
                                            color: transit.backendStatus == BackendConnectionStatus.live
                                                ? const Color(0xFF047857)
                                                : transit.backendStatus == BackendConnectionStatus.connecting
                                                    ? const Color(0xFFB45309)
                                                    : const Color(0xFF475569),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    busState != null
                                        ? '${busState.lastUpdatedSec}s ago'
                                        : 'Unavailable',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: AppColors.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Floating Simulation / Detour controls (Top Left below Header)
                  Positioned(
                    top: MediaQuery.of(context).padding.top + 64,
                    left: 16,
                    child: Column(
                      children: [
                        // Pause / Play Simulation
                        _FloatingMiniButton(
                          icon: transit.isSimulating
                              ? Icons.pause_circle_filled_rounded
                              : Icons.play_circle_filled_rounded,
                          isActive: transit.isSimulating,
                          tooltip: transit.isSimulating ? 'Pause Sim' : 'Play Sim',
                          onTap: () => transit.setSimulating(!transit.isSimulating),
                        ),
                        const SizedBox(height: 8),
                        // Detour Trigger
                        _FloatingMiniButton(
                          icon: Icons.alt_route_rounded,
                          isActive: serviceStatus == ServiceStatus.detour,
                          tooltip: 'Detour Diversion',
                          onTap: () => transit.triggerDetour(serviceStatus != ServiceStatus.detour),
                        ),
                        const SizedBox(height: 8),
                        // GPS permission / request
                        _FloatingMiniButton(
                          icon: Icons.near_me_rounded,
                          isActive: transit.userPosition != null,
                          tooltip: 'Device GPS',
                          onTap: () => transit.requestLocationPermission(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Disruption / Detour Notification Banner
            if (serviceStatus == ServiceStatus.confirmedDisruption)
              Container(
                color: AppColors.danger,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('🔴', style: TextStyle(fontSize: 18)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'CONFIRMED SERVICE DISRUPTION',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Bus breakdown confirmed by operator near ${currentStopObj?.name ?? 'Majiwada'}. Expect significant delays or take alternate routes.',
                            style: const TextStyle(fontSize: 11, color: Color(0xFFFEE2E2)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            else if (serviceStatus == ServiceStatus.possibleDisruption)
              Container(
                color: AppColors.warning,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('⚠️', style: TextStyle(fontSize: 18)),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'POSSIBLE SERVICE DISRUPTION',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Unusual long stop detected outside normal schedule. Awaiting operator confirmation.',
                            style: TextStyle(fontSize: 11, color: Color(0xFFFEF3C7)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            else if (serviceStatus == ServiceStatus.detour)
              Container(
                color: const Color(0xFF1D4ED8),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: const Row(
                  children: [
                    Text('🔀', style: TextStyle(fontSize: 16)),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Temporary route active: this bus is following an alternate path.',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Bottom Info Sheet
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: AppColors.border)),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x0F000000),
                    blurRadius: 16,
                    offset: Offset(0, -4),
                  ),
                ],
              ),
              child: busState != null
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Row 1: Route + ETA
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      '${route.operator} ${route.routeNumber}',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    StatusBadge(
                                      label: _getBadgeStatus(transit, busState),
                                      backgroundColor: AppColors.successLight,
                                      textColor: AppColors.success,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  route.name,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  serviceStatus == ServiceStatus.confirmedDisruption
                                      ? 'Delayed'
                                      : '${busState.etaMinutes} min',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                    color: serviceStatus == ServiceStatus.confirmedDisruption
                                        ? AppColors.danger
                                        : AppColors.primaryBlue,
                                  ),
                                ),
                                const Text(
                                  'Estimated arrival',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),

                        // Truthful Speeds Bar (Bus Speed + User Speed)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.speed_rounded, size: 15, color: AppColors.primaryBlue),
                                  const SizedBox(width: 6),
                                  Text(
                                    '${busState.speedKmh.toInt()} km/h',
                                    style: const TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Text(
                                    'Current bus speed',
                                    style: TextStyle(fontSize: 10.5, color: AppColors.textMuted),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Icon(
                                    Icons.person_pin_circle_outlined,
                                    size: 15,
                                    color: transit.userSpeedKmh != null
                                        ? AppColors.success
                                        : AppColors.textMuted,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    transit.userSpeedKmh != null
                                        ? '${transit.userSpeedKmh!.toInt()} km/h'
                                        : '--',
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w800,
                                      color: transit.userSpeedKmh != null
                                          ? AppColors.textPrimary
                                          : AppColors.textMuted,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Text(
                                    'Your GPS speed',
                                    style: TextStyle(fontSize: 10.5, color: AppColors.textMuted),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 10),

                        // Row 2: Next Stop | Data Quality | Occupancy
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: const BoxDecoration(
                            border: Border(
                              top: BorderSide(color: Color(0xFFF1F5F9)),
                              bottom: BorderSide(color: Color(0xFFF1F5F9)),
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Next stop',
                                      style: TextStyle(fontSize: 10, color: AppColors.textMuted),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      nextStopObj?.name ?? 'Majiwada',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textPrimary,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              Container(width: 1, height: 28, color: AppColors.border),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Data quality',
                                        style: TextStyle(fontSize: 10, color: AppColors.textMuted),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        busState.confidence.label,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.success,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Container(width: 1, height: 28, color: AppColors.border),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 8),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Occupancy',
                                        style: TextStyle(fontSize: 10, color: AppColors.textMuted),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        _getOccupancyLabel(busState.occupancy),
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textSecondary,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 8),

                        // Telemetry source message
                        Text(
                          transit.trackingSource == TrackingSource.driver
                              ? 'Direct driver telemetry verified'
                              : 'Based on multiple verified passenger signals',
                          style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
                        ),

                        const SizedBox(height: 10),

                        // Upcoming stops scrollable strip
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'UPCOMING STOPS',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.textSecondary,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  Text(
                                    '${busState.progressPercent}% route completed',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primaryBlue,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: [
                                    if (nextStopObj != null)
                                      Container(
                                        margin: const EdgeInsets.only(right: 6),
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: AppColors.primaryBlueLight,
                                          borderRadius: BorderRadius.circular(6),
                                          border: Border.all(color: const Color(0xFFBFDBFE)),
                                        ),
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 6,
                                              height: 6,
                                              decoration: const BoxDecoration(
                                                color: AppColors.primaryBlue,
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              'Next: ${nextStopObj.name}',
                                              style: const TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w700,
                                                color: AppColors.primaryBlue,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ...upcomingStops.skip(1).take(3).map(
                                          (s) => Container(
                                            margin: const EdgeInsets.only(right: 6),
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.circular(6),
                                              border: Border.all(color: AppColors.border),
                                            ),
                                            child: Text(
                                              s.name,
                                              style: const TextStyle(
                                                fontSize: 11,
                                                color: AppColors.textSecondary,
                                              ),
                                            ),
                                          ),
                                        ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Action Buttons
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _notified
                                      ? AppColors.successLight
                                      : AppColors.primaryBlue,
                                  foregroundColor: _notified
                                      ? AppColors.success
                                      : Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    side: _notified
                                        ? const BorderSide(color: Color(0xFFBBF7D0))
                                        : BorderSide.none,
                                  ),
                                  elevation: 0,
                                ),
                                onPressed: () {
                                  setState(() => _notified = !_notified);
                                },
                                child: Text(
                                  _notified ? '✓ Notification Set' : 'Notify Me',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.textPrimary,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  side: const BorderSide(color: AppColors.border),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.pushNamed(
                                    context,
                                    AppRoutes.routeDetails,
                                    arguments: route.id,
                                  );
                                },
                                child: const Text(
                                  'View Route',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Text(
                              '${route.operator} ${route.routeNumber}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const StatusBadge(
                              label: 'LIMITED DATA',
                              backgroundColor: AppColors.warningLight,
                              textColor: AppColors.warning,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.warningLight,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFFDE68A)),
                          ),
                          child: const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.info_outline, size: 16, color: Color(0xFF92400E)),
                                  SizedBox(width: 6),
                                  Text(
                                    'Live bus location is currently unavailable',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF92400E),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 4),
                              Text(
                                'No active passenger or driver signals on this route. Scheduled arrival times are shown below.',
                                style: TextStyle(fontSize: 11, color: Color(0xFFB45309)),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Next scheduled departure:',
                              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                            ),
                            Text(
                              '10:25 AM (Thane West)',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FloatingMiniButton extends StatelessWidget {
  final IconData icon;
  final bool isActive;
  final String tooltip;
  final VoidCallback onTap;

  const _FloatingMiniButton({
    required this.icon,
    required this.isActive,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isActive ? AppColors.primaryBlue : Colors.white,
      borderRadius: BorderRadius.circular(12),
      elevation: 3,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isActive ? AppColors.primaryBlue : AppColors.border,
            ),
          ),
          child: Icon(
            icon,
            size: 19,
            color: isActive ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
