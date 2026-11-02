import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:shared/testing/test_contact_fixtures.dart';
import 'package:tax_code_flutter_wear_os/screens/barcode_page.dart';
import 'package:tax_code_flutter_wear_os/widgets/previews/wear_preview_shell.dart';

/// Interactive preview for [BarcodePage] on Wear OS displays.
class WearBarcodePagePreview extends StatefulWidget {
  @Preview(name: 'Wear Barcode Screen')
  const WearBarcodePagePreview({super.key});

  @override
  State<WearBarcodePagePreview> createState() => _WearBarcodePagePreviewState();
}

class _WearBarcodePagePreviewState extends State<WearBarcodePagePreview> {
  bool _isQrCode = false;

  @override
  Widget build(BuildContext context) {
    return WearPreviewShell(
      toolbarActions: (ctx, isRound) => [
        ActionChip(
          avatar: Icon(
            _isQrCode ? Icons.qr_code_2_rounded : Icons.view_column_rounded,
            size: 16,
          ),
          label: Text(
            _isQrCode ? 'Format: QR' : 'Format: Code 128',
            style: const TextStyle(fontSize: 12),
          ),
          onPressed: () {
            setState(() {
              _isQrCode = !_isQrCode;
            });
          },
        ),
      ],
      child: KeyedSubtree(
        key: ValueKey(_isQrCode),
        child: BarcodePage(
          taxCode: TestContactFixtures.marioRossi.taxCode,
          contact: TestContactFixtures.marioRossi,
          initialIsQrCode: _isQrCode,
        ),
      ),
    );
  }
}
