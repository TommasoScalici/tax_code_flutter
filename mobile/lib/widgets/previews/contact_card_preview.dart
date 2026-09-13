import 'package:flutter/widget_previews.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared/models/birthplace.dart';
import 'package:shared/models/contact.dart';
import 'package:tax_code_flutter/core/theme/app_theme.dart';
import 'package:tax_code_flutter/l10n/app_localizations_setup.dart';
import 'package:tax_code_flutter/widgets/contact_card.dart';

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
    birthPlace: const Birthplace(name: 'Roma', state: 'RM'),
    taxCode: 'RSSMRA80A15H501U',
    listIndex: 0,
  );

  void _showFeedback(BuildContext context, String action) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Azione: $action'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
          final l10n = AppLocalizations.of(context)!;

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
                            'Modern Contact Card',
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
                            label: Text(_isDarkMode ? 'Scuro' : 'Chiaro'),
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
                      onShare: () => _showFeedback(context, l10n.share),
                      onShowBarcode: () =>
                          _showFeedback(context, l10n.cardActionBarcode),
                      onEdit: () => _showFeedback(context, l10n.cardActionEdit),
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
    );
  }
}
