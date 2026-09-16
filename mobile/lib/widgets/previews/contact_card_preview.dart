import 'dart:async';

import 'package:flutter/widget_previews.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared/models/birthplace.dart';
import 'package:shared/models/contact.dart';
import 'package:tax_code_flutter/core/theme/app_theme.dart';
import 'package:tax_code_flutter/l10n/app_localizations_setup.dart';
import 'package:tax_code_flutter/services/contact_card_image_service.dart';
import 'package:tax_code_flutter/services/contact_pdf_service.dart';
import 'package:tax_code_flutter/services/sharing_service.dart';
import 'package:tax_code_flutter/widgets/barcode_bottom_sheet.dart';
import 'package:tax_code_flutter/widgets/contact_card.dart';
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
class ContactCardPreview extends StatefulWidget {
  @Preview(name: 'Contact Card')
  const ContactCardPreview({super.key});

  @override
  State<ContactCardPreview> createState() => _ContactCardPreviewState();
}

class _ContactCardPreviewState extends State<ContactCardPreview> {
  bool _isDarkMode = false;

  final Contact _sampleContact = Contact(
    id: 'sample-1',
    firstName: 'Mario',
    lastName: 'Rossi',
    gender: 'M',
    birthDate: DateTime(1980, 1, 15),
    birthPlace: const Birthplace(name: 'Roma', state: 'RM', code: 'H501'),
    taxCode: 'RSSMRA80A15H501U',
    listIndex: 0,
  );

  void _showFeedback(BuildContext context, String action) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.l10n.actionLabel(action)),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
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
      child: MaterialApp(
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
            final l10n = context.l10n;

            return Scaffold(
              backgroundColor: theme.scaffoldBackgroundColor,
              body: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 440),
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Preview toolbar
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              l10n.appName,
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            ActionChip(
                              avatar: Icon(
                                _isDarkMode
                                    ? Icons.dark_mode_rounded
                                    : Icons.light_mode_rounded,
                                size: 16,
                              ),
                              label: Text(
                                _isDarkMode ? l10n.themeDark : l10n.themeLight,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isDarkMode = !_isDarkMode;
                                });
                              },
                            ),
                          ],
                        ),
                      ),

                      // Modern Contact Card in preview
                      ContactCard(
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
                        onEdit: () =>
                            _showFeedback(context, l10n.cardActionEdit),
                        onDelete: () =>
                            _showFeedback(context, l10n.cardActionDelete),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
