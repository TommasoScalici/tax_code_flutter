import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared/services/auth_service.dart';
import 'package:tax_code_flutter_wear_os/l10n/app_localizations.dart';

import 'home_page.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();

    if (authService.isSignedIn) {
      return const HomePage();
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(AppLocalizations.of(context)!.welcomeTo),
              Text(AppLocalizations.of(context)!.appTitle),
              const SizedBox(height: 16),
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
                    label: const Text('Login'),
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