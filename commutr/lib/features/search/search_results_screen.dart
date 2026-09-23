import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/transit_route.dart';
import '../../models/transit_stop.dart';
import '../../services/demo_data_service.dart';
import '../../services/location/location_service.dart';
import '../../services/transit_provider.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/tracking_mode_dialog.dart';

class SearchResultsScreen extends StatefulWidget {
  const SearchResultsScreen({super.key});

  @override
  State<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
  final TextEditingController _fromController = TextEditingController();
  final TextEditingController _toController = TextEditingController();
  final FocusNode _fromFocusNode = FocusNode();
  final FocusNode _toFocusNode = FocusNode();

  bool _initializedFromArgs = false;
  bool _isSearchingFrom = false;
  String _activeQuery = '';

  @override
  void initState() {
    super.initState();
    _fromFocusNode.addListener(() {
      if (_fromFocusNode.hasFocus) {
        setState(() {
          _isSearchingFrom = true;
          _activeQuery = _fromController.text;
        });
      }
    });

    _toFocusNode.addListener(() {
      if (_toFocusNode.hasFocus) {
        setState(() {
          _isSearchingFrom = false;
          _activeQuery = _toController.text;
        });
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initializedFromArgs) {
      _initializedFromArgs = true;
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      final transit = context.read<TransitProvider>();

      if (args != null && args.containsKey('from')) {
        _fromController.text = args['from'] as String;
      } else if (transit.permissionState == LocationPermissionState.granted) {
        _fromController.text = 'Current Location';
      } else {
        _fromController.text = 'Teen Hath Naka';
      }

      if (args != null && args.containsKey('to')) {
        _toController.text = args['to'] as String;
      }
    }
  }

  @override
  void dispose() {
    _fromController.dispose();
    _toController.dispose();
    _fromFocusNode.dispose();
    _toFocusNode.dispose();
    super.dispose();
  }

  void _swapFromAndTo() {
    final temp = _fromController.text;
    _fromController.text = _toController.text;
    _toController.text = temp;
    setState(() {});
  }

  void _selectStop(String stopName) {
    if (_isSearchingFrom) {
      _fromController.text = stopName;
      _fromFocusNode.unfocus();
      _toFocusNode.requestFocus();
    } else {
      _toController.text = stopName;
      _toFocusNode.unfocus();
      _saveRecentSearch();
    }
    setState(() {
      _activeQuery = '';
    });
  }

  void _saveRecentSearch() {
    final from = _fromController.text.trim();
    final to = _toController.text.trim();
    if (from.isNotEmpty && to.isNotEmpty) {
      context.read<TransitProvider>().addRecentSearch(from, to);
    }
  }

  @override
  Widget build(BuildContext context) {
    final transit = context.watch<TransitProvider>();
    final nearestStop = transit.getNearestStopForUser();
    final isFromCurrentLocation = _fromController.text.trim().toLowerCase() == 'current location';
    final hasActiveFocus = _fromFocusNode.hasFocus || _toFocusNode.hasFocus;

    // Filter matching buses based on FROM / TO / Query
    final availableRoutes = DemoDataService.findRoutesBetween(
      _fromController.text == 'Current Location' ? nearestStop.stop.name : _fromController.text,
      _toController.text,
    );

    // Dynamic Bus Results sorted by earliest expected arrival
    final busResults = [
      {
        'route': DemoDataService.routeTmt65,
        'busNumber': 'TMT 65',
        'routeName': 'Thane Station West → Wagle Estate',
        'arrivalMinutes': 3,
        'arrivalText': 'Arriving in 3 min',
        'arrivalSub': 'Arriving at ${nearestStop.stop.name} in 3 min',
        'speedText': '28 km/h',
        'crowdStatus': 'Seats Available',
        'confidence': 'High (14 people)',
        'liveStatus': 'LIVE',
      },
      {
        'route': DemoDataService.routeTmt68,
        'busNumber': 'TMT 68',
        'routeName': 'Mulund Check Naka → Cadbury Junction',
        'arrivalMinutes': 7,
        'arrivalText': 'Arriving in 7 min',
        'arrivalSub': 'Arriving at Teen Hath Naka in 7 min',
        'speedText': '26 km/h',
        'crowdStatus': 'Moderately Crowded',
        'confidence': 'High (11 people)',
        'liveStatus': 'LIVE',
      },
      {
        'route': DemoDataService.routeTmt50,
        'busNumber': 'TMT 50',
        'routeName': 'Thane Station West → Manpada',
        'arrivalMinutes': 10,
        'arrivalText': 'Arriving in 10 min',
        'arrivalSub': 'Arriving at Majiwada in 10 min',
        'speedText': '32 km/h',
        'crowdStatus': 'Mostly Occupied',
        'confidence': 'Medium (6 people)',
        'liveStatus': 'LIVE',
      },
      {
        'route': DemoDataService.routeTmt2,
        'busNumber': 'TMT 2',
        'routeName': 'Thane Station West → Balkum',
        'arrivalMinutes': 14,
        'arrivalText': 'Scheduled in 14 min',
        'arrivalSub': 'Scheduled arrival',
        'speedText': '25 km/h',
        'crowdStatus': 'Standing Room Likely',
        'confidence': 'Scheduled',
        'liveStatus': 'SCHEDULED',
      },
    ];

    // Filter results if user explicitly entered a route or destination query
    final filteredBuses = busResults.where((b) {
      final routeObj = b['route'] as TransitRoute;
      final query = _activeQuery.toLowerCase().trim();
      if (query.isNotEmpty) {
        final matchesNo = (b['busNumber'] as String).toLowerCase().contains(query);
        final matchesRoute = (b['routeName'] as String).toLowerCase().contains(query);
        final matchesStop = routeObj.stops.any((s) => s.name.toLowerCase().contains(query));
        return matchesNo || matchesRoute || matchesStop;
      }
      return availableRoutes.any((r) => r.id == routeObj.id);
    }).toList()
      ..sort((a, b) => (a['arrivalMinutes'] as int).compareTo(b['arrivalMinutes'] as int));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // -------------------------------------------------------------
            // Search Input Header: FROM & TO with Swap
            // -------------------------------------------------------------
            Container(
              color: AppColors.surface,
              padding: const EdgeInsets.fromLTRB(12, 12, 16, 16),
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                        color: AppColors.textPrimary,
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        'Track Your Bus',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // From / To Search Box Card
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        // Left dots and vertical connecting line
                        Column(
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: const BoxDecoration(
                                color: AppColors.primaryBlue,
                                shape: BoxShape.circle,
                              ),
                            ),
                            Container(
                              width: 2,
                              height: 32,
                              color: AppColors.border,
                            ),
                            Container(
                              width: 10,
                              height: 10,
                              decoration: const BoxDecoration(
                                color: AppColors.success,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 12),

                        // Text Fields
                        Expanded(
                          child: Column(
                            children: [
                              // FROM input
                              TextField(
                                controller: _fromController,
                                focusNode: _fromFocusNode,
                                onChanged: (val) => setState(() => _activeQuery = val),
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'FROM: Current Location or stop',
                                  hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: const EdgeInsets.symmetric(vertical: 4),
                                  suffixIcon: _fromController.text.isNotEmpty && _fromFocusNode.hasFocus
                                      ? IconButton(
                                          icon: const Icon(Icons.clear, size: 16, color: AppColors.textMuted),
                                          onPressed: () {
                                            _fromController.clear();
                                            setState(() => _activeQuery = '');
                                          },
                                        )
                                      : null,
                                ),
                              ),
                              const Divider(height: 12, color: AppColors.border),

                              // TO input
                              TextField(
                                controller: _toController,
                                focusNode: _toFocusNode,
                                onChanged: (val) => setState(() => _activeQuery = val),
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'TO: Search destination or stop',
                                  hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: const EdgeInsets.symmetric(vertical: 4),
                                  suffixIcon: _toController.text.isNotEmpty && _toFocusNode.hasFocus
                                      ? IconButton(
                                          icon: const Icon(Icons.clear, size: 16, color: AppColors.textMuted),
                                          onPressed: () {
                                            _toController.clear();
                                            setState(() => _activeQuery = '');
                                          },
                                        )
                                      : null,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Swap Button
                        IconButton(
                          icon: const Icon(Icons.swap_vert_rounded, color: AppColors.primaryBlue),
                          tooltip: 'Swap From & To',
                          onPressed: _swapFromAndTo,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // -------------------------------------------------------------
            // Walking Guidance Card (when FROM = Current Location)
            // -------------------------------------------------------------
            if (isFromCurrentLocation) ...[
              Container(
                margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: AppColors.primaryBlueLight,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.directions_walk_rounded,
                        size: 20,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "You're about ${nearestStop.distanceMeters} m from ${nearestStop.stop.name}",
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Head towards ${nearestStop.stop.name} (Approx. ${nearestStop.distanceMeters} m)',
                            style: const TextStyle(
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
            ],

            // -------------------------------------------------------------
            // Body Content: Autocomplete vs Results / Recent
            // -------------------------------------------------------------
            Expanded(
              child: hasActiveFocus && _activeQuery.trim().isNotEmpty
                  ? _buildAutocompleteList()
                  : _buildResultsAndRecentList(filteredBuses, transit),
            ),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // Instant Search Autocomplete for Thane Bus Stops & Routes
  // -------------------------------------------------------------
  Widget _buildAutocompleteList() {
    final matchingStops = DemoDataService.searchStops(_activeQuery);
    final matchingRoutes = DemoDataService.searchRoutes(_activeQuery);

    if (matchingStops.isEmpty && matchingRoutes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.search_off_rounded, size: 40, color: AppColors.textMuted),
            SizedBox(height: 10),
            Text(
              'No matching stops or routes found',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Try typing "Teen Hath Naka", "Wagle", or "65"',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      children: [
        // Route number results
        if (matchingRoutes.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              'ROUTES',
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.0,
              ),
            ),
          ),
          ...matchingRoutes.map((r) => _buildRouteSearchItem(r)),
          const SizedBox(height: 16),
        ],

        // Bus Stop results
        if (matchingStops.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              'BUS STOPS IN THANE',
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.0,
              ),
            ),
          ),
          ...matchingStops.map((s) => _buildStopSearchItem(s)),
        ],
      ],
    );
  }

  Widget _buildStopSearchItem(TransitStop stop) {
    return InkWell(
      onTap: () => _selectStop(stop.name),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        margin: const EdgeInsets.only(bottom: 6),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            const Icon(Icons.location_on_outlined, size: 20, color: AppColors.primaryBlue),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                stop.name,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (stop.isMajor)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlueLight,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'Major',
                  style: TextStyle(
                    color: AppColors.primaryBlue,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRouteSearchItem(TransitRoute route) {
    return InkWell(
      onTap: () {
        context.read<TransitProvider>().setSelectedRouteById(route.id);
        _toController.text = route.destination;
        _fromController.text = route.origin;
        _fromFocusNode.unfocus();
        _toFocusNode.unfocus();
        setState(() => _activeQuery = '');
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        margin: const EdgeInsets.only(bottom: 6),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primaryBlueLight,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '${route.operator} ${route.routeNumber}',
                style: const TextStyle(
                  color: AppColors.primaryBlue,
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                route.name,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // Search Results & Recent Searches List
  // -------------------------------------------------------------
  Widget _buildResultsAndRecentList(
    List<Map<String, dynamic>> buses,
    TransitProvider transit,
  ) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Available Buses Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${buses.length} ${buses.length == 1 ? 'Bus' : 'Buses'} Available',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            const Text(
              'Earliest arrival first',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Bus Cards
        ...buses.map((bus) => _buildBusResultCard(bus)),

        // Recent Searches on Search Page
        if (transit.recentSearches.isNotEmpty) ...[
          const SizedBox(height: 20),
          const Text(
            'Recent Searches',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          ...transit.recentSearches.take(3).map((s) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              child: InkWell(
                onTap: () {
                  setState(() {
                    _fromController.text = s.from;
                    _toController.text = s.to;
                    _fromFocusNode.unfocus();
                    _toFocusNode.unfocus();
                    _activeQuery = '';
                  });
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.history_rounded, size: 18, color: AppColors.textMuted),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '${s.from} → ${s.to}',
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: AppColors.textMuted),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ],
    );
  }

  Widget _buildBusResultCard(Map<String, dynamic> bus) {
    final route = bus['route'] as TransitRoute;
    final busNo = bus['busNumber'] as String;
    final routeName = bus['routeName'] as String;
    final arrivalText = bus['arrivalText'] as String;
    final arrivalSub = bus['arrivalSub'] as String;
    final speed = bus['speedText'] as String;
    final crowd = bus['crowdStatus'] as String;
    final liveStatus = bus['liveStatus'] as String;
    final confidence = bus['confidence'] as String? ?? 'High (14 people)';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => TrackingModeSheet.show(context, route),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border, width: 1.1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row: Bus Number + Route + Arrival ETA
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlueLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      busNo,
                      style: const TextStyle(
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          routeName,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          arrivalSub,
                          style: const TextStyle(
                            color: AppColors.primaryBlue,
                            fontWeight: FontWeight.w600,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        arrivalText,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 3),
                      _buildLiveBadge(liveStatus),
                    ],
                  ),
                ],
              ),

              const Divider(height: 20, color: AppColors.border),

              // Bottom Row: Speed, Confidence with People Count, Crowd Occupancy
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.speed_rounded, size: 15, color: AppColors.textMuted),
                      const SizedBox(width: 4),
                      Text(
                        speed,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.verified_user_rounded,
                        size: 14,
                        color: liveStatus == 'LIVE' ? AppColors.success : AppColors.textMuted,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        confidence,
                        style: TextStyle(
                          color: liveStatus == 'LIVE' ? AppColors.success : AppColors.textSecondary,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(Icons.airline_seat_recline_normal_rounded, size: 15, color: AppColors.textMuted),
                      const SizedBox(width: 4),
                      Text(
                        crowd,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLiveBadge(String status) {
    if (status == 'LIVE') {
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
        icon: Icons.schedule,
      );
    }
  }
}
