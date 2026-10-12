import 'package:flutter/widget_previews.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tax_code_flutter/l10n/l10n.dart';
import 'package:tax_code_flutter/widgets/form/ocr_ai_hero_banner.dart';
import 'package:tax_code_flutter/widgets/previews/preview_shell.dart';

/// Standalone preview for [OcrAiHeroBanner] within a centered mobile viewport.
class OcrAiHeroBannerPreview extends StatelessWidget {
  @Preview(name: 'OCR AI Hero Banner')
  const OcrAiHeroBannerPreview({
    super.key,
    this.locale = const Locale('it'),
    this.isDarkMode = true,
  });

  final Locale locale;
  final bool isDarkMode;

  @override
  Widget build(BuildContext context) {
    return PreviewShell(
      initialDarkMode: isDarkMode,
      initialLocale: locale,
      maxWidth: 480,
      builder: (context, _) {
        final l10n = context.l10n;
        return OcrAiHeroBanner(
          onScanPressed: () => PreviewShell.showFeedback(
            context,
            l10n.ocrHeroButton,
          ),
        );
      },
    );
  }
}
