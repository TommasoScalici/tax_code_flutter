import 'dart:async';

import 'package:flutter/widget_previews.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:shared/models/contact.dart';
import 'package:shared/testing/test_contact_fixtures.dart';
import 'package:tax_code_flutter/l10n/l10n.dart';
import 'package:tax_code_flutter/services/contact_card_image_service.dart';
import 'package:tax_code_flutter/services/contact_pdf_service.dart';
import 'package:tax_code_flutter/services/sharing_service.dart';
import 'package:tax_code_flutter/widgets/previews/preview_fakes.dart';
import 'package:tax_code_flutter/widgets/previews/preview_shell.dart';
import 'package:tax_code_flutter/widgets/share/share_contact_bottom_sheet.dart';

/// Interactive standalone preview for [ShareContactBottomSheet] (Tessera PNG, PDF, Text).
class ShareContactBottomSheetPreview extends StatefulWidget {
  @Preview(name: 'Share Contact Bottom Sheet')
  const ShareContactBottomSheetPreview({
    super.key,
    this.locale = const Locale('it'),
    this.isDarkMode = false,
  });

  final Locale locale;
  final bool isDarkMode;

  @override
  State<ShareContactBottomSheetPreview> createState() =>
      _ShareContactBottomSheetPreviewState();
}

class _ShareContactBottomSheetPreviewState
    extends State<ShareContactBottomSheetPreview> {
  int _selectedContactIndex = 0;
  final List<Contact> _contacts = TestContactFixtures.sampleContacts;

  @override
  Widget build(BuildContext context) {
    final contact = _contacts[_selectedContactIndex];

    return PreviewShell(
      initialDarkMode: widget.isDarkMode,
      initialLocale: widget.locale,
      providers: [
        Provider<SharingService>.value(value: const FakeSharingService()),
        Provider<ContactCardImageService>.value(
          value: const ContactCardImageService(),
        ),
        Provider<ContactPdfService>.value(value: const ContactPdfService()),
      ],
      toolbarActions: (context, _) {
        final l10n = context.l10n;
        return [
          SegmentedButton<int>(
            segments: [
              ButtonSegment(value: 0, label: Text(_contacts[0].firstName)),
              ButtonSegment(value: 1, label: Text(_contacts[1].firstName)),
            ],
            selected: {_selectedContactIndex},
            onSelectionChanged: (selection) {
              setState(() => _selectedContactIndex = selection.first);
            },
          ),
          FilledButton.icon(
            icon: const Icon(Icons.open_in_browser_rounded),
            label: Text(l10n.openAsBottomSheet),
            onPressed: () => unawaited(
              ShareContactBottomSheet.show(context, contact: contact),
            ),
          ),
        ];
      },
      child: ShareContactBottomSheet(contact: contact),
    );
  }
}
