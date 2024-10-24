import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:shared/providers/app_state.dart';

import '../screens/home_page.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  GoogleSignInAccount? _currentUser;
  late bool _isLoading;
  late Logger _logger;

  @override
  void initState() {
    super.initState();
    _logger = context.read<AppState>().logger;
    _checkSignedInAccount();
  }

  Future<void> _checkSignedInAccount() async {
    try {
      _isLoading = true;
      final googleUser = await _googleSignIn.signInSilently();
      setState(() => _currentUser = googleUser);
    } catch (e) {
      _logger.e("Error while retrieving default user: $e");
    } finally {
      _isLoading = false;
    }
  }

  Future<void> _signInWithDefaultUser() async {
    try {
      final googleUser = await _googleSignIn.signInSilently();
      if (googleUser != null) {
        final googleAuth = await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        await _auth.signInWithCredential(credential);
      } else {
        _logger.e("No default user found.");
      }
    } catch (e) {
      _logger.e("Error while logging with the default user: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _auth.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }

        if (!snapshot.hasData) {
          return Scaffold(
            backgroundColor: Colors.black,
            body: Center(
                child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: SingleChildScrollView(
                child: Column(children: [
                  SizedBox(height: 80),
                  if (_currentUser != null && !_isLoading)
                    SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () async => await _signInWithDefaultUser(),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (_isLoading)
                              CircularProgressIndicator()
                            else if (_currentUser != null)
                              Container(
                                width: 36,
                                height: 36,
                                margin: EdgeInsets.symmetric(vertical: 8.0),
                                child: CircleAvatar(
                                  foregroundImage: _currentUser?.photoUrl ==
                                          null
                                      ? null
                                      : NetworkImage(_currentUser!.photoUrl!),
                                  child: _currentUser?.photoUrl == null
                                      ? Icon(Icons.account_circle)
                                      : null,
                                ),
                              ),
                            SizedBox(width: 10),
                            if (_currentUser != null)
                              Flexible(
                                child: Text(
                                  _currentUser!.displayName ??
                                      _currentUser!.email,
                                  style: TextStyle(fontSize: 12),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  SizedBox(height: 10),
                  SizedBox(
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      label: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6.0),
                        child: Text(
                          'Aggiungi Account Google',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                      icon: Icon(Icons.add),
                    ),
                  ),
                  SizedBox(height: 80),
                ]),
              ),
            )),
          );
        }

        if (snapshot.hasData) {
          final user = snapshot.data;
          if (user != null) {
            Future.microtask(() async {
              if (context.mounted) {
                final appState = context.read<AppState>();
                await appState.saveUserData(user);
              }
            });
          }
        }

        return HomePage();
      },
    );
  }
}
