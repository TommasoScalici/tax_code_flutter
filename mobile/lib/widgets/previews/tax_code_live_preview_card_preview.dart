import 'package:flutter/widget_previews.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tax_code_flutter/core/theme/app_theme.dart';
import 'package:tax_code_flutter/l10n/app_localizations_setup.dart';
import 'package:tax_code_flutter/widgets/form/tax_code_live_preview_card.dart';

/// Standalone preview for [TaxCodeLivePreviewCard] with toggles for empty,
/// partial, and complete tax code states.
class TaxCodeLivePreviewCardPreview extends StatefulWidget {
  @Preview(name: 'Tax Code Live Preview Card')
  const TaxCodeLivePreviewCardPreview({super.key});

  @override
  State<TaxCodeLivePreviewCardPreview> createState() =>
      _TaxCodeLivePreviewCardPreviewState();
}

class _TaxCodeLivePreviewCardPreviewState
    extends State<TaxCodeLivePreviewCardPreview> {
  bool _isDarkMode = true;
  int _stateIndex = 2; // 0 = empty, 1 = partial, 2 = complete

  static const List<String?> _codes = [
    null,
    'RSSMRA85D15',
    'RSSMRA85D15H501Z',
  ];

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
                constraints: const BoxConstraints(maxWidth: 460),
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
                          ChoiceChip(
                            label: Text(l10n.filterEmpty),
                            selected: _stateIndex == 0,
                            onSelected: (selected) {
                              if (selected) setState(() => _stateIndex = 0);
                            },
                          ),
                          ChoiceChip(
                            label: Text(l10n.filterPartial),
                            selected: _stateIndex == 1,
                            onSelected: (selected) {
                              if (selected) setState(() => _stateIndex = 1);
                            },
                          ),
                          ChoiceChip(
                            label: Text(l10n.filterComplete),
                            selected: _stateIndex == 2,
                            onSelected: (selected) {
                              if (selected) setState(() => _stateIndex = 2);
                            },
                          ),
                        ],
                      ),
                    ),

                    // Target Widget
                    TaxCodeLivePreviewCard(
                      taxCode: _codes[_stateIndex],
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
