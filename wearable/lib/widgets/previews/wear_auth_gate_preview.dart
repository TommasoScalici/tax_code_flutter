import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:provider/provider.dart';
import 'package:shared/services/auth_service.dart';
import 'package:tax_code_flutter_wear_os/screens/auth_gate.dart';
import 'package:tax_code_flutter_wear_os/services/demo_mode_service.dart';
import 'package:tax_code_flutter_wear_os/widgets/previews/wear_preview_fakes.dart';
import 'package:tax_code_flutter_wear_os/widgets/previews/wear_preview_shell.dart';

/// Interactive preview for [AuthGate] and the Wear OS login view.
class WearAuthGatePreview extends StatefulWidget {
  @Preview(name: 'Wear Login Screen')
  const WearAuthGatePreview({super.key});

  @override
  State<WearAuthGatePreview> createState() => _WearAuthGatePreviewState();
}

class _WearAuthGatePreviewState extends State<WearAuthGatePreview> {
  late final FakeWearAuthService _authService;
  late final DefaultDemoModeService _demoModeService;
  bool _isAuthLoading = false;

  @override
  void initState() {
    super.initState();
    _authService = FakeWearAuthService(status: AuthStatus.unauthenticated);
    _demoModeService = DefaultDemoModeService();
  }

  @override
  void dispose() {
    _authService.dispose();
    _demoModeService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WearPreviewShell(
      providers: [
        ChangeNotifierProvider<AuthService>.value(value: _authService),
        ChangeNotifierProvider<DemoModeService>.value(value: _demoModeService),
      ],
      toolbarActions: (ctx, isRound) => [
        ActionChip(
          label: Text(
            _isAuthLoading ? 'State: Loading' : 'State: Idle',
            style: const TextStyle(fontSize: 12),
          ),
          onPressed: () {
            setState(() {
              _isAuthLoading = !_isAuthLoading;
              _authService.setLoading(loading: _isAuthLoading);
            });
          },
        ),
      ],
      child: const AuthGate(),
    );
  }
}
