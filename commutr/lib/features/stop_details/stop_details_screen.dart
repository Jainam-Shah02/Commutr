import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/routing/app_routes.dart';
import '../../models/transit_stop.dart';
import '../../services/transit_provider.dart';
import '../../widgets/status_badge.dart';

class StopDetailsScreen extends StatefulWidget {
  const StopDetailsScreen({super.key});

  @override
  State<StopDetailsScreen> createState() => _StopDetailsScreenState();
}

class _StopDetailsScreenState extends State<StopDetailsScreen> {
  String? _notifiedBusNo;

  @override
  Widget build(BuildContext context) {
    final transit = context.watch<TransitProvider>();
    final route = transit.selectedRoute;
    final busState = transit.busState;

    final String? stopId = ModalRoute.of(context)?.settings.arguments as String?;
    final TransitStop currentStop = route.stops.where((s) => s.id == stopId).firstOrNull ??
        (route.stops.isNotEmpty ? route.stops[0] : const TransitStop(id: 'stop-1', name: 'Majiwada Junction', latitude: 19.205, longitude: 72.975, order: 1));

    final stopIndex = route.stops.indexWhere((s) => s.id == currentStop.id);
    final isCurrentBusStop = busState?.currentStopId == currentStop.id;

    final busesAtStop = [
      {
        'no': '${route.operator} ${route.routeNumber}',
        'dest': route.destination,
        'status': busState != null ? 'LIVE' : 'SCHEDULED',
        'eta': busState != null
            ? (isCurrentBusStop ? 'At stop' : '${busState.etaMinutes} min')
            : '10:25 AM',
        'confidence': busState?.confidence,
        'routeId': route.id,
      },
      {
        'no': 'TMT 2',
        'dest': 'Balkum Naka',
        'status': 'SCHEDULED',
        'eta': '10:35 AM',
        'confidence': null,
        'routeId': 'tmt-2',
      },
      {
        'no': 'TMT 1',
        'dest': 'Wagle Naka',
        'status': 'SCHEDULED',
        'eta': '10:50 AM',
        'confidence': null,
        'routeId': 'tmt-1',
      },
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left_rounded, size: 28, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              currentStop.name,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              'Stop #${stopIndex >= 0 ? stopIndex + 1 : 1} on ${route.operator} ${route.routeNumber} · Thane',
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 11,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 14, top: 10, bottom: 10),
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                backgroundColor: const Color(0xFFEFF6FF),
                foregroundColor: AppColors.primaryBlue,
                side: const BorderSide(color: Color(0xFFBFDBFE)),
                padding: const EdgeInsets.symmetric(horizontal: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () => Navigator.pushNamed(context, AppRoutes.liveMap),
              child: const Text(
                'View on Map',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AppColors.border, height: 1),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'UPCOMING BUSES',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.6,
                ),
              ),
              Text(
                'Auto-refreshed',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...busesAtStop.map((bus) {
            final isLive = bus['status'] == 'LIVE';
            final busNo = bus['no'] as String;
            final isNotified = _notifiedBusNo == busNo;

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            busNo,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          StatusBadge(
                            label: bus['status'] as String,
                            backgroundColor: isLive
                                ? AppColors.successLight
                                : AppColors.borderLight,
                            textColor: isLive
                                ? AppColors.success
                                : AppColors.textSecondary,
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'To ${bus['dest']}',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                      if (bus['confidence'] != null) ...[
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDCFCE7),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            bus['confidence'] as String,
                            style: const TextStyle(
                              color: AppColors.success,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        bus['eta'] as String,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          if (isLive) ...[
                            InkWell(
                              onTap: () => Navigator.pushNamed(context, AppRoutes.liveMap),
                              borderRadius: BorderRadius.circular(6),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryBlue,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  'Track',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                          ],
                          InkWell(
                            onTap: () {
                              setState(() {
                                _notifiedBusNo = isNotified ? null : busNo;
                              });
                            },
                            borderRadius: BorderRadius.circular(6),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: isNotified ? const Color(0xFFDCFCE7) : const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(6),
                                border: isNotified ? Border.all(color: const Color(0xFFBBF7D0)) : null,
                              ),
                              child: Text(
                                isNotified ? '✓ Set' : 'Notify',
                                style: TextStyle(
                                  color: isNotified ? AppColors.success : AppColors.textSecondary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'How Live vs Scheduled Works',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Live ETA is computed when GPS signals from passengers or drivers are verified. When buses are still in depot or between shifts, scheduled timetable times are displayed.',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
