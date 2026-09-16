import 'package:flutter/widget_previews.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tax_code_flutter/core/theme/app_theme.dart';
import 'package:tax_code_flutter/l10n/app_localizations_setup.dart';
import 'package:tax_code_flutter/widgets/form/gender_segmented_button.dart';

/// Standalone preview for [GenderSegmentedButton] with interactive state
/// selection, error toggle, and theme switching.
class GenderSegmentedButtonPreview extends StatefulWidget {
  @Preview(name: 'Gender Segmented Button')
  const GenderSegmentedButtonPreview({super.key});

  @override
  State<GenderSegmentedButtonPreview> createState() =>
      _GenderSegmentedButtonPreviewState();
}

class _GenderSegmentedButtonPreviewState
    extends State<GenderSegmentedButtonPreview> {
  bool _isDarkMode = true;
  String? _selectedGender = 'M';
  bool _showError = false;

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
          final l10n = context.l10n;

          return Scaffold(
            backgroundColor: theme.scaffoldBackgroundColor,
            body: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 440),
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Toolbar
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
                            label: Text(_isDarkMode ? l10n.themeDark : l10n.themeLight),
                            onPressed: () {
                              setState(() {
                                _isDarkMode = !_isDarkMode;
                              });
                            },
                          ),
                          FilterChip(
                            label: Text(l10n.simulateError),
                            selected: _showError,
                            onSelected: (val) {
                              setState(() {
                                _showError = val;
                              });
                            },
                          ),
                        ],
                      ),
                    ),

                    // Target Widget
                    GenderSegmentedButton(
                      value: _selectedGender,
                      onChanged: (newVal) {
                        setState(() {
                          _selectedGender = newVal;
                        });
                      },
                      errorText: _showError ? l10n.required : null,
                    ),

                    const SizedBox(height: 20),
                    Text(
                      l10n.selectedValue(_selectedGender ?? l10n.none),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
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
