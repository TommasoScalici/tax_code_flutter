import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:shared/models/birthplace.dart';
import 'package:shared/models/contact.dart';
import 'package:shared/providers/app_state.dart';
import 'package:tax_code_flutter_wear_os/widgets/contact_list.dart';

import 'contact_list_test.mocks.dart';

@GenerateMocks([AppState])
void main() {
  late MockAppState mockAppState;

  const channel =
      MethodChannel('tommasoscalici.tax_code_flutter_wear_os/channel');

  setUp(() {
    mockAppState = MockAppState();
  });

  Widget createTestWidget() {
    return ChangeNotifierProvider<AppState>.value(
      value: mockAppState,
      child: const MaterialApp(
        home: Scaffold(
          body: ContactList(),
        ),
      ),
    );
  }

  group('ContactList Widget Tests', () {
    testWidgets('should show CircularProgressIndicator when loading',
        (tester) async {
      when(mockAppState.isLoading).thenReturn(true);
      when(mockAppState.contacts).thenReturn([]);

      await tester.pumpWidget(createTestWidget());
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should invoke native method when contacts are available',
        (tester) async {
      /// Arrange
      final mockContact = Contact(
        id: '1',
        firstName: 'Mario',
        lastName: 'Rossi',
        gender: 'M',
        taxCode: 'RSSMRA80A01H501Z',
        birthPlace: Birthplace(name: 'Roma', state: 'RM'),
        birthDate: DateTime(1980, 1, 1),
        listIndex: 0,
      );
      final mockContacts = [mockContact];

      when(mockAppState.isLoading).thenReturn(false);
      when(mockAppState.contacts).thenReturn(mockContacts);

      MethodCall? receivedCall;
      TestWidgetsFlutterBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
        receivedCall = methodCall;
        return null;
      });

      /// Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      /// Assert
      expect(receivedCall, isNotNull);
      expect(receivedCall!.method, 'openNativeContactList');
      expect(receivedCall!.arguments['contacts'][0]['firstName'], 'Mario');
    });

    testWidgets('should handle PlatformException when native method fails',
        (tester) async {
      /// Arrange
      final mockContact = Contact(
        id: '1',
        firstName: 'Mario',
        lastName: 'Rossi',
        gender: 'M',
        taxCode: 'RSSMRA80A01H501Z',
        birthPlace: Birthplace(name: 'Roma', state: 'RM'),
        birthDate: DateTime(1980, 1, 1),
        listIndex: 0,
      );
      final mockContacts = [mockContact];

      when(mockAppState.isLoading).thenReturn(false);
      when(mockAppState.contacts).thenReturn(mockContacts);

      TestWidgetsFlutterBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
        throw PlatformException(
            code: 'ERROR', message: 'Failed to open native view');
      });

      /// Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      /// Assert
      expect(tester.takeException(), isNull);
    });
  });
}
