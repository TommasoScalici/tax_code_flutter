import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared/models/birthplace.dart';
import 'package:shared/models/contact.dart';
import 'package:tax_code_flutter_wear_os/core/theme/wear_theme.dart';
import 'package:tax_code_flutter_wear_os/widgets/wear_contact_card.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('it_IT');
  });

  final testContact = Contact(
    id: 'test-id-1',
    firstName: 'Mario',
    lastName: 'Rossi',
    gender: 'M',
    taxCode: 'RSSMRA80A01H501U',
    birthPlace: const Birthplace(name: 'Roma', state: 'RM'),
    birthDate: DateTime(1980),
    listIndex: 0,
  );

  Widget buildTestCard({
    required Contact contact,
    required VoidCallback onTap,
  }) {
    return MaterialApp(
      theme: WearTheme.darkTheme,
      home: Scaffold(
        body: Center(
          child: WearContactCard(
            contact: contact,
            onTap: onTap,
          ),
        ),
      ),
    );
  }

  group('WearContactCard', () {
    testWidgets('renders contact name, tax code and metadata', (tester) async {
      await tester.pumpWidget(
        buildTestCard(contact: testContact, onTap: () {}),
      );

      expect(find.text('Mario Rossi'), findsOneWidget);
      expect(find.text('RSSMRA80A01H501U'), findsOneWidget);
      expect(find.byIcon(Icons.qr_code_2_rounded), findsOneWidget);
      expect(find.textContaining('Roma (RM)'), findsOneWidget);
    });

    testWidgets('triggers onTap callback when tapped', (tester) async {
      var tapped = false;

      await tester.pumpWidget(
        buildTestCard(
          contact: testContact,
          onTap: () {
            tapped = true;
          },
        ),
      );

      await tester.tap(find.byType(WearContactCard));
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
    });

    testWidgets('displays taxCode as fallback when name is blank', (tester) async {
      final blankNameContact = testContact.copyWith(
        firstName: '',
        lastName: '',
      );

      await tester.pumpWidget(
        buildTestCard(contact: blankNameContact, onTap: () {}),
      );

      // Should display tax code as title as well
      expect(find.text('RSSMRA80A01H501U'), findsNWidgets(2));
    });

    testWidgets('renders without overflow on small round display (192x192 dp)',
        (tester) async {
      tester.view.physicalSize = const Size(384, 384);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        buildTestCard(contact: testContact, onTap: () {}),
      );

      expect(tester.takeException(), isNull);
      expect(find.byType(WearContactCard), findsOneWidget);
    });
  });
}
