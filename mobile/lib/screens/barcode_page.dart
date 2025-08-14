import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';

import 'package:screen_brightness/screen_brightness.dart';
import 'package:tax_code_flutter/i18n/app_localizations.dart';

class BarcodePage extends StatefulWidget {
  const BarcodePage({super.key, required this.taxCode});

  final String taxCode;

  @override
  State<BarcodePage> createState() => _BarcodePageState();
}

class _BarcodePageState extends State<BarcodePage> {
  @override
  void initState() {
    super.initState();
    ScreenBrightness().setApplicationScreenBrightness(1.0);
  }

  @override
  void dispose() {
    ScreenBrightness().resetApplicationScreenBrightness();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(l10n.appTitle),
      ),
      body: Center(
        child: BarcodeWidget(
          barcode: Barcode.code39(),
          style: const TextStyle(color: Colors.black),
          data: widget.taxCode,
          height: 150,
          width: MediaQuery.of(context).size.width * .8,
        ),
      ),
    );
  }
}