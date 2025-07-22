import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:shared/providers/app_state.dart';
import 'package:tax_code_flutter_wear_os/l10n/app_localizations.dart';

import 'home_page.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  final _googleSignIn = GoogleSignIn();
  final _loadingNotifier = ValueNotifier<bool>(false);
  final _logger = Logger();

  /// Handles the entire Google Sign-In and Firebase authentication process.
  Future<void> _handleSignIn(BuildContext context) async {
    _loadingNotifier.value = true;
    try {
      final googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        _logger.w('Google Sign-In was cancelled by the user.');
        return;
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      if (userCredential.user != null && context.mounted) {
        await context.read<AppState>().saveUserData(userCredential.user!);
      }
    } catch (e) {
      _logger.e('Error during Google Sign-In: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.loginError)),
        );
      }
    } finally {
      if (mounted) {
        _loadingNotifier.value = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Colors.black,
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData) {
          return const HomePage();
        }

        return Scaffold(
          backgroundColor: Colors.black,
          body: SizedBox.expand(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(AppLocalizations.of(context)!.welcomeTo),
                Text(AppLocalizations.of(context)!.appTitle),
                const SizedBox(height: 10),
                ValueListenableBuilder<bool>(
                  valueListenable: _loadingNotifier,
                  builder: (context, isLoading, _) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          height: 50,
                          child: ElevatedButton.icon(
                            onPressed:
                                isLoading ? null : () => _handleSignIn(context),
                            icon: const Icon(Icons.login),
                            label: const Text('Login'),
                          ),
                        ),
                        if (isLoading) ...[
                          const SizedBox(height: 10),
                          const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ],
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
