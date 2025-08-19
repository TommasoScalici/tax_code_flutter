import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:shared/repositories/contact_repository.dart';
import 'package:shared/services/auth_service.dart';
import 'package:tax_code_flutter_wear_os/controllers/wearable_home_controller.dart';
import 'package:tax_code_flutter_wear_os/l10n/app_localizations.dart';
import 'package:tax_code_flutter_wear_os/screens/auth_gate.dart';
import 'package:tax_code_flutter_wear_os/screens/home_page.dart';
import 'package:tax_code_flutter_wear_os/services/native_view_service.dart';

// --- Mocks ---
class MockAuthService extends Mock implements AuthService {}

class MockContactRepository extends Mock implements ContactRepository {}

class MockLogger extends Mock implements Logger {}

class MockNativeViewService extends Mock implements NativeViewServiceAbstract {}

void main() {
  late MockAuthService mockAuthService;
  late MockContactRepository mockContactRepository;
  late MockLogger mockLogger;
  late MockNativeViewService mockNativeViewService;

  Widget createTestableWidget(Widget child) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthService>.value(value: mockAuthService),
        ChangeNotifierProvider<ContactRepository>.value(
          value: mockContactRepository,
        ),
        Provider<Logger>.value(value: mockLogger),
        Provider<NativeViewServiceAbstract>.value(value: mockNativeViewService),
        ChangeNotifierProvider<WearableHomeController>(
          create: (context) => WearableHomeController(
            contactRepository: mockContactRepository,
            nativeViewService: mockNativeViewService,
          ),
        ),
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: child,
      ),
    );
  }

  setUp(() {
    mockAuthService = MockAuthService();
    mockContactRepository = MockContactRepository();
    mockLogger = MockLogger();
    mockNativeViewService = MockNativeViewService();
    when(() => mockContactRepository.isLoading).thenReturn(false);
    when(() => mockContactRepository.contacts).thenReturn([]);
  });

  group('AuthGate', () {
    final elevatedButtonFinder = find.byWidgetPredicate(
      (widget) => widget is ElevatedButton,
    );

    testWidgets('should display HomePage when user is signed in', (
      WidgetTester tester,
    ) async {
      when(() => mockAuthService.isSignedIn).thenReturn(true);
      when(
        () => mockNativeViewService.showContactList(any()),
      ).thenAnswer((_) async {});
      when(
        () => mockNativeViewService.updateContactList(any()),
      ).thenAnswer((_) async {});

      await tester.pumpWidget(createTestableWidget(const AuthGate()));
      await tester.pump();

      expect(find.byType(HomePage), findsOneWidget);
    });

    testWidgets(
      'should display Login UI when user is signed out and not loading',
      (WidgetTester tester) async {
        when(() => mockAuthService.isSignedIn).thenReturn(false);
        when(() => mockAuthService.isLoading).thenReturn(false);
        when(
          () => mockAuthService.signInWithGoogleForWearable(),
        ).thenAnswer((_) async {});

        await tester.pumpWidget(createTestableWidget(const AuthGate()));

        expect(find.byType(HomePage), findsNothing);
        expect(elevatedButtonFinder, findsOneWidget);
        expect(find.byType(CircularProgressIndicator), findsNothing);

        final loginButton = tester.widget<ElevatedButton>(elevatedButtonFinder);
        expect(loginButton.onPressed, isNotNull);
      },
    );

    testWidgets(
      'should display loading indicator and disable button when loading',
      (WidgetTester tester) async {
        when(() => mockAuthService.isSignedIn).thenReturn(false);
        when(() => mockAuthService.isLoading).thenReturn(true);

        await tester.pumpWidget(createTestableWidget(const AuthGate()));

        expect(find.byType(CircularProgressIndicator), findsOneWidget);

        final loginButton = tester.widget<ElevatedButton>(elevatedButtonFinder);
        expect(loginButton.onPressed, isNull);
      },
    );

    testWidgets(
      'should call signInWithGoogleForWearable when login button is tapped',
      (WidgetTester tester) async {
        when(() => mockAuthService.isSignedIn).thenReturn(false);
        when(() => mockAuthService.isLoading).thenReturn(false);
        when(
          () => mockAuthService.signInWithGoogleForWearable(),
        ).thenAnswer((_) async {});

        await tester.pumpWidget(createTestableWidget(const AuthGate()));
        await tester.tap(elevatedButtonFinder);

        verify(() => mockAuthService.signInWithGoogleForWearable()).called(1);
      },
    );
  });
}
