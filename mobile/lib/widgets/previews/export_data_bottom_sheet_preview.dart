import 'dart:async';

import 'package:flutter/widget_previews.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared/models/birthplace.dart';
import 'package:shared/models/contact.dart';
import 'package:shared/repositories/contact_repository.dart';
import 'package:shared/services/data_export_service.dart';
import 'package:tax_code_flutter/l10n/l10n.dart';
import 'package:tax_code_flutter/services/sharing_service.dart';
import 'package:tax_code_flutter/widgets/export/export_data_bottom_sheet.dart';
import 'package:tax_code_flutter/widgets/previews/preview_shell.dart';

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

class _PreviewContactRepository extends ChangeNotifier
    implements ContactRepository {
  final List<Contact> _contacts;

  _PreviewContactRepository(this._contacts);

  @override
  List<Contact> get contacts => _contacts;

  @override
  bool get isLoading => false;

  @override
  bool get isSyncActive => false;

  @override
  Future<void> init() async {}

  @override
  Future<void> addOrUpdateContact(Contact contact) async {}

  @override
  Future<void> removeContact(Contact contact) async {}

  @override
  Future<void> updateContacts(List<Contact> contacts) async {}

  @override
  Future<void> saveContacts() async {}
}

/// Standalone interactive preview for [ExportDataBottomSheet] (JSON / CSV export).
class ExportDataBottomSheetPreview extends StatefulWidget {
  @Preview(name: 'Export Data Bottom Sheet')
  const ExportDataBottomSheetPreview({super.key});

  @override
  State<ExportDataBottomSheetPreview> createState() =>
      _ExportDataBottomSheetPreviewState();
}

class _ExportDataBottomSheetPreviewState
    extends State<ExportDataBottomSheetPreview> {
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

  late final _PreviewContactRepository _repository;

  @override
  void initState() {
    super.initState();
    _repository = _PreviewContactRepository(_sampleContacts);
  }

  @override
  Widget build(BuildContext context) {
    return PreviewShell(
      providers: [
        ChangeNotifierProvider<ContactRepository>.value(value: _repository),
        Provider<DataExportService>.value(
          value: const DefaultDataExportService(),
        ),
        Provider<SharingServiceAbstract>.value(
          value: const _PreviewSharingService(),
        ),
      ],
      toolbarActions: (context, _) {
        final l10n = context.l10n;
        return [
          FilledButton.icon(
            icon: const Icon(Icons.open_in_browser_rounded),
            label: Text(l10n.openAsBottomSheet),
            onPressed: () => unawaited(
              ExportDataBottomSheet.show(context),
            ),
          ),
        ];
      },
      child: const ExportDataBottomSheet(),
    );
  }
}
