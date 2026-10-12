import 'package:flutter/material.dart';
import 'package:shared/theme/app_dimensions.dart';
import 'package:tax_code_flutter_wear_os/core/theme/wear_colors.dart';
import 'package:tax_code_flutter_wear_os/core/theme/wear_dimensions.dart';
import 'package:tax_code_flutter_wear_os/core/theme/wear_typography.dart';
import 'package:tax_code_flutter_wear_os/widgets/wear_time_header.dart';

/// Top header for the Wear OS contacts list, displaying current time and an optional DEMO mode badge.
class WearContactsListHeader extends StatelessWidget {
  const WearContactsListHeader({
    required this.isDemoMode,
    this.demoBadgeLabel,
    super.key,
  });

  /// Whether the controller is in demo mode.
  final bool isDemoMode;

  /// Localized text for the demo mode badge.
  final String? demoBadgeLabel;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const WearTimeHeader(),
        if (isDemoMode && demoBadgeLabel != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xxs,
            ),
            decoration: BoxDecoration(
              color: AppColors.emeraldContainerDark.withValues(
                alpha: AppOpacity.disabled,
              ),
              borderRadius: WearDimensions.borderPill,
              border: Border.all(
                color: AppColors.emeraldPrimary.withValues(alpha: AppOpacity.divider),
                width: WearDimensions.borderThin,
              ),
            ),
            child: Text(
              demoBadgeLabel!,
              style: WearTypography.codeDisplayCard(
                color: AppColors.emeraldLight,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
        ],
      ],
    );
  }
}
