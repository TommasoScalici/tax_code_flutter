import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared/models/contact.dart';
import 'package:shared/repositories/contact_repository.dart';
import 'package:tax_code_flutter_wear_os/l10n/app_localizations.dart';
import 'package:tax_code_flutter_wear_os/l10n/app_localizations_en.dart';
import 'package:tax_code_flutter_wear_os/widgets/contacts_list.dart';

import '../fakes/fake_contact_repository.dart';

void main() {
  late FakeContactRepository fakeContactRepository;

  Widget createTestableWidget() {
    return ChangeNotifierProvider<ContactRepository>.value(
      value: fakeContactRepository,
      child: const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: ContactsList()),
      ),
    );
  }

  setUp(() {
    fakeContactRepository = FakeContactRepository();
  });

  group('ContactsList', () {
    testWidgets('should display CircularProgressIndicator when loading', (tester) async {
      // Arrange
      fakeContactRepository.setState(contacts: [], isLoading: true);

      // Act
      await tester.pumpWidget(createTestableWidget());

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(Text), findsNothing);
    });

    testWidgets('should display empty message when list is empty and not loading', (tester) async {
      // Arrange
      fakeContactRepository.setState(contacts: [], isLoading: false);

      // Act
      await tester.pumpWidget(createTestableWidget());

      // Assert
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text(AppLocalizationsEn().noContactsFoundMessage), findsOneWidget);
    });

    testWidgets('should display SizedBox.shrink when contacts are available', (tester) async {
      // Arrange
      final testContact = Contact.empty().copyWith(id: '1');
      fakeContactRepository.setState(contacts: [testContact], isLoading: false);

      // Act
      await tester.pumpWidget(createTestableWidget());

      // Assert
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.byType(Text), findsNothing);
      expect(find.byType(SizedBox), findsOneWidget);
    });
  });
}