import 'dart:async';

import 'package:flutter/widget_previews.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:shared/testing/test_contact_fixtures.dart';
import 'package:tax_code_flutter/l10n/l10n.dart';
import 'package:tax_code_flutter/services/contact_card_image_service.dart';
import 'package:tax_code_flutter/services/contact_pdf_service.dart';
import 'package:tax_code_flutter/services/sharing_service.dart';
import 'package:tax_code_flutter/widgets/barcode_bottom_sheet.dart';
import 'package:tax_code_flutter/widgets/contact_card.dart';
import 'package:tax_code_flutter/widgets/previews/preview_fakes.dart';
import 'package:tax_code_flutter/widgets/previews/preview_shell.dart';
import 'package:tax_code_flutter/widgets/share/share_contact_bottom_sheet.dart';

/// Standalone preview for [ContactCard] / [ModernContactCard]
/// within a centered mobile viewport.
class ContactCardPreview extends StatelessWidget {
  @Preview(name: 'Contact Card')
  const ContactCardPreview({super.key});

  @override
  Widget build(BuildContext context) {
    final contact = TestContactFixtures.marioRossi;

    return PreviewShell(
      providers: [
        Provider<SharingService>.value(
          value: const FakeSharingService(),
        ),
        Provider<ContactCardImageService>.value(
          value: const ContactCardImageService(),
        ),
        Provider<ContactPdfService>.value(
          value: const ContactPdfService(),
        ),
      ],
      builder: (context, _) {
        final l10n = context.l10n;

        return ContactCard(
          contact: contact,
          onShare: () => unawaited(
            ShareContactBottomSheet.show(
              context,
              contact: contact,
            ),
          ),
          onShowBarcode: () => unawaited(
            BarcodeBottomSheet.show(
              context,
              contact: contact,
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
