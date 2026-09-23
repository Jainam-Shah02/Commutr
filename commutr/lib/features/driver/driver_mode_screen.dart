import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/routing/app_routes.dart';
import '../../services/transit_provider.dart';

enum DriverFlowState {
  active,
  confirmBreakdown,
  breakdownReported,
  deviation,
}

class DriverModeScreen extends StatefulWidget {
  const DriverModeScreen({super.key});

  @override
  State<DriverModeScreen> createState() => _DriverModeScreenState();
}

class _DriverModeScreenState extends State<DriverModeScreen> {
  DriverFlowState _flowState = DriverFlowState.active;
  String _tripStatus = 'Running';

  @override
  Widget build(BuildContext context) {
    final transit = context.watch<TransitProvider>();
    final busState = transit.busState;
    final route = transit.selectedRoute;
    final driverModeActive = transit.driverModeActive;

    final nextStop = route.stops.where((s) => s.id == busState?.nextStopId).firstOrNull ??
        (route.stops.isNotEmpty ? route.stops[1] : null);

    // 1. Confirm Breakdown Screen
    if (_flowState == DriverFlowState.confirmBreakdown) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFFEE2E2), width: 2),
                  ),
                  child: const Icon(
                    Icons.warning_amber_rounded,
                    size: 36,
                    color: AppColors.danger,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Confirm bus breakdown?',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'This will immediately publish a CONFIRMED SERVICE DISRUPTION alert to all passengers on this route and notify transit dispatch.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.danger,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      transit.reportDriverBreakdown();
                      setState(() => _flowState = DriverFlowState.breakdownReported);
                    },
                    child: const Text(
                      'Confirm Breakdown',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textSecondary,
                      side: const BorderSide(color: AppColors.border),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => setState(() => _flowState = DriverFlowState.active),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // 2. Breakdown Reported Confirmation Screen
    if (_flowState == DriverFlowState.breakdownReported) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('🔴', style: TextStyle(fontSize: 48)),
                const SizedBox(height: 20),
                const Text(
                  'Breakdown Confirmed',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Passengers on ${route.operator} ${route.routeNumber} have been alerted with high priority.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Depot assistance dispatch ticket #BK-5082 generated.',
                  style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFFEE2E2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${route.operator} ${route.routeNumber} — Disruption Active',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.danger,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Last GPS position: ${nextStop?.name ?? 'Majiwada'} vicinity',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFFDC2626),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E293B),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      setState(() => _flowState = DriverFlowState.active);
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        AppRoutes.home,
                        (route) => false,
                      );
                    },
                    child: const Text(
                      'Return to Home',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // 3. Route Deviation Confirmation Screen
    if (_flowState == DriverFlowState.deviation) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('🔀', style: TextStyle(fontSize: 48)),
                const SizedBox(height: 20),
                const Text(
                  'Route Detour Required?',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Confirm detour to notify passengers that this bus is temporarily routing via Pokhran Road diversion.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.4),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF59E0B),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      transit.triggerDetour(true);
                      setState(() {
                        _flowState = DriverFlowState.active;
                        _tripStatus = 'Detour active';
                      });
                    },
                    child: const Text(
                      'Confirm Detour',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textSecondary,
                      side: const BorderSide(color: AppColors.border),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      transit.triggerDetour(false);
                      setState(() => _flowState = DriverFlowState.active);
                    },
                    child: const Text(
                      'Stay on Standard Route',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // 4. Main Driver Console Screen
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            // Dark Slate Header matching Figma
            Container(
              color: const Color(0xFF1E293B),
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 8,
                left: 16,
                right: 16,
                bottom: 20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left_rounded, size: 28, color: Colors.white70),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Text(
                        'Driver Mode',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFCBD5E1),
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Assigned Route',
                            style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${route.operator} ${route.routeNumber}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            route.name,
                            style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (driverModeActive)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF15803D),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF86EFAC),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  const Text(
                                    'TRIP ACTIVE',
                                    style: TextStyle(
                                      color: Color(0xFFDCFCE7),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF334155),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'STANDBY',
                                style: TextStyle(
                                  color: Color(0xFFCBD5E1),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          const SizedBox(height: 6),
                          Text(
                            _tripStatus,
                            style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Driver Controls Body
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Next Stop & Telemetry Source Card
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
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Next scheduled stop',
                                style: TextStyle(color: AppColors.textMuted, fontSize: 11),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                nextStop?.name ?? 'Majiwada',
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text(
                                'Telemetry Source',
                                style: TextStyle(color: AppColors.textMuted, fontSize: 11),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                driverModeActive ? 'DRIVER GPS (Verified)' : 'Passenger Crowd',
                                style: TextStyle(
                                  color: driverModeActive
                                      ? AppColors.primaryBlue
                                      : AppColors.textSecondary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Start/Stop Broadcast Button
                    if (!driverModeActive)
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.success,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            transit.startDriverTrip();
                            setState(() => _tripStatus = 'Running');
                          },
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('▶️', style: TextStyle(fontSize: 16)),
                              SizedBox(width: 8),
                              Text(
                                'Start Trip (Broadcast Driver GPS)',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0FDF4),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFDCFCE7)),
                        ),
                        child: const Row(
                          children: [
                            Text('📡', style: TextStyle(fontSize: 16)),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Driver telemetry active. Passenger LiveMap is synced to your trip.',
                                style: TextStyle(
                                  color: Color(0xFF166534),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(height: 18),

                    const Text(
                      'DRIVER CONTROLS',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textSecondary,
                        letterSpacing: 0.5,
                      ),
                    ),

                    const SizedBox(height: 12),

                    // 2x2 Grid of Driver Actions
                    Row(
                      children: [
                        Expanded(
                          child: _DriverActionTile(
                            iconText: '🔴',
                            label: 'Report Breakdown',
                            labelColor: AppColors.danger,
                            borderColor: const Color(0xFFFECACA),
                            bgColor: Colors.white,
                            onTap: () => setState(() => _flowState = DriverFlowState.confirmBreakdown),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _DriverActionTile(
                            iconText: '⏸',
                            label: 'Temporary Stop',
                            labelColor: const Color(0xFFB45309),
                            borderColor: const Color(0xFFFDE68A),
                            bgColor: Colors.white,
                            onTap: () => setState(() => _tripStatus = 'Temporary stop'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _DriverActionTile(
                            iconText: '🔀',
                            label: 'Route Blocked / Detour',
                            labelColor: AppColors.textPrimary,
                            borderColor: AppColors.border,
                            bgColor: Colors.white,
                            onTap: () => setState(() => _flowState = DriverFlowState.deviation),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _DriverActionTile(
                            iconText: '▶️',
                            label: 'Resume Standard',
                            labelColor: AppColors.success,
                            borderColor: const Color(0xFFBBF7D0),
                            bgColor: Colors.white,
                            onTap: () {
                              transit.triggerDetour(false);
                              setState(() => _tripStatus = 'Running');
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Inspect Live Passenger Map
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFEFF6FF),
                          foregroundColor: AppColors.primaryBlue,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: const BorderSide(color: Color(0xFFBFDBFE)),
                          ),
                        ),
                        onPressed: () => Navigator.pushNamed(context, AppRoutes.liveMap),
                        child: const Text(
                          'Inspect Live Passenger Map',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),

                    if (driverModeActive) ...[
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.textPrimary,
                            backgroundColor: Colors.white,
                            side: const BorderSide(color: AppColors.border),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            transit.endDriverTrip();
                            setState(() => _tripStatus = 'Trip ended');
                          },
                          child: const Text(
                            'End Trip',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DriverActionTile extends StatelessWidget {
  final String iconText;
  final String label;
  final Color labelColor;
  final Color borderColor;
  final Color bgColor;
  final VoidCallback onTap;

  const _DriverActionTile({
    required this.iconText,
    required this.label,
    required this.labelColor,
    required this.borderColor,
    required this.bgColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor),
          ),
          child: Column(
            children: [
              Text(iconText, style: const TextStyle(fontSize: 22)),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: labelColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
