import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared/models/birthplace.dart';
import 'package:shared/models/contact.dart';
import 'package:tax_code_flutter/core/theme/app_theme.dart';
import 'package:tax_code_flutter/l10n/app_localizations_setup.dart';
import 'package:tax_code_flutter/services/contact_card_image_service.dart';
import 'package:tax_code_flutter/services/contact_pdf_service.dart';
import 'package:tax_code_flutter/services/sharing_service.dart';
import 'package:tax_code_flutter/widgets/share/share_contact_bottom_sheet.dart';

import '../helpers/mocks.dart';
import '../helpers/test_setup.dart';

void main() {
  setUpAll(() {
    setupTests();
    registerFallbackValue(Contact.create());
  });

  late MockSharingService mockSharingService;
  late MockContactCardImageService mockImageService;
  late MockContactPdfService mockPdfService;
  late Directory tempDir;

  final testContact = Contact(
    id: '1',
    firstName: 'Mario',
    lastName: 'Rossi',
    gender: 'M',
    birthDate: DateTime(1985, 4, 15),
    birthPlace: const Birthplace(name: 'Roma', state: 'RM', code: 'H501'),
    taxCode: 'RSSMRA85D15H501Z',
    listIndex: 0,
  );

  setUp(() async {
    mockSharingService = MockSharingService();
    mockImageService = MockContactCardImageService();
    mockPdfService = MockContactPdfService();

    tempDir = await Directory.systemTemp.createTemp('share_test_');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (methodCall) async {
        if (methodCall.method == 'getTemporaryDirectory') {
          return tempDir.path;
        }
        return null;
      },
    );

    when(
      () => mockSharingService.share(
        text: any(named: 'text'),
      ),
    ).thenAnswer(
      (_) async => const ShareResult('com.example', ShareResultStatus.success),
    );

    when(
      () => mockSharingService.shareFile(
        filePath: any(named: 'filePath'),
        mimeType: any(named: 'mimeType'),
        subject: any(named: 'subject'),
      ),
    ).thenAnswer(
      (_) async => const ShareResult('com.example', ShareResultStatus.success),
    );

    when(
      () => mockImageService.generateCardImage(
        contact: any(named: 'contact'),
        footerText: any(named: 'footerText'),
        l10n: any(named: 'l10n'),
      ),
    ).thenAnswer((_) async => Uint8List.fromList([1, 2, 3, 4]));

    when(
      () => mockPdfService.generateContactPdf(
        contact: any(named: 'contact'),
        l10n: any(named: 'l10n'),
      ),
    ).thenAnswer((_) async => Uint8List.fromList([5, 6, 7, 8]));
  });

  tearDown(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      null,
    );
    try {
      if (tempDir.existsSync()) {
        await tempDir.delete(recursive: true);
      }
    } on Object catch (_) {
      // Ignore file lock on Windows test runner
    }
  });

  Widget buildTestApp({
    required Widget child,
    Locale locale = const Locale('it'),
  }) {
    return MultiProvider(
      providers: [
        Provider<SharingServiceAbstract>.value(value: mockSharingService),
        Provider<ContactCardImageServiceAbstract>.value(value: mockImageService),
        Provider<ContactPdfServiceAbstract>.value(value: mockPdfService),
      ],
      child: MaterialApp(
        locale: locale,
        localizationsDelegates: const [
          ...AppLocalizationsSetup.localizationsDelegates,
          ...GlobalMaterialLocalizations.delegates,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        home: Scaffold(body: child),
      ),
    );
  }

  group('ShareContactBottomSheet Widget Tests', () {
    testWidgets('renders title, contact details and 3 options in Italian', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestApp(
          child: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => ShareContactBottomSheet.show(
                context,
                contact: testContact,
              ),
              child: const Text('Open'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Condividi codice'), findsOneWidget);
      expect(
        find.text('Scegli come condividere la tessera o i dati'),
        findsOneWidget,
      );
      expect(find.text('Mario Rossi'), findsOneWidget);
      expect(find.text('RSSMRA85D15H501Z'), findsOneWidget);

      expect(find.text('Testo rapido'), findsOneWidget);
      expect(find.text('Immagine tessera (PNG)'), findsOneWidget);
      expect(find.text('Scheda riepilogativa (PDF)'), findsOneWidget);
      expect(find.text('Annulla'), findsOneWidget);
      expect(find.text('Condividi'), findsOneWidget);
    });

    testWidgets('renders labels in English when locale is en', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          locale: const Locale('en'),
          child: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => ShareContactBottomSheet.show(
                context,
                contact: testContact,
              ),
              child: const Text('Open'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Share code'), findsOneWidget);
      expect(
        find.text('Choose how to share the card or details'),
        findsOneWidget,
      );
      expect(find.text('Quick text'), findsOneWidget);
      expect(find.text('Card image (PNG)'), findsOneWidget);
      expect(find.text('Summary sheet (PDF)'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Share'), findsOneWidget);
    });

    testWidgets('tapping cancel closes the bottom sheet', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          child: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => ShareContactBottomSheet.show(
                context,
                contact: testContact,
              ),
              child: const Text('Open'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Condividi codice'), findsOneWidget);

      await tester.tap(find.byKey(const Key('share_cancel_button')));
      await tester.pumpAndSettle();

      expect(find.text('Condividi codice'), findsNothing);
    });

    testWidgets('sharing as text calls sharingService.share and closes sheet', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestApp(
          child: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => ShareContactBottomSheet.show(
                context,
                contact: testContact,
              ),
              child: const Text('Open'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // Text is selected by default
      final confirmBtn = tester.widget<FilledButton>(
        find.byKey(const Key('share_confirm_button')),
      );

      await tester.runAsync(() async {
        confirmBtn.onPressed!();
        await Future<void>.delayed(const Duration(milliseconds: 300));
      });
      await tester.pumpAndSettle();

      verify(
        () => mockSharingService.share(text: testContact.taxCode),
      ).called(1);

      expect(find.byType(ShareContactBottomSheet), findsNothing);
    });

    testWidgets(
      'sharing as image generates image, saves to file, and calls shareFile',
      (tester) async {
        await tester.pumpWidget(
          buildTestApp(
            child: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => ShareContactBottomSheet.show(
                  context,
                  contact: testContact,
                ),
                child: const Text('Open'),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();

        // Select image option
        await tester.tap(find.byKey(const Key('share_format_image_card')));
        await tester.pumpAndSettle();

        final confirmBtn = tester.widget<FilledButton>(
          find.byKey(const Key('share_confirm_button')),
        );

        await tester.runAsync(() async {
          confirmBtn.onPressed!();
          await Future<void>.delayed(const Duration(milliseconds: 300));
        });
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        verify(
          () => mockImageService.generateCardImage(
            contact: testContact,
            l10n: any(named: 'l10n'),
          ),
        ).called(1);

        verify(
          () => mockSharingService.shareFile(
            filePath: any(
              named: 'filePath',
              that: contains('tessera_RSSMRA85D15H501Z.png'),
            ),
            mimeType: 'image/png',
            subject: any(
              named: 'subject',
              that: contains('Mario Rossi'),
            ),
          ),
        ).called(1);

        expect(find.byType(ShareContactBottomSheet), findsNothing);
      },
    );

    testWidgets(
      'sharing as PDF generates PDF, saves to file, and calls shareFile',
      (tester) async {
        await tester.pumpWidget(
          buildTestApp(
            child: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => ShareContactBottomSheet.show(
                  context,
                  contact: testContact,
                ),
                child: const Text('Open'),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();

        // Select PDF option
        await tester.tap(find.byKey(const Key('share_format_pdf_card')));
        await tester.pumpAndSettle();

        final confirmBtn = tester.widget<FilledButton>(
          find.byKey(const Key('share_confirm_button')),
        );

        await tester.runAsync(() async {
          confirmBtn.onPressed!();
          await Future<void>.delayed(const Duration(milliseconds: 300));
        });
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        verify(
          () => mockPdfService.generateContactPdf(
            contact: testContact,
            l10n: any(named: 'l10n'),
          ),
        ).called(1);

        verify(
          () => mockSharingService.shareFile(
            filePath: any(
              named: 'filePath',
              that: contains('scheda_RSSMRA85D15H501Z.pdf'),
            ),
            mimeType: 'application/pdf',
            subject: any(
              named: 'subject',
              that: contains('Mario Rossi'),
            ),
          ),
        ).called(1);

        expect(find.byType(ShareContactBottomSheet), findsNothing);
      },
    );
  });
}
