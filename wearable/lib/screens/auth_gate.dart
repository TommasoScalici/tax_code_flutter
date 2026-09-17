import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared/services/auth_service.dart';
import 'package:tax_code_flutter_wear_os/core/theme/wear_colors.dart';
import 'package:tax_code_flutter_wear_os/core/theme/wear_dimensions.dart';
import 'package:tax_code_flutter_wear_os/core/theme/wear_typography.dart';
import 'package:tax_code_flutter_wear_os/l10n/app_localizations.dart';
import 'package:tax_code_flutter_wear_os/screens/home_page.dart';

/// Acts as a gate, showing HomePage if the user is signed in,
/// otherwise showing the login screen.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key, this.homePage = const HomePage()});

  final Widget homePage;

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();

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
class _LoginView extends StatelessWidget {
  const _LoginView();

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();
    final l10n = AppLocalizations.of(context)!;
    final errorColor = Theme.of(context).colorScheme.error;

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: WearDimensions.screenPaddingHorizontal,
            vertical: WearDimensions.screenPaddingTop,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Emerald Ledger Badge Icon
              Container(
                width: 36,
                height: 36,
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
                  size: 20,
                  color: AppColors.emeraldLight,
                ),
              ),
              const SizedBox(height: 8),

              Text(
                l10n.welcomeMessage(l10n.appTitle),
                textAlign: TextAlign.center,
                style: WearTypography.cardTitle(),
              ),
              const SizedBox(height: 12),

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
              if (authService.isLoading) ...[
                const SizedBox(height: 12),
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
