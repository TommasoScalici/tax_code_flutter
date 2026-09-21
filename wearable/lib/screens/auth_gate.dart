import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared/services/auth_service.dart';
import 'package:tax_code_flutter_wear_os/core/theme/wear_colors.dart';
import 'package:tax_code_flutter_wear_os/core/theme/wear_dimensions.dart';
import 'package:tax_code_flutter_wear_os/core/theme/wear_typography.dart';
import 'package:tax_code_flutter_wear_os/l10n/app_localizations.dart';
import 'package:tax_code_flutter_wear_os/screens/home_page.dart';
import 'package:tax_code_flutter_wear_os/services/demo_mode_service.dart';

/// Acts as a gate, showing HomePage if the user is signed in or in demo mode,
/// otherwise showing the login screen.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key, this.homePage = const HomePage()});

  final Widget homePage;

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();
    DemoModeServiceAbstract? demoModeService;
    try {
      demoModeService = context.watch<DemoModeServiceAbstract>();
    } on Object {
      // Safe fallback if DemoModeServiceAbstract is not in the widget tree in testing
    }

    if (demoModeService?.isDemoMode ?? false) {
      return homePage;
    }

    switch (authService.status) {
      case AuthStatus.authenticated:
        return homePage;

      case AuthStatus.unauthenticated:
        return const _LoginView();

      case AuthStatus.initializing:
        return const Scaffold(
          backgroundColor: AppColors.darkBackground,
          body: Center(
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: AppColors.emeraldPrimary,
            ),
          ),
        );
    }
  }
}

/// The private widget that builds the actual login UI on Wear OS.
class _LoginView extends StatefulWidget {
  const _LoginView();

  @override
  State<_LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<_LoginView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onPointerSignal(PointerSignalEvent event) {
    if (event is PointerScrollEvent && _scrollController.hasClients) {
      final target = (_scrollController.offset + event.scrollDelta.dy)
          .clamp(0.0, _scrollController.position.maxScrollExtent);
      _scrollController.jumpTo(target);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();
    final l10n = AppLocalizations.of(context)!;
    final errorColor = Theme.of(context).colorScheme.error;

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: Listener(
        onPointerSignal: _onPointerSignal,
        child: SingleChildScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: WearDimensions.listPadding,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Emerald Ledger Badge Icon
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.emeraldContainerDark.withValues(alpha: 0.35),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.emeraldPrimary.withValues(alpha: 0.4),
                    width: 0.8,
                  ),
                ),
                child: const Icon(
                  Icons.badge_rounded,
                  size: 18,
                  color: AppColors.emeraldLight,
                ),
              ),
              const SizedBox(height: 6),

              Text(
                l10n.welcomeMessage(l10n.appTitle),
                textAlign: TextAlign.center,
                style: WearTypography.cardTitle(),
              ),
              const SizedBox(height: 10),

              SizedBox(
                height: WearDimensions.buttonCompactHeight,
                child: ElevatedButton.icon(
                  onPressed: authService.isLoading
                      ? null
                      : () => context
                            .read<AuthService>()
                            .signInWithGoogleForWearable(),
                  icon: const Icon(Icons.login, size: 16),
                  label: Text(
                    l10n.signInWithGoogle,
                    style: WearTypography.hint(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.darkSurfaceContainerHigh,
                    foregroundColor: AppColors.darkOnSurface,
                    shape: const StadiumBorder(),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    side: BorderSide(
                      color: AppColors.darkOutline.withValues(alpha: 0.3),
                      width: 0.8,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 6),

              SizedBox(
                height: WearDimensions.buttonCompactHeight,
                child: OutlinedButton.icon(
                  onPressed: authService.isLoading
                      ? null
                      : () {
                          try {
                            context
                                .read<DemoModeServiceAbstract>()
                                .enableDemoMode();
                          } on Object {
                            // Safe fallback
                          }
                        },
                  icon: const Icon(
                    Icons.visibility_outlined,
                    size: 15,
                    color: AppColors.emeraldLight,
                  ),
                  label: Text(
                    l10n.demoMode,
                    style: WearTypography.hint(color: AppColors.darkOnSurface),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.darkOnSurface,
                    side: BorderSide(
                      color: AppColors.emeraldPrimary.withValues(alpha: 0.4),
                      width: 0.8,
                    ),
                    shape: const StadiumBorder(),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                ),
              ),
              if (authService.isLoading) ...[
                const SizedBox(height: 10),
                const SizedBox(
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: AppColors.emeraldPrimary,
                  ),
                ),
              ],

              if (authService.errorMessage != null) ...[
                const SizedBox(height: 8),
                Text(
                  l10n.loginError,
                  textAlign: TextAlign.center,
                  style: WearTypography.hint(color: errorColor),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
