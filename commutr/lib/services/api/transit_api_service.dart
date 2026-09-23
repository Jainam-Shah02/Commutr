import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// REST API Client for Commutr Spring Boot Backend
class TransitApiService {
  final String baseUrl;
  final http.Client _client;

  TransitApiService({
    String? baseUrl,
    http.Client? client,
  })  : baseUrl = baseUrl ?? _defaultBaseUrl(),
        _client = client ?? http.Client();

  static String _defaultBaseUrl() {
    if (kIsWeb) return 'http://localhost:8080';
    try {
      if (Platform.isAndroid) return 'http://10.0.2.2:8080';
    } catch (_) {}
    return 'http://localhost:8080';
  }

  /// Checks if backend is online and database is operational
  Future<bool> checkHealth() async {
    try {
      final response = await _client
          .get(Uri.parse('$baseUrl/api/v1/health'))
          .timeout(const Duration(seconds: 3));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return data['status'] == 'UP';
      }
      return false;
    } catch (e) {
      debugPrint('TransitApiService health check failed: $e');
      return false;
    }
  }

  /// Retrieves list of transit routes
  Future<List<Map<String, dynamic>>> getRoutes() async {
    try {
      final response = await _client
          .get(Uri.parse('$baseUrl/api/v1/routes'))
          .timeout(const Duration(seconds: 4));
      if (response.statusCode == 200) {
        final List<dynamic> list = jsonDecode(response.body);
        return list.cast<Map<String, dynamic>>();
      }
    } catch (e) {
      debugPrint('TransitApiService getRoutes failed: $e');
    }
    return [];
  }

  /// Retrieves route stops in order
  Future<List<Map<String, dynamic>>> getRouteStops(int routeId) async {
    try {
      final response = await _client
          .get(Uri.parse('$baseUrl/api/v1/routes/$routeId/stops'))
          .timeout(const Duration(seconds: 4));
      if (response.statusCode == 200) {
        final List<dynamic> list = jsonDecode(response.body);
        return list.cast<Map<String, dynamic>>();
      }
    } catch (e) {
      debugPrint('TransitApiService getRouteStops failed: $e');
    }
    return [];
  }

  /// Retrieves latest bus position
  Future<Map<String, dynamic>?> getBusPosition(int busId) async {
    try {
      final response = await _client
          .get(Uri.parse('$baseUrl/api/v1/buses/$busId/position'))
          .timeout(const Duration(seconds: 3));
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
    } catch (e) {
      debugPrint('TransitApiService getBusPosition failed: $e');
    }
    return null;
  }

  /// Posts crowd GPS observation anonymously to backend
  Future<bool> sendGpsObservation({
    required int busId,
    required String deviceSessionId,
    required double latitude,
    required double longitude,
    double? speedKmh,
    double? heading,
    double? accuracyMeters,
    DateTime? clientTimestamp,
  }) async {
    try {
      final payload = {
        'busId': busId,
        'deviceSessionId': deviceSessionId,
        'latitude': latitude,
        'longitude': longitude,
        'speedKmh': speedKmh,
        'heading': heading,
        'accuracyMeters': accuracyMeters,
        'clientTimestamp': (clientTimestamp ?? DateTime.now().toUtc()).toIso8601String(),
      };

      final response = await _client
          .post(
            Uri.parse('$baseUrl/api/v1/location'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 4));

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('TransitApiService sendGpsObservation failed: $e');
      return false;
    }
  }

  void dispose() {
    _client.close();
  }
}
