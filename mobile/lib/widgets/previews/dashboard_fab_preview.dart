import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:tax_code_flutter/core/theme/app_theme.dart';
import 'package:tax_code_flutter/l10n/app_localizations.dart';
import 'package:tax_code_flutter/widgets/dashboard/dashboard_fab.dart';

/// Standalone preview for [DashboardFab] within a centered mobile viewport.
class DashboardFabPreview extends StatefulWidget {
  @Preview(name: 'Dashboard FAB')
  const DashboardFabPreview({super.key});

  @override
  State<DashboardFabPreview> createState() => _DashboardFabPreviewState();
}

class _DashboardFabPreviewState extends State<DashboardFabPreview> {
  bool _isDarkMode = false;
  bool _isExtended = true;

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
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Builder(
        builder: (context) {
          final theme = Theme.of(context);
          final l10n = AppLocalizations.of(context)!;

          return Scaffold(
            backgroundColor: theme.scaffoldBackgroundColor,
            body: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 440),
                padding: const EdgeInsets.all(16.0),
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
                            label: Text(_isDarkMode ? 'Scuro' : 'Chiaro'),
                            onPressed: () {
                              setState(() {
                                _isDarkMode = !_isDarkMode;
                              });
                            },
                          ),
                          FilterChip(
                            label: const Text('Esteso'),
                            selected: _isExtended,
                            onSelected: (val) {
                              setState(() {
                                _isExtended = val;
                              });
                            },
                          ),
                        ],
                      ),
                    ),

                    // Centered preview display
                    Card(
                      child: Container(
                        height: 200,
                        alignment: Alignment.center,
                        child: DashboardFab(
                          isExtended: _isExtended,
                          onPressed: () {
                            _showFeedback(context, l10n.newTaxCode);
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
