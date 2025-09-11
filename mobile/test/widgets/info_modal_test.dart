import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:mocktail/mocktail.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:tax_code_flutter/l10n/app_localizations.dart';
import 'package:tax_code_flutter/services/info_service.dart';
import 'package:tax_code_flutter/widgets/info_modal.dart';

// --- Mocks ---
class MockInfoService extends Mock implements InfoServiceAbstract {}

void main() {
  late MockInfoService mockInfoService;

  setUp(() {
    mockInfoService = MockInfoService();
    registerFallbackValue(const Locale('en'));
  });

  final fakePackageInfo = PackageInfo(
    appName: 'Test App',
    version: '1.0.0',
    buildNumber: '1',
    packageName: 'com.example.test',
  );
  // Using a key part of the real HTML content you provided for the mock.
  const fakeHtmlTerms = 'Author: <strong>Tommaso Scalici</strong><br />';

  /// Helper function to build and pump the widget with all its dependencies.
  Future<void> pumpWidget(WidgetTester tester) async {
    await tester.pumpWidget(
      Provider<InfoServiceAbstract>.value(
        value: mockInfoService,
        child: const MaterialApp(
          locale: Locale('en'), // Pinning to 'en' for predictable strings
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: InfoModal()),
        ),
      ),
    );
  }

  group('InfoModal', () {
    testWidgets('shows loading indicator while data is being fetched', (
      tester,
    ) async {
      // Arrange
      final termsCompleter = Completer<String>();
      final packageInfoCompleter = Completer<PackageInfo>();
      when(
        () => mockInfoService.getLocalizedTerms(any()),
      ).thenAnswer((_) => termsCompleter.future);
      when(
        () => mockInfoService.getPackageInfo(),
      ).thenAnswer((_) => packageInfoCompleter.future);

      // Act
      await pumpWidget(tester);
      await tester.pump(Duration.zero);

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows error message when fetching data fails', (tester) async {
      // Arrange
      when(
        () => mockInfoService.getLocalizedTerms(any()),
      ).thenAnswer((_) async => throw Exception('Failed to load'));
      when(
        () => mockInfoService.getPackageInfo(),
      ).thenAnswer((_) async => fakePackageInfo);

      // Act
      await pumpWidget(tester);
      await tester.pumpAndSettle();

      // Assert
      expect(
        find.text('Something went wrong. Please try again.'),
        findsOneWidget,
      );
    });

    testWidgets(
      'displays terms and package info when data is fetched successfully',
      (tester) async {
        // Arrange
        when(
          () => mockInfoService.getLocalizedTerms(any()),
        ).thenAnswer((_) async => fakeHtmlTerms);
        when(
          () => mockInfoService.getPackageInfo(),
        ).thenAnswer((_) async => fakePackageInfo);

        // Act
        await pumpWidget(tester);
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Tax Code'), findsOneWidget);
        expect(find.text('Test App'), findsOneWidget);
        expect(find.text('1.0.0'), findsOneWidget);
        expect(find.text('Close'), findsOneWidget);

        final htmlWidgetFinder = find.byType(HtmlWidget);
        expect(htmlWidgetFinder, findsOneWidget);

        final htmlWidget = tester.widget<HtmlWidget>(htmlWidgetFinder);
        expect(htmlWidget.html, fakeHtmlTerms);
      },
    );

    testWidgets('closes the dialog when the Close button is tapped', (
      tester,
    ) async {
      // Arrange
      when(
        () => mockInfoService.getLocalizedTerms(any()),
      ).thenAnswer((_) async => fakeHtmlTerms);
      when(
        () => mockInfoService.getPackageInfo(),
      ).thenAnswer((_) async => fakePackageInfo);

      await pumpWidget(tester);
      await tester.pumpAndSettle();

      expect(find.byType(InfoModal), findsOneWidget);

      // Act
      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(InfoModal), findsNothing);
    });
  });
}
