import 'package:flutter/widget_previews.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tax_code_flutter/core/theme/app_theme.dart';
import 'package:tax_code_flutter/l10n/app_localizations_setup.dart';
import 'package:tax_code_flutter/widgets/dashboard/dashboard_search_bar.dart';

/// Standalone preview for [DashboardSearchBar] within a centered mobile viewport.
class DashboardSearchBarPreview extends StatefulWidget {
  @Preview(name: 'Dashboard Search Bar')
  const DashboardSearchBarPreview({super.key});

  @override
  State<DashboardSearchBarPreview> createState() =>
      _DashboardSearchBarPreviewState();
}

class _DashboardSearchBarPreviewState extends State<DashboardSearchBarPreview> {
  final TextEditingController _searchController = TextEditingController();
  bool _isDarkMode = false;
  int _cardCount = 3;
  String _currentQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
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
      localizationsDelegates: AppLocalizationsSetup.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Builder(
        builder: (context) {
          final theme = Theme.of(context);
          final colorScheme = theme.colorScheme;

          return Scaffold(
            backgroundColor: theme.scaffoldBackgroundColor,
            body: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 440),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Preview interactive toolbar
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          // Theme Switch Chip
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

                          // Card Count selector chips
                          ChoiceChip(
                            label: const Text('0 tessere'),
                            selected: _cardCount == 0,
                            onSelected: (val) {
                              if (val) setState(() => _cardCount = 0);
                            },
                          ),
                          ChoiceChip(
                            label: const Text('1 tessera'),
                            selected: _cardCount == 1,
                            onSelected: (val) {
                              if (val) setState(() => _cardCount = 1);
                            },
                          ),
                          ChoiceChip(
                            label: const Text('3 tessere'),
                            selected: _cardCount == 3,
                            onSelected: (val) {
                              if (val) setState(() => _cardCount = 3);
                            },
                          ),
                        ],
                      ),
                    ),

                    // Device card container holding the DashboardSearchBar
                    Container(
                      padding: const EdgeInsets.all(20.0),
                      decoration: BoxDecoration(
                        color: theme.scaffoldBackgroundColor,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: colorScheme.outlineVariant.withValues(
                            alpha: 0.6,
                          ),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(
                              alpha: _isDarkMode ? 0.35 : 0.08,
                            ),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          DashboardSearchBar(
                            controller: _searchController,
                            cardCount: _cardCount,
                            onChanged: (text) {
                              setState(() {
                                _currentQuery = text;
                              });
                            },
                            onClear: () {
                              setState(() {
                                _currentQuery = '';
                              });
                            },
                          ),
                          if (_currentQuery.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: colorScheme.surfaceContainerHighest
                                    .withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.filter_alt_outlined,
                                    size: 16,
                                    color: colorScheme.primary,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Filtro attivo: "$_currentQuery"',
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
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
