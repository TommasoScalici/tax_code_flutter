import 'dart:async';

import 'package:flutter_svg/flutter_svg.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:shared/services/auth_service.dart';
import 'package:tax_code_flutter/l10n/l10n.dart';
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

    if (!success && authService.errorKey != null) {
      final l10n = context.l10n;
      final message = switch (authService.errorKey) {
        'networkError' => l10n.networkError,
        'reauthFailed' => l10n.reauthFailed,
        _ => l10n.signInFailed,
      };
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
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

    if (!success && authService.errorKey != null) {
      final l10n = context.l10n;
      final message = switch (authService.errorKey) {
        'networkError' => l10n.networkError,
        _ => l10n.signInFailed,
      };
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = context.l10n;
    final isDark = theme.brightness == Brightness.dark;
    final authService = context.watch<AuthService>();
    final isLoading = authService.isLoading;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
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

                  // App Icon (Clean brand card graphic)
                  SvgPicture.asset(
                    'assets/images/tax_code_icon.svg',
                    width: 120,
                    height: 120,
                  ),
                  const SizedBox(height: 24),

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
                            ? colorScheme.surfaceContainerHigh
                            : colorScheme.surface,
                        foregroundColor: colorScheme.onSurface,
                        elevation: isDark ? 0 : 2,
                        shadowColor: colorScheme.shadow.withValues(alpha: 0.2),
                        shape: const StadiumBorder(),
                        side: BorderSide(
                          color: isDark
                              ? colorScheme.outlineVariant.withValues(alpha: 0.7)
                              : colorScheme.outline.withValues(alpha: 0.4),
                        ),
                      ),
                      child: isLoading
                          ? SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  colorScheme.primary,
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
                                      color: colorScheme.onSurface,
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
                          color: colorScheme.onSurface,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: colorScheme.outlineVariant.withValues(
                            alpha: isDark ? 0.6 : 0.4,
                          ),
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
      );
    }
  }
