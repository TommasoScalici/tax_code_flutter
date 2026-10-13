import 'dart:async';

import 'package:flutter/widget_previews.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:shared/models/contact.dart';
import 'package:shared/testing/test_contact_fixtures.dart';
import 'package:tax_code_flutter/l10n/l10n.dart';
import 'package:tax_code_flutter/services/brightness_service.dart';
import 'package:tax_code_flutter/widgets/barcode_bottom_sheet.dart';
import 'package:tax_code_flutter/widgets/previews/preview_fakes.dart';
import 'package:tax_code_flutter/widgets/previews/preview_shell.dart';

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
  final _brightnessService = FakeBrightnessService();
  final List<Contact> _contacts = TestContactFixtures.sampleContacts;

  @override
  Widget build(BuildContext context) {
    final contact = _contacts[_selectedContactIndex];

    return PreviewShell(
      maxWidth: 480,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      initialDarkMode: widget.isDarkMode,
      initialLocale: widget.locale,
      providers: [
        Provider<BrightnessService>.value(
          value: _brightnessService,
        ),
      ],
      toolbarActions: (context, _) {
        final l10n = context.l10n;
        return [
          SegmentedButton<int>(
            segments: [
              ButtonSegment(
                value: 0,
                label: Text(_contacts[0].firstName),
              ),
              ButtonSegment(
                value: 1,
                label: Text(_contacts[1].firstName),
              ),
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
                brightnessService: _brightnessService,
              ),
            ),
          ),
        ];
      },
      child: BarcodeBottomSheet(
        contact: contact,
        brightnessService: _brightnessService,
      ),
    );
  }
}
