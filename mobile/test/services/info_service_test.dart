import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';
import 'package:mocktail/mocktail.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:tax_code_flutter/services/info_service.dart';

class MockLogger extends Mock implements Logger {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockLogger mockLogger;
  late InfoService infoService;

  setUp(() {
    mockLogger = MockLogger();
    infoService = InfoService(logger: mockLogger);
  });

  group('InfoService Tests', () {
    test('returns platform package info when call succeeds', () async {
      PackageInfo.setMockInitialValues(
        appName: 'Codice Fiscale',
        packageName: 'it.scalici.taxcode',
        version: '2.0.2',
        buildNumber: '58',
        buildSignature: 'test-sig',
      );

      final result = await infoService.getPackageInfo();

      expect(result.appName, 'Codice Fiscale');
      expect(result.packageName, 'it.scalici.taxcode');
      expect(result.version, '2.0.2');
      expect(result.buildNumber, '58');
      expect(result.buildSignature, 'test-sig');
      verifyZeroInteractions(mockLogger);
    });

    test('implements InfoService interface', () {
      expect(infoService, isA<InfoService>());
    });
  });
}
