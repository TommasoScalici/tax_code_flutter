import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:screen_brightness/screen_brightness.dart';

class BarcodePage extends StatelessWidget {
  const BarcodePage({super.key, required this.taxCode});

  final String taxCode;

  @override
  Widget build(BuildContext context) {
    ScreenBrightness().setApplicationScreenBrightness(1.0);

    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        ScreenBrightness().resetApplicationScreenBrightness();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(AppLocalizations.of(context)!.appTitle),
        ),
        body: Center(
          child: BarcodeWidget(
            barcode: Barcode.code39(),
            style: TextStyle(color: Colors.black),
            data: taxCode,
            height: 150,
            width: MediaQuery.of(context).size.width * .8,
          ),
        ),
      ),
    );
  }
}
