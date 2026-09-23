import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

enum BackendConnectionStatus {
  live,
  connecting,
  offline,
}

/// WebSocket Real-time Bus Telemetry Service for Commutr
class TransitRealtimeService {
  final String wsUrl;
  WebSocketChannel? _channel;
  final StreamController<Map<String, dynamic>> _positionController =
      StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<BackendConnectionStatus> _statusController =
      StreamController<BackendConnectionStatus>.broadcast();

  BackendConnectionStatus _currentStatus = BackendConnectionStatus.offline;
  bool _isDisposed = false;
  Timer? _reconnectTimer;
  Timer? _heartbeatTimer;

  TransitRealtimeService({String? wsUrl})
      : wsUrl = wsUrl ?? _defaultWsUrl();

  static String _defaultWsUrl() {
    if (kIsWeb) return 'ws://localhost:8080/ws/bus-positions';
    try {
      if (Platform.isAndroid) return 'ws://10.0.2.2:8080/ws/bus-positions';
    } catch (_) {}
    return 'ws://localhost:8080/ws/bus-positions';
  }

  Stream<Map<String, dynamic>> get positionStream => _positionController.stream;
  Stream<BackendConnectionStatus> get statusStream => _statusController.stream;
  BackendConnectionStatus get currentStatus => _currentStatus;
  bool get isLive => _currentStatus == BackendConnectionStatus.live;

  void connect() {
    if (_isDisposed) return;
    _setStatus(BackendConnectionStatus.connecting);

    try {
      final uri = Uri.parse(wsUrl);
      _channel = WebSocketChannel.connect(uri);

      _channel!.stream.listen(
        (dynamic message) {
          _setStatus(BackendConnectionStatus.live);
          try {
            final Map<String, dynamic> data = jsonDecode(message.toString());
            _positionController.add(data);
          } catch (e) {
            debugPrint('Failed to parse WebSocket message: $e');
          }
        },
        onError: (error) {
          debugPrint('WebSocket error: $error');
          _handleDisconnect();
        },
        onDone: () {
          debugPrint('WebSocket closed');
          _handleDisconnect();
        },
        cancelOnError: true,
      );
    } catch (e) {
      debugPrint('Failed to initiate WebSocket connection: $e');
      _handleDisconnect();
    }
  }

  void _setStatus(BackendConnectionStatus status) {
    if (_currentStatus != status) {
      _currentStatus = status;
      if (!_statusController.isClosed) {
        _statusController.add(status);
      }
    }
  }

  void _handleDisconnect() {
    _setStatus(BackendConnectionStatus.offline);
    _channel = null;

    if (!_isDisposed) {
      _reconnectTimer?.cancel();
      _reconnectTimer = Timer(const Duration(seconds: 5), () {
        if (!_isDisposed && _currentStatus != BackendConnectionStatus.live) {
          connect();
        }
      });
    }
  }

  void disconnect() {
    _reconnectTimer?.cancel();
    _heartbeatTimer?.cancel();
    try {
      _channel?.sink.close();
    } catch (_) {}
    _channel = null;
    _setStatus(BackendConnectionStatus.offline);
  }

  void dispose() {
    _isDisposed = true;
    disconnect();
    _positionController.close();
    _statusController.close();
  }
}
