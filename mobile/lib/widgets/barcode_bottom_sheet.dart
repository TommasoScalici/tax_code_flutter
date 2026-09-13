import 'dart:async';

import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';
import 'package:shared/models/contact.dart';

import 'package:tax_code_flutter/l10n/app_localizations.dart';
import 'package:tax_code_flutter/services/brightness_service.dart';

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
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.75),
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
    _brightnessService = widget.brightnessService ??
        context.read<BrightnessServiceAbstract?>();
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
    final l10n = AppLocalizations.of(context)!;
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
            border: Border(top: BorderSide(color: topBorderColor, width: 1.0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.40),
                blurRadius: 32,
                offset: const Offset(0, -8),
              ),
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
                      height: 4,
                      decoration: BoxDecoration(
                        color: colorScheme.onSurfaceVariant.withValues(alpha: 0.40),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Header Area: User name, Tax Code Pill & Copy Button
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withValues(
                            alpha: isDark ? 0.16 : 0.12,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: colorScheme.primary.withValues(alpha: 0.30),
                          ),
                        ),
                        child: Icon(
                          Icons.badge_rounded,
                          color: colorScheme.primary,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
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
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: colorScheme.primary.withValues(
                                      alpha: isDark ? 0.14 : 0.09,
                                    ),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: colorScheme.primary.withValues(
                                        alpha: 0.35,
                                      ),
                                    ),
                                  ),
                                  child: Text(
                                    widget.contact.taxCode,
                                    style: GoogleFonts.jetBrainsMono(
                                      color: colorScheme.primary,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 1.1,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                InkWell(
                                  key: const Key('barcode_bottom_sheet_copy_button'),
                                  onTap: () => unawaited(
                                    _copyTaxCode(
                                      context,
                                      widget.contact.taxCode,
                                      l10n.taxCodeCopied,
                                    ),
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? colorScheme.surfaceContainerHighest
                                          : colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: colorScheme.outlineVariant.withValues(
                                          alpha: 0.5,
                                        ),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.copy_rounded,
                                          size: 14,
                                          color: colorScheme.primary,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          l10n.copyAction,
                                          style: theme.textTheme.labelSmall?.copyWith(
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
                      IconButton(
                        key: const Key('barcode_bottom_sheet_header_close_button'),
                        icon: const Icon(Icons.close_rounded),
                        tooltip: l10n.close,
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // High-Contrast Pure White Optical Container
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
                          blurRadius: 18,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 18.0,
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
                              size: 16,
                              color: Color(0xFF2E2E2E),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              l10n.barcodeCode128.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.4,
                                color: Color(0xFF4A4A4A),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 72,
                          width: double.infinity,
                          child: BarcodeWidget(
                            barcode: Barcode.code128(),
                            data: widget.contact.taxCode,
                            drawText: false,
                            color: Colors.black,
                            backgroundColor: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 6),
                        SelectableText(
                          widget.contact.taxCode,
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 2.8,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Thin Divider with "oppure"
                        Row(
                          children: [
                            const Expanded(
                              child: Divider(color: Color(0xFFE2E2E2), height: 1),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10.0),
                              child: Text(
                                l10n.barcodeOrDivider.toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.2,
                                  color: Color(0xFF888888),
                                ),
                              ),
                            ),
                            const Expanded(
                              child: Divider(color: Color(0xFFE2E2E2), height: 1),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // Section 2: 2D Health QR Code
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFEDEDED)),
                          ),
                          child: BarcodeWidget(
                            barcode: Barcode.qrCode(),
                            data: widget.contact.taxCode,
                            width: 110,
                            height: 110,
                            color: Colors.black,
                            backgroundColor: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          l10n.barcodeQrCode,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF424242),
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
                          : colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: colorScheme.outlineVariant.withValues(alpha: 0.4),
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
                  const SizedBox(height: 16),

                  // Dismiss Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton.icon(
                      key: const Key('barcode_bottom_sheet_close_button'),
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.expand_more_rounded, size: 20),
                      label: Text(
                        l10n.close,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        side: BorderSide(
                          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
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
