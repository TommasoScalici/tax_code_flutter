import 'package:flutter/widget_previews.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tax_code_flutter/core/theme/app_theme.dart';
import 'package:tax_code_flutter/l10n/app_localizations_setup.dart';
import 'package:tax_code_flutter/widgets/form/ocr_ai_hero_banner.dart';

/// Standalone preview for [OcrAiHeroBanner] within a centered mobile viewport.
class OcrAiHeroBannerPreview extends StatefulWidget {
  @Preview(name: 'OCR AI Hero Banner')
  const OcrAiHeroBannerPreview({super.key});

  @override
  State<OcrAiHeroBannerPreview> createState() => _OcrAiHeroBannerPreviewState();
}

class _OcrAiHeroBannerPreviewState extends State<OcrAiHeroBannerPreview> {
  bool _isDarkMode = true;

  void _showFeedback(BuildContext context, String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      locale: const Locale('it'),
      localizationsDelegates: AppLocalizationsSetup.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Builder(
        builder: (context) {
          final theme = Theme.of(context);

          return Scaffold(
            backgroundColor: theme.scaffoldBackgroundColor,
            body: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 480),
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Preview Toolbar
                    Padding(
                      padding: const EdgeInsets.only(bottom: 24.0),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          ActionChip(
                            avatar: Icon(
                              _isDarkMode
                                  ? Icons.dark_mode_rounded
                                  : Icons.light_mode_rounded,
                              size: 16,
                            ),
                            label: Text(_isDarkMode ? 'Scuro' : 'Chiaro'),
                            onPressed: () {
                              setState(() {
                                _isDarkMode = !_isDarkMode;
                              });
                            },
                          ),
                        ],
                      ),
                    ),

                    // Target Widget under test
                    OcrAiHeroBanner(
                      onScanPressed: () {
                        _showFeedback(
                          context,
                          'Avvio scansione Smart OCR con fotocamera...',
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
