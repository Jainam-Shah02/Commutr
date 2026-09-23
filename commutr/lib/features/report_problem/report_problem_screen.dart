import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/routing/app_routes.dart';
import '../../services/transit_provider.dart';
import '../../widgets/app_header.dart';

class ReportProblemScreen extends StatefulWidget {
  const ReportProblemScreen({super.key});

  @override
  State<ReportProblemScreen> createState() => _ReportProblemScreenState();
}

class _ReportProblemScreenState extends State<ReportProblemScreen> {
  String? _selectedProblem;
  bool _submitted = false;

  final List<Map<String, String>> _problemOptions = [
    {
      'id': 'stopped',
      'label': 'Bus stopped unexpectedly',
      'icon': '⏸',
    },
    {
      'id': 'blocked',
      'label': 'Route blocked / heavy obstruction',
      'icon': '🚧',
    },
    {
      'id': 'emergency',
      'label': 'Accident / emergency on route',
      'icon': '🚨',
    },
    {
      'id': 'other',
      'label': 'Other service issue',
      'icon': '💬',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final transit = context.watch<TransitProvider>();
    final route = transit.selectedRoute;

    if (_submitted) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: const AppHeader(title: 'Report a Problem'),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFDBEAFE), width: 2),
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    size: 38,
                    color: AppColors.primaryBlue,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Report received',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Your report has been received and flagged for operator verification.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFFDE68A)),
                  ),
                  child: const Text(
                    '⏳ Waiting for operator confirmation',
                    style: TextStyle(
                      color: Color(0xFF92400E),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Text(
                    'Passengers will see Possible Service Disruption while this incident is under review. A confirmed disruption alert is issued only after driver or transit operator confirmation.',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => Navigator.pushReplacementNamed(context, AppRoutes.liveMap),
                    child: const Text(
                      'Back to Live Map',
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

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppHeader(
        title: 'Report a Problem',
        subtitle: '${route.operator} ${route.routeNumber} · ${route.name}',
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'What seems to be the problem?',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 12),
              ..._problemOptions.map((p) {
                final isSelected = _selectedProblem == p['id'];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: InkWell(
                    onTap: () => setState(() => _selectedProblem = p['id']),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFFF0F7FF) : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? AppColors.primaryBlue : AppColors.border,
                          width: isSelected ? 1.5 : 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.02),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Text(p['icon']!, style: const TextStyle(fontSize: 20)),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              p['label']!,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                color: isSelected ? AppColors.primaryBlueDark : AppColors.textPrimary,
                              ),
                            ),
                          ),
                          if (isSelected)
                            Container(
                              width: 20,
                              height: 20,
                              decoration: const BoxDecoration(
                                color: AppColors.primaryBlue,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.check, size: 14, color: Colors.white),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Text(
                  'Reports are verified against GPS sensor signals and driver telemetry before publishing route-wide alerts.',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 11,
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selectedProblem != null
                        ? AppColors.primaryBlue
                        : const Color(0xFFE2E8F0),
                    foregroundColor: _selectedProblem != null
                        ? Colors.white
                        : const Color(0xFF94A3B8),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _selectedProblem != null
                      ? () {
                          transit.reportPassengerProblem(_selectedProblem!);
                          setState(() => _submitted = true);
                        }
                      : null,
                  child: const Text(
                    'Submit Report',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
