import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared/services/auth_service.dart';
import 'package:tax_code_flutter_wear_os/l10n/app_localizations.dart';

import 'home_page.dart';

/// Acts as a gate, showing HomePage if the user is signed in,
/// otherwise showing the login screen.
class AuthGate extends StatelessWidget {
  final Widget homePage;

  const AuthGate({super.key, this.homePage = const HomePage()});

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();
    return authService.isSignedIn ? homePage : const _LoginView();
  }
}

/// The private widget that builds the actual login UI.
class _LoginView extends StatelessWidget {
  const _LoginView();

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;
    final errorColor = Theme.of(context).colorScheme.error;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  l10n.welcomeMessage(l10n.appTitle),
                  textAlign: TextAlign.center,
                  style: textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ElevatedButton.icon(
                      onPressed: authService.isLoading
                          ? null
                          : () => context
                                .read<AuthService>()
                                .signInWithGoogleForWearable(),
                      icon: const Icon(Icons.login),
                      label: Text(
                        l10n.signInWithGoogle,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    if (authService.isLoading) ...[
                      const SizedBox(height: 16),
                      const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(strokeWidth: 3),
                      ),
                    ],
                  ],
                ),
                if (authService.errorMessage != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    l10n.loginError,
                    textAlign: TextAlign.center,
                    style: textTheme.bodySmall?.copyWith(color: errorColor),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
