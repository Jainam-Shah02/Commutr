import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/routing/app_routes.dart';
import '../../models/bus_state.dart';
import '../../services/transit_provider.dart';
import '../../widgets/status_badge.dart';

class RouteDetailsScreen extends StatefulWidget {
  const RouteDetailsScreen({super.key});

  @override
  State<RouteDetailsScreen> createState() => _RouteDetailsScreenState();
}

class _RouteDetailsScreenState extends State<RouteDetailsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final transit = context.watch<TransitProvider>();
    final route = transit.selectedRoute;
    final busState = transit.busState;
    final serviceStatus = transit.serviceStatus;

    final currentStop = route.stops.where((s) => s.id == busState?.currentStopId).firstOrNull;
    final nextStop = route.stops.where((s) => s.id == busState?.nextStopId).firstOrNull;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left_rounded, size: 28, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '${route.operator} ${route.routeNumber}',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(width: 8),
                    StatusBadge(
                      label: serviceStatus == ServiceStatus.confirmedDisruption
                          ? 'CONFIRMED DISRUPTION'
                          : busState == null
                              ? 'SCHEDULED'
                              : 'LIVE',
                      backgroundColor: busState != null
                          ? AppColors.successLight
                          : AppColors.borderLight,
                      textColor: busState != null
                          ? AppColors.success
                          : AppColors.textSecondary,
                    ),
                  ],
                ),
                Text(
                  route.name,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Column(
            children: [
              TabBar(
                controller: _tabController,
                indicatorColor: AppColors.primaryBlue,
                indicatorWeight: 2.5,
                labelColor: AppColors.primaryBlue,
                unselectedLabelColor: AppColors.textSecondary,
                labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                unselectedLabelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                tabs: const [
                  Tab(text: 'Live'),
                  Tab(text: 'Timetable'),
                  Tab(text: 'Stops'),
                ],
              ),
              Container(color: AppColors.border, height: 1),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // 1. LIVE TAB
          ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (busState != null) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
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
                                'Estimated arrival',
                                style: TextStyle(color: AppColors.textMuted, fontSize: 11),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                serviceStatus == ServiceStatus.confirmedDisruption
                                    ? 'Delayed'
                                    : '${busState.etaMinutes} min',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w800,
                                  color: serviceStatus == ServiceStatus.confirmedDisruption
                                      ? AppColors.danger
                                      : AppColors.primaryBlue,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text(
                                'Next stop',
                                style: TextStyle(color: AppColors.textMuted, fontSize: 11),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                nextStop?.name ?? 'Majiwada',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Current: ${currentStop?.name ?? 'Thane'}',
                                style: const TextStyle(color: AppColors.textMuted, fontSize: 10),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const Divider(height: 24, color: AppColors.borderLight),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.successLight,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              busState.confidence.label,
                              style: const TextStyle(
                                color: AppColors.success,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Updated ${busState.lastUpdatedSec}s ago',
                            style: const TextStyle(color: AppColors.textMuted, fontSize: 10),
                          ),
                          const Spacer(),
                          Text(
                            '${busState.occupancy.name.toUpperCase()} occupancy',
                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 10.5),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
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
                    onPressed: () => Navigator.pushNamed(context, AppRoutes.liveMap),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.map_rounded, size: 18),
                        SizedBox(width: 8),
                        Text('Open Live Map', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                ),
              ] else ...[
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Live tracking unavailable',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Check the timetable tab for scheduled departures.',
                        style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                      ),
                      const SizedBox(height: 14),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFEFF6FF),
                          foregroundColor: AppColors.primaryBlue,
                          elevation: 0,
                        ),
                        onPressed: () => _tabController.animateTo(1),
                        child: const Text('View Timetable'),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 14),
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
                      'Live Data Verification',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Commutr aggregates multiple authenticated passenger location pings with road geometry to guarantee high confidence estimates without tracking individual identities.',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // 2. TIMETABLE TAB
          ListView(
            padding: const EdgeInsets.all(16),
            children: [
              ...route.timetable.map((section) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      section.period.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textSecondary,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        children: section.times.asMap().entries.map((entry) {
                          final i = entry.key;
                          final t = entry.value;
                          return Column(
                            children: [
                              if (i > 0)
                                Container(
                                  height: 1,
                                  margin: const EdgeInsets.symmetric(horizontal: 16),
                                  color: const Color(0xFFF1F5F9),
                                ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      t.time,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    StatusBadge(
                                      label: t.status,
                                      backgroundColor: t.status == 'LIVE'
                                          ? AppColors.successLight
                                          : AppColors.borderLight,
                                      textColor: t.status == 'LIVE'
                                          ? AppColors.success
                                          : AppColors.textSecondary,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                );
              }),
            ],
          ),

          // 3. STOPS TAB
          ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: route.stops.asMap().entries.map((entry) {
                    final i = entry.key;
                    final stop = entry.value;
                    final isCurrent = busState?.currentStopId == stop.id;
                    final isNext = busState?.nextStopId == stop.id;
                    final isPassed = busState != null &&
                        route.stops.indexWhere((s) => s.id == busState.currentStopId) > i;
                    final isTerminus = i == route.stops.length - 1;

                    return Column(
                      children: [
                        if (i > 0)
                          Container(
                            height: 1,
                            margin: const EdgeInsets.symmetric(horizontal: 16),
                            color: const Color(0xFFF1F5F9),
                          ),
                        InkWell(
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              AppRoutes.stopDetails,
                              arguments: stop.id,
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            child: Row(
                              children: [
                                Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isCurrent
                                        ? AppColors.primaryBlue
                                        : isNext
                                            ? const Color(0xFF60A5FA)
                                            : isPassed
                                                ? const Color(0xFFCBD5E1)
                                                : isTerminus
                                                    ? AppColors.danger
                                                    : const Color(0xFF94A3B8),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        stop.name,
                                        style: TextStyle(
                                          fontSize: 13.5,
                                          fontWeight: isCurrent || isNext
                                              ? FontWeight.w700
                                              : FontWeight.w500,
                                          color: isCurrent
                                              ? AppColors.primaryBlue
                                              : isNext
                                                  ? AppColors.textPrimary
                                                  : AppColors.textPrimary,
                                        ),
                                      ),
                                      if (isCurrent)
                                        const Text(
                                          'Bus estimated here',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.primaryBlue,
                                          ),
                                        ),
                                      if (isNext)
                                        const Text(
                                          'Next approaching stop',
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: AppColors.textMuted,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.chevron_right_rounded, size: 18, color: Color(0xFFCBD5E1)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
