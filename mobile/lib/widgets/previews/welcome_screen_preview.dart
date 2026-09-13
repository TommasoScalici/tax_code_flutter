import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widget_previews.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:shared/services/auth_service.dart';
import 'package:tax_code_flutter/core/theme/app_theme.dart';
import 'package:tax_code_flutter/l10n/app_localizations_setup.dart';
import 'package:tax_code_flutter/screens/welcome_screen.dart';

/// Lightweight mock of [AuthService] for standalone preview rendering.
class _PreviewAuthService extends ChangeNotifier implements AuthService {
  @override
  AuthStatus get status => AuthStatus.unauthenticated;

  @override
  User? get currentUser => null;

  @override
  bool get isSignedIn => false;

  @override
  bool get isGuest => false;

  @override
  bool get isLoading => false;

  @override
  String? get errorMessage => null;

  @override
  Future<void> deleteUserAccount() async {}

  @override
  Future<bool> reauthenticateWithGoogle() async => true;

  @override
  Future<bool> signInWithGoogle() async => true;

  @override
  Future<void> signInWithGoogleForWearable() async {}

  @override
  Future<bool> signInAnonymously() async => true;

  @override
  Future<void> signOut() async {}
}

/// Standalone preview for [WelcomeScreen] with centered mobile viewport and theme toggle.
class WelcomeScreenPreview extends StatefulWidget {
  @Preview(name: 'Welcome Screen')
  const WelcomeScreenPreview({super.key});

  @override
  State<WelcomeScreenPreview> createState() => _WelcomeScreenPreviewState();
}

class _WelcomeScreenPreviewState extends State<WelcomeScreenPreview> {
  final _fakeAuthService = _PreviewAuthService();
  bool _isDarkMode = false;

  @override
  void dispose() {
    _fakeAuthService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      locale: const Locale('it'),
      localizationsDelegates: AppLocalizationsSetup.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Builder(
        builder: (context) {
          final theme = Theme.of(context);
          return Scaffold(
            backgroundColor: theme.scaffoldBackgroundColor,
            body: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 412, maxHeight: 892),
                decoration: BoxDecoration(
                  color: theme.scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: _isDarkMode ? 0.4 : 0.08),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  children: [
                    ChangeNotifierProvider<AuthService>.value(
                      value: _fakeAuthService,
                      child: const WelcomeScreen(),
                    ),
                    // Convenient top-right theme switch button
                    Positioned(
                      top: 12,
                      right: 12,
                      child: SafeArea(
                        child: Material(
                          color: theme.colorScheme.surfaceContainerHigh.withValues(alpha: 0.85),
                          shape: const CircleBorder(),
                          elevation: 2,
                          child: IconButton(
                            tooltip: _isDarkMode ? 'Passa a tema chiaro' : 'Passa a tema scuro',
                            icon: Icon(
                              _isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            onPressed: () {
                              setState(() {
                                _isDarkMode = !_isDarkMode;
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
