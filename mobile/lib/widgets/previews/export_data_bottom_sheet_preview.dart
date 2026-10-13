import 'dart:async';

import 'package:flutter/widget_previews.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:shared/repositories/contact_repository.dart';
import 'package:shared/services/data_export_service.dart';
import 'package:shared/testing/fake_contact_repository.dart';
import 'package:tax_code_flutter/l10n/l10n.dart';
import 'package:tax_code_flutter/services/sharing_service.dart';
import 'package:tax_code_flutter/widgets/export/export_data_bottom_sheet.dart';
import 'package:tax_code_flutter/widgets/previews/preview_fakes.dart';
import 'package:tax_code_flutter/widgets/previews/preview_shell.dart';

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
  late final FakeContactRepository _repository;

  @override
  void initState() {
    super.initState();
    _repository = FakeContactRepository();
  }

  @override
  Widget build(BuildContext context) {
    return PreviewShell(
      providers: [
        ChangeNotifierProvider<ContactRepository>.value(value: _repository),
        Provider<DataExportService>.value(
          value: const DefaultDataExportService(),
        ),
        Provider<SharingService>.value(value: const FakeSharingService()),
      ],
      toolbarActions: (context, _) {
        final l10n = context.l10n;
        return [
          FilledButton.icon(
            icon: const Icon(Icons.open_in_browser_rounded),
            label: Text(l10n.openAsBottomSheet),
            onPressed: () => unawaited(ExportDataBottomSheet.show(context)),
          ),
        ];
      },
      child: const ExportDataBottomSheet(),
    );
  }
}
