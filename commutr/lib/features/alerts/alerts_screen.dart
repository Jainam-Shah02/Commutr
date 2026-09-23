import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key});

  static const List<Map<String, String>> _alerts = [
    {
      'type': 'approach',
      'icon': '🚌',
      'title': 'Bus approaching',
      'body': 'TMT 50 is approximately 5 minutes away from Majiwada.',
      'time': '2 min ago',
      'severity': 'info',
    },
    {
      'type': 'eta-changed',
      'icon': '⚠️',
      'title': 'ETA changed',
      'body': 'TMT 50 arrival changed from 6 min to 10 min.',
      'time': '8 min ago',
      'severity': 'warning',
    },
    {
      'type': 'possible',
      'icon': '⚠️',
      'title': 'Possible service disruption',
      'body': 'A bus has stopped unexpectedly on TMT 50 route. Operator confirmation pending.',
      'time': '25 min ago',
      'severity': 'warning',
      'sub': 'Awaiting operator confirmation',
    },
    {
      'type': 'confirmed',
      'icon': '🔴',
      'title': 'Confirmed service disruption',
      'body': 'TMT 50 breakdown confirmed by operator. Last known position: Majiwada.',
      'time': '1 hr ago',
      'severity': 'danger',
      'sub': 'Alternative: TMT 2 via Panchpakhadi',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Alerts',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              'Route and service updates',
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 11,
              ),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AppColors.border, height: 1),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ..._alerts.map((alert) => _buildAlertCard(alert)),
          const SizedBox(height: 16),
          const Center(
            child: Text(
              'No more alerts',
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildAlertCard(Map<String, String> alert) {
    Color bg;
    Color border;

    final severity = alert['severity'];
    if (severity == 'danger') {
      bg = const Color(0xFFFEF2F2);
      border = const Color(0xFFFEE2E2);
    } else if (severity == 'warning') {
      bg = const Color(0xFFFFFBEB);
      border = const Color(0xFFFEF3C7);
    } else {
      bg = const Color(0xFFEFF6FF);
      border = const Color(0xFFDBEAFE);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(alert['icon']!, style: const TextStyle(fontSize: 16)),
                  const SizedBox(width: 8),
                  Text(
                    alert['title']!,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 13.5,
                    ),
                  ),
                ],
              ),
              Text(
                alert['time']!,
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 10.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            alert['body']!,
            style: const TextStyle(
              color: Color(0xFF475569),
              fontSize: 12,
              height: 1.4,
            ),
          ),
          if (alert['sub'] != null) ...[
            const SizedBox(height: 8),
            Text(
              alert['sub']!,
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
