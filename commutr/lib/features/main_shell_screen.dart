import 'package:flutter/material.dart';
import '../widgets/app_bottom_nav.dart';
import 'home/home_screen.dart';
import 'live/live_map_screen.dart';
import 'trips/trips_screen.dart';
import 'alerts/alerts_screen.dart';
import 'profile/profile_screen.dart';

/// Main scaffold hosting the 5 primary tabs of Commutr
class MainShellScreen extends StatefulWidget {
  final int initialTab;
  const MainShellScreen({super.key, this.initialTab = 0});

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTab;
  }

  void _onTabSelected(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          HomeScreen(),
          LiveMapScreen(),
          TripsScreen(),
          AlertsScreen(),
          ProfileScreen(),
        ],
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _currentIndex,
        onTap: _onTabSelected,
      ),
    );
  }
}
