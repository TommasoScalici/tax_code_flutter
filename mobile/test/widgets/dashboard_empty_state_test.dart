import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tax_code_flutter/widgets/dashboard/dashboard_empty_state.dart';

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

  group('DashboardEmptyState Widget Tests', () {
    testWidgets('renders empty dashboard state when searchQuery is absent', (
      tester,
    ) async {
      setMobileSize(tester);

      var addContactCalled = false;

      await pumpApp(
        tester,
        Scaffold(
          body: DashboardEmptyState(
            onAddContact: () => addContactCalled = true,
          ),
        ),
        locale: const Locale('it'),
      );

      expect(find.byIcon(Icons.credit_card_off_rounded), findsOneWidget);
      expect(find.text('Nessuna tessera salvata'), findsOneWidget);
      expect(
        find.text(
          'Aggiungi il tuo primo Codice Fiscale per averlo sempre a portata di mano anche offline.',
        ),
        findsOneWidget,
      );
      expect(find.text('Aggiungi Codice'), findsOneWidget);

      await tester.tap(find.text('Aggiungi Codice'));
      await tester.pump();

      expect(addContactCalled, isTrue);
    });

    testWidgets('renders empty search state when searchQuery is provided', (
      tester,
    ) async {
      setMobileSize(tester);

      var clearSearchCalled = false;

      await pumpApp(
        tester,
        Scaffold(
          body: DashboardEmptyState(
            searchQuery: 'Rossi',
            onClearSearch: () => clearSearchCalled = true,
          ),
        ),
        locale: const Locale('it'),
      );

      expect(find.byIcon(Icons.search_off_rounded), findsOneWidget);
      expect(find.text('Nessun codice trovato'), findsOneWidget);
      expect(
        find.text(
          "Nessuna tessera corrisponde a 'Rossi'. Prova a cercare con un altro nome o codice fiscale.",
        ),
        findsOneWidget,
      );
      expect(find.text('Reimposta ricerca'), findsOneWidget);

      await tester.tap(find.text('Reimposta ricerca'));
      await tester.pump();

      expect(clearSearchCalled, isTrue);
    });

    testWidgets('renders in English locale correctly', (tester) async {
      setMobileSize(tester);

      await pumpApp(
        tester,
        const Scaffold(
          body: DashboardEmptyState(searchQuery: 'Bianchi'),
        ),
        locale: const Locale('en'),
      );

      expect(find.text('No codes found'), findsOneWidget);
      expect(
        find.text(
          "No card matches 'Bianchi'. Try searching with a different name or tax code.",
        ),
        findsOneWidget,
      );
    });
  });
}
