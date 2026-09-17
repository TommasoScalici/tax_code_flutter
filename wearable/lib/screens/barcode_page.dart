import 'dart:async';

import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared/models/contact.dart';
import 'package:tax_code_flutter_wear_os/core/theme/wear_colors.dart';
import 'package:tax_code_flutter_wear_os/core/theme/wear_dimensions.dart';
import 'package:tax_code_flutter_wear_os/core/theme/wear_typography.dart';
import 'package:tax_code_flutter_wear_os/l10n/app_localizations.dart';
import 'package:tax_code_flutter_wear_os/services/native_view_service.dart';

/// Presentation screen for displaying the Italian Tax Code as an optical 1D
/// barcode (Code 128) or 2D QR Code, maximized for scanning speed and readability.
///
/// Features:
/// - Screen brightness override upon enter, restored on exit.
/// - High-contrast white container optimized for retail/pharmacy laser & camera scanners.
/// - Single tap toggles between Code 128 (1D) and QR Code (2D).
/// - Swipe right anywhere on screen to dismiss and return to the list.
class BarcodePage extends StatefulWidget {
  const BarcodePage({
    required this.taxCode,
    this.contact,
    super.key,
  });

  final String taxCode;
  final Contact? contact;

  @override
  State<BarcodePage> createState() => _BarcodePageState();
}

class _BarcodePageState extends State<BarcodePage> {
  late final NativeViewServiceAbstract _nativeViewService;
  bool _isQrCode = false;

  @override
  void initState() {
    super.initState();
    _nativeViewService = context.read<NativeViewServiceAbstract>();
    unawaited(_enableBrightness());
  }

  @override
  void dispose() {
    unawaited(_disableBrightness());
    super.dispose();
  }

  Future<void> _enableBrightness() async {
    await _nativeViewService.enableHighBrightnessMode();
  }

  Future<void> _disableBrightness() async {
    await _nativeViewService.disableHighBrightnessMode();
  }

  void _toggleFormat() {
    setState(() {
      _isQrCode = !_isQrCode;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final fullName = widget.contact != null
        ? '${widget.contact!.firstName} ${widget.contact!.lastName}'.trim()
        : '';

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onHorizontalDragEnd: (details) {
          // Swipe from left to right dismisses the screen
          if ((details.primaryVelocity ?? 0) > 200) {
            Navigator.of(context).maybePop();
          }
        },
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: WearDimensions.screenPaddingHorizontal,
              vertical: 10.0,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Contact name if present
                if (fullName.isNotEmpty) ...[
                  Text(
                    fullName,
                    style: WearTypography.cardTitle(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4.0),
                ],

                // Optical scanning surface
                Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(WearDimensions.opticalRadius),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: _toggleFormat,
                    child: Padding(
                      padding: WearDimensions.opticalPadding,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_isQrCode)
                            BarcodeWidget(
                              barcode: Barcode.qrCode(),
                              data: widget.taxCode,
                              width: 96,
                              height: 96,
                              drawText: false,
                              backgroundColor: Colors.white,
                            )
                          else
                            BarcodeWidget(
                              barcode: Barcode.code128(),
                              data: widget.taxCode,
                              width: double.infinity,
                              height: 48,
                              drawText: false,
                              backgroundColor: Colors.white,
                            ),
                          const SizedBox(height: 6.0),
                          Text(
                            widget.taxCode,
                            style: WearTypography.codeDisplayPresentation(),
                            maxLines: 1,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 6.0),

                // Format toggle button
                InkWell(
                  onTap: _toggleFormat,
                  borderRadius: BorderRadius.circular(WearDimensions.stadiumRadius),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8.0,
                      vertical: 2.0,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _isQrCode ? Icons.barcode_reader : Icons.qr_code_2_rounded,
                          size: WearDimensions.iconSmall,
                          color: AppColors.emeraldLight,
                        ),
                        const SizedBox(width: 4.0),
                        Text(
                          _isQrCode ? l10n.barcode1D : l10n.qrCode2D,
                          style: WearTypography.hint(color: AppColors.emeraldLight),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 2.0),
                Text(
                  l10n.swipeToClose,
                  style: WearTypography.hint(
                    color: AppColors.darkOnSurfaceVariant.withValues(alpha: 0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
