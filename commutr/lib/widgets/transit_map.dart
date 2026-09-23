import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../core/constants/app_colors.dart';
import '../models/bus_state.dart';
import '../models/transit_route.dart';
import '../models/transit_stop.dart';
import '../services/location/location_service.dart';

/// Interactive Real-world OpenStreetMap widget for Commutr
class TransitMap extends StatefulWidget {
  final TransitRoute route;
  final BusState? bus;
  final List<TransitStop> stops;
  final UserPosition? userLocation;
  final String? destinationStopId;
  final bool followBus;
  final ValueChanged<bool>? onFollowBusChanged;
  final void Function(TransitStop)? onStopSelect;
  final List<GeoCoord>? activePolyline;
  final ServiceStatus serviceStatus;

  const TransitMap({
    super.key,
    required this.route,
    required this.bus,
    required this.stops,
    this.userLocation,
    this.destinationStopId,
    this.followBus = false,
    this.onFollowBusChanged,
    this.onStopSelect,
    this.activePolyline,
    this.serviceStatus = ServiceStatus.normal,
  });

  @override
  State<TransitMap> createState() => _TransitMapState();
}

class _TransitMapState extends State<TransitMap> with TickerProviderStateMixin {
  late final MapController _mapController;
  late final AnimationController _busAnimationController;
  bool _hasInitialFitted = false;

