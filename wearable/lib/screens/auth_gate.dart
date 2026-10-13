import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared/services/auth_service.dart';
import 'package:shared/theme/app_dimensions.dart';
import 'package:tax_code_flutter_wear_os/core/theme/wear_colors.dart';
import 'package:tax_code_flutter_wear_os/core/theme/wear_dimensions.dart';
import 'package:tax_code_flutter_wear_os/core/theme/wear_typography.dart';
import 'package:tax_code_flutter_wear_os/l10n/app_localizations.dart';
import 'package:tax_code_flutter_wear_os/screens/home_page.dart';
import 'package:tax_code_flutter_wear_os/services/demo_mode_service.dart';
import 'package:tax_code_flutter_wear_os/widgets/wear_scrollbar.dart';
import 'package:tax_code_flutter_wear_os/widgets/wear_time_header.dart';

/// Acts as a gate, showing HomePage if the user is signed in or in demo mode,
/// otherwise showing the login screen.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key, this.homePage = const HomePage()});

  final Widget homePage;

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();
    final demoModeService = context.watch<DemoModeService?>();

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
              strokeWidth: WearDimensions.progressStrokeWidth,
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
      final target = (_scrollController.offset + event.scrollDelta.dy).clamp(
        0.0,
        _scrollController.position.maxScrollExtent,
      );
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
        child: WearScrollbar(
          controller: _scrollController,
          child: SingleChildScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: WearDimensions.listPadding,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Clock header
                const WearTimeHeader(),
                const SizedBox(height: AppSpacing.xs),

                // Emerald Ledger Badge Icon
                Container(
                  width: AppDimensions.iconXl,
                  height: AppDimensions.iconXl,
                  decoration: BoxDecoration(
                    color: AppColors.emeraldContainerDark.withValues(
                      alpha: AppOpacity.disabled,
                    ),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.emeraldPrimary.withValues(
                        alpha: AppOpacity.outline,
                      ),
                      width: WearDimensions.borderThin,
                    ),
                  ),
                  child: const Icon(
                    Icons.badge_rounded,
                    size: WearDimensions.iconMedium,
                    color: AppColors.emeraldLight,
                  ),
                ),
                const SizedBox(height: WearDimensions.cardSpacing),

                Text(
                  l10n.welcomeMessage(l10n.appTitle),
                  textAlign: TextAlign.center,
                  style: WearTypography.cardTitle(),
                ),
                const SizedBox(height: AppSpacing.compact),

                ConstrainedBox(
                  constraints: const BoxConstraints(
                    minHeight: WearDimensions.buttonCompactHeight,
                  ),
                  child: ElevatedButton.icon(
                    onPressed: authService.isLoading
                        ? null
                        : () => context
                              .read<AuthService>()
                              .signInWithGoogleForWearable(),
                    icon: const Icon(Icons.login, size: AppDimensions.iconSm),
                    label: Text(
                      l10n.signInWithGoogle,
                      style: WearTypography.hint(
                        color: AppColors.darkOnSurface,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.darkSurfaceContainerHigh,
                      foregroundColor: AppColors.darkOnSurface,
                      shape: const StadiumBorder(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: WearDimensions.screenPaddingHorizontal,
                      ),
                      side: BorderSide(
                        color: AppColors.darkOutline.withValues(
                          alpha: AppOpacity.translucent,
                        ),
                        width: WearDimensions.borderThin,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: WearDimensions.cardSpacing),

                ConstrainedBox(
                  constraints: const BoxConstraints(
                    minHeight: WearDimensions.buttonCompactHeight,
                  ),
                  child: OutlinedButton.icon(
                    onPressed: authService.isLoading
                        ? null
                        : () {
                            try {
                              context.read<DemoModeService>().enableDemoMode();
                            } on Object {
                              // Safe fallback
                            }
                          },
                    icon: const Icon(
                      Icons.visibility_outlined,
                      size: WearDimensions.iconSmall,
                      color: AppColors.emeraldLight,
                    ),
                    label: Text(
                      l10n.demoMode,
                      style: WearTypography.hint(
                        color: AppColors.darkOnSurface,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.darkOnSurface,
                      side: BorderSide(
                        color: AppColors.emeraldPrimary.withValues(
                          alpha: AppOpacity.outline,
                        ),
                        width: WearDimensions.borderThin,
                      ),
                      shape: const StadiumBorder(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                      ),
                    ),
                  ),
                ),
                if (authService.isLoading) ...[
                  const SizedBox(height: AppSpacing.compact),
                  const SizedBox(
                    height: AppDimensions.iconButton,
                    width: AppDimensions.iconButton,
                    child: CircularProgressIndicator(
                      strokeWidth: WearDimensions.progressStrokeWidth,
                      color: AppColors.emeraldPrimary,
                    ),
                  ),
                ],

                if (authService.errorMessage != null) ...[
                  const SizedBox(height: AppSpacing.sm),
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
      ),
    );
  }
}
