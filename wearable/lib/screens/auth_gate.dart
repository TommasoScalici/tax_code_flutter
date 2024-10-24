import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:shared/providers/app_state.dart';

import 'home_page.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  late Logger _logger;

  @override
  void initState() {
    super.initState();
    _logger = context.read<AppState>().logger;
  }

  Future<void> _signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();

      if (googleUser != null) {
        final googleAuth = await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        await _auth.signInWithCredential(credential);
      } else {
        _logger.e("No account selected");
      }
    } catch (e) {
      _logger.e("Error while Google login: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _auth.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasData) {
          final user = snapshot.data;
          if (user != null) {
            Future.microtask(() async {
              if (context.mounted) {
                final appState = context.read<AppState>();
                await appState.saveUserData(user);

                if (context.mounted) {
                  await Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => HomePage()));
                }
              }
            });
          }
        }

        if (!snapshot.hasData) {
          final currentLocale = Localizations.localeOf(context);
          final countryCode = currentLocale.countryCode?.toLowerCase();
          return Scaffold(
            backgroundColor: Colors.black,
            body: SizedBox.expand(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      child: Text(
                          countryCode == 'it' ? 'Benvenuto su' : 'Welcome to'),
                    ),
                    SizedBox(
                      child: Text(
                          countryCode == 'it' ? 'Codice Fiscale' : 'Tax Code'),
                    ),
                    SizedBox(height: 10),
                    SizedBox(
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: _signInWithGoogle,
                        icon: Icon(Icons.login),
                        label: const Text('Login'),
                      ),
                    ),
                  ]),
            ),
          );
        }

        return Center(child: CircularProgressIndicator());
      },
    );
  }
}
