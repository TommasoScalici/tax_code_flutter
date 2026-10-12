import 'dart:async';

import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/services.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:shared/models/contact.dart';
import 'package:tax_code_flutter/core/theme/app_colors.dart';
import 'package:tax_code_flutter/core/theme/app_dimensions.dart';
import 'package:tax_code_flutter/core/theme/app_typography.dart';
import 'package:tax_code_flutter/l10n/l10n.dart';
import 'package:tax_code_flutter/services/brightness_service.dart';
import 'package:tax_code_flutter/widgets/share/share_contact_bottom_sheet.dart';

/// Modal bottom sheet displaying high-contrast 1D Barcode (Code 128) and 2D QR Code
/// for the Italian Tax Code, strictly styled according to the Stitch design specifications.
///
/// Features automatic screen brightness optimization via [BrightnessServiceAbstract],
/// instant tap-to-copy action, and clean typography.
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
      alpha: isDark ? 0.40 : 0.60,
    );

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Container(
          decoration: BoxDecoration(
            color: sheetBgColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border(top: BorderSide(color: topBorderColor)),
            boxShadow: [
              AppColors.shadowSheet(isDark),
            ],
          ),
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // M3 Drag Handle
                  Center(
                    child: Container(
                      width: 40,
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
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withValues(
                            alpha: isDark ? AppOpacity.semiTranslucent : AppOpacity.faint,
                          ),
                          borderRadius: AppRadii.borderInner,
                          border: Border.all(
                            color: colorScheme.primary.withValues(alpha: AppOpacity.translucent),
                          ),
                        ),
                        child: Icon(
                          Icons.badge_rounded,
                          color: colorScheme.primary,
                          size: AppDimensions.iconButton,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${widget.contact.firstName} ${widget.contact.lastName}',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.badgeGap),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.sm,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: colorScheme.primary.withValues(
                                      alpha: isDark ? AppOpacity.semiTranslucent : AppOpacity.tint,
                                    ),
                                    borderRadius: AppRadii.borderBadge,
                                    border: Border.all(
                                      color: colorScheme.primary.withValues(
                                        alpha: AppOpacity.disabled,
                                      ),
                                    ),
                                  ),
                                  child: Text(
                                    widget.contact.taxCode,
                                    style: AppTypography.codeDisplay(
                                      color: colorScheme.primary,
                                      fontSize: 13,
                                      letterSpacing: 1.1,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                InkWell(
                                  key: const Key(
                                    'barcode_bottom_sheet_copy_button',
                                  ),
                                  onTap: () => unawaited(
                                    _copyTaxCode(
                                      context,
                                      widget.contact.taxCode,
                                      l10n.taxCodeCopied,
                                    ),
                                  ),
                                  borderRadius: AppRadii.borderCard,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: AppSpacing.compact,
                                      vertical: AppSpacing.xs,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? colorScheme.surfaceContainerHighest
                                          : colorScheme.surfaceContainerHighest
                                                .withValues(alpha: AppOpacity.muted),
                                      borderRadius: AppRadii.borderCard,
                                      border: Border.all(
                                        color: colorScheme.outlineVariant
                                            .withValues(
                                              alpha: AppOpacity.divider,
                                            ),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.copy_rounded,
                                          size: AppDimensions.iconXs,
                                          color: colorScheme.primary,
                                        ),
                                        const SizedBox(width: AppSpacing.xs),
                                        Text(
                                          l10n.copyAction,
                                          style: theme.textTheme.labelSmall
                                              ?.copyWith(
                                                fontWeight: FontWeight.w600,
                                                color: colorScheme.onSurface,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // High-Contrast Pure White Optical Container
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.opticalWhite,
                      borderRadius: AppRadii.borderCard,
                      boxShadow: [
                        AppColors.shadowCard(isDark),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppDimensions.iconAction,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Section 1: Code 128 Linear Barcode
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Symbols.barcode,
                              size: AppDimensions.iconSm,
                              color: AppColors.opticalTextPrimary,
                            ),
                            const SizedBox(width: AppSpacing.badgeGap),
                            Text(
                              l10n.barcodeCode128.toUpperCase(),
                              style: theme.textTheme.labelSmall?.copyWith(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.4,
                                color: AppColors.opticalTextSecondary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),
                        BarcodeWidget(
                          barcode: Barcode.code128(),
                          data: widget.contact.taxCode,
                          width: double.infinity,
                          height: 72,
                          backgroundColor: AppColors.opticalWhite,
                          drawText: false,
                        ),
                        const SizedBox(height: AppSpacing.badgeGap),
                        Text(
                          widget.contact.taxCode,
                          style: AppTypography.barcodeReadableText(
                            color: AppColors.opticalTextPrimary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.fieldVertical),

                        // Thin Divider with "oppure"
                        Row(
                          children: [
                            const Expanded(
                              child: Divider(
                                color: AppColors.opticalDivider,
                                height: 1,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.compact,
                              ),
                              child: Text(
                                l10n.barcodeOrDivider.toUpperCase(),
                                style: theme.textTheme.labelSmall?.copyWith(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.2,
                                  color: AppColors.opticalTextMuted,
                                ),
                              ),
                            ),
                            const Expanded(
                              child: Divider(
                                color: AppColors.opticalDivider,
                                height: 1,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.fieldVertical),

                        // Section 2: 2D Health QR Code
                        Container(
                          padding: AppSpacing.paddingSm,
                          decoration: BoxDecoration(
                            color: AppColors.opticalWhite,
                            borderRadius: AppRadii.borderInner,
                            border: Border.all(color: AppColors.opticalBorder),
                          ),
                          child: BarcodeWidget(
                            barcode: Barcode.qrCode(),
                            data: widget.contact.taxCode,
                            width: 110,
                            height: 110,
                            backgroundColor: AppColors.opticalWhite,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.badgeGap),
                        Text(
                          l10n.barcodeQrCode,
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.opticalTextSecondary,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Notice Text
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        size: 15,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 6),
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
                  const SizedBox(height: 10),

                  // Brightness Auto Indicator Pill
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? colorScheme.surfaceContainerHigh
                          : colorScheme.surfaceContainerHighest.withValues(
                              alpha: 0.5,
                            ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: colorScheme.outlineVariant.withValues(
                          alpha: 0.4,
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.wb_sunny_rounded,
                          size: 15,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(width: 6),
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
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: AppDimensions.minTouchTarget,
                          child: OutlinedButton.icon(
                            key: const Key('barcode_bottom_sheet_close_button'),
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(
                              Icons.expand_more_rounded,
                              size: AppDimensions.iconMd,
                            ),
                            label: Text(
                              l10n.close,
                              style: theme.textTheme.labelLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              shape: const RoundedRectangleBorder(
                                borderRadius: AppRadii.borderDialog,
                              ),
                              side: BorderSide(
                                color: colorScheme.outlineVariant.withValues(
                                  alpha: AppOpacity.medium,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: SizedBox(
                          height: AppDimensions.minTouchTarget,
                          child: FilledButton.icon(
                            key: const Key('barcode_bottom_sheet_share_button'),
                            onPressed: () {
                              unawaited(
                                ShareContactBottomSheet.show(
                                  context,
                                  contact: widget.contact,
                                ),
                              );
                            },
                            icon: const Icon(
                              Icons.share_rounded,
                              size: AppDimensions.iconAction,
                            ),
                            label: Text(
                              l10n.share,
                              style: theme.textTheme.labelLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: colorScheme.onPrimary,
                              ),
                            ),
                            style: FilledButton.styleFrom(
                              backgroundColor: colorScheme.primary,
                              foregroundColor: colorScheme.onPrimary,
                              shape: const RoundedRectangleBorder(
                                borderRadius: AppRadii.borderDialog,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
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
