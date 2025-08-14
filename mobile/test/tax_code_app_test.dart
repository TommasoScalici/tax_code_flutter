import 'package:firebase_auth/firebase_auth.dart'; // 1. Importa per usare il tipo User
import 'package:mocktail/mocktail.dart';
import 'package:shared/services/auth_service.dart';
import 'package:shared/services/theme_service.dart';

class MockThemeService extends Mock implements ThemeService {}
class MockAuthService extends Mock implements AuthService {}
class MockUser extends Mock implements User {}
void main() {
  // late MockThemeService mockThemeService;
  // late MockAuthService mockAuthService;

  // setUp(() {
  //   mockThemeService = MockThemeService();
  //   mockAuthService = MockAuthService();

  //   when(() => mockAuthService.currentUser).thenReturn(null);
  // });

  // Widget createWidgetUnderTest() {
  //   return MultiProvider(
  //     providers: [
  //       ChangeNotifierProvider<ThemeService>.value(value: mockThemeService),
  //       ChangeNotifierProvider<AuthService>.value(value: mockAuthService),
  //     ],
  //     child: const TaxCodeApp(),
  //   );
  // }

  // group('TaxCodeApp', () {
  //   testWidgets('applies light theme when ThemeService theme is light', (tester) async {
  //     when(() => mockThemeService.theme).thenReturn('light');

  //     await tester.pumpWidget(createWidgetUnderTest());

  //     final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
  //     expect(materialApp.theme, equals(Settings.getLightTheme()));
  //     expect(find.byType(AuthGate), findsOneWidget);
  //   });

  //   testWidgets('applies dark theme when ThemeService theme is dark', (tester) async {
  //     when(() => mockThemeService.theme).thenReturn('dark');

  //     await tester.pumpWidget(createWidgetUnderTest());

  //     final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
  //     expect(materialApp.theme, equals(Settings.getDarkTheme()));
  //     expect(find.byType(AuthGate), findsOneWidget);
  //   });
  // });
}