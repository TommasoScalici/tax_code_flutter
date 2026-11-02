import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:tax_code_flutter_wear_os/core/theme/wear_colors.dart';
import 'package:tax_code_flutter_wear_os/core/theme/wear_dimensions.dart';
import 'package:tax_code_flutter_wear_os/core/theme/wear_typography.dart';
import 'package:tax_code_flutter_wear_os/widgets/previews/wear_preview_shell.dart';
import 'package:tax_code_flutter_wear_os/widgets/wear_confirmation_dialog.dart';

/// Interactive preview for [showWearConfirmationDialog] on Wear OS displays.
class WearConfirmationDialogPreview extends StatefulWidget {
  @Preview(name: 'Wear Confirmation Dialog')
  const WearConfirmationDialogPreview({super.key});

  @override
  State<WearConfirmationDialogPreview> createState() =>
      _WearConfirmationDialogPreviewState();
}

class _WearConfirmationDialogPreviewState
    extends State<WearConfirmationDialogPreview> {
  String? _lastActionResult;
  String _dialogTitle = 'Confermi il logout?';

  @override
  Widget build(BuildContext context) {
    return WearPreviewShell(
      toolbarActions: (ctx, isRound) => [
        ActionChip(
          label: Text(
            _dialogTitle.contains('logout') ? 'Title: Logout' : 'Title: Demo',
            style: const TextStyle(fontSize: 12),
          ),
          onPressed: () {
            setState(() {
              _dialogTitle = _dialogTitle.contains('logout')
                  ? 'Uscire dalla demo?'
                  : 'Confermi il logout?';
            });
          },
        ),
        if (_lastActionResult != null)
          Chip(
            label: Text(
              _lastActionResult!,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.emeraldLight,
              ),
            ),
            backgroundColor: const Color(0xFF0F172A),
          ),
      ],
      builder: (context, isRound) {
        return Scaffold(
          backgroundColor: AppColors.darkBackground,
          body: Center(
            child: AlertDialog(
              backgroundColor: AppColors.darkSurfaceContainerHigh,
              shape: const RoundedRectangleBorder(
                borderRadius: WearDimensions.borderDialog,
              ),
              insetPadding: WearDimensions.dialogInsetPadding,
              titlePadding: WearDimensions.dialogTitlePadding,
              actionsPadding: WearDimensions.dialogActionsPadding,
              title: Text(
                _dialogTitle,
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
                    onPressed: () {
                      setState(() {
                        _lastActionResult = 'Dismissed (False)';
                      });
                    },
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
                    onPressed: () {
                      setState(() {
                        _lastActionResult = 'Confirmed (True)';
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
