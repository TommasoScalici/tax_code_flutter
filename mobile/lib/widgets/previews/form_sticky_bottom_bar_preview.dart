import 'package:flutter/widget_previews.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tax_code_flutter/core/theme/app_theme.dart';
import 'package:tax_code_flutter/l10n/app_localizations_setup.dart';
import 'package:tax_code_flutter/widgets/form/form_sticky_bottom_bar.dart';

/// Standalone preview for [FormStickyBottomBar] with interactive states
/// (enabled, disabled, loading, theme toggle).
class FormStickyBottomBarPreview extends StatefulWidget {
  @Preview(name: 'Form Sticky Bottom Bar')
  const FormStickyBottomBarPreview({super.key});

  @override
  State<FormStickyBottomBarPreview> createState() =>
      _FormStickyBottomBarPreviewState();
}

class _FormStickyBottomBarPreviewState
    extends State<FormStickyBottomBarPreview> {
  bool _isDarkMode = true;
  bool _isEnabled = true;
  bool _isLoading = false;

  void _showFeedback(BuildContext context) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Salvataggio codice in corso...'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 1),
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
            body: Column(
              children: [
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
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
                          FilterChip(
                            label: const Text('Abilitato'),
                            selected: _isEnabled,
                            onSelected: (val) {
                              setState(() {
                                _isEnabled = val;
                              });
                            },
                          ),
                          FilterChip(
                            label: const Text('In Caricamento'),
                            selected: _isLoading,
                            onSelected: (val) {
                              setState(() {
                                _isLoading = val;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Sticky Bottom Bar
                FormStickyBottomBar(
                  isEnabled: _isEnabled,
                  isLoading: _isLoading,
                  onSavePressed: () => _showFeedback(context),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
