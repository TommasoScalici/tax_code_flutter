import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:shared/models/contact.dart';
import 'package:shared/repositories/contact_repository.dart';
import 'package:tax_code_flutter_wear_os/l10n/app_localizations.dart';
import 'package:tax_code_flutter_wear_os/l10n/app_localizations_en.dart';
import 'package:tax_code_flutter_wear_os/services/native_view_service.dart';
import 'package:tax_code_flutter_wear_os/widgets/contacts_list.dart';

import '../fakes/fake_contact_repository.dart';

// Mocks
class MockNativeViewService extends Mock implements NativeViewServiceAbstract {}

void main() {
  late FakeContactRepository fakeContactRepository;
  late MockNativeViewService mockNativeViewService;

  setUp(() {
    fakeContactRepository = FakeContactRepository();
    mockNativeViewService = MockNativeViewService();
  });

  Widget createTestableWidget() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ContactRepository>.value(
          value: fakeContactRepository,
        ),
        Provider<NativeViewServiceAbstract>.value(value: mockNativeViewService),
      ],
      child: const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: ContactsList()),
      ),
    );
  }

  group('ContactsList', () {
    testWidgets('should display CircularProgressIndicator when loading', (
      tester,
    ) async {
      // Arrange
      fakeContactRepository.setState(contacts: [], isLoading: true);

      // Act
      await tester.pumpWidget(createTestableWidget());

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(Text), findsNothing);
      expect(find.byType(ElevatedButton), findsNothing);
    });

    testWidgets(
      'should display empty message and button when list is empty and not loading',
      (tester) async {
        // Arrange
        fakeContactRepository.setState(contacts: [], isLoading: false);
        when(
          () => mockNativeViewService.showContactList(any()),
        ).thenAnswer((_) async {});
        when(
          () => mockNativeViewService.updateContactList(any()),
        ).thenAnswer((_) async {});

        // Act
        await tester.pumpWidget(createTestableWidget());
        await tester.pump();

        // Assert
        expect(find.byType(CircularProgressIndicator), findsNothing);
        expect(
          find.text(AppLocalizationsEn().noContactsFoundMessage),
          findsOneWidget,
        );
        expect(find.byType(ElevatedButton), findsOneWidget);
      },
    );

    testWidgets('should display SizedBox.shrink when contacts are available', (
      tester,
    ) async {
      // Arrange
      final testContact = Contact.empty().copyWith(id: '1');
      fakeContactRepository.setState(contacts: [testContact], isLoading: false);

      when(
        () => mockNativeViewService.showContactList(any()),
      ).thenAnswer((_) async {});
      when(
        () => mockNativeViewService.updateContactList(any()),
      ).thenAnswer((_) async {});

      // Act
      await tester.pumpWidget(createTestableWidget());
      await tester.pump();

      // Assert
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.byType(Text), findsNothing);
      expect(find.byType(ElevatedButton), findsNothing);

      final sizedBox = tester.widget<SizedBox>(find.byType(SizedBox));
      expect(sizedBox.width, 0.0);
      expect(sizedBox.height, 0.0);
    });
  });
}
