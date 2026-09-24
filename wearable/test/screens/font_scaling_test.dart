import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:shared/models/birthplace.dart';
import 'package:shared/models/contact.dart';
import 'package:shared/services/auth_service.dart';
import 'package:tax_code_flutter_wear_os/controllers/contacts_list_controller.dart';
import 'package:tax_code_flutter_wear_os/l10n/app_localizations.dart';
import 'package:tax_code_flutter_wear_os/screens/auth_gate.dart';
import 'package:tax_code_flutter_wear_os/screens/barcode_page.dart';
import 'package:tax_code_flutter_wear_os/services/demo_mode_service.dart';
import 'package:tax_code_flutter_wear_os/services/native_view_service.dart';
import 'package:tax_code_flutter_wear_os/settings.dart';
import 'package:tax_code_flutter_wear_os/widgets/contacts_list.dart';

class MockAuthService extends Mock implements AuthService {}
class MockNativeViewService extends Mock implements NativeViewServiceAbstract {}
class MockDemoModeService extends Mock implements DemoModeServiceAbstract {}
class MockContactsListController extends Mock implements ContactsListController {}

void main() {
  late MockNativeViewService mockNativeViewService;
  late MockAuthService mockAuthService;
  late MockDemoModeService mockDemoModeService;
  late MockContactsListController mockContactsController;

  final testContact = Contact(
    id: 'test-id',
    firstName: 'Laura',
    lastName: 'Bianchi',
    gender: 'F',
    taxCode: 'BNCLRA85M41F205Z',
    birthPlace: const Birthplace(name: 'Milano', state: 'MI'),
    birthDate: DateTime(1985, 8),
    listIndex: 0,
  );

  setUp(() {
    mockNativeViewService = MockNativeViewService();
    mockAuthService = MockAuthService();
    mockDemoModeService = MockDemoModeService();
    mockContactsController = MockContactsListController();

    when(() => mockNativeViewService.enableHighBrightnessMode()).thenAnswer((_) async {});
    when(() => mockNativeViewService.disableHighBrightnessMode()).thenAnswer((_) async {});
    when(() => mockAuthService.status).thenReturn(AuthStatus.unauthenticated);
    when(() => mockAuthService.isLoading).thenReturn(false);
    when(() => mockAuthService.errorMessage).thenReturn(null);
    when(() => mockDemoModeService.isDemoMode).thenReturn(false);
    when(() => mockContactsController.isLoading).thenReturn(false);
    when(() => mockContactsController.hasContacts).thenReturn(false);
    when(() => mockContactsController.contacts).thenReturn([]);
    when(() => mockContactsController.isDemoMode).thenReturn(false);
    when(() => mockContactsController.isLaunchingPhoneApp).thenReturn(false);
  });

  group('Wear OS Font Scaling Compliance (WO-V1)', () {
    const scales = [1.0, 1.24, 1.3, 1.5];

    for (final scale in scales) {
      testWidgets('BarcodePage adapts to font scale ${scale}x on 390x390 circular display without overflow', (tester) async {
        tester.view.physicalSize = const Size(390, 390);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(
          MaterialApp(
            theme: Settings.getWearTheme(),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: MediaQuery(
              data: MediaQueryData(
                size: const Size(390, 390),
                textScaler: TextScaler.linear(scale),
              ),
              child: Provider<NativeViewServiceAbstract>.value(
                value: mockNativeViewService,
                child: BarcodePage(
                  taxCode: testContact.taxCode,
                  contact: testContact,
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.text('Laura Bianchi'), findsOneWidget);
        expect(find.text('BNCLRA85M41F205Z'), findsOneWidget);
      });

      testWidgets('AuthGate adapts to font scale ${scale}x without overflow', (tester) async {
        tester.view.physicalSize = const Size(390, 390);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(
          MaterialApp(
            theme: Settings.getWearTheme(),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: MediaQuery(
              data: MediaQueryData(
                size: const Size(390, 390),
                textScaler: TextScaler.linear(scale),
              ),
              child: MultiProvider(
                providers: [
                  ChangeNotifierProvider<AuthService>.value(value: mockAuthService),
                  ChangeNotifierProvider<DemoModeServiceAbstract>.value(value: mockDemoModeService),
                ],
                child: const AuthGate(),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
      });

      testWidgets('ContactsList empty state adapts to font scale ${scale}x without overflow', (tester) async {
        tester.view.physicalSize = const Size(390, 390);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(
          MaterialApp(
            theme: Settings.getWearTheme(),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: MediaQuery(
              data: MediaQueryData(
                size: const Size(390, 390),
                textScaler: TextScaler.linear(scale),
              ),
              child: MultiProvider(
                providers: [
                  ChangeNotifierProvider<ContactsListController>.value(value: mockContactsController),
                  ChangeNotifierProvider<AuthService>.value(value: mockAuthService),
                ],
                child: const Scaffold(body: ContactsList()),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
      });
    }
  });
}
