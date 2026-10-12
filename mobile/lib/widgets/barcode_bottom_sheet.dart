import 'dart:async';

import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:shared/models/contact.dart';
import 'package:tax_code_flutter/core/theme/app_colors.dart';
import 'package:tax_code_flutter/core/theme/app_dimensions.dart';
import 'package:tax_code_flutter/l10n/l10n.dart';
import 'package:tax_code_flutter/services/brightness_service.dart';
import 'package:tax_code_flutter/widgets/barcode/barcode_action_buttons.dart';
import 'package:tax_code_flutter/widgets/barcode/barcode_header.dart';
import 'package:tax_code_flutter/widgets/barcode/optical_code_display.dart';
import 'package:tax_code_flutter/widgets/share/share_contact_bottom_sheet.dart';

export 'barcode/barcode_action_buttons.dart';
export 'barcode/barcode_header.dart';
export 'barcode/optical_code_display.dart';

/// Modal bottom sheet orchestrating 1D Barcode (Code 128) and 2D QR Code presentation.
///
/// Features automatic screen brightness boost, haptic feedback on copy,
/// and responsive layout constraints conforming to the Stitch design specifications.
class BarcodeBottomSheet extends StatefulWidget {
  /// The contact whose tax code is being visualized.
  final Contact contact;

  /// Optional injected brightness service. Defaults to reading from [BuildContext].
  final BrightnessServiceAbstract? brightnessService;

  const BarcodeBottomSheet({
    super.key,
    required this.contact,
    this.brightnessService,
  });

  /// Displays the [BarcodeBottomSheet] within a modal sheet.
  static Future<void> show(
    BuildContext context, {
    required Contact contact,
    BrightnessServiceAbstract? brightnessService,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: false,
      backgroundColor: AppColors.transparent,
      barrierColor: AppColors.modalBarrier,
      builder: (_) => BarcodeBottomSheet(
        contact: contact,
        brightnessService: brightnessService,
      ),
    );
  }

  @override
  State<BarcodeBottomSheet> createState() => _BarcodeBottomSheetState();
}

class _BarcodeBottomSheetState extends State<BarcodeBottomSheet> {
  BrightnessServiceAbstract? _brightnessService;

  @override
  void initState() {
    super.initState();
    _brightnessService =
        widget.brightnessService ?? context.read<BrightnessServiceAbstract?>();
    unawaited(_brightnessService?.setMaxBrightness());
  }

  @override
  void dispose() {
    unawaited(_brightnessService?.resetBrightness());
    super.dispose();
  }

  Future<void> _copyTaxCode(
    BuildContext context,
    String taxCode,
    String message,
  ) async {
    await Clipboard.setData(ClipboardData(text: taxCode));
    await HapticFeedback.lightImpact();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = context.l10n;
    final isDark = theme.brightness == Brightness.dark;

    final sheetBgColor = isDark
        ? colorScheme.surfaceContainer
        : colorScheme.surfaceContainerLow;

    final topBorderColor = colorScheme.outlineVariant.withValues(
      alpha: isDark ? AppOpacity.outline : AppOpacity.muted,
    );

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: AppDimensions.maxContentWidth),
        child: Container(
          decoration: BoxDecoration(
            color: sheetBgColor,
            borderRadius: AppRadii.borderSheet,
            border: Border(top: BorderSide(color: topBorderColor)),
            boxShadow: [
              AppColors.shadowSheet(isDark),
            ],
          ),
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.card,
                AppSpacing.md,
                AppSpacing.card,
                AppSpacing.xl,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // M3 Drag Handle
                  Center(
                    child: Container(
                      width: AppDimensions.dragHandleWidth,
                      height: AppDimensions.dragHandleHeight,
                      decoration: BoxDecoration(
                        color: colorScheme.onSurfaceVariant.withValues(
                          alpha: AppOpacity.outline,
                        ),
                        borderRadius: AppRadii.borderHandle,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Header Area: User name, Tax Code Pill & Copy Button
                  BarcodeHeader(
                    contact: widget.contact,
                    onCopy: () => unawaited(
                      _copyTaxCode(
                        context,
                        widget.contact.taxCode,
                        l10n.taxCodeCopied,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // High-Contrast Pure White Optical Container
                  OpticalCodeDisplay(taxCode: widget.contact.taxCode),
                  const SizedBox(height: AppSpacing.lg),

                  // Notice Text
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        size: AppDimensions.iconSm,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: AppSpacing.badgeGap),
                      Flexible(
                        child: Text(
                          l10n.barcodeNotice,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.compact),

                  // Brightness Auto Indicator Pill
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.badgeGap,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? colorScheme.surfaceContainerHigh
                          : colorScheme.surfaceContainerHighest.withValues(
                              alpha: AppOpacity.divider,
                            ),
                      borderRadius: AppRadii.borderCard,
                      border: Border.all(
                        color: colorScheme.outlineVariant.withValues(
                          alpha: AppOpacity.outline,
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.wb_sunny_rounded,
                          size: AppDimensions.iconSm,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(width: AppSpacing.badgeGap),
                        Flexible(
                          child: Text(
                            l10n.barcodeMaxBrightnessActive,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Action Buttons Row: Close & Share
                  BarcodeActionButtons(
                    onClose: () => Navigator.pop(context),
                    onShare: () {
                      unawaited(
                        ShareContactBottomSheet.show(
                          context,
                          contact: widget.contact,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
