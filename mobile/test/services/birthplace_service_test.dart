import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared/models/birthplace.dart';
import 'package:tax_code_flutter/services/birthplace_service.dart';

//--- Mock ---//
class MockLogger extends Mock implements Logger {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late BirthplaceService birthplaceService;
  late MockLogger mockLogger;
  const assetPath = 'assets/json/cities.json';

  setUp(() {
    mockLogger = MockLogger();
    birthplaceService = BirthplaceService(
      logger: mockLogger,
      assetPath: assetPath,
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler('flutter/assets', null);
    rootBundle.evict(assetPath);
  });

  group('BirthplaceService', () {
    group('loadBirthplaces', () {
      test(
        'should return a list of Birthplace objects when asset loading and parsing is successful',
        () async {
          // Arrange
          final fakeJsonString = jsonEncode([
            {'name': 'ROMA', 'state': 'RM'},
            {'name': 'PALERMO', 'state': 'PA'},
          ]);

          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
              .setMockMessageHandler('flutter/assets', (message) async {
                if (message != null &&
                    utf8.decode(message.buffer.asUint8List()) == assetPath) {
                  final byteData = ByteData.sublistView(
                    utf8.encoder.convert(fakeJsonString),
                  );
                  return byteData;
                }
                return null;
              });

          // Act
          final result = await birthplaceService.loadBirthplaces();

          // Assert
          expect(result, isA<List<Birthplace>>());
          expect(result.length, 2);
          verifyNever(() => mockLogger.e(any()));
        },
      );

      test(
        'should return an empty list and log an error when asset loading fails',
        () async {
          // Arrange
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
              .setMockMessageHandler('flutter/assets', (message) {
                return Future.error(Exception('Failed to load asset'));
              });

          // Act
          final result = await birthplaceService.loadBirthplaces();

          // Assert
          expect(result, isEmpty);
          verify(
            () => mockLogger.e(
              'Failed to load or parse birthplaces asset.',
              error: any(named: 'error'),
              stackTrace: any(named: 'stackTrace'),
            ),
          ).called(1);
        },
      );
    });
  });
}
