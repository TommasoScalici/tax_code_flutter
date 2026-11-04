import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tax_code_flutter/services/deep_link_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DeepLinkService', () {
    test('captures valid initial route with taxcode scheme', () {
      final service = DeepLinkService(initialRoute: 'taxcode://barcode/me');
      addTearDown(service.dispose);

      expect(
        service.pendingDeepLink,
        equals(Uri.parse('taxcode://barcode/me')),
      );
    });

    test('captures valid initial route with app scheme', () {
      final service = DeepLinkService(
        initialRoute: 'app://tommasoscalici.taxcode/barcode?query=Mario',
      );
      addTearDown(service.dispose);

      expect(
        service.pendingDeepLink,
        equals(Uri.parse('app://tommasoscalici.taxcode/barcode?query=Mario')),
      );
    });

    test('ignores initial route with unsupported scheme or root route', () {
      final service = DeepLinkService(initialRoute: 'https://example.com');
      addTearDown(service.dispose);
      expect(service.pendingDeepLink, isNull);

      final serviceRoot = DeepLinkService(initialRoute: '/');
      addTearDown(serviceRoot.dispose);
      expect(serviceRoot.pendingDeepLink, isNull);
    });

    test(
      'captures runtime deep link via didPushRouteInformation and notifies listeners',
      () async {
        final service = DeepLinkService(initialRoute: '/');
        addTearDown(service.dispose);

        var notified = false;
        service.addListener(() => notified = true);

        final handled = await service.didPushRouteInformation(
          RouteInformation(uri: Uri.parse('taxcode://barcode/123')),
        );

        expect(handled, isTrue);
        expect(notified, isTrue);
        expect(
          service.pendingDeepLink,
          equals(Uri.parse('taxcode://barcode/123')),
        );
      },
    );

    test(
      'returns false and does not notify for unsupported runtime route',
      () async {
        final service = DeepLinkService(initialRoute: '/');
        addTearDown(service.dispose);

        var notified = false;
        service.addListener(() => notified = true);

        final handled = await service.didPushRouteInformation(
          RouteInformation(uri: Uri.parse('https://example.com/test')),
        );

        expect(handled, isFalse);
        expect(notified, isFalse);
        expect(service.pendingDeepLink, isNull);
      },
    );

    test('consumePendingDeepLink returns URI and resets pending link', () {
      final service = DeepLinkService(initialRoute: 'taxcode://barcode/me');
      addTearDown(service.dispose);

      expect(service.pendingDeepLink, isNotNull);
      final consumed = service.consumePendingDeepLink();
      expect(consumed, equals(Uri.parse('taxcode://barcode/me')));
      expect(service.pendingDeepLink, isNull);
    });

    test('setPendingDeepLink updates link and notifies listeners', () {
      final service = DeepLinkService(initialRoute: '/');
      addTearDown(service.dispose);

      var notified = false;
      service.addListener(() => notified = true);

      service.setPendingDeepLink(Uri.parse('taxcode://barcode/custom'));
      expect(notified, isTrue);
      expect(
        service.pendingDeepLink,
        equals(Uri.parse('taxcode://barcode/custom')),
      );
    });

    test('clearPendingDeepLink clears without returning', () {
      final service = DeepLinkService(initialRoute: 'taxcode://barcode/me');
      addTearDown(service.dispose);

      expect(service.pendingDeepLink, isNotNull);
      service.clearPendingDeepLink();
      expect(service.pendingDeepLink, isNull);
    });
  });
}
