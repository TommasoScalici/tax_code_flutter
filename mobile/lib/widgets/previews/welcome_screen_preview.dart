import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widget_previews.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:shared/services/auth_service.dart';
import 'package:tax_code_flutter/screens/welcome_screen.dart';
import 'package:tax_code_flutter/widgets/previews/preview_shell.dart';

/// Lightweight mock of [AuthService] for standalone preview rendering.
class _PreviewAuthService extends ChangeNotifier implements AuthService {
  @override
  AuthStatus get status => AuthStatus.unauthenticated;

  @override
  User? get currentUser => null;

  @override
  bool get isSignedIn => false;

  @override
  bool get isGuest => false;

  @override
  bool get isLoading => false;

  @override
  String? get errorMessage => null;

  @override
  String? get errorKey => null;

  @override
  AppFailure? get failure => null;

  @override
  Future<void> deleteUserAccount() async {}

  @override
  Future<bool> reauthenticateWithGoogle() async => true;

  @override
  Future<bool> signInWithGoogle() async => true;

  @override
  Future<void> signInWithGoogleForWearable() async {}

  @override
  Future<bool> signInAnonymously() async => true;

  @override
  Future<void> signOut() async {}
}

/// Standalone preview for [WelcomeScreen] with centered mobile viewport and theme toggle.
class WelcomeScreenPreview extends StatefulWidget {
  @Preview(name: 'Welcome Screen')
  const WelcomeScreenPreview({super.key});

  @override
  State<WelcomeScreenPreview> createState() => _WelcomeScreenPreviewState();
}

class _WelcomeScreenPreviewState extends State<WelcomeScreenPreview> {
  final _fakeAuthService = _PreviewAuthService();

  @override
  void dispose() {
    _fakeAuthService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PreviewShell(
      maxWidth: 412,
      maxHeight: 892,
      expandChild: true,
      padding: EdgeInsets.zero,
      providers: [
        ChangeNotifierProvider<AuthService>.value(
          value: _fakeAuthService,
        ),
      ],
      child: const WelcomeScreen(),
    );
  }
}
