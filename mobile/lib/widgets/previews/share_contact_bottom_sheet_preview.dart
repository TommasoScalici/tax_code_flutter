import 'dart:async';

import 'package:flutter/widget_previews.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared/models/birthplace.dart';
import 'package:shared/models/contact.dart';
import 'package:tax_code_flutter/l10n/l10n.dart';
import 'package:tax_code_flutter/services/contact_card_image_service.dart';
import 'package:tax_code_flutter/services/contact_pdf_service.dart';
import 'package:tax_code_flutter/services/sharing_service.dart';
import 'package:tax_code_flutter/widgets/previews/preview_shell.dart';
import 'package:tax_code_flutter/widgets/share/share_contact_bottom_sheet.dart';

class _PreviewSharingService implements SharingServiceAbstract {
  const _PreviewSharingService();

  @override
  Future<ShareResult> share({required String text}) async =>
      const ShareResult('', ShareResultStatus.success);

  @override
  Future<ShareResult> shareFile({
    required String filePath,
    required String mimeType,
    String? subject,
  }) async => const ShareResult('', ShareResultStatus.success);
}

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
      birthDate: DateTime(1990, 8, 20),
      birthPlace: const Birthplace(name: 'Milano', state: 'MI', code: 'F205'),
      taxCode: 'NRLMRA90M60F205K',
      listIndex: 1,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final contact = _sampleContacts[_selectedContactIndex];

    return PreviewShell(
      initialDarkMode: widget.isDarkMode,
      initialLocale: widget.locale,
      providers: [
        Provider<SharingServiceAbstract>.value(
          value: const _PreviewSharingService(),
        ),
        Provider<ContactCardImageServiceAbstract>.value(
          value: const ContactCardImageService(),
        ),
        Provider<ContactPdfServiceAbstract>.value(
          value: const ContactPdfService(),
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
            label: Text(l10n.openAsBottomSheet),
            onPressed: () => unawaited(
              ShareContactBottomSheet.show(
                context,
                contact: contact,
              ),
            ),
          ),
        ];
      },
      child: ShareContactBottomSheet(contact: contact),
    );
  }
}
