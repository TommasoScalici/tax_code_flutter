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
import 'package:tax_code_flutter/widgets/barcode_bottom_sheet.dart';
import 'package:tax_code_flutter/widgets/contact_card.dart';
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
  }) async =>
      const ShareResult('', ShareResultStatus.success);
}

/// Standalone preview for [ContactCard] / [ModernContactCard]
/// within a centered mobile viewport.
class ContactCardPreview extends StatelessWidget {
  @Preview(name: 'Contact Card')
  const ContactCardPreview({super.key});

  static final Contact _sampleContact = Contact(
    id: 'sample-1',
    firstName: 'Mario',
    lastName: 'Rossi',
    gender: 'M',
    birthDate: DateTime(1980, 1, 15),
    birthPlace: const Birthplace(name: 'Roma', state: 'RM', code: 'H501'),
    taxCode: 'RSSMRA80A15H501U',
    listIndex: 0,
  );

  @override
  Widget build(BuildContext context) {
    return PreviewShell(
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
      builder: (context, _) {
        final l10n = context.l10n;

        return ContactCard(
          contact: _sampleContact,
          onShare: () => unawaited(
            ShareContactBottomSheet.show(
              context,
              contact: _sampleContact,
            ),
          ),
          onShowBarcode: () => unawaited(
            BarcodeBottomSheet.show(
              context,
              contact: _sampleContact,
            ),
          ),
          onEdit: () => PreviewShell.showFeedback(
            context,
            l10n.cardActionEdit,
          ),
          onDelete: () => PreviewShell.showFeedback(
            context,
            l10n.cardActionDelete,
          ),
        );
      },
    );
  }
}
