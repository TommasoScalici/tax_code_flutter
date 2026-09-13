import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:shared/models/birthplace.dart';
import 'package:tax_code_flutter/core/theme/app_theme.dart';
import 'package:tax_code_flutter/l10n/app_localizations.dart';
import 'package:tax_code_flutter/widgets/form/birthplace_autocomplete_field.dart';

/// Standalone preview for [BirthplaceAutocompleteField] with sample mock birthplaces.
class BirthplaceAutocompleteFieldPreview extends StatefulWidget {
  @Preview(name: 'Birthplace Autocomplete Field')
  const BirthplaceAutocompleteFieldPreview({super.key});

  @override
  State<BirthplaceAutocompleteFieldPreview> createState() =>
      _BirthplaceAutocompleteFieldPreviewState();
}

class _BirthplaceAutocompleteFieldPreviewState
    extends State<BirthplaceAutocompleteFieldPreview> {
  bool _isDarkMode = true;
  final FocusNode _focusNode = FocusNode();

  final List<Birthplace> _mockBirthplaces = const [
    Birthplace(name: 'Roma', state: 'RM'),
    Birthplace(name: 'Milano', state: 'MI'),
    Birthplace(name: 'Napoli', state: 'NA'),
    Birthplace(name: 'Torino', state: 'TO'),
    Birthplace(name: 'Palermo', state: 'PA'),
    Birthplace(name: 'Francia', state: 'EE'),
    Birthplace(name: 'Germania', state: 'EE'),
  ];

  Birthplace? _selectedBirthplace;

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      locale: const Locale('it'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Builder(
        builder: (context) {
          final theme = Theme.of(context);

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
                        label: Text(_isDarkMode ? 'Scuro' : 'Chiaro'),
                        onPressed: () {
                          setState(() {
                            _isDarkMode = !_isDarkMode;
                          });
                        },
                      ),
                    ),

                    // Target Widget
                    BirthplaceAutocompleteField(
                      focusNode: _focusNode,
                      birthplaces: _mockBirthplaces,
                      value: _selectedBirthplace,
                      onChanged: (newPlace) {
                        setState(() {
                          _selectedBirthplace = newPlace;
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
