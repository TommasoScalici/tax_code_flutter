import 'dart:async';

import 'package:flutter/widget_previews.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:shared/models/birthplace.dart';
import 'package:shared/models/contact.dart';
import 'package:tax_code_flutter/core/theme/app_theme.dart';
import 'package:tax_code_flutter/l10n/app_localizations_setup.dart';
import 'package:tax_code_flutter/services/brightness_service.dart';
import 'package:tax_code_flutter/widgets/barcode_bottom_sheet.dart';

/// Interactive preview for [BarcodeBottomSheet] (Task 7.1).
///
/// Showcases high-contrast 1D Barcode (Code 128) and 2D QR Code rendering,
/// brightness service integration, copy functionality, and theme adaptability.
class BarcodeBottomSheetPreview extends StatefulWidget {
  @Preview(name: 'Barcode & QR Bottom Sheet')
  const BarcodeBottomSheetPreview({
    super.key,
    this.locale = const Locale('it'),
    this.isDarkMode = false,
  });

  final Locale locale;
  final bool isDarkMode;

  @override
  State<BarcodeBottomSheetPreview> createState() =>
      _BarcodeBottomSheetPreviewState();
}

class _MockBrightnessService implements BrightnessServiceAbstract {
  bool isMaxBrightness = false;

  @override
  Future<void> setMaxBrightness() async {
    isMaxBrightness = true;
  }

  @override
  Future<void> resetBrightness() async {
    isMaxBrightness = false;
  }
}

class _BarcodeBottomSheetPreviewState extends State<BarcodeBottomSheetPreview> {
  late bool _isDarkMode;
  int _selectedContactIndex = 0;
  final _mockBrightnessService = _MockBrightnessService();

  @override
  void initState() {
    super.initState();
    _isDarkMode = widget.isDarkMode;
  }

  static final List<Contact> _sampleContacts = [
    Contact(
      id: '1',
      firstName: 'Mario',
      lastName: 'Rossi',
      gender: 'M',
      birthDate: DateTime(1985, 4, 15),
      birthPlace: const Birthplace(name: 'Roma', state: 'RM', code: 'H501'),
      taxCode: 'RSSMRA85D15H501Z',
      listIndex: 0,
    ),
    Contact(
      id: '2',
      firstName: 'Laura',
      lastName: 'Neri',
      gender: 'F',
      birthDate: DateTime(1980),
      birthPlace: const Birthplace(name: 'Torino', state: 'TO', code: 'L219'),
      taxCode: 'NRLMRA80A41L219K',
      listIndex: 1,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final contact = _sampleContacts[_selectedContactIndex];

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      locale: widget.locale,
      localizationsDelegates: AppLocalizationsSetup.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Provider<BrightnessServiceAbstract>.value(
        value: _mockBrightnessService,
        child: Builder(
          builder: (context) {
            final theme = Theme.of(context);
            final colorScheme = theme.colorScheme;

            return Scaffold(
              backgroundColor: colorScheme.surface,
              appBar: AppBar(
                title: const Text(
                  'Preview Barcode & QR Sheet',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                actions: [
                  IconButton(
                    icon: Icon(
                      _isDarkMode
                          ? Icons.light_mode_rounded
                          : Icons.dark_mode_rounded,
                    ),
                    tooltip: _isDarkMode
                        ? context.l10n.switchToLightMode
                        : context.l10n.switchToDarkMode,
                    onPressed: () => setState(() => _isDarkMode = !_isDarkMode),
                  ),
                ],
              ),
              body: ListView(
                padding: EdgeInsets.zero,
                children: [
                  // Controls Toolbar
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Wrap(
                      spacing: 12,
                      runSpacing: 10,
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        SegmentedButton<int>(
                          segments: const [
                            ButtonSegment(
                              value: 0,
                              label: Text('Mario Rossi'),
                            ),
                            ButtonSegment(
                              value: 1,
                              label: Text('Laura Neri'),
                            ),
                          ],
                          selected: {_selectedContactIndex},
                          onSelectionChanged: (selection) {
                            setState(() {
                              _selectedContactIndex = selection.first;
                            });
                          },
                        ),
                        FilledButton.icon(
                          icon: const Icon(Icons.open_in_browser_rounded),
                          label: Text(context.l10n.openModal),
                          onPressed: () {
                            unawaited(
                              BarcodeBottomSheet.show(
                                context,
                                contact: contact,
                                brightnessService: _mockBrightnessService,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  const Divider(height: 1),

                  // Embedded Sheet Presentation
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 16,
                    ),
                    child: BarcodeBottomSheet(
                      contact: contact,
                      brightnessService: _mockBrightnessService,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