  LatLng? _oldBusPos;
  LatLng? _targetBusPos;
  double _oldHeading = 0.0;
  double _targetHeading = 0.0;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _busAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 950),
    );

    if (widget.bus != null) {
      _oldBusPos = LatLng(widget.bus!.latitude, widget.bus!.longitude);
      _targetBusPos = _oldBusPos;
      _oldHeading = widget.bus!.heading;
      _targetHeading = widget.bus!.heading;
    }
  }

  @override
  void dispose() {
    _busAnimationController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant TransitMap oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.bus != null) {
      final nextPos = LatLng(widget.bus!.latitude, widget.bus!.longitude);
      if (_targetBusPos == null) {
        _oldBusPos = nextPos;
        _targetBusPos = nextPos;
        _oldHeading = widget.bus!.heading;
        _targetHeading = widget.bus!.heading;
      } else if (_targetBusPos!.latitude != nextPos.latitude ||
          _targetBusPos!.longitude != nextPos.longitude) {
        final t = _busAnimationController.value;
        final curLat = _oldBusPos!.latitude +
            (_targetBusPos!.latitude - _oldBusPos!.latitude) * t;
        final curLon = _oldBusPos!.longitude +
            (_targetBusPos!.longitude - _oldBusPos!.longitude) * t;

        _oldBusPos = LatLng(curLat, curLon);
        _targetBusPos = nextPos;
        _oldHeading = _targetHeading;
        _targetHeading = widget.bus!.heading;
        _busAnimationController.forward(from: 0.0);
      }

      // If followBus is active, animate camera
      if (widget.followBus) {
        final busPt = LatLng(widget.bus!.latitude, widget.bus!.longitude);
        _mapController.move(busPt, _mapController.camera.zoom);
      }
    }

    // If route changed, fit bounds to new route
    if (oldWidget.route.id != widget.route.id) {
      _fitRouteBounds();
    }
  }

  void _fitRouteBounds() {
    final coords = widget.activePolyline ?? widget.route.coordinates;
    if (coords.isEmpty) return;

    final latLngs = coords.map((c) => LatLng(c.latitude, c.longitude)).toList();
    final bounds = LatLngBounds.fromPoints(latLngs);

    _mapController.fitCamera(
      CameraFit.bounds(
        bounds: bounds,
        padding: const EdgeInsets.only(top: 80, bottom: 220, left: 30, right: 30),
        maxZoom: 15.5,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final coords = widget.activePolyline ?? widget.route.coordinates;
    final primaryPoints = coords.map((c) => LatLng(c.latitude, c.longitude)).toList();

    // Default initial center is first coordinate or Thane station
    final initialCenter = primaryPoints.isNotEmpty
        ? primaryPoints[primaryPoints.length ~/ 2]
        : const LatLng(19.205, 72.975);

    final isDetour = widget.serviceStatus == ServiceStatus.detour &&
        widget.route.detourCoordinates != null;

    final originalPoints = widget.route.coordinates
        .map((c) => LatLng(c.latitude, c.longitude))
        .toList();

    final currentStopIndex =
        widget.stops.indexWhere((s) => s.id == widget.bus?.currentStopId);

    return Stack(
      children: [
        // Interactive OpenStreetMap Layer
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: initialCenter,
            initialZoom: 13.5,
            minZoom: 10.0,
            maxZoom: 18.0,
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.all,
            ),
            onMapReady: () {
              if (!_hasInitialFitted) {
                _fitRouteBounds();
                _hasInitialFitted = true;
              }
            },
          ),
          children: [
            // Standard OpenStreetMap Tile Layer
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.commutr.app',
              maxZoom: 19,
            ),

            // Route Polylines
            PolylineLayer(
              polylines: [
                // If Detour active: draw original route in dashed grey
                if (isDetour && originalPoints.isNotEmpty)
                  Polyline(
                    points: originalPoints,
                    strokeWidth: 4.0,
                    color: const Color(0xFF94A3B8).withValues(alpha: 0.8),
                    strokeCap: StrokeCap.round,
                    strokeJoin: StrokeJoin.round,
                  ),

                // Primary Active Route (Electric Municipal Blue)
                if (primaryPoints.isNotEmpty)
                  Polyline(
                    points: primaryPoints,
                    strokeWidth: 5.0,
                    color: AppColors.primaryBlue,
                    strokeCap: StrokeCap.round,
                    strokeJoin: StrokeJoin.round,
                  ),
              ],
            ),

            // Stop Markers
            MarkerLayer(
              markers: [
                // Render Stops
                ...widget.stops.asMap().entries.map((entry) {
                  final i = entry.key;
                  final stop = entry.value;
                  final isDestination = stop.id == widget.destinationStopId;
                  final isCurrent = widget.bus != null && stop.id == widget.bus!.currentStopId;
                  final isPassed = currentStopIndex >= 0 && i < currentStopIndex;

                  return Marker(
                    point: LatLng(stop.latitude, stop.longitude),
                    width: 70,
                    height: 40,
                    alignment: Alignment.center,
                    child: GestureDetector(
                      onTap: () => widget.onStopSelect?.call(stop),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: isCurrent || isDestination ? 14 : 10,
                            height: isCurrent || isDestination ? 14 : 10,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isDestination
                                  ? Colors.white
                                  : isCurrent
                                      ? AppColors.primaryBlue
                                      : isPassed
                                          ? const Color(0xFF94A3B8)
                                          : Colors.white,
                              border: Border.all(
                                color: isDestination
                                    ? AppColors.danger
                                    : isCurrent
                                        ? Colors.white
                                        : AppColors.primaryBlue,
                                width: isDestination ? 3.0 : 2.0,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.2),
                                  blurRadius: 4,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 2),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.9),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: const Color(0xFFE2E8F0), width: 0.5),
                            ),
                            child: Text(
                              stop.name,
                              style: TextStyle(
                                fontSize: 8.5,
                                fontWeight: isCurrent || isDestination
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: isDestination
                                    ? AppColors.danger
                                    : AppColors.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),

                // Real User Location Marker (if granted & tracking)
                if (widget.userLocation != null)
                  Marker(
                    point: LatLng(
                      widget.userLocation!.latitude,
                      widget.userLocation!.longitude,
                    ),
                    width: 32,
                    height: 32,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF38BDF8).withValues(alpha: 0.3),
                          ),
                        ),
                        Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF0284C7),
                            border: Border.all(color: Colors.white, width: 2.5),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.25),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),

            // Live Virtual Bus Marker (Smoothly Animated 60fps)
            if (widget.bus != null)
              AnimatedBuilder(
                animation: _busAnimationController,
                builder: (context, _) {
                  final t = _busAnimationController.value;
                  final lat = (_oldBusPos != null && _targetBusPos != null)
                      ? _oldBusPos!.latitude +
                          (_targetBusPos!.latitude - _oldBusPos!.latitude) * t
                      : widget.bus!.latitude;
                  final lon = (_oldBusPos != null && _targetBusPos != null)
                      ? _oldBusPos!.longitude +
                          (_targetBusPos!.longitude - _oldBusPos!.longitude) * t
                      : widget.bus!.longitude;
                  final heading =
                      _oldHeading + (_targetHeading - _oldHeading) * t;

                  return MarkerLayer(
                    markers: [
                      Marker(
                        point: LatLng(lat, lon),
                        width: 44,
                        height: 44,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Pulsing outer aura
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.primaryBlue.withValues(alpha: 0.25),
                              ),
                            ),
                            // Rotated bus icon oriented with road heading
                            Transform.rotate(
                              angle: heading * (math.pi / 180.0),
                              child: Container(
                                width: 26,
                                height: 26,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.primaryBlue,
                                  border: Border.all(color: Colors.white, width: 2),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.3),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.navigation_rounded,
                                  size: 15,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
          ],
        ),

        // Floating Map Controls (Right Side)
        Positioned(
          top: MediaQuery.of(context).padding.top + 64,
          right: 16,
          child: Column(
            children: [
              // Follow Bus button
              if (widget.bus != null)
                _MapControlButton(
                  icon: Icons.my_location_rounded,
                  isActive: widget.followBus,
                  tooltip: widget.followBus ? 'Following Bus' : 'Center on Bus',
                  onTap: () {
                    final next = !widget.followBus;
                    widget.onFollowBusChanged?.call(next);
                    if (next && widget.bus != null) {
                      _mapController.move(
                        LatLng(widget.bus!.latitude, widget.bus!.longitude),
                        _mapController.camera.zoom,
                      );
                    }
                  },
                ),
              const SizedBox(height: 8),

              // Reset / Fit Route Bounds button
              _MapControlButton(
                icon: Icons.crop_free_rounded,
                isActive: false,
                tooltip: 'Fit Route',
                onTap: () {
                  widget.onFollowBusChanged?.call(false);
                  _fitRouteBounds();
                },
              ),
              const SizedBox(height: 8),

              // Zoom In
              _MapControlButton(
                icon: Icons.add_rounded,
                isActive: false,
                tooltip: 'Zoom In',
                onTap: () {
                  _mapController.move(
                    _mapController.camera.center,
                    _mapController.camera.zoom + 1,
                  );
                },
              ),
              const SizedBox(height: 8),

              // Zoom Out
              _MapControlButton(
                icon: Icons.remove_rounded,
                isActive: false,
                tooltip: 'Zoom Out',
                onTap: () {
                  _mapController.move(
                    _mapController.camera.center,
                    _mapController.camera.zoom - 1,
                  );
                },
              ),
            ],
          ),
        ),

        // Map Legend (Bottom Right of Map Area)
        Positioned(
          bottom: 12,
          right: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 6,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 14,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'Route',
                      style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
                    ),
                  ],
                ),
                if (isDetour) ...[
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 14,
                        height: 4,
                        decoration: BoxDecoration(
                          color: const Color(0xFF94A3B8),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'Original route',
                        style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 9,
                      height: 9,
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'Bus Live',
                      style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
                    ),
                  ],
                ),
                if (widget.userLocation != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 9,
                        height: 9,
                        decoration: BoxDecoration(
                          color: const Color(0xFF0284C7),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'You (GPS)',
                        style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),

        // OpenStreetMap Attribution (Bottom Left)
        Positioned(
          bottom: 4,
          left: 8,
          child: Text(
            '© OpenStreetMap contributors',
            style: TextStyle(
              fontSize: 9,
              color: Colors.black.withValues(alpha: 0.4),
              backgroundColor: Colors.white.withValues(alpha: 0.6),
            ),
          ),
        ),
      ],
    );
  }
}

class _MapControlButton extends StatelessWidget {
  final IconData icon;
  final bool isActive;
  final String tooltip;
  final VoidCallback onTap;

  const _MapControlButton({
    required this.icon,
    required this.isActive,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isActive ? AppColors.primaryBlue : Colors.white,
      borderRadius: BorderRadius.circular(12),
      elevation: 3,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isActive ? AppColors.primaryBlue : AppColors.border,
            ),
          ),
          child: Icon(
            icon,
            size: 19,
            color: isActive ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
