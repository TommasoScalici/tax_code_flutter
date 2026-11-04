import 'dart:convert';
import 'package:flutter_app_functions/flutter_app_functions.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared/models/birthplace.dart';
import 'package:shared/models/contact.dart';
import 'package:shared/services/contact_resolution_service.dart';
import 'package:tax_code_flutter/services/app_functions_service.dart';
import 'package:tax_code_flutter/services/deep_link_service.dart';
import 'package:tax_code_flutter/services/gemini_integration_service.dart';

import '../helpers/mocks.dart';

class MockDeepLinkService extends Mock implements DeepLinkService {}

class MockGeminiIntegrationService extends Mock
    implements GeminiIntegrationService {}

class MockAppFunctionsClient extends Mock implements AppFunctionsClient {}

class FakeAppFunctionDefinition extends Fake implements AppFunctionDefinition {}

void main() {
  group('AppFunctionsService', () {
    late MockContactRepository mockContactRepository;
    late MockAuthService mockAuthService;
    late MockDeepLinkService mockDeepLinkService;
    late MockGeminiIntegrationService mockGeminiService;
    late MockAppFunctionsClient mockClient;
    late MockLogger mockLogger;
    late AppFunctionsService service;

    const dummyContext = AppFunctionContext(
      functionId: 'dummy',
      rawParameters: {},
    );

    const birthplace = Birthplace(name: 'Roma', state: 'RM', code: 'H501');

    final primaryContact = Contact(
      id: 'id-me',
      firstName: 'Tommaso',
      lastName: 'Scalici',
      gender: 'M',
      taxCode: 'SCLTMS91A01H501X',
      birthPlace: birthplace,
      birthDate: DateTime(1991),
      listIndex: 0,
      isMe: true,
    );

    final otherContact = Contact(
      id: 'id-mario',
      firstName: 'Mario',
      lastName: 'Rossi',
      gender: 'M',
      taxCode: 'RSSMRA80A01H501Y',
      birthPlace: birthplace,
      birthDate: DateTime(1980),
      listIndex: 1,
    );

    setUpAll(() {
      registerFallbackValue(FakeAppFunctionDefinition());
    });

    setUp(() {
      mockContactRepository = MockContactRepository();
      mockAuthService = MockAuthService();
      mockDeepLinkService = MockDeepLinkService();
      mockGeminiService = MockGeminiIntegrationService();
      mockClient = MockAppFunctionsClient();
      mockLogger = MockLogger();

      when(() => mockGeminiService.isGeminiEnabled).thenReturn(true);
      when(() => mockAuthService.currentUser).thenReturn(null);
      when(
        () => mockContactRepository.contacts,
      ).thenReturn([primaryContact, otherContact]);

      service = AppFunctionsService(
        contactRepository: mockContactRepository,
        contactResolutionService: const ContactResolutionService(),
        authService: mockAuthService,
        deepLinkService: mockDeepLinkService,
        geminiIntegrationService: mockGeminiService,
        client: mockClient,
        logger: mockLogger,
      );

      service.init();
    });

    test('init registers all 4 AppFunctions with client', () {
      expect(service.definitions.length, 4);
      expect(service.definitions.containsKey('getMyTaxCode'), isTrue);
      expect(service.definitions.containsKey('getContactTaxCode'), isTrue);
      expect(service.definitions.containsKey('openMyTaxCodeBarcode'), isTrue);
      expect(
        service.definitions.containsKey('openContactTaxCodeBarcode'),
        isTrue,
      );
      verify(() => mockClient.register(any())).called(4);
    });

    group('getMyTaxCode handler', () {
      test('throws AppFunctionDisabledException when Gemini is disabled', () {
        when(() => mockGeminiService.isGeminiEnabled).thenReturn(false);
        final handler = service.definitions['getMyTaxCode']!.handler;

        expect(
          () => handler(dummyContext, {}),
          throwsA(isA<AppFunctionDisabledException>()),
        );
      });

      test(
        'throws AppFunctionElementNotFoundException when no primary contact',
        () {
          when(() => mockContactRepository.contacts).thenReturn([]);
          final handler = service.definitions['getMyTaxCode']!.handler;

          expect(
            () => handler(dummyContext, {}),
            throwsA(isA<AppFunctionElementNotFoundException>()),
          );
        },
      );

      test('returns valid JSON with phonetic spelling when found', () async {
        final handler = service.definitions['getMyTaxCode']!.handler;
        final result = await handler(dummyContext, {'spellOut': true});

        expect(result, isA<String>());
        final json = jsonDecode(result as String) as Map<String, dynamic>;

        expect(json['fullName'], 'Tommaso Scalici');
        expect(json['taxCode'], 'SCLTMS91A01H501X');
        expect(json['spelledOut'], isTrue);
        expect(json['phoneticSpelling'], contains('S come Sassari'));
      });
    });

    group('getContactTaxCode handler', () {
      test('throws AppFunctionDisabledException when disabled', () {
        when(() => mockGeminiService.isGeminiEnabled).thenReturn(false);
        final handler = service.definitions['getContactTaxCode']!.handler;

        expect(
          () => handler(dummyContext, {'name': 'Mario Rossi'}),
          throwsA(isA<AppFunctionDisabledException>()),
        );
      });

      test('throws AppFunctionInvalidArgumentException when name is empty', () {
        final handler = service.definitions['getContactTaxCode']!.handler;

        expect(
          () => handler(dummyContext, {'name': '   '}),
          throwsA(isA<AppFunctionInvalidArgumentException>()),
        );
      });

      test(
        'throws AppFunctionElementNotFoundException when contact not found',
        () {
          final handler = service.definitions['getContactTaxCode']!.handler;

          expect(
            () => handler(dummyContext, {'name': 'Giuseppe Verdi'}),
            throwsA(isA<AppFunctionElementNotFoundException>()),
          );
        },
      );

      test(
        'returns contact tax code and phonetic spelling when found',
        () async {
          final handler = service.definitions['getContactTaxCode']!.handler;
          final result = await handler(dummyContext, {
            'name': 'Mario Rossi',
            'spellOut': false,
          });

          final json = jsonDecode(result as String) as Map<String, dynamic>;
          expect(json['fullName'], 'Mario Rossi');
          expect(json['taxCode'], 'RSSMRA80A01H501Y');
          expect(json['spelledOut'], isFalse);
        },
      );
    });

    group('openMyTaxCodeBarcode handler', () {
      test('throws AppFunctionDisabledException when disabled', () {
        when(() => mockGeminiService.isGeminiEnabled).thenReturn(false);
        final handler = service.definitions['openMyTaxCodeBarcode']!.handler;

        expect(
          () => handler(dummyContext, {}),
          throwsA(isA<AppFunctionDisabledException>()),
        );
      });

      test(
        'throws AppFunctionElementNotFoundException when primary missing',
        () {
          when(() => mockContactRepository.contacts).thenReturn([]);
          final handler = service.definitions['openMyTaxCodeBarcode']!.handler;

          expect(
            () => handler(dummyContext, {}),
            throwsA(isA<AppFunctionElementNotFoundException>()),
          );
        },
      );

      test('triggers deepLinkService and returns opened status', () async {
        final handler = service.definitions['openMyTaxCodeBarcode']!.handler;
        final result = await handler(dummyContext, {});

        final json = jsonDecode(result as String) as Map<String, dynamic>;
        expect(json['status'], 'opened');
        expect(json['target'], 'me');
        verify(
          () => mockDeepLinkService.setPendingDeepLink(
            Uri.parse('taxcode://barcode/me'),
          ),
        ).called(1);
      });
    });

    group('openContactTaxCodeBarcode handler', () {
      test(
        'throws AppFunctionInvalidArgumentException when name is missing',
        () {
          final handler =
              service.definitions['openContactTaxCodeBarcode']!.handler;

          expect(
            () => handler(dummyContext, {'name': ''}),
            throwsA(isA<AppFunctionInvalidArgumentException>()),
          );
        },
      );

      test('triggers deepLinkService with contact id when found', () async {
        final handler =
            service.definitions['openContactTaxCodeBarcode']!.handler;
        final result = await handler(dummyContext, {'name': 'Mario'});

        final json = jsonDecode(result as String) as Map<String, dynamic>;
        expect(json['status'], 'opened');
        expect(json['target'], 'id-mario');
        verify(
          () => mockDeepLinkService.setPendingDeepLink(
            Uri.parse('taxcode://barcode/id-mario'),
          ),
        ).called(1);
      });
    });
  });
}
