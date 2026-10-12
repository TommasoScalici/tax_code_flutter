import 'dart:async';

import 'package:flutter_svg/flutter_svg.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:shared/services/auth_service.dart';
import 'package:shared/utils/error_mapper.dart';
import 'package:tax_code_flutter/core/theme/app_dimensions.dart';
import 'package:tax_code_flutter/l10n/l10n.dart';
import 'package:tax_code_flutter/utils/app_failure_l10n.dart';
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
      final failure = ErrorMapper.fromKey(authService.errorKey);
      final message = failure.toLocalizedMessage(l10n);
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
      final failure = ErrorMapper.fromKey(authService.errorKey);
      final message = failure.toLocalizedMessage(l10n);
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
          maxWidth: AppDimensions.maxWelcomeWidth,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.lg),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: AppSpacing.lg),

                  // App Icon (Clean brand card graphic)
                  SvgPicture.asset(
                    'assets/images/tax_code_icon.svg',
                    width: AppDimensions.heroLogo,
                    height: AppDimensions.heroLogo,
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Headline
                  Text(
                    l10n.welcomeTitle,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineLarge?.copyWith(
                      letterSpacing: AppLetterSpacing.headlineTight,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Subtitle
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: AppDimensions.maxSubtitleWidth),
                    child: Text(
                      l10n.welcomeSubtitle,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        height: AppLineHeights.relaxed,
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xxl),

                  // Primary Action: Google SSO Pill
                  SizedBox(
                    width: double.infinity,
                    height: AppDimensions.heroButtonHeight,
                    child: ElevatedButton(
                      onPressed: isLoading
                          ? null
                          : () => _handleGoogleSignIn(context, authService),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark
                            ? colorScheme.surfaceContainerHigh
                            : colorScheme.surface,
                        foregroundColor: colorScheme.onSurface,
                        elevation: isDark ? AppElevation.none : AppElevation.level1,
                        shadowColor: colorScheme.shadow.withValues(alpha: AppOpacity.glow),
                        shape: const StadiumBorder(),
                        side: BorderSide(
                          color: isDark
                              ? colorScheme.outlineVariant.withValues(alpha: AppOpacity.medium)
                              : colorScheme.outline.withValues(alpha: AppOpacity.outline),
                        ),
                      ),
                      child: isLoading
                          ? SizedBox(
                              width: AppDimensions.iconButton,
                              height: AppDimensions.iconButton,
                              child: CircularProgressIndicator(
                                strokeWidth: AppDimensions.progressStrokeWidth,
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
                                  width: AppDimensions.iconButton,
                                  height: AppDimensions.iconButton,
                                ),
                                const SizedBox(width: AppSpacing.md),
                                Flexible(
                                  child: Text(
                                    l10n.continueWithGoogle,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.textTheme.labelLarge?.copyWith(
                                      fontSize: AppFontSizes.bodyLg,
                                      letterSpacing: AppLetterSpacing.micro,
                                      color: colorScheme.onSurface,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Secondary Action: Guest Mode Pill
                  SizedBox(
                    width: double.infinity,
                    height: AppDimensions.primaryButtonHeight,
                    child: OutlinedButton.icon(
                      onPressed: isLoading
                          ? null
                          : () => _handleGuestSignIn(context, authService),
                      icon: Icon(
                        Icons.person_outline_rounded,
                        size: AppDimensions.iconMd,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      label: Text(
                        l10n.continueAsGuest,
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontSize: AppFontSizes.input,
                          fontWeight: FontWeight.w500,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: colorScheme.outlineVariant.withValues(
                            alpha: isDark ? AppOpacity.muted : AppOpacity.outline,
                          ),
                        ),
                      ),
                    ),
                  ),

                      const SizedBox(height: AppSpacing.card),

                      // Footer: Terms & Disclaimer
                      Text(
                        l10n.termsAndCondition,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant.withValues(alpha: AppOpacity.medium),
                          fontSize: AppFontSizes.bodySm,
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
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                        ),
                        child: Text(
                          l10n.showTerms,
                          style: theme.textTheme.labelMedium?.copyWith(
                            fontSize: AppFontSizes.titleSm,
                            fontWeight: FontWeight.w500,
                            color: colorScheme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                    ],
                  ),
                ),
              ),
            ),
          ),
      );
    }
  }
