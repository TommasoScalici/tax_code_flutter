import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:shared/providers/app_state.dart';

import 'home_page.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  Future<void> _signInWithGoogle(BuildContext context) async {
    final appState = context.read<AppState>();
    final logger = Logger();

    try {
      final auth = FirebaseAuth.instance;
      final googleSignIn = GoogleSignIn();
      final googleUser = await googleSignIn.signIn();

      if (googleUser != null) {
        final googleAuth = await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        final userCredential = await auth.signInWithCredential(credential);
        final user = userCredential.user;
        if (user != null) await appState.saveUserData(user);
      } else {
        logger.w('No account selected');
      }
    } catch (e) {
      logger.e('Error while Google login: $e');
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
                      SizedBox(height: 10),
                      SizedBox(
                        height: 50,
                        child: ElevatedButton.icon(
                          onPressed: () async =>
                              await _signInWithGoogle(context),
                          icon: Icon(Icons.login),
                          label: const Text('Login'),
                        ),
                      ),
                    ]),
              ),
            );
          },
        );
      },
    );
  }
}
