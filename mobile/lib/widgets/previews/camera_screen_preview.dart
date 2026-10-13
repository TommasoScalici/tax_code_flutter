import 'package:flutter/widget_previews.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tax_code_flutter/controllers/camera_page_controller.dart';
import 'package:tax_code_flutter/core/theme/app_colors.dart';
import 'package:tax_code_flutter/core/theme/app_dimensions.dart';
import 'package:tax_code_flutter/l10n/l10n.dart';
import 'package:tax_code_flutter/screens/camera_page.dart';
import 'package:tax_code_flutter/widgets/camera/camera_preview_overlay.dart';
import 'package:tax_code_flutter/widgets/previews/preview_shell.dart';

/// Standalone interactive preview for [CameraPage] UI and ID-1 scanner overlay.
class CameraScreenPreview extends StatefulWidget {
  @Preview(name: 'Camera & ID-1 Scanner Screen')
  const CameraScreenPreview({super.key});

  @override
  State<CameraScreenPreview> createState() => _CameraScreenPreviewState();
}

class _CameraScreenPreviewState extends State<CameraScreenPreview> {
  CameraStatus _selectedStatus = CameraStatus.readyToScan;
  bool _isFlashOn = false;

  @override
  Widget build(BuildContext context) {
    return PreviewShell(
      maxWidth: 412,
      maxHeight: 892,
      expandChild: true,
      padding: EdgeInsets.zero,
      toolbarActions: (context, _) {
        return [
          ChoiceChip(
            label: const Text('Scanner Feed'),
            selected: _selectedStatus == CameraStatus.readyToScan,
            onSelected: (val) {
              if (val) {
                setState(() => _selectedStatus = CameraStatus.readyToScan);
              }
            },
          ),
          ChoiceChip(
            label: const Text('Permission Denied'),
            selected: _selectedStatus == CameraStatus.permissionDenied,
            onSelected: (val) {
              if (val) {
                setState(() => _selectedStatus = CameraStatus.permissionDenied);
              }
            },
          ),
          ChoiceChip(
            label: const Text('Error'),
            selected: _selectedStatus == CameraStatus.error,
            onSelected: (val) {
              if (val) setState(() => _selectedStatus = CameraStatus.error);
            },
          ),
        ];
      },
      builder: (context, isDarkMode) {
        final l10n = context.l10n;
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;

        return Scaffold(
          backgroundColor: AppColors.opticalBlack,
          body: _buildBody(context, l10n, colorScheme),
        );
      },
    );
  }

  Widget _buildBody(
    BuildContext context,
    AppLocalizations l10n,
    ColorScheme colorScheme,
  ) {
    switch (_selectedStatus) {
      case CameraStatus.permissionDenied:
        return SafeArea(
          child: Center(
            child: Padding(
              padding: AppSpacing.paddingXl,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.no_photography,
                    size: AppDimensions.iconHero,
                    color: AppColors.cameraReticleMuted,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    l10n.cameraPermissionInfo,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.cameraReticle,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.settings),
                    label: Text(l10n.openSettings),
                    onPressed: () =>
                        PreviewShell.showFeedback(context, l10n.openSettings),
                  ),
                ],
              ),
            ),
          ),
        );

      case CameraStatus.error:
        return SafeArea(
          child: Center(
            child: Text(
              l10n.genericError,
              style: const TextStyle(color: AppColors.opticalWhite),
            ),
          ),
        );

      case CameraStatus.initializing:
      case CameraStatus.readyToScan:
      case CameraStatus.pictureTaken:
      case CameraStatus.processing:
        return _buildSimulatedScanner(context, l10n, colorScheme);
    }
  }

  Widget _buildSimulatedScanner(
    BuildContext context,
    AppLocalizations l10n,
    ColorScheme colorScheme,
  ) {
    final size = MediaQuery.sizeOf(context);
    final cardWidth = size.width * 0.86;
    final cardHeight = cardWidth / CameraPreviewOverlay.cardAspectRatio;

    return Stack(
      children: [
        // Simulated camera background dark viewfinder
        Positioned.fill(
          child: Container(
            color: const Color(0xFF101413),
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.camera_alt_outlined,
                  size: 48,
                  color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                ),
                const SizedBox(height: 12),
                Text(
                  'Live Camera Feed Simulator',
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),

        // ID-1 ISO Card Guide Reticle
        Center(
          child: Container(
            width: cardWidth,
            height: cardHeight,
            decoration: BoxDecoration(
              border: Border.all(color: colorScheme.primary, width: 2.0),
              borderRadius: BorderRadius.circular(16),
            ),
            alignment: Alignment.center,
            child: Text(
              l10n.cameraCardGuideHint,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.opticalWhite,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                shadows: [Shadow(blurRadius: 4)],
              ),
            ),
          ),
        ),

        // Top Toolbar (Back button & Flash toggle)
        Positioned(
          top: 16,
          left: 16,
          right: 16,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton.filledTonal(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => PreviewShell.showFeedback(
                  context,
                  l10n.actionLabel('Back'),
                ),
              ),
              IconButton.filledTonal(
                icon: Icon(
                  _isFlashOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
                ),
                onPressed: () {
                  setState(() => _isFlashOn = !_isFlashOn);
                  PreviewShell.showFeedback(
                    context,
                    _isFlashOn ? 'Flash ON' : 'Flash OFF',
                  );
                },
              ),
            ],
          ),
        ),

        // Bottom Capture Controls
        Positioned(
          bottom: 32,
          left: 0,
          right: 0,
          child: Center(
            child: GestureDetector(
              onTap: () => PreviewShell.showFeedback(context, l10n.takePicture),
              child: Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.opticalWhite, width: 4),
                  color: colorScheme.primary,
                ),
                child: const Icon(
                  Icons.camera,
                  color: AppColors.opticalBlack,
                  size: 36,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
