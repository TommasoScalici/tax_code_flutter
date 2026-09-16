import 'package:flutter/widget_previews.dart';
import 'package:material_ui/material_ui.dart';

import 'package:tax_code_flutter/core/theme/app_colors.dart';
import 'package:tax_code_flutter/core/theme/app_theme.dart';
import 'package:tax_code_flutter/core/theme/app_typography.dart';
import 'package:tax_code_flutter/l10n/app_localizations_setup.dart';

/// A preview showcase demonstrating the Emerald Ledger design system tokens,
/// cards, buttons, inputs, and typography across both dark and light modes.
class ThemeShowcasePreview extends StatefulWidget {
  @Preview(name: 'Theme Showcase Widget')
  const ThemeShowcasePreview({super.key});

  @override
  State<ThemeShowcasePreview> createState() => _ThemeShowcasePreviewState();
}

class _ThemeShowcasePreviewState extends State<ThemeShowcasePreview> {
  bool _isDarkMode = false;
  String _selectedGender = 'M';

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
          final l10n = context.l10n;

          return Scaffold(
            backgroundColor: theme.scaffoldBackgroundColor,
            body: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 412, maxHeight: 892),
                decoration: BoxDecoration(
                  color: theme.scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                  ),
                  boxShadow: [
                    AppColors.shadowPreviewCard(_isDarkMode),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: Scaffold(
                  backgroundColor: theme.scaffoldBackgroundColor,
                  appBar: AppBar(
                    title: Text(l10n.themeShowcase),
                    actions: [
                      IconButton(
                        icon: Icon(
                          _isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                        ),
                        tooltip: _isDarkMode ? l10n.switchToLightMode : l10n.switchToDarkMode,
                        onPressed: () {
                          setState(() {
                            _isDarkMode = !_isDarkMode;
                          });
                        },
                      ),
                    ],
                  ),
                  floatingActionButton: FloatingActionButton.extended(
                    onPressed: () {},
                    icon: const Icon(Icons.add),
                    label: Text(l10n.addCode.toUpperCase()),
                  ),
                  body: ListView(
                    padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 96.0),
                    children: [
                      // Section 1: Typography & Monospace
                      Text(
                        'Typography & Monospace',
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Mario Rossi',
                                style: theme.textTheme.headlineMedium,
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: colorScheme.surfaceContainerLowest,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: colorScheme.outlineVariant),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'RSSMRA85D15H501Z',
                                      style: AppTypography.codeDisplayCard(
                                        color: colorScheme.primary,
                                      ),
                                    ),
                                    Icon(
                                      Icons.credit_card,
                                      size: 18,
                                      color: colorScheme.outline,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Roma (RM) • 15/04/1985 • ${l10n.genderMale}',
                                style: theme.textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Section 2: Form Controls & Inputs
                      Text(
                        'Form Controls & Inputs',
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        initialValue: 'Mario',
                        decoration: InputDecoration(
                          labelText: l10n.firstName,
                          prefixIcon: const Icon(Icons.person),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SegmentedButton<String>(
                        segments: [
                          ButtonSegment(
                            value: 'M',
                            label: Text(l10n.genderMale),
                            icon: const Icon(Icons.male),
                          ),
                          ButtonSegment(
                            value: 'F',
                            label: Text(l10n.genderFemale),
                            icon: const Icon(Icons.female),
                          ),
                        ],
                        selected: {_selectedGender},
                        onSelectionChanged: (newSelection) {
                          setState(() {
                            _selectedGender = newSelection.first;
                          });
                        },
                      ),
                      const SizedBox(height: 24),

                      // Section 3: Buttons (Pill shaped)
                      Text(
                        'Pill-Shaped Action Buttons',
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      FilledButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.calculate),
                        label: Text(l10n.saveCode.toUpperCase()),
                      ),
                      const SizedBox(height: 10),
                      OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.qr_code_2),
                        label: Text(l10n.tooltipShowBarcode.toUpperCase()),
                      ),
                      const SizedBox(height: 24),

                      // Section 4: Optical Barcode / QR Preview Container
                      Text(
                        'Optical Scanner Container (High Contrast)',
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.opticalWhite,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: colorScheme.outlineVariant),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'RSSMRA85D15H501Z',
                              style: AppTypography.barcodeReadableText(
                                
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              l10n.barcodeNotice,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: AppColors.opticalTextMuted,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
