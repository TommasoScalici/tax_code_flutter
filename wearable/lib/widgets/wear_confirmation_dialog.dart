import 'package:flutter/material.dart';
import 'package:tax_code_flutter_wear_os/core/theme/wear_colors.dart';
import 'package:tax_code_flutter_wear_os/core/theme/wear_dimensions.dart';
import 'package:tax_code_flutter_wear_os/core/theme/wear_typography.dart';

/// Displays a high-contrast Wear OS confirmation dialog with check and close action buttons.
Future<bool?> showWearConfirmationDialog({
  required BuildContext context,
  required String title,
}) {
  return showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: AppColors.darkSurfaceContainerHigh,
      shape: const RoundedRectangleBorder(
        borderRadius: WearDimensions.borderDialog,
      ),
      insetPadding: WearDimensions.dialogInsetPadding,
      titlePadding: WearDimensions.dialogTitlePadding,
      actionsPadding: WearDimensions.dialogActionsPadding,
      title: Text(
        title,
        style: WearTypography.cardTitle(),
        textAlign: TextAlign.center,
      ),
      actionsAlignment: MainAxisAlignment.spaceEvenly,
      actions: [
        SizedBox(
          width: WearDimensions.dialogButtonSize,
          height: WearDimensions.dialogButtonSize,
          child: IconButton(
            padding: EdgeInsets.zero,
            icon: const Icon(
              Icons.close_rounded,
              size: WearDimensions.dialogActionIconSize,
              color: AppColors.darkOnSurfaceVariant,
            ),
            onPressed: () => Navigator.of(ctx).pop(false),
          ),
        ),
        SizedBox(
          width: WearDimensions.dialogButtonSize,
          height: WearDimensions.dialogButtonSize,
          child: IconButton(
            padding: EdgeInsets.zero,
            icon: const Icon(
              Icons.check_rounded,
              size: WearDimensions.dialogActionIconSize,
              color: AppColors.emeraldLight,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
          ),
        ),
      ],
    ),
  );
}
