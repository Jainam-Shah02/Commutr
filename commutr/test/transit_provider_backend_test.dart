import 'package:flutter_test/flutter_test.dart';
import 'package:commutr/services/transit_provider.dart';
import 'package:commutr/services/realtime/transit_realtime_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('TransitProvider Backend & Fallback Tests', () {
    test('Connection badge reflects backend state and Demo fallback operates safely', () async {
      final provider = TransitProvider();

      // Initial state is connecting or offline
      expect(
        provider.backendStatus == BackendConnectionStatus.connecting ||
            provider.backendStatus == BackendConnectionStatus.offline,
        isTrue,
      );
      expect(
        provider.connectionStatusBadgeText == 'CONNECTING' ||
            provider.connectionStatusBadgeText == 'OFFLINE / DEMO',
        isTrue,
      );
      expect(provider.isBackendLive, isFalse);

      // Bus state operates normally via Demo fallback (never null when isLiveAvailable is true)
      final bus = provider.busState;
      expect(bus, isNotNull);
      expect(bus!.routeNumber, '50');
      expect(bus.latitude, isNotNull);
      expect(bus.longitude, isNotNull);

      provider.dispose();
    });

    test('Route switching preserves safe bus state in demo mode', () {
      final provider = TransitProvider();
      provider.setSelectedRouteById('tmt-2');
      expect(provider.selectedRoute.routeNumber, '2');

      final bus = provider.busState;
      expect(bus, isNotNull);
      expect(bus!.routeNumber, '2');

      provider.dispose();
    });
  });
}
