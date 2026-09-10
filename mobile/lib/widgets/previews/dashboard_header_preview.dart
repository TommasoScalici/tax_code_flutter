import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:provider/provider.dart';
import 'package:shared/services/auth_service.dart';
import 'package:tax_code_flutter/core/theme/app_theme.dart';
import 'package:tax_code_flutter/l10n/app_localizations.dart';
import 'package:tax_code_flutter/widgets/dashboard/dashboard_header.dart';

/// Lightweight mock of [AuthService] for [DashboardHeaderPreview].
class _HeaderPreviewAuthService extends ChangeNotifier implements AuthService {
  final bool _signedIn;
  final bool _guest;

  _HeaderPreviewAuthService({bool signedIn = true, bool guest = false})
      : _signedIn = signedIn,
        _guest = guest;

  @override
  AuthStatus get status =>
      _signedIn ? AuthStatus.authenticated : AuthStatus.unauthenticated;

  @override
  User? get currentUser => null;

  @override
  bool get isSignedIn => _signedIn;

  @override
  bool get isGuest => _guest;

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

/// Standalone preview for [DashboardHeader] within a centered mobile viewport.
class DashboardHeaderPreview extends StatefulWidget {
  @Preview(name: 'Dashboard Header')
  const DashboardHeaderPreview({super.key});

  @override
  State<DashboardHeaderPreview> createState() => _DashboardHeaderPreviewState();
}

class _DashboardHeaderPreviewState extends State<DashboardHeaderPreview> {
  bool _isDarkMode = false;
  bool _isGuestMode = false;

  @override
  Widget build(BuildContext context) {
    final fakeAuthService = _HeaderPreviewAuthService(
      signedIn: true,
      guest: _isGuestMode,
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      locale: const Locale('it'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Builder(
        builder: (context) {
          final theme = Theme.of(context);
          final colorScheme = theme.colorScheme;

          return Scaffold(
            backgroundColor: theme.scaffoldBackgroundColor,
            body: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 412),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Mode description tag
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              'Dashboard Header',
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          FilterChip(
                            label: Text(_isGuestMode ? 'Ospite' : 'Google Sync'),
                            selected: !_isGuestMode,
                            onSelected: (val) {
                              setState(() {
                                _isGuestMode = !val;
                              });
                            },
                          ),
                        ],
                      ),
                    ),

                    // Device card container holding the DashboardHeader
                    Container(
                      decoration: BoxDecoration(
                        color: theme.scaffoldBackgroundColor,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: colorScheme.outlineVariant.withValues(alpha: 0.6),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: _isDarkMode ? 0.35 : 0.08),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: ChangeNotifierProvider<AuthService>.value(
                        value: fakeAuthService,
                        child: DashboardHeader(
                          onThemeToggle: () {
                            setState(() {
                              _isDarkMode = !_isDarkMode;
                            });
                          },
                          onProfileTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Tap su Profilo'),
                                duration: Duration(seconds: 1),
                              ),
                            );
                          },
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
