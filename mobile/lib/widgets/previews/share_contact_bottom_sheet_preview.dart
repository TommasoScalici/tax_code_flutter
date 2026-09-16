import 'dart:async';

import 'package:flutter/widget_previews.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared/models/birthplace.dart';
import 'package:shared/models/contact.dart';
import 'package:tax_code_flutter/core/theme/app_colors.dart';
import 'package:tax_code_flutter/core/theme/app_theme.dart';
import 'package:tax_code_flutter/l10n/app_localizations_setup.dart';
import 'package:tax_code_flutter/services/contact_card_image_service.dart';
import 'package:tax_code_flutter/services/contact_pdf_service.dart';
import 'package:tax_code_flutter/services/sharing_service.dart';
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
  late bool _isDarkMode;
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
  void initState() {
    super.initState();
    _isDarkMode = widget.isDarkMode;
  }

  @override
  Widget build(BuildContext context) {
    final contact = _sampleContacts[_selectedContactIndex];

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
        locale: widget.locale,
        localizationsDelegates: AppLocalizationsSetup.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) {
            final theme = Theme.of(context);
            final l10n = context.l10n;

            return Scaffold(
              backgroundColor: theme.scaffoldBackgroundColor,
              appBar: AppBar(
                title: Text(
                  l10n.shareContactTitle,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                actions: [
                  IconButton(
                    icon: Icon(
                      _isDarkMode
                          ? Icons.light_mode_rounded
                          : Icons.dark_mode_rounded,
                    ),
                    tooltip: _isDarkMode
                        ? l10n.switchToLightMode
                        : l10n.switchToDarkMode,
                    onPressed: () => setState(() => _isDarkMode = !_isDarkMode),
                  ),
                ],
              ),
              body: ListView(
                padding: EdgeInsets.zero,
                children: [
                  // Controls Toolbar
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 10.0,
                    ),
                    color: _isDarkMode
                        ? AppColors.darkSurfaceContainerLowest
                        : AppColors.lightSurfaceContainerLow,
                    child: Wrap(
                      spacing: 12,
                      runSpacing: 8,
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
                          label: Text(l10n.openAsBottomSheet),
                          onPressed: () {
                            unawaited(
                              ShareContactBottomSheet.show(
                                context,
                                contact: contact,
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
                    child: ShareContactBottomSheet(contact: contact),
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
