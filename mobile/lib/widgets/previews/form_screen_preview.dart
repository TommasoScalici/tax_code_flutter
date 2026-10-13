import 'package:flutter/widget_previews.dart';
import 'package:logger/logger.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:shared/models/birthplace.dart';
import 'package:shared/models/contact.dart';
import 'package:shared/models/scanned_data.dart';
import 'package:shared/repositories/contact_repository.dart';
import 'package:shared/services/birthplace_service.dart';
import 'package:shared/services/tax_code_service.dart';
import 'package:shared/testing/testing.dart';
import 'package:tax_code_flutter/routes.dart';
import 'package:tax_code_flutter/screens/form_page.dart';
import 'package:tax_code_flutter/widgets/previews/preview_shell.dart';

/// Full screen interactive preview for [FormPage],
/// maintaining 1:1 Screen Parity with production.
///
/// Features interactive toggles for:
/// - Light vs Dark mode
/// - English vs Italian localization
/// - Create Mode (blank form + OCR AI Hero Banner) vs Edit Mode (pre-populated)
/// - Simulated OCR scanning route navigation
class FormScreenPreview extends StatefulWidget {
  @Preview(name: 'Form Screen')
  const FormScreenPreview({
    super.key,
    this.locale = const Locale('it'),
    this.initialContact,
    this.isDarkMode = false,
  });

  final Locale locale;
  final Contact? initialContact;
  final bool isDarkMode;

  @override
  State<FormScreenPreview> createState() => _FormScreenPreviewState();
}

class _FormScreenPreviewState extends State<FormScreenPreview> {
  late bool _isEditing;
  late final FakeBirthplaceService _birthplaceService;
  late final FakeTaxCodeService _taxCodeService;
  late final FakeContactRepository _contactRepository;
  late final Logger _logger;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.initialContact != null;
    _birthplaceService = FakeBirthplaceService();
    _taxCodeService = FakeTaxCodeService(birthplaceService: _birthplaceService);
    _contactRepository = FakeContactRepository();
    _logger = Logger(level: Level.off);
  }

  @override
  void dispose() {
    _birthplaceService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PreviewShell(
      maxWidth: 520,
      expandChild: true,
      padding: EdgeInsets.zero,
      initialDarkMode: widget.isDarkMode,
      initialLocale: widget.locale,
      routes: {Routes.camera: (context) => _CameraMockPage()},
      providers: [
        Provider<BirthplaceService>.value(value: _birthplaceService),
        Provider<TaxCodeService>.value(value: _taxCodeService),
        ChangeNotifierProvider<ContactRepository>.value(
          value: _contactRepository,
        ),
        Provider<Logger>.value(value: _logger),
      ],
      toolbarActions: (context, _) => [
        ChoiceChip(
          label: const Text('Nuovo'),
          selected: !_isEditing,
          onSelected: (val) {
            if (val) setState(() => _isEditing = false);
          },
        ),
        ChoiceChip(
          label: const Text('Modifica'),
          selected: _isEditing,
          onSelected: (val) {
            if (val) setState(() => _isEditing = true);
          },
        ),
      ],
      child: FormPage(
        key: ValueKey<bool>(_isEditing),
        contact: _isEditing
            ? (widget.initialContact ?? TestContactFixtures.marioRossi)
            : null,
      ),
    );
  }
}

/// Simulated scanner view returned by [Routes.camera] in preview mode.
class _CameraMockPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Simulazione Scanner OCR')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.document_scanner_rounded, size: 64),
              const SizedBox(height: 16),
              const Text(
                'Simulazione rilevamento tessera sanitaria / codice fiscale',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Applica dati scansionati (Laura Neri)'),
                onPressed: () {
                  final scanned = ScannedData(
                    firstName: 'Laura',
                    lastName: 'Neri',
                    gender: 'F',
                    birthDate: DateTime(1985, 10, 20),
                    birthPlace: const Birthplace(
                      name: 'Milano',
                      state: 'MI',
                      code: 'F205',
                    ),
                  );
                  Navigator.of(context).pop<ScannedData>(scanned);
                },
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Annulla'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
