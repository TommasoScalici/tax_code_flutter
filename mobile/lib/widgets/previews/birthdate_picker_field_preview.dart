import 'package:flutter/widget_previews.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tax_code_flutter/core/theme/app_theme.dart';
import 'package:tax_code_flutter/l10n/app_localizations_setup.dart';
import 'package:tax_code_flutter/widgets/form/birthdate_picker_field.dart';

/// Standalone preview for [BirthdatePickerField] with Dark/Light toggle and date selection.
class BirthdatePickerFieldPreview extends StatefulWidget {
  @Preview(name: 'Birthdate Picker Field')
  const BirthdatePickerFieldPreview({super.key});

  @override
  State<BirthdatePickerFieldPreview> createState() =>
      _BirthdatePickerFieldPreviewState();
}

class _BirthdatePickerFieldPreviewState
    extends State<BirthdatePickerFieldPreview> {
  bool _isDarkMode = true;
  DateTime? _selectedDate = DateTime(1985, 4, 15);

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
                      child: ActionChip(
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
                    ),

                    // Target Widget
                    BirthdatePickerField(
                      value: _selectedDate,
                      onChanged: (newDate) {
                        setState(() {
                          _selectedDate = newDate;
                        });
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
