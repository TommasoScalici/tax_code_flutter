import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tax_code_flutter/widgets/dashboard/dashboard_search_bar.dart';

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

  group('DashboardSearchBar Widget Tests', () {
    testWidgets('renders search text field with default hint and search icon', (tester) async {
      setMobileSize(tester);

      await pumpApp(
        tester,
        const Scaffold(
          body: DashboardSearchBar(),
        ),
        locale: const Locale('it'),
      );

      expect(find.byType(TextField), findsOneWidget);
      expect(find.byIcon(Icons.search_rounded), findsOneWidget);
      expect(find.text('Cerca per nome o codice fiscale...'), findsOneWidget);
      expect(find.byKey(const Key('dashboard_search_bar_clear_button')), findsNothing);
    });

    testWidgets('renders custom hint text when provided', (tester) async {
      setMobileSize(tester);

      await pumpApp(
        tester,
        const Scaffold(
          body: DashboardSearchBar(hintText: 'Filtra anagrafica...'),
        ),
      );

      expect(find.text('Filtra anagrafica...'), findsOneWidget);
    });

    testWidgets('entering text triggers onChanged and displays clear button', (tester) async {
      setMobileSize(tester);
      String? changedText;

      await pumpApp(
        tester,
        Scaffold(
          body: DashboardSearchBar(
            onChanged: (val) => changedText = val,
          ),
        ),
      );

      final textField = find.byType(TextField);
      await tester.enterText(textField, 'Mario');
      await tester.pump();

      expect(changedText, 'Mario');
      expect(find.byKey(const Key('dashboard_search_bar_clear_button')), findsOneWidget);
    });

    testWidgets('tapping clear button clears input and triggers callbacks', (tester) async {
      setMobileSize(tester);
      final controller = TextEditingController(text: 'Rossi');
      var clearCalled = false;
      String? changedText;

      await pumpApp(
        tester,
        Scaffold(
          body: DashboardSearchBar(
            controller: controller,
            onChanged: (val) => changedText = val,
            onClear: () => clearCalled = true,
          ),
        ),
      );

      expect(find.byKey(const Key('dashboard_search_bar_clear_button')), findsOneWidget);

      await tester.tap(find.byKey(const Key('dashboard_search_bar_clear_button')));
      await tester.pump();

      expect(controller.text, isEmpty);
      expect(clearCalled, isTrue);
      expect(changedText, isEmpty);
      expect(find.byKey(const Key('dashboard_search_bar_clear_button')), findsNothing);
    });

    testWidgets('displays card counter badge when cardCount is provided', (tester) async {
      setMobileSize(tester);

      // Plural test (3)
      await pumpApp(
        tester,
        const Scaffold(
          body: DashboardSearchBar(cardCount: 3),
        ),
        locale: const Locale('it'),
      );

      expect(find.byKey(const Key('dashboard_search_bar_count_badge')), findsOneWidget);
      expect(find.text('3 tessere salvate'), findsOneWidget);

      // Singular test (1)
      await pumpApp(
        tester,
        const Scaffold(
          body: DashboardSearchBar(cardCount: 1),
        ),
        locale: const Locale('it'),
      );

      expect(find.text('1 tessera salvata'), findsOneWidget);

      // Zero test (0)
      await pumpApp(
        tester,
        const Scaffold(
          body: DashboardSearchBar(cardCount: 0),
        ),
        locale: const Locale('it'),
      );

      expect(find.text('Nessuna tessera salvata'), findsOneWidget);
    });

    testWidgets('omits card counter badge when cardCount is null', (tester) async {
      setMobileSize(tester);

      await pumpApp(
        tester,
        const Scaffold(
          body: DashboardSearchBar(cardCount: null),
        ),
      );

      expect(find.byKey(const Key('dashboard_search_bar_count_badge')), findsNothing);
    });
  });
}
