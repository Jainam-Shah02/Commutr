import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:commutr/services/api/transit_api_service.dart';

void main() {
  group('TransitApiService Tests', () {
    test('checkHealth returns true when backend responds UP', () async {
      final mockClient = MockClient((request) async {
        if (request.url.path == '/api/v1/health') {
          return http.Response(
            jsonEncode({'status': 'UP', 'service': 'commutr-backend'}),
            200,
            headers: {'content-type': 'application/json'},
          );
        }
        return http.Response('Not Found', 404);
      });

      final apiService = TransitApiService(
        baseUrl: 'http://localhost:8080',
        client: mockClient,
      );

      final isHealthy = await apiService.checkHealth();
      expect(isHealthy, isTrue);
    });

    test('getRoutes returns list of routes when backend responds 200', () async {
      final mockClient = MockClient((request) async {
        if (request.url.path == '/api/v1/routes') {
          return http.Response(
            jsonEncode([
              {'id': 1, 'routeNumber': '50', 'routeName': 'Thane to Manpada'},
              {'id': 2, 'routeNumber': '2', 'routeName': 'Thane to Balkum'},
            ]),
            200,
            headers: {'content-type': 'application/json'},
          );
        }
        return http.Response('Not Found', 404);
      });

      final apiService = TransitApiService(
        baseUrl: 'http://localhost:8080',
        client: mockClient,
      );

      final routes = await apiService.getRoutes();
      expect(routes.length, 2);
      expect(routes.first['routeNumber'], '50');
    });

    test('sendGpsObservation posts JSON payload and returns true on 200', () async {
      final mockClient = MockClient((request) async {
        if (request.url.path == '/api/v1/location') {
          final body = jsonDecode(request.body) as Map<String, dynamic>;
          expect(body['busId'], 1);
          expect(body['deviceSessionId'], 'session-xyz');
          expect(body['latitude'], 19.1932);
          return http.Response(
            jsonEncode({'status': 'ACCEPTED', 'busId': 1}),
            200,
            headers: {'content-type': 'application/json'},
          );
        }
        return http.Response('Not Found', 404);
      });

      final apiService = TransitApiService(
        baseUrl: 'http://localhost:8080',
        client: mockClient,
      );

      final success = await apiService.sendGpsObservation(
        busId: 1,
        deviceSessionId: 'session-xyz',
        latitude: 19.1932,
        longitude: 72.9692,
        speedKmh: 25.0,
      );

      expect(success, isTrue);
    });
  });
}
