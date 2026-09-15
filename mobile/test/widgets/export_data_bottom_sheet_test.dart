import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared/models/birthplace.dart';
import 'package:shared/models/contact.dart';
import 'package:shared/repositories/contact_repository.dart';
import 'package:shared/services/data_export_service.dart';
import 'package:tax_code_flutter/core/theme/app_theme.dart';
import 'package:tax_code_flutter/l10n/app_localizations_setup.dart';
import 'package:tax_code_flutter/services/sharing_service.dart';
import 'package:tax_code_flutter/widgets/export/export_data_bottom_sheet.dart';

import '../helpers/mocks.dart';
import '../helpers/test_setup.dart';

void main() {
  setUpAll(() {
    setupTests();
    registerFallbackValue(ExportFormat.json);
  });

  late MockContactRepository mockContactRepository;
  late MockDataExportService mockDataExportService;
  late MockSharingService mockSharingService;
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
    mockContactRepository = MockContactRepository();
    mockDataExportService = MockDataExportService();
    mockSharingService = MockSharingService();

    tempDir = await Directory.systemTemp.createTemp('export_test_');
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

    when(() => mockDataExportService.fileExtension(any())).thenReturn('json');
    when(() => mockDataExportService.mimeType(any()))
        .thenReturn('application/json');
    when(
      () => mockDataExportService.formatContacts(
        contacts: any(named: 'contacts'),
        format: any(named: 'format'),
      ),
    ).thenReturn('[{"id":"1"}]');

    when(
      () => mockSharingService.shareFile(
        filePath: any(named: 'filePath'),
        mimeType: any(named: 'mimeType'),
        subject: any(named: 'subject'),
      ),
    ).thenAnswer(
      (_) async => const ShareResult('com.example', ShareResultStatus.success),
    );
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
      // Ignore file locks on Windows test runner
    }
  });

  Widget buildTestApp({
    required Widget child,
    Locale locale = const Locale('it'),
  }) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ContactRepository>.value(
          value: mockContactRepository,
        ),
        Provider<DataExportServiceAbstract>.value(value: mockDataExportService),
        Provider<SharingServiceAbstract>.value(value: mockSharingService),
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

  group('ExportDataBottomSheet Widget Tests', () {
    testWidgets('renders empty state message and disables export when no contacts', (
      tester,
    ) async {
      when(() => mockContactRepository.contacts).thenReturn([]);

      await tester.pumpWidget(
        buildTestApp(
          child: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => ExportDataBottomSheet.show(context),
              child: const Text('Open'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Esporta codici'), findsOneWidget);
      expect(
        find.text('Non hai ancora salvato alcun codice fiscale da esportare.'),
        findsOneWidget,
      );

      final confirmBtn = tester.widget<FilledButton>(
        find.byKey(const Key('export_confirm_button')),
      );
      expect(confirmBtn.onPressed, isNull);
    });

    testWidgets('renders contact count and allows switching between JSON and CSV', (
      tester,
    ) async {
      when(() => mockContactRepository.contacts).thenReturn([testContact]);

      await tester.pumpWidget(
        buildTestApp(
          child: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => ExportDataBottomSheet.show(context),
              child: const Text('Open'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(
        find.text("1 codice fiscale pronto per l'esportazione"),
        findsOneWidget,
      );

      // JSON is selected by default
      expect(find.byKey(const Key('export_format_json_card')), findsOneWidget);
      expect(find.byKey(const Key('export_format_csv_card')), findsOneWidget);

      // Tap CSV option card
      await tester.tap(find.byKey(const Key('export_format_csv_card')));
      await tester.pumpAndSettle();

      // Export button is enabled
      final confirmBtn = tester.widget<FilledButton>(
        find.byKey(const Key('export_confirm_button')),
      );
      expect(confirmBtn.onPressed, isNotNull);
    });

    testWidgets('tapping cancel closes the bottom sheet', (tester) async {
      when(() => mockContactRepository.contacts).thenReturn([testContact]);

      await tester.pumpWidget(
        buildTestApp(
          child: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => ExportDataBottomSheet.show(context),
              child: const Text('Open'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Esporta codici'), findsOneWidget);

      await tester.tap(find.byKey(const Key('export_cancel_button')));
      await tester.pumpAndSettle();

      expect(find.text('Esporta codici'), findsNothing);
    });

    testWidgets('tapping export formats data, pops sheet, and calls sharingService.shareFile', (
      tester,
    ) async {
      when(() => mockContactRepository.contacts).thenReturn([testContact]);

      await tester.pumpWidget(
        buildTestApp(
          child: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => ExportDataBottomSheet.show(context),
              child: const Text('Open'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      final btn = tester.widget<FilledButton>(
        find.byKey(const Key('export_confirm_button')),
      );
      expect(btn.onPressed, isNotNull);

      await tester.runAsync(() async {
        btn.onPressed!();
        await Future<void>.delayed(const Duration(milliseconds: 300));
      });
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      verify(
        () => mockDataExportService.formatContacts(
          contacts: any(named: 'contacts'),
          format: ExportFormat.json,
        ),
      ).called(1);

      verify(
        () => mockSharingService.shareFile(
          filePath: any(named: 'filePath'),
          mimeType: 'application/json',
          subject: any(named: 'subject'),
        ),
      ).called(1);

      // The sheet is dismissed after export
      expect(find.byType(ExportDataBottomSheet), findsNothing);
    });
  });
}
