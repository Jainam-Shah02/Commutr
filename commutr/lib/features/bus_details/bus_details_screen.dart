import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/routing/app_routes.dart';
import '../../models/bus_state.dart';
import '../../models/transit_stop.dart';
import '../../services/transit_provider.dart';
import '../../widgets/app_header.dart';
import '../../widgets/status_badge.dart';

class BusDetailsScreen extends StatefulWidget {
  const BusDetailsScreen({super.key});

  @override
  State<BusDetailsScreen> createState() => _BusDetailsScreenState();
}

class _BusDetailsScreenState extends State<BusDetailsScreen> {
  bool _notified = false;

  @override
  Widget build(BuildContext context) {
    final transit = context.watch<TransitProvider>();
    final busState = transit.busState;
    final selectedRoute = transit.selectedRoute;
    final serviceStatus = transit.serviceStatus;
    final trackingSource = transit.trackingSource;

    final currentStopIndex = selectedRoute.stops.indexWhere((s) => s.id == busState?.currentStopId);
    final currentStop = currentStopIndex >= 0 ? selectedRoute.stops[currentStopIndex] : selectedRoute.stops.first;
    final nextStop = selectedRoute.stops.firstWhere(
      (s) => s.id == busState?.nextStopId,
      orElse: () => selectedRoute.stops[1],
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppHeader(
        title: '${selectedRoute.operator} ${selectedRoute.routeNumber}',
        subtitle: selectedRoute.name,
        trailing: Container(
          margin: const EdgeInsets.only(right: 4),
          child: StatusBadge.fromServiceStatus(serviceStatus),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ETA & Status Card
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: busState != null
                  ? Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.02),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Estimated arrival',
                                    style: TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    serviceStatus == ServiceStatus.confirmedDisruption
                                        ? 'Delayed'
                                        : '${busState.etaMinutes} min',
                                    style: TextStyle(
                                      color: serviceStatus == ServiceStatus.confirmedDisruption
                                          ? AppColors.danger
                                          : AppColors.primaryBlue,
                                      fontSize: 32,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: -0.8,
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  const Text(
                                    'Current area',
                                    style: TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    currentStop.name,
                                    style: const TextStyle(
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    'Next: ${nextStop.name}',
                                    style: const TextStyle(
                                      color: AppColors.primaryBlue,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const Divider(height: 24),
                          Row(
                            children: [
                              StatusBadge.fromConfidence(busState.confidence),
                              const SizedBox(width: 8),
                              Text(
                                'Updated ${busState.lastUpdatedSec}s ago',
                                style: const TextStyle(
                                  color: AppColors.textMuted,
                                  fontSize: 11,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                busState.occupancy.displayText,
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    )
                  : Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFFCD34D)),
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.warning_amber_rounded, color: AppColors.warning, size: 24),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Live bus location unavailable',
                                  style: TextStyle(
                                    color: AppColors.warning,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Showing scheduled departure: 10:25 AM. Live tracking activates with passenger signals.',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
            ),

            // Disruption / Detour Alert Message
            if (busState?.disruptionMessage != null) ...[
              Container(
                margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: serviceStatus == ServiceStatus.confirmedDisruption
                      ? AppColors.dangerLight
                      : AppColors.warningLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: serviceStatus == ServiceStatus.confirmedDisruption
                        ? const Color(0xFFFCA5A5)
                        : const Color(0xFFFCD34D),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      serviceStatus == ServiceStatus.confirmedDisruption
                          ? Icons.error_outline
                          : Icons.warning_amber_rounded,
                      color: serviceStatus == ServiceStatus.confirmedDisruption
                          ? AppColors.danger
                          : AppColors.warning,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        busState!.disruptionMessage!,
                        style: TextStyle(
                          color: serviceStatus == ServiceStatus.confirmedDisruption
                              ? AppColors.danger
                              : AppColors.warning,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Sensor Origin Telemetry Explanation
            Container(
              margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: trackingSource == TrackingSource.driver
                    ? AppColors.successLight
                    : AppColors.primaryBlueLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: trackingSource == TrackingSource.driver
                      ? const Color(0xFFBBF7D0)
                      : const Color(0xFFBFDBFE),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    trackingSource == TrackingSource.driver
                        ? Icons.badge_outlined
                        : Icons.groups_outlined,
                    size: 20,
                    color: trackingSource == TrackingSource.driver
                        ? AppColors.success
                        : AppColors.primaryBlue,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      trackingSource == TrackingSource.driver
                          ? 'Driver Telemetry Active: Virtual position is anchored by the authorized operator smartphone.'
                          : 'Crowdsourced Telemetry: Virtual bus position is verified from passenger trajectories.',
                      style: TextStyle(
                        color: trackingSource == TrackingSource.driver
                            ? const Color(0xFF166534)
                            : AppColors.primaryBlueDark,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Action Buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => Navigator.pushNamed(context, AppRoutes.liveMap),
                          icon: const Icon(Icons.map_outlined, size: 18),
                          label: const Text('Live Map'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => Navigator.pushNamed(context, AppRoutes.boarding),
                          icon: const Icon(Icons.airline_seat_recline_normal_rounded, size: 18),
                          label: const Text('Did you board?'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            setState(() => _notified = !_notified);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(_notified
                                    ? 'Arrival notifications enabled for TMT 50.'
                                    : 'Arrival notifications disabled.'),
                              ),
                            );
                          },
                          icon: Icon(
                            _notified ? Icons.notifications_active : Icons.notifications_none,
                            size: 18,
                            color: _notified ? AppColors.primaryBlue : AppColors.textSecondary,
                          ),
                          label: Text(_notified ? 'Notified' : 'Notify me'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => Navigator.pushNamed(context, AppRoutes.reportProblem),
                          icon: const Icon(Icons.report_problem_outlined, size: 18, color: AppColors.danger),
                          label: const Text(
                            'Report problem',
                            style: TextStyle(color: AppColors.danger),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Stop-by-Stop Route Progress
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Route Stops',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          '${selectedRoute.stops.length} stops total',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ...List.generate(selectedRoute.stops.length, (idx) {
                      final stop = selectedRoute.stops[idx];
                      final isLast = idx == selectedRoute.stops.length - 1;
                      final isPassed = currentStopIndex >= 0 && idx < currentStopIndex;
                      final isCurrent = currentStopIndex >= 0 && idx == currentStopIndex;
                      final isNext = nextStop.id == stop.id;

                      return _buildTimelineStopRow(
                        stop: stop,
                        isLast: isLast,
                        isPassed: isPassed,
                        isCurrent: isCurrent,
                        isNext: isNext,
                        estimatedMinutes: (idx - (currentStopIndex >= 0 ? currentStopIndex : 0)) * 3,
                      );
                    }),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineStopRow({
    required TransitStop stop,
    required bool isLast,
    required bool isPassed,
    required bool isCurrent,
    required bool isNext,
    required int estimatedMinutes,
  }) {
    Color nodeColor = AppColors.border;
    Widget nodeIcon = Container();

    if (isPassed) {
      nodeColor = AppColors.success;
      nodeIcon = const Icon(Icons.check, size: 10, color: Colors.white);
    } else if (isCurrent) {
      nodeColor = AppColors.primaryBlue;
      nodeIcon = Container(
        width: 6,
        height: 6,
        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
      );
    } else if (isNext) {
      nodeColor = AppColors.warning;
      nodeIcon = const Icon(Icons.arrow_forward_rounded, size: 10, color: Colors.white);
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline indicator line + circle
          SizedBox(
            width: 24,
            child: Column(
              children: [
                Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: nodeColor,
                    shape: BoxShape.circle,
                  ),
                  child: Center(child: nodeIcon),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: isPassed ? AppColors.successLight : AppColors.border,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // Stop name and badges
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            stop.name,
                            style: TextStyle(
                              color: isCurrent
                                  ? AppColors.primaryBlue
                                  : isPassed
                                      ? AppColors.textSecondary
                                      : AppColors.textPrimary,
                              fontWeight: isCurrent || isNext ? FontWeight.w700 : FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                          if (stop.isMajor) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                              decoration: BoxDecoration(
                                color: AppColors.primaryBlueLight,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'Major',
                                style: TextStyle(
                                  color: AppColors.primaryBlue,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (isCurrent)
                        const Text(
                          'Bus is currently near here',
                          style: TextStyle(
                            color: AppColors.primaryBlue,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        )
                      else if (isNext)
                        const Text(
                          'Next stop',
                          style: TextStyle(
                            color: AppColors.warning,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                    ],
                  ),
                  if (!isPassed && estimatedMinutes > 0)
                    Text(
                      '~${estimatedMinutes}m',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
