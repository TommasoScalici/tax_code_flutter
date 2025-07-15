import 'dart:convert';
import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
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
  final _googleSignIn = GoogleSignIn.instance;
  final _remoteConfig = FirebaseRemoteConfig.instance;
  final _loadingNotifier = ValueNotifier<bool>(false);
  final _logger = Logger();
  bool _isGoogleSignInInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeGoogleSignIn();
  }

  Future<void> _initializeGoogleSignIn() async {
    try {
      final serverClientId =
          _remoteConfig.getString('google_provider_client_id');

      if (serverClientId.isEmpty) {
        _logger.e('Server Client ID is empty. Check Firebase Remote Config.');
        return;
      }

      final rawNonce = _generateNonce();

      await _googleSignIn.initialize(
          nonce: rawNonce, serverClientId: serverClientId);

      if (mounted) {
        setState(() {
          _isGoogleSignInInitialized = true;
        });
      }
    } catch (e) {
      _logger.e('Error initializing Google Sign In: $e');
    }
  }

  String _generateNonce() {
    final random = Random.secure();
    return base64Url.encode(List<int>.generate(32, (_) => random.nextInt(256)));
  }

  Future<GoogleSignInAccount?> _selectGoogleAccount() async {
    if (!_isGoogleSignInInitialized) return null;

    try {
      _loadingNotifier.value = true;
      return await _googleSignIn.authenticate();
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

      final googleAuth = googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
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
    if (!_isGoogleSignInInitialized) return;

    _loadingNotifier.value = true;
    final googleUser = await _selectGoogleAccount();
    _loadingNotifier.value = false;

    if (googleUser != null && context.mounted) {
      _loadingNotifier.value = true;
      final user = await _authenticateWithFirebase(context, googleUser);
      _loadingNotifier.value = false;

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
