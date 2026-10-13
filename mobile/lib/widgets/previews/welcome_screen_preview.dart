import 'package:flutter/widget_previews.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:shared/services/auth_service.dart';
import 'package:shared/testing/fake_auth_service.dart';
import 'package:tax_code_flutter/screens/welcome_screen.dart';
import 'package:tax_code_flutter/widgets/previews/preview_shell.dart';

/// Standalone preview for [WelcomeScreen] with centered mobile viewport and theme toggle.
class WelcomeScreenPreview extends StatefulWidget {
  @Preview(name: 'Welcome Screen')
  const WelcomeScreenPreview({super.key});

  @override
  State<WelcomeScreenPreview> createState() => _WelcomeScreenPreviewState();
}

class _WelcomeScreenPreviewState extends State<WelcomeScreenPreview> {
  final _fakeAuthService = FakeAuthService.unauthenticated();

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
        ChangeNotifierProvider<AuthService>.value(value: _fakeAuthService),
      ],
      child: const WelcomeScreen(),
    );
  }
}
