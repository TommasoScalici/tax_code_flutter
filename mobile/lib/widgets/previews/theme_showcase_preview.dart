import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_typography.dart';

/// Theme applicator for the Flutter Widget Previewer environment.
final class EmeraldPreviewThemeData extends PreviewThemeData {
  const EmeraldPreviewThemeData();

  @override
  Widget apply(BuildContext context, Widget child) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Theme(
      data: isDark ? AppTheme.darkTheme : AppTheme.lightTheme,
      child: child,
    );
  }
}

/// Factory function providing custom theme data to `@Preview`.
PreviewThemeData emeraldPreviewTheme() => const EmeraldPreviewThemeData();

@Preview(
  name: 'Emerald Ledger (Dark OLED)',
  brightness: Brightness.dark,
  size: Size(390, 844),
  theme: emeraldPreviewTheme,
)
@Preview(
  name: 'Emerald Ledger (Light)',
  brightness: Brightness.light,
  size: Size(390, 844),
  theme: emeraldPreviewTheme,
)
Widget buildThemeShowcasePreview() {
  return const ThemeShowcasePreview();
}

/// A preview showcase demonstrating the Emerald Ledger design system tokens,
/// cards, buttons, inputs, and typography across both dark and light modes.
class ThemeShowcasePreview extends StatefulWidget {
  @Preview(
    name: 'Theme Showcase Widget',
    size: Size(390, 844),
    theme: emeraldPreviewTheme,
  )
  const ThemeShowcasePreview({
    super.key,
    this.initialDarkMode,
  });

  final bool? initialDarkMode;

  @override
  State<ThemeShowcasePreview> createState() => _ThemeShowcasePreviewState();
}

class _ThemeShowcasePreviewState extends State<ThemeShowcasePreview> {
  bool? _isDarkModeOverride;
  String _selectedGender = 'M';

  @override
  Widget build(BuildContext context) {
    // Check if ambient widget previewer provides Directionality/MaterialApp
    final hasDirectionality = Directionality.maybeOf(context) != null;

    // Default to the ambient theme brightness (controlled by the Previewer toolbar)
    final isAmbientDark = Theme.of(context).brightness == Brightness.dark;
    final isDark =
        _isDarkModeOverride ?? widget.initialDarkMode ?? isAmbientDark;
    final theme = isDark ? AppTheme.darkTheme : AppTheme.lightTheme;

    final content = Theme(
      data: theme,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          title: const Text('Emerald Ledger Showcase'),
          actions: [
            IconButton(
              icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
              tooltip: isDark ? 'Passa a tema chiaro' : 'Passa a tema scuro',
              onPressed: () {
                setState(() {
                  _isDarkModeOverride = !isDark;
                });
              },
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {},
          icon: const Icon(Icons.add),
          label: const Text('NUOVO CODICE'),
        ),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: ListView(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 20.0,
              ),
              children: [
                // Section 1: Typography
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
                            color: isDark
                                ? AppColors.darkSurfaceContainerLowest
                                : AppColors.lightSurfaceContainerLow,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'RSSMRA85D15H501Z',
                                style: AppTypography.codeDisplayCard(
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                              Icon(
                                Icons.credit_card,
                                size: 18,
                                color: theme.colorScheme.outline,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Roma (RM) • 15/04/1985 • Maschile',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Section 2: Form Inputs & Segmented Button
                Text(
                  'Form Controls & Inputs',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  initialValue: 'Mario',
                  decoration: const InputDecoration(
                    labelText: 'Nome',
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
                const SizedBox(height: 12),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(
                      value: 'M',
                      label: Text('Maschile (M)'),
                      icon: Icon(Icons.male),
                    ),
                    ButtonSegment(
                      value: 'F',
                      label: Text('Femminile (F)'),
                      icon: Icon(Icons.female),
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
                  label: const Text('CALCOLA E SALVA'),
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.qr_code_2),
                  label: const Text('MOSTRA BARCODE'),
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
                    border: Border.all(color: Colors.white),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'RSSMRA85D15H501Z',
                        style: AppTypography.barcodeReadableText(),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Visualizzatore per scanner ottico farmacia',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.black54,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
    );

    if (!hasDirectionality) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
        home: content,
      );
    }

    return content;
  }
}
