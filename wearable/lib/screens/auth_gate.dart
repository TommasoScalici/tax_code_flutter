import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared/services/auth_service.dart';
import 'package:tax_code_flutter_wear_os/l10n/app_localizations.dart';

import 'home_page.dart';

/// Acts as a gate, showing HomePage if the user is signed in,
/// otherwise showing the login screen.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();
    return authService.isSignedIn ? const HomePage() : const _LoginView();
  }
}

/// The private widget that builds the actual login UI.
class _LoginView extends StatelessWidget {
  const _LoginView();

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                l10n.welcomeMessage(l10n.appTitle),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 24),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton.icon(
                    onPressed: authService.isLoading
                        ? null
                        : () => context.read<AuthService>().signInWithGoogleForWearable(),
                    icon: const Icon(Icons.login),
                    label: Text(l10n.signInWithGoogle),
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
            ],
          ),
        ),
      ),
    );
  }
}