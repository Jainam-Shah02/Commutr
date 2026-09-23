import 'package:flutter/material.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/onboarding/location_permission_screen.dart';
import '../../features/main_shell_screen.dart';
import '../../features/search/search_results_screen.dart';
import '../../features/bus_details/bus_details_screen.dart';
import '../../features/boarding/boarding_screen.dart';
import '../../features/ride_verification/ride_verification_screen.dart';
import '../../features/route_details/route_details_screen.dart';
import '../../features/stop_details/stop_details_screen.dart';
import '../../features/driver/driver_mode_screen.dart';
import '../../features/report_problem/report_problem_screen.dart';
import '../../features/privacy/privacy_settings_screen.dart';
import '../../features/destination_tracking/destination_tracking_screen.dart';

/// Commutr Route Registry
/// Exactly maps to all 17 screens from the reference application
class AppRoutes {
  AppRoutes._();

  static const String initial = '/';
  static const String onboarding = '/onboarding';
  static const String locationPermission = '/location-permission';
  static const String home = '/home';
  static const String search = '/search';
  static const String busDetails = '/bus';
  static const String liveMap = '/live-map';
  static const String boarding = '/board';
  static const String rideVerification = '/ride-verification';
  static const String trips = '/trips';
  static const String alerts = '/alerts';
  static const String profile = '/profile';
  static const String routeDetails = '/route';
  static const String stopDetails = '/stop';
  static const String driver = '/driver';
  static const String reportProblem = '/report-problem';
  static const String privacy = '/privacy';
  static const String destinationTracking = '/destination-tracking';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case initial:
      case onboarding:
        return _buildRoute(const OnboardingScreen(), settings);
      case locationPermission:
        return _buildRoute(const LocationPermissionScreen(), settings);
      case home:
        return _buildRoute(const MainShellScreen(initialTab: 0), settings);
      case search:
        return _buildRoute(const SearchResultsScreen(), settings);
      case busDetails:
        return _buildRoute(const BusDetailsScreen(), settings);
      case liveMap:
        return _buildRoute(const MainShellScreen(initialTab: 1), settings);
      case boarding:
        return _buildRoute(const BoardingScreen(), settings);
      case rideVerification:
        return _buildRoute(const RideVerificationScreen(), settings);
      case trips:
        return _buildRoute(const MainShellScreen(initialTab: 2), settings);
      case alerts:
        return _buildRoute(const MainShellScreen(initialTab: 3), settings);
      case profile:
        return _buildRoute(const MainShellScreen(initialTab: 4), settings);
      case routeDetails:
        return _buildRoute(const RouteDetailsScreen(), settings);
      case stopDetails:
        return _buildRoute(const StopDetailsScreen(), settings);
      case driver:
        return _buildRoute(const DriverModeScreen(), settings);
      case reportProblem:
        return _buildRoute(const ReportProblemScreen(), settings);
      case privacy:
        return _buildRoute(const PrivacySettingsScreen(), settings);
      case destinationTracking:
        return _buildRoute(const DestinationTrackingScreen(), settings);
      default:
        return _buildRoute(const MainShellScreen(initialTab: 0), settings);
    }
  }

  static MaterialPageRoute _buildRoute(Widget screen, RouteSettings settings) {
    return MaterialPageRoute(builder: (_) => screen, settings: settings);
  }
}
