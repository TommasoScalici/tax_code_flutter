import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';
import 'package:mocktail/mocktail.dart';

//--- Mock ---//
class MockLogger extends Mock implements Logger {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const assetPath = 'assets/json/cities.json';

  setUp(() {
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
