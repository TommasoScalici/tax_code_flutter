import 'package:flutter/widget_previews.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tax_code_flutter/core/theme/app_theme.dart';
import 'package:tax_code_flutter/l10n/app_localizations_setup.dart';
import 'package:tax_code_flutter/widgets/form/form_section_divider.dart';

/// Standalone preview for [FormSectionDivider] with dark/light mode toggle.
class FormSectionDividerPreview extends StatefulWidget {
  @Preview(name: 'Form Section Divider')
  const FormSectionDividerPreview({super.key});

  @override
  State<FormSectionDividerPreview> createState() =>
      _FormSectionDividerPreviewState();
}

class _FormSectionDividerPreviewState extends State<FormSectionDividerPreview> {
  bool _isDarkMode = true;

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
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Toolbar
                    Padding(
                      padding: const EdgeInsets.only(bottom: 24.0),
                      child: ActionChip(
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
                    ),

                    // Target Widget
                    const FormSectionDivider(),
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
