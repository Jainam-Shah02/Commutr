import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/bus_state.dart';
import '../../models/transit_stop.dart';
import '../../services/transit_provider.dart';
import '../../widgets/app_header.dart';
import '../../widgets/status_badge.dart';

class DestinationTrackingScreen extends StatefulWidget {
  const DestinationTrackingScreen({super.key});

  @override
  State<DestinationTrackingScreen> createState() => _DestinationTrackingScreenState();
}

class _DestinationTrackingScreenState extends State<DestinationTrackingScreen> {
  String _notifyOption = '5min'; // '5min' or 'stop'
  bool _trackingActive = true;

  @override
  Widget build(BuildContext context) {
    final transit = context.watch<TransitProvider>();
    final busState = transit.busState;
    final route = transit.selectedRoute;

    final destinationStop = route.stops.firstWhere(
      (s) => s.id == transit.destinationStopId,
      orElse: () => route.stops.last,
    );

    final currentIndex = route.stops.indexWhere((s) => s.id == busState?.currentStopId);
    final destIndex = route.stops.indexWhere((s) => s.id == destinationStop.id);
    final isApproaching = busState != null &&
        currentIndex >= 0 &&
        destIndex >= 0 &&
        (destIndex - currentIndex <= 1);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppHeader(
        title: 'Track my destination',
        subtitle: '${route.operator} ${route.routeNumber} · ${destinationStop.name}',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Approaching Alert Banner
            if (isApproaching && _trackingActive) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryBlue.withValues(alpha: 0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Text('🔔', style: TextStyle(fontSize: 24)),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Your stop is next',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Get ready — ${destinationStop.name} is approaching.',
                            style: const TextStyle(
                              color: Color(0xFFDBEAFE),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
            ],

            // ETA Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Destination',
                            style: TextStyle(color: AppColors.textMuted, fontSize: 11),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            destinationStop.name,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text(
                            'Estimated arrival',
                            style: TextStyle(color: AppColors.textMuted, fontSize: 11),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            busState != null ? '${busState.etaMinutes} min' : '10:25 AM',
                            style: const TextStyle(
                              color: AppColors.primaryBlue,
                              fontWeight: FontWeight.w800,
                              fontSize: 22,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Divider(height: 24, color: AppColors.borderLight),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      StatusBadge(
                        label: busState != null ? 'LIVE' : 'SCHEDULED',
                        backgroundColor: busState != null
                            ? AppColors.successLight
                            : AppColors.borderLight,
                        textColor: busState != null
                            ? AppColors.success
                            : AppColors.textSecondary,
                      ),
                      Text(
                        busState != null ? busState.confidence.label : 'Scheduled service',
                        style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // Route Progress Timeline
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ROUTE PROGRESS TO ${destinationStop.name.toUpperCase()}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textSecondary,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 14),
                  ...route.stops.asMap().entries.map((entry) {
                    final i = entry.key;
                    final stop = entry.value;
                    final isDestination = stop.id == destinationStop.id;
                    final isCurrent = busState != null && stop.id == busState.currentStopId;
                    final isPassed = currentIndex >= 0 && i < currentIndex;

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Indicator node & vertical line
                        Column(
                          children: [
                            Container(
                              width: 14,
                              height: 14,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isCurrent
                                    ? AppColors.primaryBlue
                                    : isPassed
                                        ? const Color(0xFFCBD5E1)
                                        : Colors.white,
                                border: Border.all(
                                  color: isDestination
                                      ? AppColors.danger
                                      : isCurrent
                                          ? AppColors.primaryBlue
                                          : const Color(0xFFCBD5E1),
                                  width: 2.5,
                                ),
                              ),
                            ),
                            if (i < route.stops.length - 1)
                              Container(
                                width: 2,
                                height: 32,
                                color: isPassed ? const Color(0xFFE2E8F0) : const Color(0xFFDBEAFE),
                              ),
                          ],
                        ),
                        const SizedBox(width: 12),
                        // Stop Name & Tag
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  stop.name,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: isDestination || isCurrent
                                        ? FontWeight.w800
                                        : FontWeight.w500,
                                    color: isDestination
                                        ? AppColors.danger
                                        : isCurrent
                                            ? AppColors.primaryBlue
                                            : isPassed
                                                ? AppColors.textMuted
                                                : AppColors.textPrimary,
                                  ),
                                ),
                                if (isCurrent)
                                  const Text(
                                    'Bus here now',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.primaryBlue,
                                    ),
                                  ),
                                if (isDestination)
                                  const Text(
                                    'Alighting stop',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.danger,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // Notification Settings Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Notify me before my stop',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () => setState(() => _notifyOption = '5min'),
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: _notifyOption == '5min'
                                  ? const Color(0xFFEFF6FF)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: _notifyOption == '5min'
                                    ? AppColors.primaryBlue
                                    : AppColors.border,
                              ),
                            ),
                            child: Text(
                              '5 min before',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: _notifyOption == '5min'
                                    ? AppColors.primaryBlue
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: InkWell(
                          onTap: () => setState(() => _notifyOption = 'stop'),
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: _notifyOption == 'stop'
                                  ? const Color(0xFFEFF6FF)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: _notifyOption == 'stop'
                                    ? AppColors.primaryBlue
                                    : AppColors.border,
                              ),
                            ),
                            child: Text(
                              'At approaching stop',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: _notifyOption == 'stop'
                                    ? AppColors.primaryBlue
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // Destination Selector
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Change Destination Stop',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ...route.stops.map((TransitStop stop) {
                    final isSelected = stop.id == destinationStop.id;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: InkWell(
                        onTap: () => transit.setDestinationStopId(stop.id),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFFEFF6FF) : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isSelected ? AppColors.primaryBlue : AppColors.border,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                stop.name,
                                style: TextStyle(
                                  color: isSelected
                                      ? AppColors.primaryBlueDark
                                      : AppColors.textPrimary,
                                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                  fontSize: 13,
                                ),
                              ),
                              if (isSelected)
                                const Icon(Icons.check_circle, size: 18, color: AppColors.primaryBlue),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Pause / Resume Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textSecondary,
                  side: const BorderSide(color: AppColors.border),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  setState(() => _trackingActive = !_trackingActive);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        _trackingActive
                            ? 'Destination tracking resumed.'
                            : 'Destination tracking paused.',
                      ),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
                child: Text(
                  _trackingActive ? 'Pause Tracking' : 'Resume Tracking',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
