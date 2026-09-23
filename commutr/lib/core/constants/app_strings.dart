/// Commutr Standard Terminology and Core Copy
/// Adheres strictly to the Commutr Truthfulness & Verification Principles:
/// - Never claim exact bus location ("Estimated real-time position")
/// - Never claim exact seat counts ("Seats likely available")
/// - Never let an unconfirmed report claim breakdown ("Possible service disruption")
class AppStrings {
  AppStrings._();

  static const String appName = 'Commutr';
  static const String appTagline = 'Crowdsourced Real-time Transit Intelligence';

  // Navigation
  static const String navHome = 'Home';
  static const String navLive = 'Live';
  static const String navTrips = 'Trips';
  static const String navAlerts = 'Alerts';
  static const String navProfile = 'Profile';

  // Search & Destination
  static const String searchPrompt = 'Where are you going?';
  static const String searchBus = 'Search bus, stop, or destination';
  static const String nearbyStops = 'Nearby Stops';
  static const String nearbyBuses = 'Live Buses Nearby';
  static const String savedRoutes = 'Saved Routes';
  static const String recentTrips = 'Recent Trips';

  // Data Quality & Confidence
  static const String highConfidence = 'High confidence';
  static const String mediumConfidence = 'Medium confidence';
  static const String limitedLiveData = 'Limited live data';
  static const String noLiveData = 'No live data';
  static const String scheduledOnly = 'Using scheduled information';
  static const String liveUnavailable = 'Live location unavailable';
  static const String estimatedBusPosition = 'Estimated real-time position';

  // Occupancy
  static const String seatsLikely = 'Seats likely available';
  static const String moderatelyCrowded = 'Moderately crowded';
  static const String mostlyOccupied = 'Mostly occupied';
  static const String standingRoom = 'Standing room likely';

  // Disruptions & Detours
  static const String possibleDisruption = 'Possible service disruption';
  static const String confirmedDisruption = 'Confirmed service disruption';
  static const String routeDeviation = 'Route deviation detected';
  static const String alternateRoute = 'Bus is taking an alternate route';

  // Ride Verification & Location Sharing
  static const String didYouBoard = 'Did you board this bus?';
  static const String startSharing = 'Start Sharing';
  static const String stopSharing = 'Stop Sharing';
  static const String notNow = 'Not Now';
  static const String rideTrustTitle = 'RideTrust Verification';
  static const String passengerPrivacyNotice =
      'Your anonymized phone movement helps verify bus location for fellow commuters. Sharing stops automatically.';

  // Driver / Conductor Mode
  static const String driverMode = 'Driver / Conductor Mode';
  static const String authorizedLogin = 'Authorized Operator Login';
  static const String reportBreakdown = 'Report Breakdown';
  static const String temporaryStop = 'Report Temporary Stop';
  static const String routeBlocked = 'Report Route Blocked';
  static const String resumeTrip = 'Resume Trip';
  static const String endTrip = 'End Trip';
}
