import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared/models/contact.dart';
import 'package:tax_code_flutter_wear_os/controllers/wearable_home_controller.dart';
import 'package:tax_code_flutter_wear_os/services/native_view_service.dart';

import '../fakes/fake_contact_repository.dart';

// Mocks
class MockNativeViewService extends Mock implements NativeViewServiceAbstract {}

void main() {
  late WearableHomeController controller;
  late FakeContactRepository fakeContactRepository;
  late MockNativeViewService mockNativeViewService;

  final testContacts = [Contact.empty().copyWith(id: '1')];

  setUp(() {
    fakeContactRepository = FakeContactRepository();
    mockNativeViewService = MockNativeViewService();
    
    when(() => mockNativeViewService.showContactList(any())).thenAnswer((_) async {});

    controller = WearableHomeController(
      contactRepository: fakeContactRepository,
      nativeViewService: mockNativeViewService,
    );
  });

  group('WearableHomeController', () {
    test('does NOT call native view when contacts are initially empty', () {
      // Assert
      verifyNever(() => mockNativeViewService.showContactList(any()));
    });

    test('calls native view service when contacts first appear', () {
      // Act
      fakeContactRepository.setState(contacts: testContacts);

      // Assert
      verify(() => mockNativeViewService.showContactList(testContacts)).called(1);
    });

    test('does NOT call native view service on subsequent contact updates', () {
      // Arrange
      fakeContactRepository.setState(contacts: testContacts);

      // Act
      final updatedContacts = [Contact.empty().copyWith(id: '2')];
      fakeContactRepository.setState(contacts: updatedContacts);

      // Assert
      verify(() => mockNativeViewService.showContactList(any())).called(1);
    });

    test('resets flag and allows showing native view again if contacts are cleared and repopulated', () {
      // Act
      fakeContactRepository.setState(contacts: testContacts);
      fakeContactRepository.setState(contacts: []);
      fakeContactRepository.setState(contacts: testContacts);

      // Assert
      verify(() => mockNativeViewService.showContactList(any())).called(2);
    });

    test('removes listener from ContactRepository on dispose', () {
      // Assert
      expect(fakeContactRepository.listenerCount, 1);

      // Act
      controller.dispose();

      // Assert
      expect(fakeContactRepository.listenerCount, 0);
    });

  });
}