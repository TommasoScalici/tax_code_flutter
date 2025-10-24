import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared/models/birthplace.dart';
import 'package:shared/models/contact.dart';
import 'package:shared/repositories/contact_repository.dart';
import 'package:tax_code_flutter/controllers/home_page_controller.dart';
import 'package:tax_code_flutter/services/sharing_service.dart';

class MockContactRepository extends Mock implements ContactRepository {}

class MockSharingService extends Mock implements SharingServiceAbstract {}

class FakeContact extends Fake implements Contact {}

class FakeBirthplace extends Fake implements Birthplace {}

void main() {
  late HomePageController homePageController;
  late MockContactRepository mockContactRepository;
  late MockSharingService mockSharingService;

  final sampleContacts = [
    Contact(
      id: '1',
      firstName: 'John',
      lastName: 'Doe',
      gender: 'M',
      taxCode: 'JHNDOE80A01H501A',
      birthPlace: const Birthplace(name: 'Rome', state: 'RM'),
      birthDate: DateTime(1980, 1, 1),
      listIndex: 0,
    ),
    Contact(
      id: '2',
      firstName: 'Jane',
      lastName: 'Smith',
      gender: 'F',
      taxCode: 'JNESMT85M51H501B',
      birthPlace: const Birthplace(name: 'Milan', state: 'MI'),
      birthDate: DateTime(1985, 8, 11),
      listIndex: 1,
    ),
  ];

  setUp(() {
    // Register fallback values for custom types used in mocktail
    registerFallbackValue(FakeContact());
    registerFallbackValue(FakeBirthplace());

    mockContactRepository = MockContactRepository();
    mockSharingService = MockSharingService();

    // Stub the initial behavior of the repository
    when(() => mockContactRepository.isLoading).thenReturn(false);
    when(() => mockContactRepository.contacts).thenReturn([]);
    when(() => mockContactRepository.addListener(any())).thenAnswer((_) {});
    when(() => mockContactRepository.removeListener(any())).thenAnswer((_) {});

    homePageController = HomePageController(
      contactRepository: mockContactRepository,
      sharingService: mockSharingService,
    );
  });

  tearDown(() {
    homePageController.dispose();
  });

  group('HomePageController', () {
    test('initial state is correct', () {
      // Assert
      expect(homePageController.isLoading, isFalse);
      expect(homePageController.contactsToShow, isEmpty);
      expect(homePageController.searchText, '');
      expect(homePageController.isReorderable, isTrue);
    });

    test('initialization adds a listener to the repository', () {
      // Assert
      verify(() => mockContactRepository.addListener(any())).called(1);
    });

    group('filterContacts', () {
      setUp(() {
        // Arrange: Provide a list of contacts from the repository for filter tests
        when(() => mockContactRepository.contacts).thenReturn(sampleContacts);

        // Simulate the repository updating the controller by capturing and invoking the listener
        final listener =
            verify(
                  () => mockContactRepository.addListener(captureAny()),
                ).captured.single
                as VoidCallback;
        listener(); // This triggers `_onContactsChanged` in the controller
      });

      test('filters contacts based on last name (case-insensitive)', () {
        // Act
        homePageController.filterContacts('smith');

        // Assert
        expect(homePageController.contactsToShow.length, 1);
        expect(homePageController.contactsToShow.first.lastName, 'Smith');
        expect(homePageController.searchText, 'smith');
        expect(homePageController.isReorderable, isFalse);
      });

      test('filters contacts based on birth place name', () {
        // Act
        homePageController.filterContacts('Rome');

        // Assert
        expect(homePageController.contactsToShow.length, 1);
        expect(homePageController.contactsToShow.first.birthPlace.name, 'Rome');
      });

      test('returns all contacts when filter text is empty', () {
        // Act
        homePageController.filterContacts('John'); // First, apply a filter
        homePageController.filterContacts(''); // Then, clear it

        // Assert
        expect(homePageController.contactsToShow.length, 2);
        expect(homePageController.isReorderable, isTrue);
      });

      test('notifies listeners when filter is applied', () {
        // Arrange
        var listenerCalled = false;
        homePageController.addListener(() => listenerCalled = true);

        // Act
        homePageController.filterContacts('test');

        // Assert
        expect(listenerCalled, isTrue);
      });
    });

    test('reorderContacts calls repository with reordered list', () {
      // Arrange
      when(() => mockContactRepository.contacts).thenReturn(sampleContacts);
      final listener =
          verify(
                () => mockContactRepository.addListener(captureAny()),
              ).captured.single
              as VoidCallback;
      listener();

      when(
        () => mockContactRepository.updateContacts(any()),
      ).thenAnswer((_) async {});

      // Act
      homePageController.reorderContacts(0, 1);

      // Assert
      final captured = verify(
        () => mockContactRepository.updateContacts(captureAny()),
      ).captured;
      final reorderedList = captured.single as List<Contact>;

      expect(reorderedList.length, 2);
      expect(
        reorderedList[0].firstName,
        'Jane',
      ); // Jane was at index 1, moved to 0
      expect(
        reorderedList[1].firstName,
        'John',
      ); // John was at index 0, moved to 1
    });

    test('saveContact calls repository addOrUpdateContact', () {
      // Arrange
      final newContact = sampleContacts.first;
      when(
        () => mockContactRepository.addOrUpdateContact(any()),
      ).thenAnswer((_) async {});

      // Act
      homePageController.saveContact(newContact);

      // Assert
      verify(
        () => mockContactRepository.addOrUpdateContact(newContact),
      ).called(1);
    });

    test('deleteContact calls repository removeContact', () {
      // Arrange
      final contactToDelete = sampleContacts.first;
      when(
        () => mockContactRepository.removeContact(any()),
      ).thenAnswer((_) async {});

      // Act
      homePageController.deleteContact(contactToDelete);

      // Assert
      verify(
        () => mockContactRepository.removeContact(contactToDelete),
      ).called(1);
    });

    test('shareContact calls sharing service with correct tax code', () {
      // Arrange
      final contactToShare = sampleContacts.first;
      when(() => mockSharingService.share(text: any(named: 'text'))).thenAnswer(
        (_) async => const ShareResult('', ShareResultStatus.success),
      );

      // Act
      homePageController.shareContact(contactToShare);

      // Assert
      verify(
        () => mockSharingService.share(text: contactToShare.taxCode),
      ).called(1);
    });

    test('dispose removes the listener from the repository', () {
      // Arrange: Create a local controller just for this test
      final localController = HomePageController(
        contactRepository: mockContactRepository,
        sharingService: mockSharingService,
      );

      // Act
      localController.dispose();

      // Assert
      // We still verify against the global mock, which is fine
      verify(() => mockContactRepository.removeListener(any())).called(1);
    });
  });
}
