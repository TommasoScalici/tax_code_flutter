import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tax_code_flutter/models/scanned_data.dart';
import 'package:tax_code_flutter/services/gemini_service.dart';

//--- Mocks ---//
class MockLogger extends Mock implements Logger {}

class MockFirebaseFunctions extends Mock implements FirebaseFunctions {}

class MockHttpsCallable extends Mock implements HttpsCallable {}

class MockHttpsCallableResult extends Mock
    implements HttpsCallableResult<Map<String, dynamic>> {}

void main() {
  late GeminiService geminiService;
  late MockFirebaseFunctions mockFunctions;
  late MockLogger mockLogger;
  late MockHttpsCallable mockCallable;

  setUp(() {
    mockLogger = MockLogger();
    mockFunctions = MockFirebaseFunctions();
    mockCallable = MockHttpsCallable();
    geminiService = GeminiService(functions: mockFunctions, logger: mockLogger);

    when(() => mockFunctions.httpsCallable(any())).thenReturn(mockCallable);
  });

  group('GeminiService', () {
    const testBase64Image = 'base64_image_string';
    const functionName = 'extractDataFromDocument';

    test(
      'should return ScannedData when Firebase Function call is successful',
      () async {
        // Arrange
        final fakeResponseData = {'firstName': 'MARIO', 'lastName': 'ROSSI'};
        final mockResult = MockHttpsCallableResult();
        when(() => mockResult.data).thenReturn(fakeResponseData);

        when(
          () => mockCallable.call<Map<String, dynamic>>(any()),
        ).thenAnswer((_) async => mockResult);

        // Act
        final result = await geminiService.extractDataFromDocument(
          testBase64Image,
        );

        // Assert
        expect(result, isA<ScannedData>());
        expect(result?.firstName, 'MARIO');
        expect(result?.lastName, 'ROSSI');

        verify(() => mockFunctions.httpsCallable(functionName)).called(1);
        final captured = verify(
          () => mockCallable.call<Map<String, dynamic>>(captureAny()),
        ).captured;
        expect(captured.first['image'], testBase64Image);

        verify(() => mockLogger.i(any(that: contains('Calling')))).called(1);
        verify(
          () => mockLogger.i(any(that: contains('Successfully received'))),
        ).called(1);
        verifyNever(() => mockLogger.e(any()));
      },
    );

    test(
      'should return null and log error on FirebaseFunctionsException',
      () async {
        // Arrange
        final exception = FirebaseFunctionsException(
          code: 'not-found',
          message: 'Function not found',
        );

        when(
          () => mockCallable.call<Map<String, dynamic>>(any()),
        ).thenThrow(exception);

        // Act
        final result = await geminiService.extractDataFromDocument(
          testBase64Image,
        );

        // Assert
        expect(result, isNull);
        verify(
          () => mockLogger.e(
            any(that: contains('Firebase Function failed')),
            error: exception,
            stackTrace: any(named: 'stackTrace'),
            time: any(named: 'time'),
          ),
        ).called(1);
      },
    );

    test('should return null and log error on generic exception', () async {
      // Arrange
      final exception = Exception('A generic error');

      when(
        () => mockCallable.call<Map<String, dynamic>>(any()),
      ).thenThrow(exception);

      // Act
      final result = await geminiService.extractDataFromDocument(
        testBase64Image,
      );

      // Assert
      expect(result, isNull);
      verify(
        () => mockLogger.e(
          'An unexpected error occurred while calling the Gemini service.',
          error: exception,
          stackTrace: any(named: 'stackTrace'),
          time: any(named: 'time'),
        ),
      ).called(1);
    });
  });
}
