import 'package:flutter/widget_previews.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tax_code_flutter/core/theme/app_theme.dart';
import 'package:tax_code_flutter/l10n/app_localizations_setup.dart';
import 'package:tax_code_flutter/widgets/dashboard/dashboard_empty_state.dart';

/// Standalone preview for [DashboardEmptyState] within a centered viewport.
class DashboardEmptyStatePreview extends StatefulWidget {
  @Preview(name: 'Dashboard Empty State')
  const DashboardEmptyStatePreview({super.key});

  @override
  State<DashboardEmptyStatePreview> createState() =>
      _DashboardEmptyStatePreviewState();
}

enum _EmptyStateScenario {
  noSavedCards,
  searchNoResults,
}

class _DashboardEmptyStatePreviewState
    extends State<DashboardEmptyStatePreview> {
  bool _isDarkMode = false;
  _EmptyStateScenario _scenario = _EmptyStateScenario.noSavedCards;
  final String _searchQuery = 'Mario Rossi';

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
          final l10n = AppLocalizations.of(context)!;

          return Scaffold(
            backgroundColor: theme.scaffoldBackgroundColor,
            body: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 480),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Toolbar
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
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
                          ChoiceChip(
                            label: const Text('Nessuna tessera'),
                            selected:
                                _scenario == _EmptyStateScenario.noSavedCards,
                            onSelected: (val) {
                              if (val) {
                                setState(() {
                                  _scenario = _EmptyStateScenario.noSavedCards;
                                });
                              }
                            },
                          ),
                          ChoiceChip(
                            label: const Text('Ricerca vuota'),
                            selected:
                                _scenario == _EmptyStateScenario.searchNoResults,
                            onSelected: (val) {
                              if (val) {
                                setState(() {
                                  _scenario =
                                      _EmptyStateScenario.searchNoResults;
                                });
                              }
                            },
                          ),
                        ],
                      ),
                    ),

                    // Empty State Widget
                    Expanded(
                      child: Center(
                        child: DashboardEmptyState(
                          searchQuery: _scenario ==
                                  _EmptyStateScenario.searchNoResults
                              ? _searchQuery
                              : null,
                          onClearSearch: () {
                            _showFeedback(context, l10n.emptySearchClearAction);
                            setState(() {
                              _scenario = _EmptyStateScenario.noSavedCards;
                            });
                          },
                          onAddContact: () {
                            _showFeedback(context, l10n.addCode);
                          },
                        ),
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
