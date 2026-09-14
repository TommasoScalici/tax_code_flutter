import 'dart:async';

import 'package:flutter_svg/flutter_svg.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:shared/services/auth_service.dart';
import 'package:tax_code_flutter/l10n/app_localizations.dart';
import 'package:tax_code_flutter/l10n/app_localizations_it.dart';
import 'package:tax_code_flutter/widgets/profile_bottom_sheet.dart';
import 'package:tax_code_flutter/widgets/responsive_layout.dart';

///
/// The Welcome and Login Screen following the Emerald Ledger design system.
/// Allows users to authenticate via Google SSO or proceed directly in Guest Mode.
///
class WelcomeScreen extends StatelessWidget {
  /// Optional callbacks for dependency injection and testing.
  final VoidCallback? onGoogleSignIn;
  final VoidCallback? onGuestContinue;

  const WelcomeScreen({
    super.key,
    this.onGoogleSignIn,
    this.onGuestContinue,
  });

  Future<void> _handleGoogleSignIn(
    BuildContext context,
    AuthService authService,
  ) async {
    if (onGoogleSignIn != null) {
      onGoogleSignIn!();
      return;
    }

    final success = await authService.signInWithGoogle();
    if (!context.mounted) return;

    if (!success && authService.errorMessage != null) {
      final l10n = AppLocalizations.of(context) ?? AppLocalizationsIt();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authService.errorMessage ?? l10n.signInFailed),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _handleGuestSignIn(
    BuildContext context,
    AuthService authService,
  ) async {
    if (onGuestContinue != null) {
      onGuestContinue!();
      return;
    }

    final success = await authService.signInAnonymously();
    if (!context.mounted) return;

    if (!success && authService.errorMessage != null) {
      final l10n = AppLocalizations.of(context) ?? AppLocalizationsIt();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authService.errorMessage ?? l10n.signInFailed),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context) ?? AppLocalizationsIt();
    final isDark = theme.brightness == Brightness.dark;
    final authService = context.watch<AuthService>();
    final isLoading = authService.isLoading;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Background Atmospheric Radial Glows
          Positioned(
            top: -80,
            left: 0,
            right: 0,
            child: IgnorePointer(
              child: Center(
                child: Container(
                  width: 320,
                  height: 320,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        colorScheme.primary.withValues(alpha: isDark ? 0.12 : 0.08),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -60,
            right: -60,
            child: IgnorePointer(
              child: Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      colorScheme.primary.withValues(alpha: isDark ? 0.08 : 0.05),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Main Content
          SafeArea(
            child: ResponsiveLayout(
              maxWidth: 480.0,
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 16),

                      // App Icon
                      Container(
                        width: 104,
                        height: 104,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24.0),
                          boxShadow: [
                            BoxShadow(
                              color: colorScheme.shadow.withValues(alpha: 0.18),
                              blurRadius: 24,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24.0),
                          child: SvgPicture.asset(
                            'assets/images/tax_code_icon.svg',
                          ),
                        ),
                      ),
                      const SizedBox(height: 36),

                      // Headline
                      Text(
                        l10n.welcomeTitle,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.headlineLarge?.copyWith(
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Subtitle
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 320),
                        child: Text(
                          l10n.welcomeSubtitle,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            height: 1.45,
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Primary Action: Google SSO Pill
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: isLoading
                              ? null
                              : () => _handleGoogleSignIn(context, authService),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isDark
                                ? colorScheme.onSurface
                                : colorScheme.surface,
                            foregroundColor: isDark
                                ? colorScheme.surface
                                : colorScheme.onSurface,
                            elevation: 2,
                            shadowColor: colorScheme.shadow.withValues(alpha: 0.2),
                            shape: const StadiumBorder(),
                            side: isDark
                                ? BorderSide.none
                                : BorderSide(
                                    color: colorScheme.outline.withValues(alpha: 0.4),
                                  ),
                          ),
                          child: isLoading
                              ? SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      isDark
                                          ? colorScheme.surface
                                          : colorScheme.primary,
                                    ),
                                  ),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SvgPicture.asset(
                                      'assets/images/google_logo.svg',
                                      width: 22,
                                      height: 22,
                                    ),
                                    const SizedBox(width: 12),
                                    Flexible(
                                      child: Text(
                                        l10n.continueWithGoogle,
                                        overflow: TextOverflow.ellipsis,
                                        style: theme.textTheme.labelLarge?.copyWith(
                                          fontSize: 16,
                                          letterSpacing: 0.1,
                                          color: isDark
                                              ? colorScheme.surface
                                              : colorScheme.onSurface,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Secondary Action: Guest Mode Pill
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: OutlinedButton.icon(
                          onPressed: isLoading
                              ? null
                              : () => _handleGuestSignIn(context, authService),
                          icon: Icon(
                            Icons.person_outline_rounded,
                            size: 20,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          label: Text(
                            l10n.continueAsGuest,
                            style: theme.textTheme.labelLarge?.copyWith(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: colorScheme.outline.withValues(alpha: 0.25),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Footer: Terms & Disclaimer
                      Text(
                        l10n.termsAndCondition,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                          fontSize: 12,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          unawaited(
                            ProfileBottomSheet.show<void>(
                              context,
                              startAtAppInfo: true,
                            ),
                          );
                        },
                        style: TextButton.styleFrom(
                          visualDensity: VisualDensity.compact,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                        child: Text(
                          l10n.showTerms,
                          style: theme.textTheme.labelMedium?.copyWith(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: colorScheme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
