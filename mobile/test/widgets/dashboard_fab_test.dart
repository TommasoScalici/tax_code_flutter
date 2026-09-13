import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tax_code_flutter/widgets/dashboard/dashboard_fab.dart';

import '../helpers/pump_app.dart';
import '../helpers/test_setup.dart';

void main() {
  setUpAll(setupTests);

  void setMobileSize(WidgetTester tester) {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  }

  group('DashboardFab Widget Tests', () {
    testWidgets('renders extended FAB with default label and icon in Italian', (
      tester,
    ) async {
      setMobileSize(tester);
      var pressed = false;

      await pumpApp(
        tester,
        Scaffold(
          floatingActionButton: DashboardFab(
            onPressed: () => pressed = true,
          ),
        ),
        locale: const Locale('it'),
      );

      expect(find.byType(DashboardFab), findsOneWidget);
      expect(find.text('Nuovo Codice'), findsOneWidget);
      expect(find.byIcon(Icons.add_rounded), findsOneWidget);

      await tester.tap(find.byType(DashboardFab));
      await tester.pump();

      expect(pressed, isTrue);
    });

    testWidgets('renders collapsed FAB when isExtended is false', (tester) async {
      setMobileSize(tester);

      await pumpApp(
        tester,
        Scaffold(
          floatingActionButton: DashboardFab(
            isExtended: false,
            onPressed: () {},
          ),
        ),
        locale: const Locale('it'),
      );

      expect(find.byType(DashboardFab), findsOneWidget);
      expect(find.byIcon(Icons.add_rounded), findsOneWidget);
      // In collapsed mode, the label is omitted
      expect(find.text('Nuovo Codice'), findsNothing);
    });

    testWidgets('allows custom label and icon override', (tester) async {
      setMobileSize(tester);

      await pumpApp(
        tester,
        Scaffold(
          floatingActionButton: DashboardFab(
            label: 'Crea Tessera',
            icon: const Icon(Icons.credit_card_rounded),
            onPressed: () {},
          ),
        ),
        locale: const Locale('it'),
      );

      expect(find.text('Crea Tessera'), findsOneWidget);
      expect(find.byIcon(Icons.credit_card_rounded), findsOneWidget);
    });

    testWidgets('renders English localization when locale is en', (tester) async {
      setMobileSize(tester);

      await pumpApp(
        tester,
        Scaffold(
          floatingActionButton: DashboardFab(
            onPressed: () {},
          ),
        ),
        locale: const Locale('en'),
      );

      expect(find.text('New Code'), findsOneWidget);
    });
  });
}
