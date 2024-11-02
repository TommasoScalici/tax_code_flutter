import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:shared/providers/app_state.dart';

import 'home_page.dart';

class AuthGate extends StatelessWidget {
  AuthGate({super.key});

  final _loadingNotifier = ValueNotifier<bool>(false);
  final _logger = Logger();

  Future<GoogleSignInAccount?> _selectGoogleAccount() async {
    try {
      _loadingNotifier.value = true;
      final googleSignIn = GoogleSignIn();
      return await googleSignIn.signIn();
    } catch (e) {
      _logger.e('Error while selecting Google account: $e');
      return null;
    } finally {
      _loadingNotifier.value = false;
    }
  }

  Future<User?> _authenticateWithFirebase(
    BuildContext context,
    GoogleSignInAccount googleUser,
  ) async {
    try {
      _loadingNotifier.value = true;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const CircularProgressIndicator(),
          ),
        ),
      );

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final auth = FirebaseAuth.instance;
      final userCredential = await auth.signInWithCredential(credential);

      if (context.mounted) Navigator.of(context).pop();

      return userCredential.user;
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.loginError)),
        );
      }
      _logger.e('Error while Firebase authentication: $e');
      return null;
    } finally {
      _loadingNotifier.value = false;
    }
  }

  Future<void> _handleSignIn(BuildContext context) async {
    final googleUser = await _selectGoogleAccount();

    if (googleUser != null && context.mounted) {
      final user = await _authenticateWithFirebase(context, googleUser);
      if (user != null && context.mounted) {
        await context.read<AppState>().saveUserData(user);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, value, child) {
        return StreamBuilder(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return const HomePage();
            }

            return Scaffold(
              backgroundColor: Colors.black,
              body: SizedBox.expand(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      child: Text(AppLocalizations.of(context)!.welcomeTo),
                    ),
                    SizedBox(
                      child: Text(AppLocalizations.of(context)!.appTitle),
                    ),
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
                                onPressed: isLoading
                                    ? null
                                    : () => _handleSignIn(context),
                                icon: const Icon(Icons.login),
                                label: const Text('Login'),
                              ),
                            ),
                            if (isLoading) ...[
                              const SizedBox(height: 10),
                              const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
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
      },
    );
  }
}
