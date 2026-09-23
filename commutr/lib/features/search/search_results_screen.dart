import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/routing/app_routes.dart';
import '../../models/bus_state.dart';
import '../../services/transit_provider.dart';
import '../../widgets/status_badge.dart';

class SearchResultsScreen extends StatefulWidget {
  const SearchResultsScreen({super.key});

  @override
  State<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
  final TextEditingController _searchController = TextEditingController(text: '50');
  String _query = '50';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final transit = context.watch<TransitProvider>();
    final busState = transit.busState;
    final selectedRoute = transit.selectedRoute;
    final isDisruption = transit.serviceStatus == ServiceStatus.confirmedDisruption;
    final nextStop = selectedRoute.stops.firstWhere(
      (s) => s.id == busState?.nextStopId,
      orElse: () => selectedRoute.stops.first,
    );

    // List of searchable routes
    final routes = [
      {
        'id': selectedRoute.id,
        'routeId': 'tmt-50',
        'no': '${selectedRoute.operator} ${selectedRoute.routeNumber}',
        'route': selectedRoute.name,
        'destination': selectedRoute.destination,
        'origin': selectedRoute.origin,
        'stops': selectedRoute.stops.map((s) => s.name).toList(),
        'status': isDisruption
            ? 'CONFIRMED DISRUPTION'
            : busState != null
                ? 'LIVE'
                : 'SCHEDULED',
        'eta': isDisruption
            ? 'Delayed'
            : busState != null
                ? '${busState.etaMinutes} min'
                : '10:25 AM',
        'nextStop': busState != null ? nextStop.name : null,
        'confidence': busState?.confidence.displayText,
      },
      {
        'id': 'tmt2-1',
        'routeId': 'tmt-2',
        'no': 'TMT 2',
        'route': 'Thane Station West → Balkum',
        'destination': 'Balkum',
        'origin': 'Thane Station West',
        'stops': ['Thane Station West', 'Panchpakhadi', 'Majiwada Junction', 'Balkum Naka'],
        'status': 'SCHEDULED',
        'eta': '10:35 AM',
        'nextStop': null,
        'confidence': null,
      },
      {
        'id': 'tmt1-1',
        'routeId': 'tmt-1',
        'no': 'TMT 1',
        'route': 'Thane Station West → Wagle Naka',
        'destination': 'Wagle Naka',
        'origin': 'Thane Station West',
        'stops': ['Thane Station West', 'Teen Hath Naka', 'Wagle Circle', 'Wagle Naka'],
        'status': 'SCHEDULED',
        'eta': '10:50 AM',
        'nextStop': null,
        'confidence': null,
      },
      {
        'id': 'best251-1',
        'routeId': 'best-251',
        'no': 'BEST 251',
        'route': 'Vesava → Andheri Station',
        'destination': 'Andheri Station',
        'origin': 'Vesava',
        'stops': ['Vesava', 'Seven Bungalows', 'Four Bungalows', 'Andheri Station'],
        'status': 'LIMITED DATA',
        'eta': 'Sch. 11:15 AM',
        'nextStop': null,
        'confidence': 'Limited live data',
      },
    ];

    final filtered = routes.where((r) {
      if (_query.trim().isEmpty) return true;
      final q = _query.toLowerCase();
      final no = (r['no'] as String).toLowerCase();
      final routeName = (r['route'] as String).toLowerCase();
      final dest = (r['destination'] as String).toLowerCase();
      final orig = (r['origin'] as String).toLowerCase();
      final stops = (r['stops'] as List<String>).map((s) => s.toLowerCase()).toList();

      return no.contains(q) ||
          routeName.contains(q) ||
          dest.contains(q) ||
          orig.contains(q) ||
          stops.any((s) => s.contains(q));
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Search Input Header
            Container(
              color: AppColors.surface,
              padding: const EdgeInsets.fromLTRB(12, 12, 16, 12),
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                        color: AppColors.textPrimary,
                        onPressed: () => Navigator.pop(context),
                      ),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: TextField(
                            controller: _searchController,
                            autofocus: true,
                            onChanged: (val) => setState(() => _query = val),
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w500,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Search bus, route, stop or destination...',
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                              prefixIcon: const Icon(Icons.search, size: 20, color: AppColors.textSecondary),
                              suffixIcon: _query.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.cancel, size: 18, color: AppColors.textMuted),
                                      onPressed: () {
                                        _searchController.clear();
                                        setState(() => _query = '');
                                      },
                                    )
                                  : null,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${filtered.length} ${filtered.length == 1 ? 'route' : 'routes'} found',
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                        const Text(
                          'Live + Scheduled',
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

            // Search Results List
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.search_off_rounded, size: 48, color: AppColors.textMuted),
                          SizedBox(height: 12),
                          Text(
                            'No routes or stops found',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Try searching for 50, Manpada, or Thane',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: filtered.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final r = filtered[index];
                        final status = r['status'] as String;
                        final nextStopName = r['nextStop'] as String?;
                        final confidence = r['confidence'] as String?;

                        return InkWell(
                          onTap: () {
                            if (r['routeId'] == 'tmt-50') {
                              Navigator.pushNamed(context, AppRoutes.busDetails);
                            } else {
                              Navigator.pushNamed(context, AppRoutes.routeDetails);
                            }
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.all(16),
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
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                r['no'] as String,
                                                style: const TextStyle(
                                                  color: AppColors.textPrimary,
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 16,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              _buildBadgeForStatus(status),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            r['route'] as String,
                                            style: const TextStyle(
                                              color: AppColors.textSecondary,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          r['eta'] as String,
                                          style: const TextStyle(
                                            color: AppColors.primaryBlue,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 18,
                                          ),
                                        ),
                                        Text(
                                          status == 'LIVE' ? 'Estimated arrival' : 'Scheduled',
                                          style: const TextStyle(
                                            color: AppColors.textMuted,
                                            fontSize: 10,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                if (nextStopName != null || confidence != null) ...[
                                  const SizedBox(height: 12),
                                  const Divider(height: 1),
                                  const SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      if (nextStopName != null)
                                        Row(
                                          children: [
                                            Container(
                                              width: 6,
                                              height: 6,
                                              decoration: const BoxDecoration(
                                                color: AppColors.primaryBlue,
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              'Next stop: $nextStopName',
                                              style: const TextStyle(
                                                color: AppColors.textSecondary,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        )
                                      else
                                        const SizedBox.shrink(),
                                      if (confidence != null)
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: AppColors.successLight,
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            confidence,
                                            style: const TextStyle(
                                              color: AppColors.success,
                                              fontSize: 10,
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
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadgeForStatus(String status) {
    if (status == 'CONFIRMED DISRUPTION') {
      return const StatusBadge(
        label: 'CONFIRMED DISRUPTION',
        backgroundColor: AppColors.dangerLight,
        textColor: AppColors.danger,
        icon: Icons.error_outline,
      );
    } else if (status == 'LIVE') {
      return const StatusBadge(
        label: 'LIVE',
        backgroundColor: AppColors.successLight,
        textColor: AppColors.success,
        icon: Icons.sensors,
      );
    } else if (status == 'LIMITED DATA') {
      return const StatusBadge(
        label: 'LIMITED DATA',
        backgroundColor: AppColors.warningLight,
        textColor: AppColors.warning,
      );
    } else {
      return const StatusBadge(
        label: 'SCHEDULED',
        backgroundColor: AppColors.borderLight,
        textColor: AppColors.textSecondary,
      );
    }
  }
}
