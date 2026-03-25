import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';
import 'package:mocktail/mocktail.dart';
// import 'package:tax_code_flutter/services/birthplace_service.dart';

//--- Mock ---//
class MockLogger extends Mock implements Logger {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // late BirthplaceService birthplaceService;
  // late MockLogger mockLogger;
  const assetPath = 'assets/json/cities.json';

  setUp(() {
    // mockLogger = MockLogger();
    // birthplaceService = BirthplaceService(
    //   logger: mockLogger,
    //   storagePath: assetPath,
    // );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler('flutter/assets', null);
    rootBundle.evict(assetPath);
  });

  group('BirthplaceService', () {
    group('loadBirthplaces', () {
      test(
        'test skipped for now due to Firebase Storage mocking requirement',
        () {},
      );
    });
  });
}
