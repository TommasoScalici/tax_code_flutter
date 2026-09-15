import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:shared/models/birthplace.dart';
import 'package:shared/models/contact.dart';
import 'package:shared/repositories/contact_repository.dart';
import 'package:shared/services/auth_service.dart';
import 'package:shared/services/sync_service.dart';
import 'package:tax_code_flutter/controllers/home_page_controller.dart';
import 'package:tax_code_flutter/core/theme/app_theme.dart';
import 'package:tax_code_flutter/l10n/app_localizations_setup.dart';
import 'package:tax_code_flutter/services/in_app_review_service.dart';
import 'package:tax_code_flutter/services/info_service.dart';
import 'package:tax_code_flutter/widgets/export/export_data_bottom_sheet.dart';
import 'package:tax_code_flutter/widgets/profile_bottom_sheet.dart';

import '../helpers/mocks.dart';
import '../helpers/test_setup.dart';

class MockSyncService extends Mock implements SyncService {}

class MockInAppReviewService extends Mock implements InAppReviewService {}

void main() {
  setUpAll(setupTests);

  late MockAuthService mockAuthService;
  late MockUser mockUser;
  late MockSyncService mockSyncService;
  late MockHomePageController mockHomeController;
  late MockInfoService mockInfoService;
  late MockInAppReviewService mockInAppReviewService;
  late MockLogger mockLogger;
  late MockContactRepository mockContactRepository;

  final sampleContacts = [
    Contact(
      id: '1',
      firstName: 'Mario',
      lastName: 'Rossi',
      gender: 'M',
      birthDate: DateTime(1985, 4, 15),
      birthPlace: const Birthplace(name: 'Roma', state: 'RM', code: 'H501'),
      taxCode: 'RSSMRA85D15H501Z',
      listIndex: 0,
    ),
    Contact(
      id: '2',
      firstName: 'Laura',
      lastName: 'Neri',
      gender: 'F',
      birthDate: DateTime(1992, 8, 24),
      birthPlace: const Birthplace(name: 'Milano', state: 'MI', code: 'F205'),
      taxCode: 'NREBNC92M64F205K',
      listIndex: 1,
    ),
  ];

  setUp(() {
    mockAuthService = MockAuthService();
    mockUser = MockUser();
    mockSyncService = MockSyncService();
    mockHomeController = MockHomePageController();
    mockInfoService = MockInfoService();
    mockInAppReviewService = MockInAppReviewService();
    mockLogger = MockLogger();
    mockContactRepository = MockContactRepository();

    when(() => mockContactRepository.contacts).thenReturn(sampleContacts);

    when(() => mockAuthService.currentUser).thenReturn(mockUser);
    when(() => mockAuthService.isGuest).thenReturn(false);
    when(() => mockAuthService.isSignedIn).thenReturn(true);
    when(() => mockUser.displayName).thenReturn('Mario Rossi');
    when(() => mockUser.email).thenReturn('mario.rossi@gmail.com');
    when(() => mockUser.photoURL).thenReturn(null);

    when(() => mockSyncService.isSyncEnabled).thenReturn(true);
    when(() => mockSyncService.canSync).thenReturn(true);

    when(() => mockHomeController.contactsToShow).thenReturn(sampleContacts);

    when(() => mockInfoService.getPackageInfo()).thenAnswer(
      (_) async => PackageInfo(
        appName: 'Codice Fiscale',
        packageName: 'tommasoscalici.taxcode',
        version: '2.0.0',
        buildNumber: '1',
        installerStore: 'Google Play',
      ),
    );

    when(() => mockInAppReviewService.openStoreListing())
        .thenAnswer((_) async {});
  });

  Widget buildTestApp({
    required Widget child,
    Locale locale = const Locale('it'),
    Brightness brightness = Brightness.dark,
  }) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthService>.value(value: mockAuthService),
        ChangeNotifierProvider<SyncService>.value(value: mockSyncService),
        ChangeNotifierProvider<HomePageController>.value(
            value: mockHomeController),
        Provider<InfoServiceAbstract>.value(value: mockInfoService),
        Provider<InAppReviewService>.value(value: mockInAppReviewService),
        Provider<Logger>.value(value: mockLogger),
        ChangeNotifierProvider<ContactRepository>.value(
          value: mockContactRepository,
        ),
      ],
      child: MaterialApp(
        locale: locale,
        localizationsDelegates: const [
          ...AppLocalizationsSetup.localizationsDelegates,
          ...GlobalMaterialLocalizations.delegates,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        theme: brightness == Brightness.dark
            ? AppTheme.darkTheme
            : AppTheme.lightTheme,
        home: Scaffold(body: child),
      ),
    );
  }

  void setLargeViewport(WidgetTester tester) {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  }

  group('ProfileBottomSheet Widget Tests', () {
    testWidgets(
        'renders authenticated Google user profile, sync pill, and all action cards in Italian',
        (tester) async {
      setLargeViewport(tester);

      await tester.pumpWidget(
        buildTestApp(child: const ProfileBottomSheet(isEmbedded: true)),
      );
      await tester.pumpAndSettle();

      // Header
      expect(find.text('Account & Impostazioni'), findsOneWidget);

      // Section 1: User & Sync
      expect(find.text('Mario Rossi'), findsOneWidget);
      expect(find.text('mario.rossi@gmail.com'), findsOneWidget);
      expect(find.text('Google'), findsOneWidget);
      expect(find.textContaining('Sincronizzazione attiva'), findsOneWidget);
      expect(find.textContaining('2 codici salvati'), findsOneWidget);

      // Section 2: Data & Utilities
      expect(find.text('DATI E FUNZIONI'), findsOneWidget);
      expect(find.text('Esporta codici'), findsOneWidget);
      expect(find.text('Backup offline in formato JSON o CSV'), findsOneWidget);
      expect(find.text('Valuta sul Play Store'), findsOneWidget);

      // Section 3: Legal
      expect(find.text('INFORMAZIONI LEGALI'), findsOneWidget);
      expect(find.text("Informazioni sull'app"), findsOneWidget);
      expect(find.textContaining('Versione 2.0.0'), findsOneWidget);

      // Section 4: Account Management
      expect(find.text('GESTIONE ACCOUNT'), findsOneWidget);
      expect(find.text('Esci'), findsOneWidget);
      expect(find.text('Elimina Account'), findsOneWidget);
    });

    testWidgets('renders all translated elements in English', (tester) async {
      setLargeViewport(tester);

      await tester.pumpWidget(
        buildTestApp(
          child: const ProfileBottomSheet(isEmbedded: true),
          locale: const Locale('en'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Account & Settings'), findsOneWidget);
      expect(find.text('DATA & UTILITIES'), findsOneWidget);
      expect(find.text('Export codes'), findsOneWidget);
      expect(find.text('Rate on the Play Store'), findsOneWidget);
      expect(find.text('LEGAL INFORMATION'), findsOneWidget);
      expect(find.text('App Information'), findsOneWidget);
      expect(find.text('ACCOUNT MANAGEMENT'), findsOneWidget);
      expect(find.text('Sign Out'), findsOneWidget);
      expect(find.text('Delete Account'), findsOneWidget);
    });

    testWidgets(
        'renders guest mode with upgrade banner and tapping Google sign in calls authService',
        (tester) async {
      setLargeViewport(tester);

      when(() => mockAuthService.isGuest).thenReturn(true);
      when(() => mockAuthService.currentUser).thenReturn(null);
      when(() => mockAuthService.signInWithGoogle())
          .thenAnswer((_) async => true);

      await tester.pumpWidget(
        buildTestApp(child: const ProfileBottomSheet(isEmbedded: true)),
      );
      await tester.pumpAndSettle();

      expect(find.text('Ospite'), findsAtLeastNWidgets(2)); // Name + Badge
      expect(find.text('Attiva il Backup Cloud'), findsOneWidget);
      expect(find.text('Continua con Google'), findsOneWidget);

      await tester.tap(find.byKey(const Key('profile_guest_google_signin_button')));
      await tester.pump();

      verify(() => mockAuthService.signInWithGoogle()).called(1);
    });

    testWidgets(
        "tapping Informazioni sull'app navigates to App Info sub-view and back button returns to main view",
        (tester) async {
      setLargeViewport(tester);

      await tester.pumpWidget(
        buildTestApp(child: const ProfileBottomSheet(isEmbedded: true)),
      );
      await tester.pumpAndSettle();

      // Initially on main view
      expect(find.text('Account & Impostazioni'), findsOneWidget);
      expect(find.byKey(const Key('profile_app_info_tile')), findsOneWidget);

      // Tap on App Info tile
      await tester.tap(find.byKey(const Key('profile_app_info_tile')));
      await tester.pumpAndSettle();

      // Now on App Info view
      expect(find.text("Informazioni sull'app"), findsOneWidget);
      expect(find.text('Codice Fiscale'), findsOneWidget);
      expect(find.text('v2.0.0 (1)'), findsOneWidget);
      expect(find.text('tommasoscalici.taxcode'), findsOneWidget);
      expect(find.text('Disclaimer Istituzionale'), findsOneWidget);
      expect(find.text('Privacy & Protezione Dati'), findsOneWidget);
      expect(find.byKey(const Key('profile_open_online_policy_button')), findsOneWidget);
      expect(find.text('Sviluppata da Tommaso Scalici'), findsOneWidget);

      // Back button in header is visible
      expect(find.byKey(const Key('profile_sheet_back_button')), findsOneWidget);

      // Tap back button
      await tester.tap(find.byKey(const Key('profile_sheet_back_button')));
      await tester.pumpAndSettle();

      // Back on main view
      expect(find.text('Account & Impostazioni'), findsOneWidget);
      expect(find.byKey(const Key('profile_app_info_tile')), findsOneWidget);
    });

    testWidgets('tapping Valuta sul Play Store calls inAppReviewService',
        (tester) async {
      setLargeViewport(tester);

      await tester.pumpWidget(
        buildTestApp(child: const ProfileBottomSheet(isEmbedded: true)),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('profile_rate_app_tile')));
      await tester.pump();

      verify(() => mockInAppReviewService.openStoreListing()).called(1);
    });

    testWidgets('tapping Esporta codici opens ExportDataBottomSheet',
        (tester) async {
      setLargeViewport(tester);

      await tester.pumpWidget(
        buildTestApp(child: const ProfileBottomSheet(isEmbedded: true)),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('profile_export_codes_tile')));
      await tester.pumpAndSettle();

      expect(find.byType(ExportDataBottomSheet), findsOneWidget);
    });

    testWidgets("tapping Esci dall'account calls authService.signOut",
        (tester) async {
      setLargeViewport(tester);

      when(() => mockAuthService.signOut()).thenAnswer((_) async {});

      await tester.pumpWidget(
        buildTestApp(child: const ProfileBottomSheet(isEmbedded: true)),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('profile_sign_out_tile')));
      await tester.pumpAndSettle();

      verify(() => mockAuthService.signOut()).called(1);
    });

    testWidgets(
        'tapping Elimina account e dati shows confirmation dialog and cancel dismisses it',
        (tester) async {
      setLargeViewport(tester);

      await tester.pumpWidget(
        buildTestApp(child: const ProfileBottomSheet(isEmbedded: true)),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('profile_delete_account_tile')));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Conferma Eliminazione'), findsOneWidget);

      await tester.tap(find.text('Annulla'));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsNothing);
      verifyNever(() => mockAuthService.deleteUserAccount());
    });

    testWidgets(
        'confirming account deletion calls authService.deleteUserAccount',
        (tester) async {
      setLargeViewport(tester);

      when(() => mockAuthService.deleteUserAccount()).thenAnswer((_) async {});

      await tester.pumpWidget(
        buildTestApp(child: const ProfileBottomSheet(isEmbedded: true)),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('profile_delete_account_tile')));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Elimina'));
      await tester.pumpAndSettle();

      verify(() => mockAuthService.deleteUserAccount()).called(1);
    });

    testWidgets('modal bottom sheet show displays and dismisses via close button',
        (tester) async {
      setLargeViewport(tester);

      await tester.pumpWidget(
        buildTestApp(
          child: Builder(
            builder: (ctx) => ElevatedButton(
              onPressed: () => ProfileBottomSheet.show<void>(ctx),
              child: const Text('Open'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Open bottom sheet
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.byType(ProfileBottomSheet), findsOneWidget);
      expect(find.byKey(const Key('profile_sheet_close_button')), findsOneWidget);

      // Close bottom sheet
      await tester.tap(find.byKey(const Key('profile_sheet_close_button')));
      await tester.pumpAndSettle();

      expect(find.byType(ProfileBottomSheet), findsNothing);
    });

    testWidgets('modal bottom sheet with startAtAppInfo: true opens directly to App Info view',
        (tester) async {
      setLargeViewport(tester);

      await tester.pumpWidget(
        buildTestApp(
          child: Builder(
            builder: (ctx) => ElevatedButton(
              onPressed: () => ProfileBottomSheet.show<void>(
                ctx,
                startAtAppInfo: true,
              ),
              child: const Text('Open Info'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open Info'));
      await tester.pumpAndSettle();

      expect(find.byType(ProfileBottomSheet), findsOneWidget);
      expect(find.text("Informazioni sull'app"), findsOneWidget);
      expect(find.text('Disclaimer Istituzionale'), findsOneWidget);
      expect(find.byKey(const Key('profile_open_online_policy_button')), findsOneWidget);

      // Back button pops modal
      await tester.tap(find.byKey(const Key('profile_sheet_back_button')));
      await tester.pumpAndSettle();

      expect(find.byType(ProfileBottomSheet), findsNothing);
    });
  });
}
