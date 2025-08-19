import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared/models/contact.dart';
import 'package:tax_code_flutter_wear_os/services/native_view_service.dart';

class MockLogger extends Mock implements Logger {}

class MockMethodChannel extends Mock implements MethodChannel {}

void main() {
  // TestWidgetsFlutterBinding.ensureInitialized();

  // late NativeViewService nativeViewService;
  // late MockLogger mockLogger;
  // late MockMethodChannel mockMethodChannel;

  // final testContact = Contact.empty().copyWith(id: '1');
  // final testContacts = [testContact];

  // setUp(() {
  //   mockLogger = MockLogger();
  //   mockMethodChannel = MockMethodChannel();

  //   nativeViewService = NativeViewService(
  //     logger: mockLogger,
  //     platform: mockMethodChannel,
  //   );

  //   when(() => mockLogger.i(any())).thenAnswer((_) {});
  //   when(() => mockLogger.e(any(), error: any(named: 'error'), stackTrace: any(named: 'stackTrace')))
  //       .thenAnswer((_) {});
  // });

  // group('showContactList', () {
  //   test('should log, map contacts, and invoke the correct method channel on success', () async {
  //     // Arrange
  //     when(() => mockMethodChannel.invokeMethod(any(), any())).thenAnswer((_) async => null);

  //     // Act
  //     await nativeViewService.showContactList(testContacts);

  //     // Assert
  //     verify(() => mockLogger.i('Invoking native contact list view.')).called(1);

  //     final verificationResult = verify(() => mockMethodChannel.invokeMethod(captureAny(), captureAny()));
  //     verificationResult.called(1);

  //     final capturedMethod = verificationResult.captured[0] as String;
  //     final capturedArgs = verificationResult.captured[1] as Map;

  //     expect(capturedMethod, 'openNativeContactList');
  //     expect(capturedArgs['contacts'], isA<List>());
  //     expect((capturedArgs['contacts'] as List).first['id'], testContact.id);
  //   });

  //   test('should log and rethrow PlatformException when invocation fails', () async {
  //     // Arrange
  //     final exception = PlatformException(code: 'ERROR', message: 'Native call failed');
  //     when(() => mockMethodChannel.invokeMethod(any(), any())).thenThrow(exception);

  //     // Act
  //     final future = nativeViewService.showContactList(testContacts);

  //     // Assert
  //     expect(future, throwsA(isA<PlatformException>()));

  //     await pumpEventQueue();
  //     verify(() => mockLogger.e(
  //       "Failed to invoke native method: '${exception.message}'.",
  //       error: exception,
  //       stackTrace: any(named: 'stackTrace'),
  //     )).called(1);
  //   });
  // });

  // group('Constructor', () {
  //   test('should use default MethodChannel when none is provided', () async {
  //     // Arrange
  //     final List<MethodCall> log = [];
  //     TestWidgetsFlutterBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
  //       const MethodChannel('tommasoscalici.tax_code_flutter_wear_os/channel'),
  //       (MethodCall methodCall) async {
  //         log.add(methodCall);
  //         return null;
  //       },
  //     );

  //     final serviceWithDefault = NativeViewService(logger: mockLogger);

  //     // Act
  //     await serviceWithDefault.showContactList(testContacts);

  //     // Assert
  //     expect(log, hasLength(1));
  //     expect(log.first.method, 'openNativeContactList');
  //   });
  // });
}
