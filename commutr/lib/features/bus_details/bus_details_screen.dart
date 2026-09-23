import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/routing/app_routes.dart';
import '../../models/bus_state.dart';
import '../../models/transit_stop.dart';
import '../../services/transit_provider.dart';
import '../../widgets/app_header.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/transit_map.dart';

class BusDetailsScreen extends StatefulWidget {
  const BusDetailsScreen({super.key});

  @override
  State<BusDetailsScreen> createState() => _BusDetailsScreenState();
}

class _BusDetailsScreenState extends State<BusDetailsScreen> {
  bool _notified = false;
  bool _followBus = true;

  @override
  Widget build(BuildContext context) {
    final transit = context.watch<TransitProvider>();
    final busState = transit.busState;
    final selectedRoute = transit.selectedRoute;
    final serviceStatus = transit.serviceStatus;
    final isTravelling = transit.trackingMode == TrackingMode.travelling;

    final currentStopIndex = selectedRoute.stops.indexWhere((s) => s.id == busState?.currentStopId);
    final currentStop = currentStopIndex >= 0 ? selectedRoute.stops[currentStopIndex] : selectedRoute.stops.first;
    final nextStop = selectedRoute.stops.firstWhere(
      (s) => s.id == busState?.nextStopId,
      orElse: () => selectedRoute.stops.length > 1 ? selectedRoute.stops[1] : selectedRoute.stops.first,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppHeader(
        title: '${selectedRoute.operator} ${selectedRoute.routeNumber}',
        subtitle: selectedRoute.name,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.report_problem_outlined, size: 20, color: AppColors.warning),
              tooltip: 'Report Issue',
              onPressed: () => Navigator.pushNamed(context, AppRoutes.reportProblem),
            ),
            Container(
              margin: const EdgeInsets.only(right: 4),
              child: const StatusBadge(
                label: 'LIVE',
                backgroundColor: AppColors.successLight,
                textColor: AppColors.success,
                icon: Icons.sensors,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // -------------------------------------------------------------
            // 1. Top Section: ETA, Speeds, Crowd Status
            // -------------------------------------------------------------
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Container(
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
                    // Arrival & Next Stop Row
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
                                  : busState != null
                                      ? '${busState.etaMinutes} min'
                                      : '3 min',
                              style: TextStyle(
                                color: serviceStatus == ServiceStatus.confirmedDisruption
                                    ? AppColors.danger
                                    : AppColors.primaryBlue,
                                fontSize: 30,
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
                              'Next Stop',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              nextStop.name,
                              style: const TextStyle(
                                color: AppColors.primaryBlue,
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              'From: ${currentStop.name}',
                              style: const TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const Divider(height: 22, color: AppColors.border),

                    // Telemetry & Crowd Row
                    Row(
                      children: [
                        const Icon(Icons.speed_rounded, size: 16, color: AppColors.primaryBlue),
                        const SizedBox(width: 6),
                        Text(
                          'Bus Speed: ${transit.busSpeedKmh.toStringAsFixed(0)} km/h',
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.primaryBlueLight,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            busState?.occupancy.displayText ?? 'Seats Available',
                            style: const TextStyle(
                              color: AppColors.primaryBlue,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Confidence Level & Contributor Count Pill
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                      decoration: BoxDecoration(
                        color: transit.isPassengerSignalReliable
                            ? AppColors.successLight
                            : AppColors.warning.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.verified_user_rounded,
                            size: 14,
                            color: transit.isPassengerSignalReliable
                                ? AppColors.success
                                : AppColors.warning,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${transit.confidenceLevelLabel} Confidence',
                            style: TextStyle(
                              color: transit.isPassengerSignalReliable
                                  ? AppColors.success
                                  : AppColors.warning,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            width: 3,
                            height: 3,
                            decoration: BoxDecoration(
                              color: AppColors.textSecondary.withValues(alpha: 0.6),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Row(
                              children: [
                                const Icon(Icons.people_alt_rounded, size: 13, color: AppColors.textSecondary),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    transit.confidencePeopleDescription,
                                    style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Passenger Telemetry Comparison Card if Travelling Onboard
                    if (isTravelling) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Estimated bus speed',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  '${transit.busSpeedKmh.toStringAsFixed(0)} km/h',
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Your speed',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  '${transit.effectiveUserSpeedKmh.toStringAsFixed(0)} km/h',
                                  style: const TextStyle(
                                    color: AppColors.primaryBlue,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Tracking confidence',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  transit.trackingConfidenceText,
                                  style: TextStyle(
                                    color: transit.isPassengerSignalReliable
                                        ? AppColors.success
                                        : AppColors.warning,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Active passengers',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                                Row(
                                  children: [
                                    const Icon(Icons.people_alt_rounded, size: 14, color: AppColors.primaryBlue),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${transit.activePassengerContributorsCount} people on board',
                                      style: const TextStyle(
                                        color: AppColors.textPrimary,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // -------------------------------------------------------------
            // 2. Main Section: REAL MAP (flutter_map / OpenStreetMap)
            // -------------------------------------------------------------
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Container(
                height: 290,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border, width: 1.2),
                ),
                child: Stack(
                  children: [
                    TransitMap(
                      route: selectedRoute,
                      bus: busState,
                      stops: selectedRoute.stops,
                      userLocation: transit.userPosition,
                      destinationStopId: transit.destinationStopId,
                      followBus: _followBus,
                      onFollowBusChanged: (val) {
                        setState(() => _followBus = val);
                      },
                      activePolyline: transit.activePolyline,
                      serviceStatus: serviceStatus,
                    ),
                    // Map Overlay: Follow Bus Toggle
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: Icon(
                            _followBus ? Icons.gps_fixed : Icons.gps_not_fixed,
                            color: _followBus ? AppColors.primaryBlue : AppColors.textMuted,
                            size: 20,
                          ),
                          tooltip: 'Follow Bus',
                          onPressed: () => setState(() => _followBus = !_followBus),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // -------------------------------------------------------------
            // 3. Tracking Mode Toggle & Actions
            // -------------------------------------------------------------
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: BorderSide(
                          color: isTravelling ? AppColors.success : AppColors.primaryBlue,
                          width: 1.2,
                        ),
                        backgroundColor: isTravelling ? AppColors.successLight : AppColors.surface,
                      ),
                      onPressed: () {
                        if (isTravelling) {
                          transit.setTrackingMode(TrackingMode.tracking);
                        } else {
                          transit.setTrackingMode(TrackingMode.travelling);
                        }
                      },
                      icon: Icon(
                        isTravelling ? Icons.check_circle_rounded : Icons.airline_seat_recline_normal_rounded,
                        size: 18,
                        color: isTravelling ? AppColors.success : AppColors.primaryBlue,
                      ),
                      label: Text(
                        isTravelling ? "I'm on this bus" : "I'm travelling on this bus",
                        style: TextStyle(
                          color: isTravelling ? AppColors.success : AppColors.primaryBlue,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      side: const BorderSide(color: AppColors.border),
                    ),
                    onPressed: () {
                      setState(() => _notified = !_notified);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(_notified
                              ? 'Arrival alerts enabled for ${selectedRoute.operator} ${selectedRoute.routeNumber}.'
                              : 'Arrival alerts disabled.'),
                        ),
                      );
                    },
                    child: Icon(
                      _notified ? Icons.notifications_active : Icons.notifications_none,
                      size: 20,
                      color: _notified ? AppColors.primaryBlue : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      side: const BorderSide(color: AppColors.border),
                      backgroundColor: AppColors.surface,
                    ),
                    onPressed: () => Navigator.pushNamed(context, AppRoutes.reportProblem),
                    icon: const Icon(Icons.report_problem_outlined, size: 18, color: AppColors.warning),
                    label: const Text(
                      'Report',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Report Issue Quick Card
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: InkWell(
                onTap: () => Navigator.pushNamed(context, AppRoutes.reportProblem),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.report_problem_rounded, color: AppColors.warning, size: 16),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Report an Issue with this Bus',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            SizedBox(height: 1),
                            Text(
                              'Unexpected stop, route breakdown, or road obstruction',
                              style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.textMuted, size: 13),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // -------------------------------------------------------------
            // 4. Bottom Section: Route Stop Timeline
            // -------------------------------------------------------------
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
                            fontSize: 15,
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
                        estimatedMinutes: (idx - (currentStopIndex >= 0 ? currentStopIndex : 0)).clamp(0, 50) * 3,
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
