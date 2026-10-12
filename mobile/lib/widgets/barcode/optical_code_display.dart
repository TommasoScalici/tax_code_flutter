import 'package:barcode_widget/barcode_widget.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tax_code_flutter/core/theme/app_colors.dart';
import 'package:tax_code_flutter/core/theme/app_dimensions.dart';
import 'package:tax_code_flutter/core/theme/app_typography.dart';
import 'package:tax_code_flutter/l10n/l10n.dart';

/// High-contrast pure white container rendering 1D Barcode (Code 128) and 2D Health QR Code
/// for optical scanning desks at pharmacies and hospitals.
class OpticalCodeDisplay extends StatelessWidget {
  /// The Italian tax code string to encode in the barcodes.
  final String taxCode;

  const OpticalCodeDisplay({
    super.key,
    required this.taxCode,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
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
                  fontSize: AppFontSizes.micro,
                  fontWeight: FontWeight.w800,
                  letterSpacing: AppLetterSpacing.wide,
                  color: AppColors.opticalTextSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          BarcodeWidget(
            barcode: Barcode.code128(),
            data: taxCode,
            width: double.infinity,
            height: AppDimensions.barcodeHeight,
            backgroundColor: AppColors.opticalWhite,
            drawText: false,
          ),
          const SizedBox(height: AppSpacing.badgeGap),
          Text(
            taxCode,
            style: AppTypography.barcodeReadableText(
              color: AppColors.opticalTextPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.fieldVertical),

          // Thin Divider with "oppure" / "or"
          Row(
            children: [
              const Expanded(
                child: Divider(
                  color: AppColors.opticalDivider,
                  height: AppDimensions.borderHairline,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.compact,
                ),
                child: Text(
                  l10n.barcodeOrDivider.toUpperCase(),
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontSize: AppFontSizes.micro,
                    fontWeight: FontWeight.w700,
                    letterSpacing: AppLetterSpacing.uppercase,
                    color: AppColors.opticalTextMuted,
                  ),
                ),
              ),
              const Expanded(
                child: Divider(
                  color: AppColors.opticalDivider,
                  height: AppDimensions.borderHairline,
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
              data: taxCode,
              width: AppDimensions.qrCodeSize,
              height: AppDimensions.qrCodeSize,
              backgroundColor: AppColors.opticalWhite,
            ),
          ),
          const SizedBox(height: AppSpacing.badgeGap),
          Text(
            l10n.barcodeQrCode,
            style: theme.textTheme.labelSmall?.copyWith(
              fontSize: AppFontSizes.caption,
              fontWeight: FontWeight.w700,
              color: AppColors.opticalTextSecondary,
              letterSpacing: AppLetterSpacing.label,
            ),
          ),
        ],
      ),
    );
  }
}
