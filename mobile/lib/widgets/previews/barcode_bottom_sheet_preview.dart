import 'dart:async';

import 'package:flutter/widget_previews.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:shared/models/birthplace.dart';
import 'package:shared/models/contact.dart';
import 'package:tax_code_flutter/l10n/l10n.dart';
import 'package:tax_code_flutter/services/brightness_service.dart';
import 'package:tax_code_flutter/widgets/barcode_bottom_sheet.dart';
import 'package:tax_code_flutter/widgets/previews/preview_shell.dart';

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

/// Interactive preview for [BarcodeBottomSheet].
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

class _BarcodeBottomSheetPreviewState extends State<BarcodeBottomSheetPreview> {
  int _selectedContactIndex = 0;
  final _mockBrightnessService = _MockBrightnessService();

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

    return PreviewShell(
      maxWidth: 480,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      initialDarkMode: widget.isDarkMode,
      initialLocale: widget.locale,
      providers: [
        Provider<BrightnessServiceAbstract>.value(
          value: _mockBrightnessService,
        ),
      ],
      toolbarActions: (context, _) {
        final l10n = context.l10n;
        return [
          SegmentedButton<int>(
            segments: const [
              ButtonSegment(value: 0, label: Text('Mario')),
              ButtonSegment(value: 1, label: Text('Laura')),
            ],
            selected: {_selectedContactIndex},
            onSelectionChanged: (selection) {
              setState(() => _selectedContactIndex = selection.first);
            },
          ),
          FilledButton.icon(
            icon: const Icon(Icons.open_in_browser_rounded),
            label: Text(l10n.openModal),
            onPressed: () => unawaited(
              BarcodeBottomSheet.show(
                context,
                contact: contact,
                brightnessService: _mockBrightnessService,
              ),
            ),
          ),
        ];
      },
      child: BarcodeBottomSheet(
        contact: contact,
        brightnessService: _mockBrightnessService,
      ),
    );
  }
}
