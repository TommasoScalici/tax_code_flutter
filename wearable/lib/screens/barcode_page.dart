import 'dart:async';

import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared/models/contact.dart';
import 'package:shared/theme/app_dimensions.dart';
import 'package:tax_code_flutter_wear_os/core/theme/wear_colors.dart';
import 'package:tax_code_flutter_wear_os/core/theme/wear_dimensions.dart';
import 'package:tax_code_flutter_wear_os/core/theme/wear_typography.dart';
import 'package:tax_code_flutter_wear_os/l10n/app_localizations.dart';
import 'package:tax_code_flutter_wear_os/services/native_view_service.dart';
import 'package:tax_code_flutter_wear_os/widgets/wear_scrollbar.dart';

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
    this.initialIsQrCode = false,
    super.key,
  });

  final String taxCode;
  final Contact? contact;
  final bool initialIsQrCode;

  @override
  State<BarcodePage> createState() => _BarcodePageState();
}

class _BarcodePageState extends State<BarcodePage> {
  final ScrollController _scrollController = ScrollController();
  late final NativeViewService _nativeViewService;
  late bool _isQrCode;
  double _dragDistance = 0.0;

  @override
  void initState() {
    super.initState();
    _isQrCode = widget.initialIsQrCode;
    _nativeViewService = context.read<NativeViewService>();
    unawaited(_enableBrightness());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    unawaited(_disableBrightness());
    super.dispose();
  }

  void _onPointerSignal(PointerSignalEvent event) {
    if (event is PointerScrollEvent && _scrollController.hasClients) {
      final target = (_scrollController.offset + event.scrollDelta.dy).clamp(
        0.0,
        _scrollController.position.maxScrollExtent,
      );
      _scrollController.jumpTo(target);
    }
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
        onHorizontalDragStart: (_) {
          _dragDistance = 0.0;
        },
        onHorizontalDragUpdate: (details) {
          _dragDistance += details.primaryDelta ?? 0.0;
        },
        onHorizontalDragEnd: (details) {
          // Swipe from left to right dismisses the screen:
          // Triggers on either quick flick (velocity > 150) or steady drag (distance > 45px).
          if ((details.primaryVelocity ?? 0.0) > 150.0 ||
              _dragDistance > 45.0) {
            Navigator.of(context).maybePop();
          }
        },
        child: Listener(
          onPointerSignal: _onPointerSignal,
          child: WearScrollbar(
            controller: _scrollController,
            child: SingleChildScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              padding: WearDimensions.listPadding,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Contact name if present (with safe horizontal margins and multi-line wrapping)
                  if (fullName.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.compact,
                      ),
                      child: Text(
                        fullName,
                        style: WearTypography.cardTitle(),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: WearDimensions.cardSpacing),
                  ],

                  // Optical scanning surface
                  Material(
                    color: AppColors.opticalWhite,
                    borderRadius: WearDimensions.borderOptical,
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
                                width: WearDimensions.opticalQrSize,
                                height: WearDimensions.opticalQrSize,
                                drawText: false,
                                backgroundColor: AppColors.opticalWhite,
                              )
                            else
                              BarcodeWidget(
                                barcode: Barcode.code128(),
                                data: widget.taxCode,
                                width: double.infinity,
                                height: WearDimensions.opticalBarcodeHeight,
                                drawText: false,
                                backgroundColor: AppColors.opticalWhite,
                              ),
                            const SizedBox(height: WearDimensions.cardSpacing),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                widget.taxCode,
                                style: WearTypography.codeDisplayPresentation(),
                                maxLines: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.sm),

                  // Format toggle button
                  InkWell(
                    onTap: _toggleFormat,
                    borderRadius: WearDimensions.borderStadium,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.compact,
                        vertical: AppSpacing.xs,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _isQrCode
                                ? Icons.barcode_reader
                                : Icons.qr_code_2_rounded,
                            size: WearDimensions.iconSmall,
                            color: AppColors.emeraldLight,
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Flexible(
                            child: Text(
                              _isQrCode ? l10n.barcode1D : l10n.qrCode2D,
                              style: WearTypography.hint(
                                color: AppColors.emeraldLight,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xs),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                    ),
                    child: Text(
                      l10n.swipeToClose,
                      style: WearTypography.hint(
                        color: AppColors.darkOnSurfaceVariant.withValues(
                          alpha: AppOpacity.medium,
                        ),
                      ),
                      textAlign: TextAlign.center,
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
