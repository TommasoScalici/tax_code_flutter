import 'package:flutter_test/flutter_test.dart';
import 'package:tax_code_flutter_wear_os/services/demo_mode_service.dart';

void main() {
  late DemoModeService demoModeService;

  setUp(() {
    demoModeService = DemoModeService();
  });

  group('DemoModeService', () {
    test('initial state has isDemoMode false', () {
      expect(demoModeService.isDemoMode, isFalse);
    });

    test('exposes non-empty list of realistic demo contacts', () {
      final contacts = demoModeService.demoContacts;
      expect(contacts, isNotEmpty);
      expect(contacts.length, greaterThanOrEqualTo(2));
      expect(contacts.any((c) => c.firstName == 'Mario' && c.lastName == 'Rossi'), isTrue);
      expect(contacts.every((c) => c.taxCode.isNotEmpty), isTrue);
    });

    test('enableDemoMode sets isDemoMode to true and notifies listeners', () {
      var notified = false;
      demoModeService.addListener(() => notified = true);

      demoModeService.enableDemoMode();

      expect(demoModeService.isDemoMode, isTrue);
      expect(notified, isTrue);
    });

    test('enableDemoMode does not notify if already in demo mode', () {
      demoModeService.enableDemoMode();

      var notifyCount = 0;
      demoModeService.addListener(() => notifyCount++);

      demoModeService.enableDemoMode();

      expect(notifyCount, 0);
    });

    test('exitDemoMode sets isDemoMode to false and notifies listeners', () {
      demoModeService.enableDemoMode();

      var notified = false;
      demoModeService.addListener(() => notified = true);

      demoModeService.exitDemoMode();

      expect(demoModeService.isDemoMode, isFalse);
      expect(notified, isTrue);
    });

    test('exitDemoMode does not notify if already not in demo mode', () {
      var notifyCount = 0;
      demoModeService.addListener(() => notifyCount++);

      demoModeService.exitDemoMode();

      expect(notifyCount, 0);
    });
  });
}
