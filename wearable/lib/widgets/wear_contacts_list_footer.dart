import 'package:flutter/material.dart';
import 'package:shared/theme/app_dimensions.dart';
import 'package:tax_code_flutter_wear_os/core/theme/wear_colors.dart';
import 'package:tax_code_flutter_wear_os/core/theme/wear_dimensions.dart';
import 'package:tax_code_flutter_wear_os/core/theme/wear_typography.dart';

/// Trailing action footer rendered at the bottom of the Wear OS contacts list.
///
/// Provides quick action to open companion app on phone, and a secondary action
/// to either exit demo mode or sign out.
class WearContactsListFooter extends StatelessWidget {
  const WearContactsListFooter({
    required this.isDemoMode,
    required this.openOnPhoneLabel,
    required this.authActionLabel,
    required this.onOpenOnPhone,
    required this.onAuthAction,
    super.key,
  });

  /// Whether the controller is in demo mode.
  final bool isDemoMode;

  /// Label for the companion phone app button.
  final String openOnPhoneLabel;

  /// Label for the exit demo or sign out button.
  final String authActionLabel;

  /// Callback when the phone button is pressed.
  final VoidCallback onOpenOnPhone;

  /// Callback when the sign out / exit demo button is pressed.
  final VoidCallback onAuthAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm, bottom: AppSpacing.md),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: WearDimensions.buttonCompactHeight,
            ),
            child: OutlinedButton.icon(
              icon: const Icon(Icons.phone_android, size: WearDimensions.iconSmall),
              label: Text(
                openOnPhoneLabel,
                style: WearTypography.hint(
                  color: AppColors.darkOnSurface,
                ),
              ),
              onPressed: onOpenOnPhone,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.darkOnSurfaceVariant,
                side: BorderSide(
                  color: AppColors.darkOutline.withValues(alpha: AppOpacity.translucent),
                  width: WearDimensions.borderThin,
                ),
                shape: const StadiumBorder(),
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              ),
            ),
          ),
          const SizedBox(height: WearDimensions.cardSpacing),
          ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: WearDimensions.buttonCompactHeight,
            ),
            child: TextButton.icon(
              icon: const Icon(
                Icons.logout_rounded,
                size: WearDimensions.iconSmall,
                color: AppColors.darkOnSurfaceVariant,
              ),
              label: Text(
                authActionLabel,
                style: WearTypography.hint(color: AppColors.darkOnSurfaceVariant),
              ),
              onPressed: onAuthAction,
            ),
          ),
        ],
      ),
    );
  }
}
