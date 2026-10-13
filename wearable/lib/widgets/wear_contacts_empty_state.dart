import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:shared/theme/app_dimensions.dart';
import 'package:tax_code_flutter_wear_os/core/theme/wear_colors.dart';
import 'package:tax_code_flutter_wear_os/core/theme/wear_dimensions.dart';
import 'package:tax_code_flutter_wear_os/core/theme/wear_typography.dart';
import 'package:tax_code_flutter_wear_os/l10n/app_localizations.dart';
import 'package:tax_code_flutter_wear_os/widgets/wear_scrollbar.dart';
import 'package:tax_code_flutter_wear_os/widgets/wear_time_header.dart';

/// Empty state display for Wear OS when no contacts are present.
///
/// Features a rotary-aware scrollable container, explanation message,
/// and buttons to open companion phone app or sign out.
class WearContactsEmptyState extends StatelessWidget {
  const WearContactsEmptyState({
    required this.scrollController,
    required this.onPointerSignal,
    required this.isLaunchingPhoneApp,
    required this.isDemoMode,
    required this.onOpenOnPhone,
    required this.onAuthAction,
    super.key,
  });

  /// The scroll controller tracking bezel / touch scroll.
  final ScrollController scrollController;

  /// Pointer signal handler for rotary crown input.
  final void Function(PointerSignalEvent) onPointerSignal;

  /// Whether the phone app is currently being launched.
  final bool isLaunchingPhoneApp;

  /// Whether the app is currently running in demo mode.
  final bool isDemoMode;

  /// Callback to trigger launching the phone companion app.
  final VoidCallback onOpenOnPhone;

  /// Callback to exit demo mode or sign out.
  final VoidCallback onAuthAction;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Listener(
      onPointerSignal: onPointerSignal,
      child: WearScrollbar(
        controller: scrollController,
        child: SingleChildScrollView(
          controller: scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: WearDimensions.listPadding,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const WearTimeHeader(),
              const SizedBox(height: AppSpacing.sm),
              Container(
                width: WearDimensions.buttonHeight,
                height: WearDimensions.buttonHeight,
                decoration: BoxDecoration(
                  color: AppColors.emeraldContainerDark.withValues(
                    alpha: AppOpacity.subtleBorder,
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.credit_card_off_rounded,
                  size: WearDimensions.iconLarge,
                  color: AppColors.emeraldLight,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                l10n.noContactsFoundMessage,
                textAlign: TextAlign.center,
                style: WearTypography.cardSubtitle(
                  color: AppColors.darkOnSurface,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                l10n.syncTakesFewMinutes,
                textAlign: TextAlign.center,
                style: WearTypography.hint(
                  color: AppColors.darkOnSurfaceVariant.withValues(
                    alpha: AppOpacity.high,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.compact),
              if (isLaunchingPhoneApp)
                const SizedBox(
                  height: AppDimensions.iconLg,
                  width: AppDimensions.iconLg,
                  child: CircularProgressIndicator(
                    strokeWidth: WearDimensions.progressStrokeWidth,
                    color: AppColors.emeraldPrimary,
                  ),
                )
              else
                ConstrainedBox(
                  constraints: const BoxConstraints(
                    minHeight: WearDimensions.buttonCompactHeight,
                  ),
                  child: ElevatedButton.icon(
                    icon: const Icon(
                      Icons.phone_android,
                      size: AppDimensions.iconSm,
                    ),
                    label: Text(
                      l10n.openOnPhone,
                      style: WearTypography.hint(
                        color: AppColors.onEmeraldAccent,
                      ),
                    ),
                    onPressed: onOpenOnPhone,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.emeraldPrimary,
                      foregroundColor: AppColors.onEmeraldAccent,
                      shape: const StadiumBorder(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: WearDimensions.screenPaddingHorizontal,
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: AppSpacing.sm),
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
                    isDemoMode ? l10n.exitDemo : l10n.logout,
                    style: WearTypography.hint(
                      color: AppColors.darkOnSurfaceVariant,
                    ),
                  ),
                  onPressed: onAuthAction,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
