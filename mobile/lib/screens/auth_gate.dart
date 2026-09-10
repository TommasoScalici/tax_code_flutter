import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared/services/auth_service.dart';

import 'home_page.dart';
import 'welcome_screen.dart';

///
/// Gatekeeper widget that dynamically routes the user to [HomePage] or [WelcomeScreen]
/// based on their current [AuthService] status.
///
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();

    switch (authService.status) {
      case AuthStatus.authenticated:
        return const HomePage();
      case AuthStatus.unauthenticated:
        return const WelcomeScreen();
      case AuthStatus.initializing:
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
    }
  }
}
