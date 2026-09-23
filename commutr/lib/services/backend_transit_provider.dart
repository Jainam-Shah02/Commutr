import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'api/transit_api_service.dart';
import 'realtime/transit_realtime_service.dart';

/// Real-time Backend Transit Provider
/// Coordinates REST queries, WebSocket updates, and anonymous crowd GPS telemetry
class BackendTransitProvider extends ChangeNotifier {
  final TransitApiService _apiService;
  final TransitRealtimeService _realtimeService;

  BackendConnectionStatus _connectionStatus = BackendConnectionStatus.offline;
  StreamSubscription<Map<String, dynamic>>? _positionSub;
  StreamSubscription<BackendConnectionStatus>? _statusSub;

  Map<String, dynamic>? _latestBackendPosition;
  final String _deviceSessionId;

  BackendTransitProvider({
    TransitApiService? apiService,
    TransitRealtimeService? realtimeService,
  })  : _apiService = apiService ?? TransitApiService(),
        _realtimeService = realtimeService ?? TransitRealtimeService(),
        _deviceSessionId = _generateSessionId() {
    _init();
  }

  static String _generateSessionId() {
    final rand = math.Random();
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    return 'dev-${List.generate(12, (_) => chars[rand.nextInt(chars.length)]).join()}';
  }

  // Getters
  TransitApiService get apiService => _apiService;
  TransitRealtimeService get realtimeService => _realtimeService;
  BackendConnectionStatus get connectionStatus => _connectionStatus;
  bool get isConnected => _connectionStatus == BackendConnectionStatus.live;
  Map<String, dynamic>? get latestBackendPosition => _latestBackendPosition;
  String get deviceSessionId => _deviceSessionId;

  bool _isDisposed = false;

  void _init() {
    _statusSub = _realtimeService.statusStream.listen((status) {
      if (_isDisposed) return;
      _connectionStatus = status;
      notifyListeners();
    });

    _positionSub = _realtimeService.positionStream.listen((data) {
      if (_isDisposed) return;
      _latestBackendPosition = data;
      _connectionStatus = BackendConnectionStatus.live;
      notifyListeners();
    });

    // Try initial health check and connect
    checkBackendAndConnect();
  }

  Future<void> checkBackendAndConnect() async {
    if (_isDisposed) return;
    _connectionStatus = BackendConnectionStatus.connecting;
    notifyListeners();

    final isUp = await _apiService.checkHealth();
    if (_isDisposed) return;

    if (isUp) {
      _realtimeService.connect();
    } else {
      _connectionStatus = BackendConnectionStatus.offline;
      if (!_isDisposed) {
        notifyListeners();
      }
    }
  }

  /// Sends passenger GPS observation anonymously
  Future<bool> reportObservation({
    required int busId,
    required double latitude,
    required double longitude,
    double? speedKmh,
    double? heading,
    double? accuracyMeters,
  }) async {
    if (_isDisposed) return false;
    return await _apiService.sendGpsObservation(
      busId: busId,
      deviceSessionId: _deviceSessionId,
      latitude: latitude,
      longitude: longitude,
      speedKmh: speedKmh,
      heading: heading,
      accuracyMeters: accuracyMeters,
      clientTimestamp: DateTime.now().toUtc(),
    );
  }

  @override
  void dispose() {
    _isDisposed = true;
    _positionSub?.cancel();
    _statusSub?.cancel();
    _realtimeService.dispose();
    _apiService.dispose();
    super.dispose();
  }
}
